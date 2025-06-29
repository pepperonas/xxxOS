#!/bin/bash

# xxxOS Control Script
# Zentrales Steuerungsskript für Privacy-Tools
# (c) 2025 Martin Pfeffer - MIT License

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOR_SCRIPT="$SCRIPT_DIR/scripts/tor_control.sh"
MAC_SCRIPT="$SCRIPT_DIR/scripts/mac_spoofer.sh"
PRIVACY_SCRIPT="$SCRIPT_DIR/scripts/privacy_enhance.sh"
PROXYCHAINS_SCRIPT="$SCRIPT_DIR/scripts/proxychains_setup.sh"

# Farben für die Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner anzeigen
show_banner() {
echo -e "${GREEN}"
echo "                    xxxOS v0.0.1-beta                         "
echo "                Privacy & Anonymity Tools                 "
echo "                                                            "
echo "       01001000 01001001 01000100 01000100 01000101         "
echo "       01001110 00100000 01001001 01001110 00100000         "
echo "       01010000 01001100 01000001 01001001 01001110         "
echo "       00100000 01010011 01001001 01000111 01001000         "
echo "       01010100 00101110 00101110 00101110 00101110         "
echo "                                                            "
echo "                ▐▄• ▄▐▄• ▄▐▄• ▄     .▄▄ ·                    "
echo "                 █▌█▌▪█▌█▌▪█▌█▌▪    ▐█                      "
echo "                 ·██· ·██· ·██· ▄█▀▄▄▀▀▀█▄                   "
echo "                ▪▐█·█▪▐█·█▪▐█·█▐█▌.▐▐█▄▪▐█                  "
echo "                •▀▀ ▀•▀▀ ▀•▀▀ ▀▀▀█▄▀▪▀▀▀▀                    "
echo "                                                            "
echo "      \"The human race has only one really effective     "
echo "           weapon, and that is laughter.\"               "
echo "                                                         "
echo "                   - Mark Twain                          "
echo "                                                            "
echo -e "${BLUE}            Built 🔒 by Martin Pfeffer                  ${NC}"
echo "                                                            "
echo "                                                            "
}

# Hilfe anzeigen
show_help() {
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  status           - Gesamtstatus aller Privacy-Funktionen"
    echo "  ipinfo           - Detaillierte IP-Informationen anzeigen"
    echo ""
    echo "  tor <action>     - Tor-Kontrolle"
    echo "    start          - Tor starten"
    echo "    stop           - Tor stoppen"
    echo "    status         - Status anzeigen"
    echo "    proxy-on       - System-Proxy aktivieren"
    echo "    proxy-off      - System-Proxy deaktivieren"
    echo "    full-on        - Tor + Proxy aktivieren"
    echo "    full-off       - Tor + Proxy deaktivieren"
    echo "    test           - Verbindung testen"
    echo ""
    echo "  mac              - MAC-Adresse ändern (benötigt sudo)"
    echo ""
    echo "  privacy          - Vollständiger Privacy-Modus"
    echo "    on             - MAC ändern + Tor aktivieren"
    echo "    off            - Tor deaktivieren"
    echo "    status         - Aktuellen Status anzeigen"
    echo "    ultra          - Ultra-Privacy (alle Funktionen)"
    echo ""
    echo "  enhance <action> - Erweiterte Privacy-Funktionen"
    echo "    dns-clear      - DNS-Cache leeren"
    echo "    hostname       - Hostname randomisieren"
    echo "    browser-clear  - Browser-Daten löschen"
    echo "    firewall       - Firewall aktivieren"
    echo "    dns-privacy    - Privacy-DNS setzen"
    echo "    block-tracking - Tracking blockieren"
    echo "    all            - Alle Funktionen aktivieren"
    echo ""
    echo "  proxychains      - ProxyChains für Terminal einrichten"
    echo ""
    echo "  help             - Diese Hilfe anzeigen"
    echo ""
    echo "Examples:"
    echo "  $0 status                 # Gesamtstatus anzeigen"
    echo "  $0 ipinfo                 # Detaillierte IP-Informationen"
    echo "  $0 tor start              # Tor starten"
    echo "  $0 mac                    # MAC-Adresse ändern"
    echo "  $0 privacy on             # Vollständiger Privacy-Modus"
    echo "  $0 privacy ultra          # Maximum Privacy"
    echo "  $0 enhance dns-clear      # DNS-Cache leeren"
}

