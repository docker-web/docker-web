# docker-compose wrapper for self-hosted servers
- pegaz ls: list all services with state (start/stop/fail)

# PORT RANGE
7700 -> 8000
7700 -> 7709 reserved for nginx-proxy and test
7710 -> 7719 reserved for nextcloud

## 1. Reverso proxy
- nginx docker :!
https://linuxhandbook.com/nginx-reverse-proxy-docker/

https://pinia.vuejs.org/

## TOOL-PACK
réunir un ensemble de logiciel libre abordable pour aider / sensibiliser le grand public
- ublock origin
- unblockit.cam
- f-droid / aptoid
- exodus privacy - https://reports.exodus-privacy.eu.org/fr/
- dark reader
- tronScript
- web extension youtube-dl ?
- blokada https://f-droid.org/en/packages/org.blokada.fem.fdroid/

## whitePaper pour crowdfounding

Où mettre les 9e / mois de netflix ?
-> labels indépendant
-> achat de vod
-> achat de blueray
-> aller au cinema
-> aller aux concerts
-> https://curiositystream.com/?coupon=THOMASFLIGHT#signup

- jellyfin
- deluge
- nextcloud/libreoffice
- liquidsoap/icecast
- web tv ?
- yunohost
https://yunohost.org/en/apps

sign on https://web0.small-web.org/

## THISISNOTBOYCOT (ban french gafam)
- préparer un etc/host avec les marmiton.org, auxfeminin etc (voir exodus privacy)
- construire un outils capable de facilement mettre à jour etc/hosts (outils auto-destructif pour la sécurité ?) :: https://fr.wikipedia.org/wiki/Aufeminin#cite_ref-13

## Réfléchir à :
- qu'est ce que serait des "Conventions d'usages", est ce que cela existe déjà ?
## YOUTUBE-DL UI ?
- do not search anymore on youtube, search on this ui to dl & play on your server

 Simple and privacy-friendly Google Analytics alternative 
https://plausible.io/

## BOSSER L'UI

linode ? hardware ?

trakt ? re-try radarr / sonarr with unblockit ?
https://www.youtube.com/watch?v=J8KcJL9gylA
https://trakt.tv/movies/le-degre-6-du-voyageur-2013

- [x] tester un premier domaine en https
- [x] deployer en CI
- [ ] https://konstaui.com/ for backend UI ?
- [ ] SWAG !! https://docs.linuxserver.io/general/swag
- [ ] SWAG CONFIG!!  https://github.com/linuxserver/reverse-proxy-confs
- [ ] clone repo madrigal sur le serveur pour debug direct
- [ ] ajouter des domaines automatiquements
- [ ] configurateur de sous domaines
- [ ] ajouter des domaines manuellement
- [ ] ajouter un domaine depuis un autre/docker-compose ? config file ?
- [ ] ajouter nextcloud
- [ ] tester multi compose file
- [ ] set download folder to 777
- [ ] deluge plugins ato add label etc
- [ ] portainer to manage docker ? (Switch off, restart, update) https://github.com/valerebron/usetube/issues/16


### Deluge dark theme
https://github.com/joelacus/deluge-web-dark-theme
cd /opt/deluge/config
sed -i "s|\"theme\": \"gray\"|\"theme\": \"dark\"|g" web.conf
sudo wget -c https://github.com/joelacus/deluge-web-dark-theme/raw/main/deluge_web_dark_theme.tar.gz -O - | sudo tar -xz -C ./

SEEDBOXes scripts
https://github.com/search?q=seedbox

SUPABASE 4 BaaS
https://github.com/supabase/supabase 

## VPS:
mivocloud
185.163.45.199

Nextcloud with Traefik:
https://github.com/pagnotta/treafik_nxtcloud

## SPLITED DOCKER-COMPOSE:
docker-compose $(find docker* | sed -e 's/^/-f /') up -d

Nextcloud / libre office online
https://github.com/smehrbrodt/nextcloud-libreoffice-online

## SOURCES
https://github.com/nextcloud/docker/blob/master/.examples/docker-compose/with-nginx-proxy/postgres/fpm/docker-compose.yml
https://github.com/gilyes/docker-nginx-letsencrypt-sample


easy way to add custom link
add paths in env
.music path (for radio)
.public talk path with bash script ?
.nextcloud link
.idée de sites : lister des réalisateurs / acteurs & afficher des liens magnet pour télécharger
.croiser magnet-dl / ygg API & imdb API (https://rapidapi.com/hub)

raspberry install ?
arm ? no

cron ? (node js script ?)

backup ?

ipfixe ?

domain name ?

NO ARM --> LINUXSERVER.io has ! - NO RASPBERRY OR WHATEVER
FIND Ideal PC Case


APPS :

- [ ] RSS: https://github.com/GetStream/Winds
- [ ] server CODE https://github.com/linuxserver/docker-code-server
- [ ] penpot ? https://help.penpot.app/technical-guide/getting-started/
- [ ] Google Analytics alternative https://plausible.io/
- [ ] Email server https://github.com/docker-mailserver/docker-mailserver#examples
