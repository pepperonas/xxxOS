#!/bin/bash

# Test-Script für sudo-Zugriff

echo "🔐 Teste sudo-Zugriff..."
echo "Bitte gib dein Mac-Benutzerpasswort ein:"
echo "(Das gleiche Passwort, mit dem du dich am Mac anmeldest)"
echo ""

# Teste sudo
if sudo echo "✅ Sudo funktioniert!"; then
    echo ""
    echo "Dein Benutzername ist: $(whoami)"
    echo "Du bist in diesen Gruppen: $(groups)"
    echo ""
    
    # Prüfe ob User in admin-Gruppe ist
    if groups | grep -q admin; then
        echo "✅ Du bist in der admin-Gruppe"
    else
        echo "❌ Du bist NICHT in der admin-Gruppe"
        echo "   Das könnte das Problem sein!"
    fi
else
    echo "❌ Sudo-Zugriff fehlgeschlagen"
fi