# Überprüfe ob Skripte existieren
check_scripts() {
    if [ ! -f "$TOR_SCRIPT" ]; then
        echo -e "${RED}Fehler: tor_control.sh nicht gefunden in $TOR_SCRIPT${NC}"
        exit 1
    fi
    if [ ! -f "$MAC_SCRIPT" ]; then
        echo -e "${RED}Fehler: mac_spoofer.sh nicht gefunden in $MAC_SCRIPT${NC}"
        exit 1
    fi
    if [ ! -f "$PRIVACY_SCRIPT" ]; then
        echo -e "${RED}Fehler: privacy_enhance.sh nicht gefunden in $PRIVACY_SCRIPT${NC}"
        exit 1
    fi
}

# Tor-Kontrolle
handle_tor() {
    if [ -z "$1" ]; then
        echo -e "${RED}Fehler: Keine Aktion angegeben${NC}"
        echo "Verwende: $0 tor {start|stop|status|proxy-on|proxy-off|full-on|full-off|test}"
        exit 1
    fi
    "$TOR_SCRIPT" "$1"
}

# MAC-Adresse ändern
handle_mac() {
    echo -e "${YELLOW}MAC-Adresse wird geändert (benötigt sudo)...${NC}"
    sudo "$MAC_SCRIPT"
}

# Privacy-Modus
handle_privacy() {
    case "$1" in
        on)
            show_banner
            echo -e "${GREEN}🔒 Aktiviere vollständigen Privacy-Modus...${NC}"
            echo ""
            
            # MAC-Adresse ändern
            echo -e "${BLUE}Schritt 1: MAC-Adresse ändern${NC}"
            sudo "$MAC_SCRIPT"
            echo ""
            
            # Tor aktivieren
            echo -e "${BLUE}Schritt 2: Tor aktivieren${NC}"
            "$TOR_SCRIPT" full-on
            echo ""
            
            echo -e "${GREEN}✅ Privacy-Modus aktiviert!${NC}"
            echo ""
            echo "Tipps:"
            echo "- Verwende den Tor Browser für maximale Anonymität"
            echo "- Oder nutze: proxychains4 <command> für einzelne Anwendungen"
            echo "- Safari nutzt automatisch den System-Proxy"
            ;;
            
        off)
            show_banner
            echo -e "${YELLOW}🔓 Deaktiviere Privacy-Modus...${NC}"
            echo ""
            
            "$TOR_SCRIPT" full-off
            echo ""
            
            echo -e "${GREEN}✅ Privacy-Modus deaktiviert${NC}"
            echo -e "${YELLOW}Hinweis: MAC-Adresse bleibt geändert bis zum Neustart${NC}"
            ;;
            
        status)
            show_banner
            echo -e "${BLUE}📊 Privacy-Status${NC}"
            echo "=================="
            echo ""
            
            # MAC-Adresse Status
            echo -e "${BLUE}MAC-Adresse:${NC}"
            CURRENT_MAC=$(ifconfig en0 | grep ether | awk '{print $2}')
            echo "Aktuelle MAC: $CURRENT_MAC"
            echo ""
            
            # Tor Status
            "$TOR_SCRIPT" status
            ;;
            
        ultra)
            show_banner
            echo -e "${RED}🛡️  ULTRA PRIVACY MODUS${NC}"
            echo "======================"
            echo ""
            
            # MAC-Adresse ändern
            echo -e "${BLUE}Schritt 1: MAC-Adresse ändern${NC}"
            sudo "$MAC_SCRIPT"
            echo ""
            
            # Erweiterte Privacy-Funktionen
            echo -e "${BLUE}Schritt 2: Erweiterte Privacy-Funktionen${NC}"
            "$PRIVACY_SCRIPT" all
            echo ""
            
            # Tor aktivieren
            echo -e "${BLUE}Schritt 3: Tor aktivieren${NC}"
            "$TOR_SCRIPT" full-on
            echo ""
            
            # ProxyChains Setup
            echo -e "${BLUE}Schritt 4: ProxyChains konfigurieren${NC}"
            "$PROXYCHAINS_SCRIPT" install
            echo ""
            
            echo -e "${GREEN}✅ ULTRA PRIVACY MODUS AKTIVIERT!${NC}"
            echo ""
            echo -e "${YELLOW}Wichtige Hinweise:${NC}"
            echo "- Firewall ist aktiv mit Stealth-Modus"
            echo "- DNS läuft über Cloudflare (1.1.1.1)"
            echo "- Tracking-Domains sind blockiert"
            echo "- Browser-Daten wurden gelöscht"
            echo "- Hostname wurde randomisiert"
            echo "- Ortungsdienste sind deaktiviert"
            echo "- ProxyChains ist konfiguriert für Terminal-Befehle"
            echo ""
            echo -e "${RED}⚠️  Terminal-Nutzung:${NC}"
            echo "- Normale Befehle: curl ipinfo.io (zeigt echte IP)"
            echo "- Über Tor: proxychains4 curl ipinfo.io"
            echo "- Oder kürzer: pc curl ipinfo.io"
            echo "- Tor-Shell: torshell (alles über Tor)"
            echo ""
            echo -e "${RED}⚠️  Browser:${NC}"
            echo "- WebRTC in deinem Browser deaktivieren"
            echo "- Tor Browser für maximale Anonymität nutzen"
            echo "- JavaScript wenn möglich deaktivieren"
            ;;
            
        *)
            echo -e "${RED}Fehler: Ungültige Option${NC}"
            echo "Verwende: $0 privacy {on|off|status|ultra}"
            exit 1
            ;;
    esac
}

