#!/usr/bin/env bash

# xxxOS Simple TorShell
# Einfache, funktionierende TorShell mit IPv4-Schutz
# (c) 2025 Martin Pfeffer - MIT License

echo "🧅 Starte TorShell..."

# Prüfe ob Tor läuft
if ! lsof -i :9050 > /dev/null 2>&1; then
    echo "⚠️  Tor läuft nicht! Starte mit: ./xxxos tor start"
    exit 1
fi

# Teste Tor-Verbindung schnell
TOR_TEST=$(curl -4 -s --connect-timeout 3 --socks5 localhost:9050 https://check.torproject.org/api/ip 2>/dev/null)
if echo "$TOR_TEST" | grep -q '"IsTor":true'; then
    TOR_IP=$(echo "$TOR_TEST" | grep -o '"IP":"[^"]*' | cut -d'"' -f4)
    echo "✅ Tor aktiv! IP: $TOR_IP"
else
    echo "❌ Tor-Verbindung fehlgeschlagen!"
    exit 1
fi

# Definiere Tor-Funktionen - DIREKT SOCKS5 mit Timeouts
curl() { /usr/bin/curl --socks5 localhost:9050 -4 --connect-timeout 10 --max-time 30 "$@"; }
wget() { /usr/bin/wget --proxy=socks5://localhost:9050 --inet4-only --timeout=30 "$@"; }
git() { /usr/bin/git -c http.proxy=socks5://localhost:9050 "$@"; }
ssh() { /usr/bin/ssh -o ProxyCommand="nc -X 5 -x localhost:9050 %h %p" "$@"; }
ping() { echo "⚠️  ping funktioniert nicht über SOCKS5"; }
dig() { /usr/bin/dig @127.0.0.1 -p 9053 "$@"; }
nslookup() { /usr/bin/nslookup "$@" 127.0.0.1; }
nc() { /usr/bin/nc -X 5 -x localhost:9050 "$@"; }
telnet() { /usr/bin/nc -X 5 -x localhost:9050 "$@"; }

# Hilfs-Funktionen
checkip() { 
    echo "🧅 Tor-IP Check:"
    curl -s https://check.torproject.org/api/ip | jq . 2>/dev/null || curl -s https://check.torproject.org/api/ip
}

realip() {
    echo "🌐 Echte IP (ohne Tor):"
    /usr/bin/curl -4 -s https://check.torproject.org/api/ip | jq . 2>/dev/null || /usr/bin/curl -4 -s https://check.torproject.org/api/ip
}

torip() {
    curl -s http://icanhazip.com
}

# Exportiere Funktionen für Sub-Shells
export -f curl wget git ssh ping dig nslookup nc telnet checkip realip torip

# Setze Prompt
export PS1="🧅 [TOR] %~ %# "

# Erstelle temporäre .zshrc für TorShell
TORSHELL_DIR="/tmp/torshell_$$"
mkdir -p "$TORSHELL_DIR"

cat > "$TORSHELL_DIR/.zshrc" << 'EOF'
# TorShell-spezifische Konfiguration
curl() { /usr/bin/curl --socks5 localhost:9050 -4 "$@"; }
wget() { /usr/bin/wget --proxy=socks5://localhost:9050 --inet4-only "$@"; }
git() { /usr/bin/git -c http.proxy=socks5://localhost:9050 "$@"; }
ssh() { /usr/bin/ssh -o ProxyCommand="nc -X 5 -x localhost:9050 %h %p" "$@"; }
nc() { /usr/bin/nc -X 5 -x localhost:9050 "$@"; }

# SECURITY TOOLS über Tor (nur für autorisierte Tests!)
sqlmap() { 
    echo "⚠️  SQLMap über Tor - Nur für autorisierte Penetrationstests!"
    /opt/homebrew/bin/sqlmap --proxy="socks5://localhost:9050" "$@"
}
nmap() { 
    echo "⚠️  NMAP über Tor - Nur für autorisierte Sicherheitsaudits!"
    proxychains4 -q /opt/homebrew/bin/nmap "$@"
}
gobuster() { 
    echo "⚠️  Gobuster über Tor - Nur für autorisierte Tests!"
    /opt/homebrew/bin/gobuster --proxy="socks5://localhost:9050" "$@"
}
nikto() { 
    echo "⚠️  Nikto über Tor - Nur für autorisierte Scans!"
    /opt/homebrew/bin/nikto -useproxy socks5://localhost:9050 "$@"
}

checkip() { 
    echo "🧅 Tor-IP Check:"
    /usr/bin/curl --socks5 localhost:9050 -4 --connect-timeout 5 --max-time 10 -s https://check.torproject.org/api/ip | jq . 2>/dev/null || /usr/bin/curl --socks5 localhost:9050 -4 --connect-timeout 5 --max-time 10 -s https://check.torproject.org/api/ip
}

realip() {
    echo "🌐 Echte IP (ohne Tor):"
    /usr/bin/curl -4 --connect-timeout 5 --max-time 10 -s https://check.torproject.org/api/ip | jq . 2>/dev/null || /usr/bin/curl -4 --connect-timeout 5 --max-time 10 -s https://check.torproject.org/api/ip
}

torip() { /usr/bin/curl --socks5 localhost:9050 -4 --connect-timeout 5 --max-time 10 -s http://icanhazip.com; }

export PS1="🧅 [TOR] %~ %# "

echo ""
echo "🔒 TorShell aktiv! Teste: curl https://check.torproject.org/api/ip"
EOF

# Starte Shell mit TorShell-Konfiguration
cd "$TORSHELL_DIR"
ZDOTDIR="$TORSHELL_DIR" exec zsh

# Cleanup
rm -rf "$TORSHELL_DIR" 2>/dev/null