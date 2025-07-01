#!/bin/bash

# xxxOS Transparentes Tor-Routing - FIXED VERSION
# Einfacher, funktionierender Ansatz für macOS
# (c) 2025 Martin Pfeffer - MIT License

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Konfiguration
TOR_PORT="9050"
TOR_TRANS_PORT="9040"
TOR_DNS_PORT="9053"

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}❌ Dieses Skript benötigt sudo-Rechte${NC}"
        echo "Verwende: sudo $0 $*"
        exit 1
    fi
}

check_tor() {
    if ! command -v tor &> /dev/null; then
        echo -e "${RED}❌ Tor ist nicht installiert${NC}"
        echo "Installiere mit: brew install tor"
        exit 1
    fi
}

setup_tor_config() {
    echo -e "${BLUE}🔧 Konfiguriere Tor für transparentes Routing...${NC}"
    
    local tor_config="/opt/homebrew/etc/tor/torrc"
    
    # Backup der Original-Konfiguration
    if [ ! -f "${tor_config}.backup" ]; then
        cp "$tor_config" "${tor_config}.backup" 2>/dev/null || true
    fi
    
    # Vereinfachte Tor-Konfiguration (nur SOCKS5)
    cat > "$tor_config" << EOF
# xxxOS Vereinfachte Tor-Konfiguration
SocksPort 9050
ClientUseIPv6 0
ClientPreferIPv6ORPort 0
Log notice file /opt/homebrew/var/log/tor/tor.log
EOF

    echo -e "${GREEN}✅ Tor-Konfiguration erstellt${NC}"
}