# Security-Analyse-Funktionen
handle_security() {
    case "$1" in
        system|network|dns|privacy|vuln|full)
            "$SCRIPT_DIR/scripts/security_tools.sh" "$1"
            ;;
        "")
            show_banner
            echo -e "${BLUE}🛡️ XXXOS SECURITY TOOLS${NC}"
            echo "========================"
            echo ""
            echo "Verfügbare Security Checks:"
            echo ""
            echo "  system  - System-Sicherheitsanalyse"
            echo "  network - Netzwerk-Sicherheitsscan"
            echo "  dns     - DNS-Sicherheitscheck"
            echo "  privacy - Privacy-Audit"
            echo "  vuln    - Vulnerability-Check"
            echo "  full    - Komplette Sicherheitsanalyse"
            echo ""
            echo "Verwendung: $0 security [check-typ]"
            echo ""
            echo "Tor-Shell Security Tools:"
            echo "  torshell - Öffnet Shell mit Security-Tools über Tor"
            echo "  Verfügbar: nmap, gobuster, sqlmap, hydra, john"
            ;;
        *)
            echo -e "${RED}Fehler: Ungültiger Security Check${NC}"
            echo "Verwende: $0 security [system|network|dns|privacy|vuln|full]"
            exit 1
            ;;
    esac
}

# Erweiterte Privacy-Funktionen
handle_enhance() {
    if [ -z "$1" ]; then
        echo -e "${RED}Fehler: Keine Aktion angegeben${NC}"
        "$PRIVACY_SCRIPT"
        exit 1
    fi
    "$PRIVACY_SCRIPT" "$1"
}

