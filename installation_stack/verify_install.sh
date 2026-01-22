#!/bin/bash
echo "=== VÉRIFICATION ENVIRONNEMENT DEV ==="
echo ""
echo "1. Docker:"
docker --version 2>/dev/null && echo "  ✅ Docker OK" || echo "  ❌ Docker NON INSTALLÉ"
docker compose version 2>/dev/null && echo "  ✅ Docker Compose OK" || echo "  ❌ Docker Compose NON INSTALLÉ"

echo ""
echo "2. ASDF:"
asdf --version 2>/dev/null && echo "  ✅ ASDF OK" || echo "  ❌ ASDF NON INSTALLÉ"

echo ""
echo "3. VS Code:"
code --version 2>/dev/null | head -n 1 && echo "  ✅ VS Code OK" || echo "  ❌ VS Code NON INSTALLÉ"

echo ""
echo "4. IntelliJ IDEA:"
snap list 2>/dev/null | grep -q intellij && echo "  ✅ IntelliJ IDEA OK" || echo "  ❌ IntelliJ IDEA NON INSTALLÉ"

echo ""
echo "5. Postman:"
snap list 2>/dev/null | grep -q postman && echo "  ✅ Postman OK" || echo "  ❌ Postman NON INSTALLÉ"

echo ""
echo "6. Android Studio:"
[[ -f /opt/android-studio/bin/studio.sh ]] && echo "  ✅ Android Studio OK (manuel)" || \
  (snap list 2>/dev/null | grep -q android-studio && echo "  ✅ Android Studio OK (snap)" || \
  echo "  ❌ Android Studio NON INSTALLÉ")

echo ""
echo "7. MongoDB:"
sudo systemctl is-active --quiet mongod && echo "  ✅ MongoDB OK (actif)" || echo "  ❌ MongoDB INACTIF"

echo ""
echo "8. Outils Supplémentaires:"
command -v eza >/dev/null 2>&1 && echo "  ✅ eza OK" || echo "  ❌ eza NON INSTALLÉ"
command -v ncdu >/dev/null 2>&1 && echo "  ✅ ncdu OK" || echo "  ❌ ncdu NON INSTALLÉ"
command -v httpie >/dev/null 2>&1 && echo "  ✅ httpie OK" || echo "  ❌ httpie NON INSTALLÉ"

echo ""
echo "==================================="