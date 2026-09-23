import asyncio
import json
import os
import random
import time
from pathlib import Path

from aiohttp import web


# ============================================================
# Configuration
# ============================================================

MUSIC_DIR = Path(
    os.environ.get("MUSIC_DIR", "/music")
)

DATA_DIR = Path(
    os.environ.get("DATA_DIR", "/data")
)

PORT = int(
    os.environ.get("PORT", "8000")
)

RADIO_NAME = os.environ.get(
    "RADIO_NAME",
    "WebRadio"
)

STATE_FILE = DATA_DIR / "state.json"


AUDIO_EXTENSIONS = {
    ".mp3",
    ".flac",
    ".wav",
    ".ogg",
    ".oga",
    ".opus",
    ".m4a",
    ".aac",
    ".webm",
}


# ============================================================
# Etat de la radio
# ============================================================

known_files = set()
played_files = set()

current_file = None
current_started = None

radio_task = None


# ============================================================
# Clients connectés
# ============================================================

# Chaque client possède une queue contenant les morceaux
# du flux commun.
#
# Le producteur FFmpeg écrit UNE seule fois le flux.
# Les données sont ensuite distribuées à tous les clients.

clients = set()


# ============================================================
# Etat persistant
# ============================================================

def load_state():
    global known_files
    global played_files

    DATA_DIR.mkdir(
        parents=True,
        exist_ok=True
    )

    if not STATE_FILE.exists():
        return

    try:
        with STATE_FILE.open(
            "r",
            encoding="utf-8"
        ) as f:

            state = json.load(f)

        known_files = set(
            state.get("known_files", [])
        )

        played_files = set(
            state.get("played_files", [])
        )

    except Exception as exc:

        print(
            f"[state] Erreur chargement : {exc}"
        )

        known_files = set()
        played_files = set()


def save_state():
    DATA_DIR.mkdir(
        parents=True,
        exist_ok=True
    )

    temporary = STATE_FILE.with_suffix(
        ".tmp"
    )

    state = {
        "known_files": sorted(
            known_files
        ),
        "played_files": sorted(
            played_files
        ),
    }

    with temporary.open(
        "w",
        encoding="utf-8"
    ) as f:

        json.dump(
            state,
            f,
            ensure_ascii=False,
            indent=2
        )

    temporary.replace(
        STATE_FILE
    )


# ============================================================
# Recherche des fichiers audio
# ============================================================

def scan_files():
    """
    Recherche récursive de tous les fichiers audio.
    """

    if not MUSIC_DIR.exists():
        return set()

    files = set()

    for path in MUSIC_DIR.rglob("*"):

        if not path.is_file():
            continue

        if path.suffix.lower() not in AUDIO_EXTENSIONS:
            continue

        try:

            relative = str(
                path.relative_to(MUSIC_DIR)
            )

            files.add(relative)

        except ValueError:
            pass

    return files


# ============================================================
# Mise à jour de la bibliothèque
# ============================================================

def refresh_library():
    global known_files
    global played_files

    files = scan_files()

    # Nouveaux fichiers depuis le dernier scan
    new_files = files - known_files

    if new_files:

        for filename in sorted(new_files):
            print(
                f"[library] Nouveau fichier : {filename}"
            )

        known_files.update(
            new_files
        )

    # Les fichiers supprimés ne doivent plus
    # rester dans l'état.
    known_files.intersection_update(
        files
    )

    played_files.intersection_update(
        files
    )

    if new_files:
        save_state()

    return files, new_files


# ============================================================
# Sélection du prochain morceau
# ============================================================

def choose_next():
    global known_files
    global played_files

    files, new_files = refresh_library()

    if not files:
        return None

    # --------------------------------------------------------
    # PRIORITE 1
    #
    # Fichiers nouvellement détectés.
    # --------------------------------------------------------

    if new_files:

        selected = random.choice(
            list(new_files)
        )

        played_files.add(
            selected
        )

        save_state()

        return MUSIC_DIR / selected

    # --------------------------------------------------------
    # PRIORITE 2
    #
    # Morceaux encore jamais joués dans le cycle actuel.
    # --------------------------------------------------------

    available = (
        files - played_files
    )

    if available:

        selected = random.choice(
            list(available)
        )

        played_files.add(
            selected
        )

        save_state()

        return MUSIC_DIR / selected

    # --------------------------------------------------------
    # PRIORITE 3
    #
    # Tout a été joué.
    #
    # Nouveau cycle.
    # --------------------------------------------------------

    print(
        "[radio] Cycle terminé, nouveau cycle."
    )

    played_files.clear()

    save_state()

    # Re-scan au cas où des fichiers auraient été
    # ajoutés exactement à ce moment.
    files, new_files = refresh_library()

    if not files:
        return None

    # Si de nouveaux fichiers sont apparus entre-temps,
    # ils gardent leur priorité.
    if new_files:

        selected = random.choice(
            list(new_files)
        )

    else:

        selected = random.choice(
            list(files)
        )

    played_files.add(
        selected
    )

    save_state()

    return MUSIC_DIR / selected


# ============================================================
# Distribution du flux
# ============================================================

