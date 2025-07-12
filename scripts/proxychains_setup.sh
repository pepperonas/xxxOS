#!/bin/bash

# ProxyChains Setup für xxxOS
# Konfiguriert ProxyChains für Tor-Nutzung

# ProxyChains Config Pfad (Homebrew auf Apple Silicon)
if [ -d "/opt/homebrew" ]; then
    PROXYCHAINS_CONFIG="/opt/homebrew/etc/proxychains.conf"
else
    PROXYCHAINS_CONFIG="/usr/local/etc/proxychains.conf"
fi

# ProxyChains installieren falls nicht vorhanden
install_proxychains() {
    if ! command -v proxychains4 &> /dev/null; then
        echo "📦 Installiere ProxyChains..."
        brew install proxychains-ng
    else
        echo "✅ ProxyChains bereits installiert"
    fi
}

# ProxyChains für Tor konfigurieren
configure_proxychains() {
    echo "⚙️  Konfiguriere ProxyChains für Tor..."
    
    # Backup erstellen falls Datei existiert (ohne Cache-Helper!)
    if [ -f "$PROXYCHAINS_CONFIG" ]; then
        sudo cp "$PROXYCHAINS_CONFIG" "$PROXYCHAINS_CONFIG.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
    fi
    
    # Konfiguration erstellen (direkt ohne Cache-Helper)
    sudo tee "$PROXYCHAINS_CONFIG" > /dev/null << 'EOF'
# ProxyChains-4 Konfiguration für xxxOS
# Optimiert für Tor-Nutzung mit IPv6-Schutz

# Quiet mode (weniger Output)
quiet_mode

# Dynamic chain - alle Proxies der Reihe nach, tote überspringen
dynamic_chain

# Proxy DNS requests - wichtig für Anonymität!
proxy_dns

# IPv6 komplett deaktivieren für bessere Tor-Kompatibilität
# Verhindert IPv6-Leaks die ProxyChains umgehen
localnet 127.0.0.0/255.0.0.0
localnet 10.0.0.0/255.0.0.0
localnet 172.16.0.0/255.240.0.0
localnet 192.168.0.0/255.255.0.0

# TCP connection timeout in milliseconds
tcp_connect_time_out 8000
tcp_read_time_out 15000

# Tor SOCKS5 Proxy
[ProxyList]
socks5 127.0.0.1 9050
EOF

    echo "✅ ProxyChains konfiguriert für Tor"
}

# Shell-Aliase einrichten
setup_aliases() {
    echo "🔧 Richte Shell-Aliase ein..."
    
    # Aliase definieren
    ALIASES='
# xxxOS ProxyChains Aliase
alias pc="proxychains4"
alias pccurl="proxychains4 curl"
alias pcwget="proxychains4 wget"
alias pcgit="proxychains4 git"
alias pcnpm="proxychains4 npm"
alias pcssh="proxychains4 ssh"
alias pcping="proxychains4 ping"

# IP-Check Aliase - IPv4 erzwingen
alias checkip="curl -4 ipinfo.io"
alias torip="proxychains4 curl -4 ipinfo.io"
alias torcheck="proxychains4 curl -4 https://check.torproject.org/api/ip"

# Tor-Terminal - ALLE Befehle über Tor  
alias torshell="PROXYCHAINS_QUIET_MODE=1 proxychains4 zsh"
'
    
    # Für Zsh
    if [ -f ~/.zshrc ]; then
        if ! grep -q "xxxOS ProxyChains Aliase" ~/.zshrc; then
            echo "$ALIASES" >> ~/.zshrc
            echo "✅ Aliase zu ~/.zshrc hinzugefügt"
        else
            echo "ℹ️  Aliase bereits in ~/.zshrc vorhanden"
        fi
    fi
    
    # Für Bash
    if [ -f ~/.bash_profile ]; then
        if ! grep -q "xxxOS ProxyChains Aliase" ~/.bash_profile; then
            echo "$ALIASES" >> ~/.bash_profile
            echo "✅ Aliase zu ~/.bash_profile hinzugefügt"
        else
            echo "ℹ️  Aliase bereits in ~/.bash_profile vorhanden"
        fi
    fi
    
    echo ""
    echo "📝 Neue Aliase:"
    echo "  pc         - ProxyChains Kurzform"
    echo "  pccurl     - curl über Tor"
    echo "  pcgit      - git über Tor"
    echo "  torip      - Zeige Tor IP"
    echo "  torcheck   - Prüfe Tor-Verbindung"
    echo "  torshell   - Neue Shell mit allem über Tor"
    echo ""
    echo "⚠️  Neue Terminal-Session öffnen oder 'source ~/.zshrc' ausführen!"
}

# Test-Funktion
test_proxychains() {
    echo ""
    echo "🧪 Teste ProxyChains..."
    
    # Normale IP
    echo "Deine normale IP:"
    curl -s ipinfo.io | jq -r '.ip' 2>/dev/null || curl -s ipinfo.io | grep -o '"ip":"[^"]*' | cut -d'"' -f4
    
    # Tor IP
    echo ""
    echo "Deine Tor IP:"
    proxychains4 -q curl -s ipinfo.io | jq -r '.ip' 2>/dev/null || proxychains4 -q curl -s ipinfo.io | grep -o '"ip":"[^"]*' | cut -d'"' -f4
    
    # Tor-Status
    echo ""
    echo "Tor-Status:"
    local tor_status=$(proxychains4 -q curl -s https://check.torproject.org/api/ip | jq -r '.IsTor' 2>/dev/null)
    if [ "$tor_status" = "true" ]; then
        echo "✅ Du bist über Tor verbunden!"
    else
        echo "❌ Keine Tor-Verbindung!"
    fi
}

# Hauptfunktion
main() {
    case "$1" in
        install)
            install_proxychains
            configure_proxychains
            setup_aliases
            test_proxychains
            ;;
        config)
            configure_proxychains
            ;;
        aliases)
            setup_aliases
            ;;
        test)
            test_proxychains
            ;;
        *)
            echo "🔗 ProxyChains Setup für xxxOS"
            echo "==============================="
            echo ""
            echo "Usage: $0 {install|config|aliases|test}"
            echo ""
            echo "  install - Vollständige Installation und Konfiguration"
            echo "  config  - Nur ProxyChains konfigurieren"
            echo "  aliases - Nur Shell-Aliase einrichten"
            echo "  test    - ProxyChains testen"
            ;;
    esac
}

main "$1"