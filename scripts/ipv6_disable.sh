#!/usr/bin/env bash

# xxxOS IPv6 Disable/Enable Tool
# Deaktiviert IPv6 um Tor-Leaks zu verhindern
# (c) 2025 Martin Pfeffer - MIT License

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# SwiftBar Helper einbinden
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/swiftbar_helper.sh" ]; then
    source "$SCRIPT_DIR/swiftbar_helper.sh"
fi

# IPv6 deaktivieren
disable_ipv6() {
    echo -e "${BLUE}🚫 Deaktiviere IPv6 für bessere Tor-Sicherheit...${NC}"
    
    # Alle Netzwerk-Interfaces finden
    local interfaces=$(networksetup -listallhardwareports | awk '/Hardware Port:/{getline; print $2}')
    
    for interface in $interfaces; do
        if networksetup -getinfo "$interface" >/dev/null 2>&1; then
            echo "Deaktiviere IPv6 für $interface..."
            sudo networksetup -setv6off "$interface" 2>/dev/null
        fi
    done
    
    echo -e "${GREEN}✅ IPv6 deaktiviert${NC}"
    echo -e "${YELLOW}⚠️  Neustart empfohlen für vollständige Wirkung${NC}"
    
}

# IPv6 aktivieren
enable_ipv6() {
    echo -e "${BLUE}🌐 Aktiviere IPv6...${NC}"
    
    # Alle Netzwerk-Interfaces finden
    local interfaces=$(networksetup -listallhardwareports | awk '/Hardware Port:/{getline; print $2}')
    
    for interface in $interfaces; do
        if networksetup -getinfo "$interface" >/dev/null 2>&1; then
            echo "Aktiviere IPv6 für $interface..."
            sudo networksetup -setv6automatic "$interface" 2>/dev/null
        fi
    done
    
    echo -e "${GREEN}✅ IPv6 aktiviert${NC}"
    
}

# IPv6 Status prüfen
check_ipv6_status() {
    echo -e "${BLUE}📊 IPv6-Status:${NC}"
    echo ""
    
    local ipv6_disabled=true
    
    # Alle Netzwerk-Interfaces prüfen
    local interfaces=$(networksetup -listallhardwareports | awk '/Hardware Port:/{getline; print $2}')
    
    for interface in $interfaces; do
        if networksetup -getinfo "$interface" >/dev/null 2>&1; then
            local ipv6_config=$(networksetup -getinfo "$interface" | grep "IPv6:")
            if [[ "$ipv6_config" == *"Off"* ]]; then
                echo "  $interface: ✅ IPv6 deaktiviert"
            else
                echo "  $interface: ❌ IPv6 aktiv"
                ipv6_disabled=false
            fi
        fi
    done
    
    echo ""
    if $ipv6_disabled; then
        echo -e "${GREEN}✅ IPv6 vollständig deaktiviert - Tor-Leaks verhindert${NC}"
    else
        echo -e "${YELLOW}⚠️  IPv6 teilweise aktiv - Mögliche Tor-Leaks${NC}"
    fi
}

# Hauptfunktion
main() {
    case "$1" in
        "disable"|"off")
            disable_ipv6
            ;;
        "enable"|"on")
            enable_ipv6
            ;;
        "status"|"")
            check_ipv6_status
            ;;
        *)
            echo "Usage: $0 [disable|enable|status]"
            echo ""
            echo "Befehle:"
            echo "  disable/off  - IPv6 deaktivieren (empfohlen für Tor)"
            echo "  enable/on    - IPv6 wieder aktivieren"
            echo "  status       - IPv6-Status anzeigen (Standard)"
            echo ""
            echo "Beispiele:"
            echo "  $0 disable    # IPv6 für bessere Tor-Sicherheit deaktivieren"
            echo "  $0 status     # Aktuellen IPv6-Status prüfen"
            echo "  $0 enable     # IPv6 wieder aktivieren"
            ;;
    esac
}

main "$@"