# Gesamtstatus anzeigen
show_overall_status() {
    show_banner
    echo -e "${BLUE}📊 XXXOS PRIVACY STATUS${NC}"
    echo "========================"
    echo ""
    
    # MAC-Adresse
    echo -e "${BLUE}[1] MAC-Adresse${NC}"
    CURRENT_MAC=$(ifconfig en0 | grep ether | awk '{print $2}' 2>/dev/null || echo "Unbekannt")
    echo "    └─ Aktuelle MAC: $CURRENT_MAC"
    echo ""
    
    # Tor Status
    echo -e "${BLUE}[2] Tor-Netzwerk${NC}"
    local is_tor="false"  # Standardwert setzen
    if pgrep -x "tor" > /dev/null 2>&1 || netstat -an | grep -E "\.9050.*LISTEN" > /dev/null 2>&1; then
        echo "    ├─ Service: ✅ Läuft (Port 9050)"
        # Proxy Status
        local proxy_state=$(networksetup -getsocksfirewallproxy "Wi-Fi" 2>/dev/null | grep "Enabled: Yes")
        if [ -n "$proxy_state" ]; then
            echo "    ├─ System-Proxy: ✅ Aktiviert"
        else
            echo "    ├─ System-Proxy: ❌ Deaktiviert"
        fi
        # IP-Check
        is_tor=$(curl -s --connect-timeout 3 https://check.torproject.org/api/ip 2>/dev/null | jq -r '.IsTor' 2>/dev/null || echo "false")
        if [ "$is_tor" = "true" ]; then
            echo "    └─ Verbindung: ✅ Über Tor"
        else
            echo "    └─ Verbindung: ⚠️  Direkt (nicht über Tor)"
        fi
    else
        echo "    └─ Service: ❌ Gestoppt"
    fi
    echo ""
    
    # Firewall Status
    echo -e "${BLUE}[3] Firewall${NC}"
    local fw_status=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null | grep "enabled")
    if [ -n "$fw_status" ]; then
        echo "    ├─ Status: ✅ Aktiviert"
        local stealth=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode 2>/dev/null | grep "enabled")
        if [ -n "$stealth" ]; then
            echo "    └─ Stealth-Modus: ✅ Aktiviert"
        else
            echo "    └─ Stealth-Modus: ❌ Deaktiviert"
        fi
    else
        echo "    └─ Status: ❌ Deaktiviert"
    fi
    echo ""
    
    # DNS Status
    echo -e "${BLUE}[4] DNS-Konfiguration${NC}"
    local dns_servers=$(networksetup -getdnsservers "Wi-Fi" 2>/dev/null | head -2 | tr '\n' ' ')
    if [[ "$dns_servers" == *"1.1.1.1"* ]]; then
        echo "    └─ Server: ✅ Cloudflare (Privacy)"
    elif [[ "$dns_servers" == *"9.9.9.9"* ]]; then
        echo "    └─ Server: ✅ Quad9 (Privacy)"
    elif [[ "$dns_servers" == *"There aren't any"* ]]; then
        echo "    └─ Server: ⚠️  Standard (DHCP)"
    else
        echo "    └─ Server: $dns_servers"
    fi
    echo ""
    
    # Hostname
    echo -e "${BLUE}[5] System-Identifikation${NC}"
    local hostname=$(scutil --get ComputerName 2>/dev/null || echo "Unbekannt")
    echo "    └─ Hostname: $hostname"
    echo ""
    
    # Tracking-Schutz
    echo -e "${BLUE}[6] Tracking-Schutz${NC}"
    if grep -q "# xxxOS Privacy Block List" /etc/hosts 2>/dev/null; then
        local blocked_count=$(grep -c "^0.0.0.0" /etc/hosts 2>/dev/null || echo "0")
        echo "    └─ Hosts-Datei: ✅ Modifiziert ($blocked_count Domains blockiert)"
    else
        echo "    └─ Hosts-Datei: ❌ Standard"
    fi
    echo ""
    
    # Ortungsdienste
    echo -e "${BLUE}[7] Ortungsdienste${NC}"
    if pgrep -x "locationd" > /dev/null 2>&1; then
        echo "    └─ Status: ⚠️  Aktiviert"
    else
        echo "    └─ Status: ✅ Deaktiviert"
    fi
    echo ""
    
    # Privacy-Level Einschätzung
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    local privacy_score=0
    
    # Punkte berechnen (Tor wird sehr stark gewichtet)
    # Tor-Punkte vergeben wenn: Service läuft UND (Verbindung über Tor ODER System-Proxy aktiv)
    local tor_running=$(pgrep -x "tor" > /dev/null 2>&1 || netstat -an | grep -E "\.9050.*LISTEN" > /dev/null 2>&1; echo $?)
    local proxy_active=$(networksetup -getsocksfirewallproxy "Wi-Fi" 2>/dev/null | grep "Enabled: Yes")
    if [ "$tor_running" = "0" ] && ([ "$is_tor" = "true" ] || [ -n "$proxy_active" ]); then
        privacy_score=$((privacy_score + 6))  # Tor ist wichtigster Faktor
    fi
    [ -n "$fw_status" ] && privacy_score=$((privacy_score + 2))
    [[ "$dns_servers" == *"1.1.1.1"* || "$dns_servers" == *"9.9.9.9"* ]] && privacy_score=$((privacy_score + 1))
    grep -q "# xxxOS Privacy Block List" /etc/hosts 2>/dev/null && privacy_score=$((privacy_score + 1))
    ! pgrep -x "locationd" > /dev/null 2>&1 && privacy_score=$((privacy_score + 1))
    
    # Privacy-Level-Anzeige (ohne Tor maximal NIEDRIG)
    local tor_active=false
    [ "$tor_running" = "0" ] && ([ "$is_tor" = "true" ] || [ -n "$proxy_active" ]) && tor_active=true
    
    echo -n "Privacy-Level: "
    if [ "$tor_active" = true ]; then
        # Mit Tor: Volle Skala möglich
        if [ $privacy_score -ge 9 ]; then
            echo -e "${GREEN}⬛⬛⬛⬛⬛ MAXIMUM${NC}"
        elif [ $privacy_score -ge 7 ]; then
            echo -e "${GREEN}⬛⬛⬛⬛⬜ HOCH${NC}"
        elif [ $privacy_score -ge 4 ]; then
            echo -e "${YELLOW}⬛⬛⬛⬜⬜ MITTEL${NC}"
        else
            echo -e "${YELLOW}⬛⬛⬜⬜⬜ NIEDRIG${NC}"
        fi
    else
        # Ohne Tor: Maximal NIEDRIG
        if [ $privacy_score -ge 4 ]; then
            echo -e "${YELLOW}⬛⬛⬜⬜⬜ NIEDRIG${NC} (⚠️ Tor inaktiv)"
        elif [ $privacy_score -ge 2 ]; then
            echo -e "${RED}⬛⬜⬜⬜⬜ MINIMAL${NC}"
        else
            echo -e "${RED}⬜⬜⬜⬜⬜ KEINE${NC}"
        fi
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Detaillierte IP-Informationen anzeigen
show_ip_info() {
    show_banner
    echo -e "${BLUE}📍 IP-INFORMATIONEN${NC}"
    echo "===================="
    echo ""
    
    # Prüfe ob jq installiert ist
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}⚠️  jq ist nicht installiert. Installiere es mit: brew install jq${NC}"
        echo ""
    fi
    
    echo -e "${BLUE}[1] Normale Verbindung${NC}"
    echo "────────────────────────"
    if command -v jq &> /dev/null; then
        curl -s --connect-timeout 10 https://ipapi.co/json/ | jq -r '
        "🌐 IP-Adresse:     " + .ip,
        "🏙️  Stadt:          " + .city,
        "🗺️  Region:         " + .region,
        "🏳️  Land:           " + .country_name + " (" + .country + ")",
        "📍 Koordinaten:    " + (.latitude|tostring) + ", " + (.longitude|tostring),
        "🕐 Zeitzone:       " + .timezone + " (UTC" + .utc_offset + ")",
        "🌐 ISP:            " + .isp'
    else
        echo "IP-Adresse: $(curl -s --connect-timeout 10 http://icanhazip.com)"
    fi
    echo ""
    
    # Tor-Verbindung (falls aktiv)
    if pgrep -x "tor" > /dev/null 2>&1 || netstat -an | grep -E "\.9050.*LISTEN" > /dev/null 2>&1; then
        echo -e "${BLUE}[2] Tor-Verbindung${NC}"
        echo "─────────────────────"
        
        # Prüfe ob ProxyChains funktioniert
        local tor_test=$(proxychains4 -q curl -s --connect-timeout 10 https://check.torproject.org/api/ip 2>/dev/null | jq -r '.IsTor' 2>/dev/null)
        
        if [[ "$tor_test" == "true" ]]; then
            if command -v jq &> /dev/null; then
                proxychains4 -q curl -s --connect-timeout 10 https://ipapi.co/json/ 2>/dev/null | jq -r '
                "🧅 Tor-IP:         " + .ip,
                "🏙️  Stadt:          " + .city,
                "🗺️  Region:         " + .region,
                "🏳️  Land:           " + .country_name + " (" + .country + ")",
                "📍 Koordinaten:    " + (.latitude|tostring) + ", " + (.longitude|tostring),
                "🕐 Zeitzone:       " + .timezone + " (UTC" + .utc_offset + ")",
                "🌐 ISP:            " + .isp'
            else
                echo "Tor-IP: $(proxychains4 -q curl -s --connect-timeout 10 http://icanhazip.com 2>/dev/null)"
            fi
            echo ""
            echo -e "${GREEN}✅ Tor-Anonymisierung aktiv${NC}"
        else
            echo -e "${RED}❌ Tor-Verbindung fehlgeschlagen${NC}"
        fi
    else
        echo -e "${YELLOW}ℹ️  Tor ist nicht aktiv${NC}"
        echo "   Starte Tor mit: $0 tor start"
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${BLUE}💡 Tipps:${NC}"
    echo "• Für maximale Anonymität: Verwende den Tor Browser"
    echo "• Tor-Shell starten: torshell"
    echo "• Privacy-Status prüfen: $0 status"
}

