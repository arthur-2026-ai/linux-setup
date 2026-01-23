#!/usr/bin/env bash

###############################################################################
# fix-java-home.sh - Corriger JAVA_HOME pour Kobweb
###############################################################################

echo "🔧 Correction de JAVA_HOME..."

# 1. Trouver le bon chemin Java
JAVA_PATH=$(update-alternatives --query java | grep 'Value:' | cut -d' ' -f2)
CORRECT_JAVA_HOME=$(dirname $(dirname "$JAVA_PATH"))

echo "Java trouvé à: $JAVA_PATH"
echo "JAVA_HOME correct: $CORRECT_JAVA_HOME"

# 2. Sauvegarder le .bashrc
cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d-%H%M%S)
echo "✓ Backup de .bashrc créé"

# 3. Nettoyer toutes les anciennes références Java
sed -i '/# Java/d' ~/.bashrc
sed -i '/JAVA_HOME/d' ~/.bashrc
sed -i '/java.*\/bin/d' ~/.bashrc
echo "✓ Anciennes configurations supprimées"

# 4. Ajouter la bonne configuration
cat >> ~/.bashrc << EOF

# Java - Configuration automatique
export JAVA_HOME="$CORRECT_JAVA_HOME"
export PATH="\$PATH:\$JAVA_HOME/bin"
EOF
echo "✓ Nouvelle configuration ajoutée"

# 5. Charger pour la session actuelle
export JAVA_HOME="$CORRECT_JAVA_HOME"
export PATH="$PATH:$JAVA_HOME/bin"

# 6. Vérifications
echo ""
echo "========================================"
echo "Vérifications:"
echo "========================================"
echo "JAVA_HOME: $JAVA_HOME"
echo ""
echo "Java version:"
java -version 2>&1 | head -n 1
echo ""

if command -v kobweb >/dev/null 2>&1; then
    echo "Kobweb version:"
    if kobweb version 2>&1 | grep -q "ERROR"; then
        echo "❌ Kobweb ne fonctionne toujours pas"
        echo ""
        echo "Solution manuelle:"
        echo "1. Fermez ce terminal"
        echo "2. Ouvrez un nouveau terminal"
        echo "3. Testez: kobweb version"
    else
        kobweb version
        echo "✓ Kobweb fonctionne !"
    fi
else
    echo "⚠️  Kobweb n'est pas installé"
fi

echo ""
echo "========================================"
echo "✓ Configuration terminée"
echo "========================================"
echo ""
echo "Pour que les changements prennent effet:"
echo "1. Fermez ce terminal"
echo "2. Ouvrez un nouveau terminal"
echo "3. Vérifiez: echo \$JAVA_HOME"
echo "4. Testez: kobweb version"