async def broadcast(data):
    """
    Envoie les mêmes données à tous les auditeurs.
    """

    dead_clients = []

    for queue in list(clients):

        try:

            # Queue limitée pour éviter qu'un client
            # lent fasse exploser la mémoire.
            queue.put_nowait(data)

        except asyncio.QueueFull:

            # Client trop lent.
            dead_clients.append(queue)

    for queue in dead_clients:

        clients.discard(queue)

        print(
            "[clients] Client retiré : trop lent."
        )


# ============================================================
# Génération du flux radio
# ============================================================

async def play_file(path):
    global current_file
    global current_started

    try:

        relative = path.relative_to(
            MUSIC_DIR
        )

        current_file = str(
            relative
        )

    except ValueError:

        current_file = path.name

    current_started = time.time()

    print(
        f"[radio] ▶ {current_file}"
    )

    command = [
        "ffmpeg",

        "-hide_banner",
        "-loglevel",
        "warning",

        # Lecture en temps réel
        "-re",

        "-i",
        str(path),

        # Supprime une éventuelle piste vidéo
        "-vn",

        # Format radio
        "-ac",
        "2",

        "-ar",
        "44100",

        "-c:a",
        "libmp3lame",

        "-b:a",
        "128k",

        "-f",
        "mp3",

        "pipe:1",
    ]

    process = await asyncio.create_subprocess_exec(
        *command,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
    )

    try:

        while True:

            chunk = await process.stdout.read(
                64 * 1024
            )

            if not chunk:
                break

            await broadcast(
                chunk
            )

    except asyncio.CancelledError:

        process.terminate()

        try:
            await asyncio.wait_for(
                process.wait(),
                timeout=2
            )

        except asyncio.TimeoutError:

            process.kill()

        raise

    finally:

        if process.returncode is None:

            process.terminate()

            try:

                await asyncio.wait_for(
                    process.wait(),
                    timeout=2
                )

            except asyncio.TimeoutError:

                process.kill()

                await process.wait()

        current_file = None
        current_started = None


# ============================================================
# Boucle principale de la radio
# ============================================================

async def radio_loop():

    print(
        f"[radio] {RADIO_NAME}"
    )

    print(
        f"[radio] Musique : {MUSIC_DIR}"
    )

    while True:

        try:

            path = choose_next()

            if path is None:

                print(
                    "[radio] Aucun fichier audio."
                )

                await asyncio.sleep(5)

                continue

            if not path.exists():

                print(
                    f"[radio] Fichier disparu : {path}"
                )

                continue

            await play_file(
                path
            )

            # Petite pause de sécurité entre deux morceaux.
            await asyncio.sleep(0.1)

        except asyncio.CancelledError:

            raise

        except Exception as exc:

            print(
                f"[radio] Erreur : {exc}"
            )

            await asyncio.sleep(2)


# ============================================================
# Endpoint /radio
# ============================================================

async def radio(request):

    # Une queue par auditeur.
    #
    # 32 x 64 Ko ≈ 2 Mo maximum par client.
    queue = asyncio.Queue(
        maxsize=32
    )

    clients.add(
        queue
    )

    print(
        f"[client] Connexion "
        f"(total={len(clients)})"
    )

    response = web.StreamResponse(
        status=200,
        headers={
            "Content-Type": "audio/mpeg",
            "Cache-Control": "no-cache, no-store",
            "Connection": "keep-alive",
            "Access-Control-Allow-Origin": "*",

            "icy-name": RADIO_NAME,
            "icy-description": RADIO_NAME,
        },
    )

    try:

        await response.prepare(
            request
        )

        while True:

            chunk = await queue.get()

            await response.write(
                chunk
            )

    except (
        asyncio.CancelledError,
        ConnectionResetError,
        BrokenPipeError,
    ):
        pass

    except Exception as exc:

        print(
            f"[client] Déconnexion : {exc}"
        )

    finally:

        clients.discard(
            queue
        )

        print(
            f"[client] Déconnexion "
            f"(total={len(clients)})"
        )

    return response


# ============================================================
# Endpoint racine
# ============================================================

async def root(request):

    return web.Response(
        text=(
            f"{RADIO_NAME}\n\n"
            f"Flux : /radio\n"
            f"Etat : /status\n"
            f"Health : /health\n"
        ),
        content_type="text/plain",
    )


# ============================================================
# Etat
# ============================================================

async def status(request):

    files = scan_files()

    return web.json_response({
        "radio": RADIO_NAME,
        "current": current_file,
        "total_files": len(files),
        "played_in_cycle": len(
            played_files
        ),
        "remaining_in_cycle": len(
            files - played_files
        ),
        "listeners": len(
            clients
        ),
    })


# ============================================================
# Healthcheck
# ============================================================

async def health(request):

    return web.json_response({
        "status": "ok"
    })


# ============================================================
# Application
# ============================================================

async def create_app():

    global radio_task

    load_state()

    app = web.Application()

    app.router.add_get(
        "/",
        radio
    )

    app.router.add_get(
        "/radio",
        root
    )

    app.router.add_get(
        "/status",
        status
    )

    app.router.add_get(
        "/health",
        health
    )

    radio_task = asyncio.create_task(
        radio_loop()
    )

    return app


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":

    web.run_app(
        create_app(),
        host="0.0.0.0",
        port=PORT,
    )