# Interaktives Hauptmenü anzeigen
show_interactive_menu() {
    show_banner
    echo -e "${BLUE}🔧 XXXOS HAUPTMENÜ${NC}"
    echo "=================="
    echo ""
    echo "Verfügbare Funktionen:"
    echo ""
    echo "  1) status           - Gesamtstatus aller Privacy-Funktionen"
    echo "  2) ipinfo           - Detaillierte IP-Informationen anzeigen"
    echo "  3) privacy          - Privacy-Modi (on/off/status/ultra)"
    echo "  4) tor              - Tor-Kontrolle (start/stop/status/full-on/full-off)"
    echo "  5) mac              - MAC-Adresse ändern"
    echo "  6) enhance          - Erweiterte Privacy-Funktionen"
    echo "  7) proxychains      - ProxyChains für Terminal einrichten"
    echo "  8) security         - Security-Analyse-Tools"
    echo "  9) help             - Hilfe anzeigen"
    echo ""
    echo " 99) more             - Weitere Tools und Einstellungen"
    echo "  0) exit             - Beenden"
    echo ""
}

# Interaktive Eingabe verarbeiten
handle_interactive_input() {
    local choice="$1"
    local param="$2"
    
    case "$choice" in
        1|status)
            show_overall_status
            ;;
        2|ipinfo)
            show_ip_info
            ;;
        3|privacy)
            if [ -z "$param" ]; then
                echo ""
                echo "Privacy-Modi:"
                echo "  on     - Basic Privacy (MAC + Tor)"
                echo "  off    - Privacy deaktivieren" 
                echo "  status - Privacy-Status anzeigen"
                echo "  ultra  - Ultra Privacy (alle Funktionen)"
                echo ""
                read -p "Welchen Privacy-Modus möchtest du? (on/off/status/ultra): " param
            fi
            handle_privacy "$param"
            ;;
        4|tor)
            if [ -z "$param" ]; then
                echo ""
                echo "Tor-Aktionen:"
                echo "  start    - Tor starten"
                echo "  stop     - Tor stoppen"
                echo "  status   - Status anzeigen"
                echo "  full-on  - Tor + Proxy aktivieren"
                echo "  full-off - Tor + Proxy deaktivieren"
                echo ""
                read -p "Welche Tor-Aktion möchtest du? (start/stop/status/full-on/full-off): " param
            fi
            handle_tor "$param"
            ;;
        5|mac)
            handle_mac
            ;;
        6|enhance)
            if [ -z "$param" ]; then
                echo ""
                echo "Erweiterte Privacy-Funktionen:"
                echo "  dns-clear      - DNS-Cache leeren"
                echo "  hostname       - Hostname randomisieren"
                echo "  browser-clear  - Browser-Daten löschen"
                echo "  firewall       - Firewall aktivieren"
                echo "  dns-privacy    - Privacy-DNS setzen"
                echo "  block-tracking - Tracking blockieren"
                echo "  all            - Alle Funktionen aktivieren"
                echo ""
                read -p "Welche Funktion möchtest du? (dns-clear/hostname/browser-clear/etc.): " param
            fi
            handle_enhance "$param"
            ;;
        7|proxychains)
            "$PROXYCHAINS_SCRIPT" install
            ;;
        8|security)
            if [ -z "$2" ]; then
                echo ""
                echo "Security-Analyse:"
                echo "  system  - System-Sicherheitsanalyse"
                echo "  network - Netzwerk-Sicherheitsscan"
                echo "  dns     - DNS-Sicherheitscheck"
                echo "  privacy - Privacy-Audit"
                echo "  vuln    - Vulnerability-Check"
                echo "  full    - Komplette Analyse"
                echo ""
                read -p "Welchen Security-Check möchtest du? (system/network/dns/privacy/vuln/full): " param
            else
                param="$2"
            fi
            handle_security "$param"
            ;;
        9|help)
            show_banner
            show_help
            ;;
        99|more)
            handle_sonstiges "$param"
            ;;
        0|exit)
            echo "👋 Auf Wiedersehen!"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Ungültige Eingabe: $choice${NC}"
            echo "Bitte Nummer (0-9, 99) oder Funktionsname eingeben."
            return 1
            ;;
    esac
}

