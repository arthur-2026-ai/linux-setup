# 🌐 Module 6 : Réseau Linux & Outils Développeur

## 🎯 Objectifs de ce module

À la fin de ce module, vous saurez :
- ✅ Diagnostiquer les problèmes réseau courants
- ✅ Tester les APIs et services web (curl, httpie)
- ✅ Gérer les ports et connexions
- ✅ Déboguer les applications Kotlin/Kobweb réseau
- ✅ Sécuriser vos connexions de développement

---

## 📊 Pourquoi le réseau est crucial pour le développement ?

En tant que développeur Kotlin/Kobweb, vous travaillez avec :

| Scénario                      | Outils nécessaires                     |
|-------------------------------|----------------------------------------|
| API backend Kotlin            | `curl`, `httpie`, `netcat`             |
| Frontend Kobweb (localhost)   | `ss`, `lsof`, `chrome://net-internals` |
| Services externes (DB, cache) | `ping`, `telnet`, `nmap`               |
| Déploiement                   | `scp`, `rsync`, `ssh`                  |
| Debug réseau                  | `tcpdump`, `wireshark`, `mitmproxy`    |

---

## 🔍 Commandes réseau ESSENTIELLES

### `ip` - Remplace ifconfig (moderne)
```bash
ip addr show           # Voir toutes les interfaces
ip addr show eth0      # Voir une interface spécifique
ip route show          # Voir la table de routage
ip -s link             # Statistiques réseau
```
### `ss` - Socket Statistics (remplace netstat)

ss -tulpn              # Tous les ports en écoute
ss -tun                # Toutes les connexions TCP/UDP
ss -t state established # Connexions établies
ss -tp                 # Avec processus
ss -tl                 # Seulement les ports en écoute

### ping & traceroute
```
ping google.com        # Test de connectivité
ping -c 4 8.8.8.8      # 4 paquets seulement
traceroute github.com  # Voir le chemin des paquets
mtr google.com         # Ping + traceroute combiné
```
### curl
```
# GET simple
curl https://api.github.com

# GET avec headers
curl -H "Authorization: Bearer token" https://api.example.com

# POST avec JSON (très utile pour les APIs)
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"name":"test","value":42}' \
  http://localhost:8080/api/users

# POST avec fichier
curl -X POST \
  -H "Content-Type: application/json" \
  --data-binary @data.json \
  http://localhost:8080/api

# Download fichier
curl -O https://example.com/file.zip
curl -o custom_name.zip https://example.com/file.zip

# Upload fichier
curl -X PUT \
  -H "Content-Type: application/octet-stream" \
  --data-binary @file.txt \
  http://localhost:8080/upload

# Suivre les redirections
curl -L http://example.com

# Sauvegarder les cookies
curl -c cookies.txt http://example.com/login
curl -b cookies.txt http://example.com/dashboard

# Verbose mode (débogage)
curl -v http://localhost:8080

# Mesurer le temps
curl -w "@curl-format.txt" -o /dev/null -s http://example.com
```