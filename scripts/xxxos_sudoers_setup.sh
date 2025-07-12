#!/bin/bash

# xxxOS Sudoers Setup
# Dieses Script richtet passwortlose sudo-Befehle für xxxOS ein

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              xxxOS Sudo-Konfiguration                      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Dieses Script richtet passwortlose sudo-Befehle für xxxOS ein.${NC}"
echo -e "${YELLOW}Sie müssen Ihr Passwort nur einmal eingeben.${NC}"
echo ""

# Erstelle sudoers.d Datei für xxxOS
SUDOERS_FILE="/etc/sudoers.d/xxxos"
SUDOERS_CONTENT=$(cat << 'EOF'
# xxxOS Password-less Commands
# Allows xxxOS privacy commands without password prompt

# System identification and hostname
%admin ALL=(ALL) NOPASSWD: /usr/sbin/scutil --set ComputerName *
%admin ALL=(ALL) NOPASSWD: /usr/sbin/scutil --set LocalHostName *
%admin ALL=(ALL) NOPASSWD: /usr/sbin/scutil --set HostName *
%admin ALL=(ALL) NOPASSWD: /usr/sbin/scutil --get ComputerName
%admin ALL=(ALL) NOPASSWD: /usr/sbin/scutil --get LocalHostName
%admin ALL=(ALL) NOPASSWD: /usr/sbin/scutil --get HostName

# DNS and cache management
%admin ALL=(ALL) NOPASSWD: /usr/bin/dscacheutil -flushcache
%admin ALL=(ALL) NOPASSWD: /usr/bin/killall mDNSResponder
%admin ALL=(ALL) NOPASSWD: /usr/bin/killall -HUP mDNSResponder
%admin ALL=(ALL) NOPASSWD: /usr/bin/killall -9 mDNSResponder
%admin ALL=(ALL) NOPASSWD: /usr/bin/killall -9 mDNSResponderHelper

# Network interface management
%admin ALL=(ALL) NOPASSWD: /sbin/ifconfig * ether *
%admin ALL=(ALL) NOPASSWD: /sbin/ifconfig * down
%admin ALL=(ALL) NOPASSWD: /sbin/ifconfig * up
%admin ALL=(ALL) NOPASSWD: /sbin/ifconfig *
%admin ALL=(ALL) NOPASSWD: /sbin/ipconfig set * DHCP
%admin ALL=(ALL) NOPASSWD: /usr/sbin/networksetup *
%admin ALL=(ALL) NOPASSWD: /usr/sbin/networksetup -setairportpower * *
%admin ALL=(ALL) NOPASSWD: /sbin/route delete *

# Service management
%admin ALL=(ALL) NOPASSWD: /bin/launchctl *
%admin ALL=(ALL) NOPASSWD: /usr/local/bin/brew services *

# Process management
%admin ALL=(ALL) NOPASSWD: /usr/bin/killall tor
%admin ALL=(ALL) NOPASSWD: /usr/bin/killall SwiftBar
%admin ALL=(ALL) NOPASSWD: /usr/bin/pkill -f tor

# Hosts file management
%admin ALL=(ALL) NOPASSWD: /bin/cp /etc/hosts *
%admin ALL=(ALL) NOPASSWD: /bin/cp /etc/hosts.xxxos.backup /etc/hosts
%admin ALL=(ALL) NOPASSWD: /usr/bin/tee -a /etc/hosts
%admin ALL=(ALL) NOPASSWD: /usr/bin/tee /etc/hosts
%admin ALL=(ALL) NOPASSWD: /usr/bin/sed -i.bak * /etc/hosts
%admin ALL=(ALL) NOPASSWD: /usr/bin/sed -i * /etc/hosts
%admin ALL=(ALL) NOPASSWD: /bin/rm -f /etc/hosts.xxxos.backup

# Firewall management
%admin ALL=(ALL) NOPASSWD: /usr/libexec/ApplicationFirewall/socketfilterfw *
%admin ALL=(ALL) NOPASSWD: /sbin/pfctl *
%admin ALL=(ALL) NOPASSWD: /bin/cp /etc/pf.conf.backup /etc/pf.conf
%admin ALL=(ALL) NOPASSWD: /bin/cp /etc/pf.conf /etc/pf.conf.backup

# Configuration file management
%admin ALL=(ALL) NOPASSWD: /usr/bin/tee /usr/local/etc/proxychains.conf
%admin ALL=(ALL) NOPASSWD: /bin/cp /usr/local/etc/proxychains.conf *
%admin ALL=(ALL) NOPASSWD: /bin/chmod 440 /etc/sudoers.d/xxxos
%admin ALL=(ALL) NOPASSWD: /bin/rm -f /etc/sudoers.d/xxxos
%admin ALL=(ALL) NOPASSWD: /bin/rm -f /Library/Preferences/SystemConfiguration/*.plist
%admin ALL=(ALL) NOPASSWD: /bin/mv /etc/pam.d/sudo.backup /etc/pam.d/sudo
%admin ALL=(ALL) NOPASSWD: /bin/cp /etc/pam.d/sudo /etc/pam.d/sudo.backup
%admin ALL=(ALL) NOPASSWD: /usr/bin/sed -i * /etc/pam.d/sudo

# Installation
%admin ALL=(ALL) NOPASSWD: /usr/sbin/installer -pkg * -target /

# Validation commands
%admin ALL=(ALL) NOPASSWD: /usr/sbin/visudo -c -f /etc/sudoers.d/xxxos

EOF
)

echo -e "${BLUE}Schreibe sudoers-Konfiguration...${NC}"
echo "$SUDOERS_CONTENT" | sudo tee "$SUDOERS_FILE" > /dev/null

# Setze korrekte Berechtigungen
sudo chmod 440 "$SUDOERS_FILE"

# Validiere sudoers-Datei
echo -e "${BLUE}Validiere Konfiguration...${NC}"
if sudo visudo -c -f "$SUDOERS_FILE"; then
    echo -e "${GREEN}✅ Sudo-Konfiguration erfolgreich installiert!${NC}"
    echo ""
    echo -e "${GREEN}Die folgenden Befehle benötigen ab jetzt kein Passwort mehr:${NC}"
    echo "  • MAC-Adresse ändern"
    echo "  • Hostname ändern"
    echo "  • DNS-Cache leeren"
    echo "  • Netzwerkeinstellungen ändern"
    echo "  • Tor-Service steuern"
    echo "  • Hosts-Datei bearbeiten"
    echo "  • SwiftBar neustarten"
    echo "  • Firewall-Einstellungen ändern"
    echo "  • Packet Filter (pfctl) steuern"
    echo "  • ProxyChains konfigurieren"
    echo "  • Touch ID für sudo konfigurieren"
    echo ""
    echo -e "${YELLOW}⚠️  Hinweis: Diese Konfiguration erhöht den Komfort, reduziert aber die Sicherheit.${NC}"
    echo -e "${YELLOW}   Entfernen mit: sudo rm $SUDOERS_FILE${NC}"
else
    echo -e "${RED}❌ Fehler in der sudoers-Konfiguration!${NC}"
    sudo rm -f "$SUDOERS_FILE"
    exit 1
fi