# More-Menü
handle_sonstiges() {
    echo -e "${BLUE}🔧 MORE${NC}"
    echo "============="
    echo ""
    echo "Zusätzliche Tools und Einstellungen:"
    echo ""
    echo "  1) torshell-icon    - Tor-Shell Icon ändern"
    echo "  2) zurück           - Zurück zum Hauptmenü"
    echo ""
    
    if [ -z "$1" ]; then
        read -p "Welche Funktion möchtest du? (1-2): " choice
    else
        choice="$1"
    fi
    
    case "$choice" in
        1|torshell-icon|icon)
            echo ""
            "$SCRIPT_DIR/scripts/torshell_icon.sh"
            ;;
        2|zurück|back)
            return 0
            ;;
        *)
            echo -e "${RED}❌ Ungültige Eingabe: $choice${NC}"
            echo "Bitte Nummer (1-2) eingeben."
            return 1
            ;;
    esac
}

# Hauptprogramm
main() {
    check_scripts
    
    if [ $# -eq 0 ]; then
        while true; do
            show_interactive_menu
            echo ""
            read -p "Funktion wählen (1-9, 99 oder Name): " user_choice
            
            # Parse Eingabe (z.B. "3 ultra" oder "privacy ultra")
            choice=$(echo "$user_choice" | awk '{print $1}')
            param=$(echo "$user_choice" | awk '{print $2}')
            
            # Exit-Befehle behandeln
            if [[ "$choice" == "0" || "$choice" == "exit" || "$choice" == "quit" ]]; then
                echo "Auf Wiedersehen!"
                exit 0
            fi
            
            echo ""
            handle_interactive_input "$choice" "$param"
            
            echo ""
            echo "Drücke Enter um zum Hauptmenü zurückzukehren..."
            read -r
        done
    fi
    
    case "$1" in
        status)
            show_overall_status
            ;;
        ipinfo)
            show_ip_info
            ;;
        tor)
            handle_tor "$2"
            ;;
        mac)
            handle_mac
            ;;
        privacy)
            handle_privacy "$2"
            ;;
        enhance)
            handle_enhance "$2"
            ;;
        proxychains)
            "$PROXYCHAINS_SCRIPT" install
            ;;
        security)
            handle_security "$2"
            ;;
        help|-h|--help)
            show_banner
            show_help
            ;;
        *)
            echo -e "${RED}Fehler: Unbekannter Befehl '$1'${NC}"
            echo "Verwende: $0 help für Hilfe"
            exit 1
            ;;
    esac
}

# Skript ausführen
main "$@"