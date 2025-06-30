#!/bin/bash

# Hostname wiederherstellen

echo "🔧 Hostname-Wiederherstellung"
echo "============================"
echo ""

# Aktueller Hostname
current_hostname=$(hostname)
echo "Aktueller Hostname: $current_hostname"
echo ""

# Optionen
echo "1) MacBookPro (Standard)"
echo "2) Martins-MacBook-Pro"
echo "3) Eigenen Namen eingeben"
echo "4) Abbrechen"
echo ""

read -p "Wähle eine Option (1-4): " choice

case "$choice" in
    1)
        new_hostname="MacBookPro"
        ;;
    2)
        new_hostname="Martins-MacBook-Pro"
        ;;
    3)
        read -p "Neuer Hostname: " new_hostname
        ;;
    4)
        echo "Abgebrochen."
        exit 0
        ;;
    *)
        echo "Ungültige Eingabe."
        exit 1
        ;;
esac

# Hostname setzen
echo ""
echo "Setze Hostname zu: $new_hostname"
sudo scutil --set ComputerName "$new_hostname"
sudo scutil --set LocalHostName "$new_hostname"
sudo scutil --set HostName "$new_hostname"

echo "✅ Hostname wiederhergestellt zu: $new_hostname"
echo ""
echo "Neue Shell-Sessions werden den korrekten Namen zeigen."