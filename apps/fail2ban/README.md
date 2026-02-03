# Fail2ban Global pour docker-web

Service de protection centralisé contre les attaques par brute force et les tentatives d'intrusion pour toutes les applications docker-web.

## Description

Ce service Fail2ban global surveille les logs de toutes vos applications docker-web et bannit automatiquement les adresses IP suspectes. Il protège contre :
- Les tentatives de connexion par brute force
- Les scans de vulnérabilités
- Les tentatives d'accès non autorisés
- Les attaques par déni de service (DoS)

## Applications supportées

- **Nginx Proxy** : Protection contre les attaques web
- **Nextcloud** : Protection des connexions et fichiers
- **Gitea** : Protection des dépôts Git
- **Transmission** : Protection du client torrent
- **SSH** : Protection des connexions système

## Installation

1. **Configurer les variables d'environnement** :
   ```bash
   cd /var/docker-web/apps/fail2ban
   nano env.sh
   ```

2. **Adapter les chemins des logs** si nécessaire dans `docker-compose.yml`

3. **Démarrer le service** :
   ```bash
   docker-web up fail2ban
   ```

## Configuration

### Variables d'environnement (env.sh)

- `PUID/PGID` : IDs utilisateur/groupe (défaut: 1000)
- `TZ` : Fuseau horaire (défaut: Europe/Paris)
- `BANTIME` : Durée de bannissement en secondes (défaut: 3600)
- `MAXRETRY` : Nombre de tentatives avant bannissement (défaut: 3)
- `FINDTIME` : Période de détection en secondes (défaut: 600)

### Règles de filtrage (jail.local)

Chaque application a ses propres règles :
- **nginx-http-auth** : Échecs d'authentification HTTP
- **nextcloud** : Connexions Nextcloud échouées
- **gitea** : Tentatives d'accès Git non autorisées
- **transmission** : Accès client torrent non autorisés

### Filtres personnalisés (filter.d/)

Les filtres définissent les patterns à détecter dans les logs :
- `nextcloud.conf` : Logs Nextcloud au format JSON
- `gitea.conf` : Logs d'authentification Gitea
- `transmission.conf` : Logs d'accès Transmission
- `nginx-*.conf` : Protection web Nginx

## Utilisation

### Vérifier le statut
```bash
docker exec fail2ban-global fail2ban-client status
```

### Voir les jails actifs
```bash
docker exec fail2ban-global fail2ban-client status
```

### Voir une jail spécifique
```bash
docker exec fail2ban-global fail2ban-client status nginx-http-auth
```

### Bannir manuellement une IP
```bash
docker exec fail2ban-global fail2ban-client set nginx-http-auth banip 192.168.1.100
```

### Débannir une IP
```bash
docker exec fail2ban-global fail2ban-client set nginx-http-auth unbanip 192.168.1.100
```

### Voir les logs
```bash
docker logs -f fail2ban-global
```

## Maintenance

### Redémarrer fail2ban après modification
```bash
docker-web restart fail2ban
```

### Recharger la configuration
```bash
docker exec fail2ban-global fail2ban-client reload
```

### Mettre à jour
```bash
docker-web pull fail2ban
docker-web up fail2ban
```

## Sécurité

- Le service utilise `network_mode: host` pour accéder à iptables
- `privileged: true` est nécessaire pour manipuler le firewall
- Les logs sont montés en lecture seule (`:ro`)
- Le conteneur est isolé dans le réseau dockerweb

## Dépannage

### Problèmes courants

1. **Logs non trouvés** : Vérifiez les chemins dans `docker-compose.yml`
2. **Permissions** : Assurez-vous que PUID/PGID sont corrects
3. **IPs non bannies** : Vérifiez que `network_mode: host` fonctionne

### Debug

```bash
# Tester un filtre
docker exec fail2ban-global fail2ban-regex /var/log/nginx/error.log nginx-http-auth

# Voir la configuration
docker exec fail2ban-global fail2ban-client get nginx-http-auth bantime
```

## Personnalisation

Pour ajouter une nouvelle application :

1. Créer un filtre dans `config/filter.d/nouvelle_app.conf`
2. Ajouter une jail dans `config/jail.local`
3. Monter les logs dans `docker-compose.yml`
4. Recharger fail2ban

## Avertissements

- Ce service nécessite des privilèges élevés
- Testez toujours les filtres avant production
- Surveillez les faux positifs
- Gardez une sauvegarde de votre configuration
