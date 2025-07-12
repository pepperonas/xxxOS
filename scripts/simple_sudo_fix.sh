#!/bin/bash

# Einfache Alternative: Touch ID für sudo aktivieren

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Touch ID für sudo aktivieren                     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Diese Methode aktiviert Touch ID (Fingerabdruck) für sudo.${NC}"
echo -e "${YELLOW}Du musst nie wieder ein Passwort für sudo eingeben!${NC}"
echo ""

# Prüfe ob Touch ID verfügbar ist
if ! system_profiler SPHardwareDataType | grep -q "Touch ID"; then
    echo -e "${RED}❌ Dein Mac hat kein Touch ID${NC}"
    echo -e "${YELLOW}Diese Methode funktioniert nur mit Touch ID Macs${NC}"
    exit 1
fi

echo -e "${BLUE}Möchtest du Touch ID für sudo aktivieren? (j/n)${NC}"
read -r response

if [[ "$response" != "j" ]]; then
    echo "Abgebrochen."
    exit 0
fi

# Backup der sudo-Konfiguration
echo -e "${BLUE}Erstelle Backup...${NC}"
sudo cp /etc/pam.d/sudo /etc/pam.d/sudo.backup

# Füge Touch ID Zeile hinzu
echo -e "${BLUE}Aktiviere Touch ID...${NC}"
sudo sed -i '' '1s/^/auth       sufficient     pam_tid.so\n/' /etc/pam.d/sudo

echo -e "${GREEN}✅ Touch ID für sudo wurde aktiviert!${NC}"
echo ""
echo -e "${GREEN}Ab jetzt kannst du deinen Fingerabdruck statt Passwort verwenden.${NC}"
echo -e "${YELLOW}Hinweis: Nach System-Updates musst du dies eventuell wiederholen.${NC}"
echo ""
echo -e "${YELLOW}Rückgängig machen mit:${NC}"
echo "sudo mv /etc/pam.d/sudo.backup /etc/pam.d/sudo"