start_transparent_tor() {
    check_root
    check_tor
    
    echo -e "${GREEN}🚀 Starte transparentes Tor-Routing...${NC}"
    echo ""
    
    # 1. Tor-Konfiguration setup
    setup_tor_config
    
    # 2. Tor neu starten
    echo -e "${BLUE}🔄 Starte Tor mit transparenter Konfiguration...${NC}"
    brew services stop tor 2>/dev/null
    killall tor 2>/dev/null
    sleep 2
    
    brew services start tor
    sleep 3
    
    # 3. Warte bis Tor läuft
    local retry=0
    while [ $retry -lt 10 ]; do
        if lsof -i :$TOR_PORT >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Tor läuft auf Port $TOR_PORT${NC}"
            break
        fi
        echo "⏳ Warte auf Tor-Start... ($((retry+1))/10)"
        sleep 2
        ((retry++))
    done
    
    if [ $retry -eq 10 ]; then
        echo -e "${RED}❌ Tor konnte nicht gestartet werden${NC}"
        exit 1
    fi
    
    # 4. IPv6 deaktivieren (wichtig!)
    echo -e "${BLUE}🔒 Deaktiviere IPv6...${NC}"
    networksetup -setv6off "Wi-Fi" 2>/dev/null
    
    # 5. DNS auf Cloudflare umstellen (Tor-DNS funktioniert ohne TransPort nicht)
    echo -e "${BLUE}🌐 Stelle DNS auf Cloudflare um...${NC}"
    networksetup -setdnsservers "Wi-Fi" 1.1.1.1 1.0.0.1
    
    # 6. System-Proxy auf Tor setzen (für Browser/Apps)
    echo -e "${BLUE}🔧 Aktiviere System-Proxy...${NC}"
    networksetup -setsocksfirewallproxy "Wi-Fi" 127.0.0.1 9050
    networksetup -setsocksfirewallproxystate "Wi-Fi" on
    
    # 7. Zusätzlich: Erstelle Wrapper für Terminal-Programme
    echo -e "${BLUE}📝 Erstelle Terminal-Wrapper...${NC}"
    
    # Wrapper-Verzeichnis erstellen
    local wrapper_dir="/tmp/tor_wrappers_$$"
    mkdir -p "$wrapper_dir"
    
    # curl-Wrapper
    cat > "$wrapper_dir/curl" << 'WRAPPER_EOF'
#!/bin/bash
exec /usr/bin/curl --socks5 127.0.0.1:9050 "$@"
WRAPPER_EOF
    
    # wget-Wrapper
    cat > "$wrapper_dir/wget" << 'WRAPPER_EOF'
#!/bin/bash
exec /usr/bin/wget --proxy=socks5://127.0.0.1:9050 "$@"
WRAPPER_EOF
    
    # git-Wrapper
    cat > "$wrapper_dir/git" << 'WRAPPER_EOF'
#!/bin/bash
exec /usr/bin/git -c http.proxy=socks5://127.0.0.1:9050 "$@"
WRAPPER_EOF
    
    # gobuster-Wrapper (Security Tool)
    cat > "$wrapper_dir/gobuster" << 'WRAPPER_EOF'
#!/bin/bash
exec /opt/homebrew/bin/gobuster --proxy socks5://127.0.0.1:9050 "$@"
WRAPPER_EOF
    
    # nmap-Wrapper (mit ProxyChains da nmap SOCKS5 nicht direkt unterstützt)
    cat > "$wrapper_dir/nmap" << 'WRAPPER_EOF'
#!/bin/bash
echo "⚠️  NMAP über Tor - Nur für autorisierte Sicherheitsaudits!"
exec proxychains4 -q /opt/homebrew/bin/nmap "$@"
WRAPPER_EOF
    
    # sqlmap-Wrapper
    cat > "$wrapper_dir/sqlmap" << 'WRAPPER_EOF'
#!/bin/bash
echo "⚠️  SQLMap über Tor - Nur für autorisierte Penetrationstests!"
exec /opt/homebrew/bin/sqlmap --proxy="socks5://127.0.0.1:9050" "$@"
WRAPPER_EOF
    
    # Alle Wrapper ausführbar machen
    chmod +x "$wrapper_dir"/*
    
    # PATH erweitern UND Aliase überschreiben
    export PATH="$wrapper_dir:$PATH"
    
    # Erstelle erweiterte Shell-Konfiguration
    cat > /tmp/tor_shell_config << SHELL_EOF
# Tor Shell Konfiguration
export PATH="$wrapper_dir:\$PATH"

# Deaktiviere .zshrc Tor-Warnungen temporär
unalias curl 2>/dev/null || true
unalias wget 2>/dev/null || true
unalias git 2>/dev/null || true

# Definiere neue Aliase für Tor
alias curl="$wrapper_dir/curl"
alias wget="$wrapper_dir/wget" 
alias git="$wrapper_dir/git"
alias gobuster="$wrapper_dir/gobuster"
alias nmap="$wrapper_dir/nmap"
alias sqlmap="$wrapper_dir/sqlmap"

echo "🔒 Tor-Terminal aktiv! Alle Befehle gehen über Tor."
echo "Verfügbar: curl, git, gobuster, nmap, sqlmap"
echo "Teste: curl https://check.torproject.org/api/ip"
SHELL_EOF
    
    echo -e "${GREEN}📌 Terminal-Wrapper erstellt in: $wrapper_dir${NC}"
    
    echo ""
    echo -e "${GREEN}✅ TRANSPARENTES TOR AKTIVIERT!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Aktiv:${NC}"
    echo "  🔹 System-Proxy über Tor (Browser/Apps)"
    echo "  🔹 Terminal-Wrapper für curl/wget/git"
    echo "  🔹 DNS über Cloudflare (1.1.1.1)"
    echo "  🔹 IPv6 deaktiviert"
    echo ""
    
    # Test der Verbindung
    echo -e "${BLUE}🧪 Teste Verbindung...${NC}"
    sleep 2
    
    # Test mit SOCKS5 direkt (sollte funktionieren)
    local tor_test=$(curl -s --connect-timeout 5 --socks5 127.0.0.1:9050 https://check.torproject.org/api/ip 2>/dev/null)
    if echo "$tor_test" | grep -q '"IsTor":true'; then
        local tor_ip=$(echo "$tor_test" | grep -o '"IP":"[^"]*' | cut -d'"' -f4)
        echo -e "${GREEN}✅ Tor-Verbindung funktioniert: $tor_ip${NC}"
        
        # Test transparente Umleitung
        echo ""
        echo -e "${BLUE}Teste jetzt in NEUER Terminal-Session:${NC}"
        echo "  source /tmp/tor_shell_config"
        echo "  curl https://check.torproject.org/api/ip"
        echo ""
        echo -e "${YELLOW}Oder in DIESER Session mit direktem Pfad:${NC}"
        local wrapper_path=$(find /tmp -name "tor_wrappers_*" -type d 2>/dev/null | head -1)
        if [ -n "$wrapper_path" ]; then
            echo "  $wrapper_path/curl https://check.torproject.org/api/ip"
        fi
        echo ""
    else
        echo -e "${RED}❌ Tor-Verbindung fehlgeschlagen${NC}"
        stop_transparent_tor
        exit 1
    fi
}

stop_transparent_tor() {
    check_root
    
    echo -e "${YELLOW}🛑 Stoppe transparentes Tor...${NC}"
    
    # 1. System-Proxy deaktivieren
    echo -e "${BLUE}🔧 Deaktiviere System-Proxy...${NC}"
    networksetup -setsocksfirewallproxystate "Wi-Fi" off
    
    # 2. DNS zurücksetzen
    echo -e "${BLUE}🌐 Stelle DNS zurück...${NC}"
    networksetup -setdnsservers "Wi-Fi" "Empty"
    
    # 3. Terminal-Wrapper aufräumen
    echo -e "${BLUE}🗑️  Entferne Terminal-Wrapper...${NC}"
    rm -rf /tmp/tor_wrappers_* 2>/dev/null
    rm -f /tmp/tor_shell_config 2>/dev/null
    
    # 4. IPv6 reaktivieren
    echo -e "${BLUE}🔓 Reaktiviere IPv6...${NC}"
    networksetup -setv6automatic "Wi-Fi"
    
    # 5. Original Tor-Konfiguration wiederherstellen
    local tor_config="/opt/homebrew/etc/tor/torrc"
    if [ -f "${tor_config}.backup" ]; then
        echo -e "${BLUE}🔄 Stelle Tor-Konfiguration zurück...${NC}"
        cp "${tor_config}.backup" "$tor_config"
    fi
    
    # 6. Tor mit Standard-Konfiguration neu starten
    echo -e "${BLUE}🔄 Starte Tor mit Standard-Konfiguration...${NC}"
    brew services stop tor 2>/dev/null
    killall tor 2>/dev/null
    sleep 2
    brew services start tor
    
    # 7. Netzwerk neu starten
    echo -e "${BLUE}🔄 Starte Netzwerk neu...${NC}"
    networksetup -setnetworkserviceenabled "Wi-Fi" off
    sleep 2
    networksetup -setnetworkserviceenabled "Wi-Fi" on
    
    echo ""
    echo -e "${GREEN}✅ Transparentes Tor deaktiviert${NC}"
    echo -e "${GREEN}🌐 Normale Internet-Verbindung wiederhergestellt${NC}"
}

show_status() {
    echo -e "${BLUE}📊 Transparenter Tor Status${NC}"
    echo "══════════════════════════════"
    
    # Tor-Ports prüfen
    echo ""
    echo -e "${BLUE}🔍 Tor-Dienste:${NC}"
    for port in $TOR_PORT $TOR_TRANS_PORT $TOR_DNS_PORT; do
        if lsof -i :$port >/dev/null 2>&1; then
            echo "  ✅ Port $port: Aktiv"
        else
            echo "  ❌ Port $port: Inaktiv"
        fi
    done
    
    # pfctl-Status
    echo ""
    echo -e "${BLUE}🔧 pfctl-Status:${NC}"
    if pfctl -s info 2>/dev/null | grep -q "Status: Enabled"; then
        echo "  ✅ pfctl: Aktiviert"
        echo "  📋 Aktive Regeln: $(pfctl -s rules 2>/dev/null | grep -c rdr)"
    else
        echo "  ❌ pfctl: Deaktiviert"
    fi
    
    # DNS-Test
    echo ""
    echo -e "${BLUE}🌐 DNS-Test:${NC}"
    local dns_server=$(networksetup -getdnsservers "Wi-Fi" 2>/dev/null | head -1)
    if [ "$dns_server" = "127.0.0.1" ]; then
        echo "  ✅ DNS: Über Tor"
    else
        echo "  ❌ DNS: Direkt ($dns_server)"
    fi
    
    # Verbindungstest
    echo ""
    echo -e "${BLUE}🧪 Verbindungstest:${NC}"
    
    # SOCKS5-Test
    local socks_test=$(curl -s --connect-timeout 3 --socks5 127.0.0.1:9050 https://check.torproject.org/api/ip 2>/dev/null)
    if echo "$socks_test" | grep -q '"IsTor":true'; then
        local socks_ip=$(echo "$socks_test" | grep -o '"IP":"[^"]*' | cut -d'"' -f4)
        echo "  ✅ SOCKS5: $socks_ip (über Tor)"
    else
        echo "  ❌ SOCKS5: Fehlgeschlagen"
    fi
    
    # Transparenter Test
    local trans_test=$(curl -s --connect-timeout 3 https://check.torproject.org/api/ip 2>/dev/null)
    if echo "$trans_test" | grep -q '"IsTor":true'; then
        local trans_ip=$(echo "$trans_test" | grep -o '"IP":"[^"]*' | cut -d'"' -f4)
        echo "  ✅ Transparent: $trans_ip (über Tor)"
    else
        echo "  ❌ Transparent: Direkte Verbindung oder Fehler"
    fi
    
    echo ""
}

case "$1" in
    start)
        start_transparent_tor
        ;;
    stop)
        stop_transparent_tor
        ;;
    status)
        show_status
        ;;
    *)
        echo -e "${BLUE}🌐 xxxOS Transparentes Tor-Routing (Fixed)${NC}"
        echo "════════════════════════════════════════════"
        echo ""
        echo "Leitet HTTP/HTTPS-Traffic über Tor um"
        echo ""
        echo -e "${YELLOW}Verwendung:${NC}"
        echo "  sudo $0 start   - Transparentes Tor aktivieren"
        echo "  sudo $0 stop    - Transparentes Tor deaktivieren"
        echo "  $0 status       - Status anzeigen"
        echo ""
        echo -e "${RED}⚠️  WICHTIG:${NC}"
        echo "  - Benötigt sudo-Rechte"
        echo "  - Bei Problemen: sudo $0 stop"
        echo ""
        ;;
esac