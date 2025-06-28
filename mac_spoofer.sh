#!/bin/bash

# Überprüfen, ob das Skript mit sudo ausgeführt wird
if [[ $EUID -ne 0 ]]; then
   echo "Dieses Skript muss mit sudo ausgeführt werden: sudo $0"
   exit 1
fi

# Netzwerkschnittstelle festlegen (z.B. en0 für Wi-Fi auf macOS)
INTERFACE="en0"

# Überprüfen, ob die Schnittstelle existiert
if ! ifconfig "$INTERFACE" > /dev/null 2>&1; then
    echo "Netzwerkschnittstelle $INTERFACE nicht gefunden!"
    exit 1
fi

# Überprüfen, ob openssl installiert ist
if ! command -v openssl &> /dev/null; then
    echo "openssl ist nicht installiert. Bitte installiere es (z.B. via Homebrew: brew install openssl)."
    exit 1
fi

# Generiere eine zufällige MAC-Adresse
# Format: XX:XX:XX:XX:XX:XX, wobei die erste Stelle ungerade sein muss (Unicast)
NEW_MAC=$(openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//; s/^\(.\)[13579bdf]/\12/')

echo "Aktuelle MAC-Adresse von $INTERFACE:"
ifconfig "$INTERFACE" | grep ether | awk '{print $2}'

# Wi-Fi kurz deaktivieren
echo "Deaktiviere Wi-Fi..."
networksetup -setairportpower "$INTERFACE" off

# MAC-Adresse ändern
echo "Setze neue MAC-Adresse: $NEW_MAC"
ifconfig "$INTERFACE" ether "$NEW_MAC"

# Wi-Fi wieder aktivieren
echo "Aktiviere Wi-Fi..."
networksetup -setairportpower "$INTERFACE" on

# Warte kurz, bis die Schnittstelle wieder aktiv ist
sleep 2

# Neue MAC-Adresse anzeigen
echo "Neue MAC-Adresse von $INTERFACE:"
ifconfig "$INTERFACE" | grep ether | awk '{print $2}'

echo "MAC-Adresse erfolgreich geändert!"