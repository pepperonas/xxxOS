#!/bin/bash

# xxxOS Tor Shell Wrapper
# Startet eine Shell mit echtem Tor-Routing

echo "🧅 Starte Tor-Shell..."

# Prüfe ob Tor läuft
if ! lsof -i :9050 > /dev/null 2>&1; then
    echo "⚠️  Tor läuft nicht! Starte mit: ./xxxos tor start"
    exit 1
fi

# IPv6-Check und Warnung
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ipv6_status=$("$SCRIPT_DIR/ipv6_disable.sh" status 2>/dev/null | grep -q "vollständig deaktiviert" && echo "disabled" || echo "enabled")

if [ "$ipv6_status" = "enabled" ]; then
    echo "⚠️  IPv6 ist aktiv - Dies kann zu Tor-Leaks führen!"
    echo "   Tipp: IPv6 deaktivieren mit: $SCRIPT_DIR/ipv6_disable.sh disable"
    echo ""
fi

# Teste Tor mit IPv4
TOR_IP=$(proxychains4 -q curl -4 -s https://check.torproject.org/api/ip 2>/dev/null | grep -o '"IP":"[^"]*' | cut -d'"' -f4)
echo "✅ Tor-IP: $TOR_IP"
echo ""

# Erstelle Wrapper-Skripte für alle Befehle
WRAPPER_DIR="/tmp/xxxos_tor_wrappers_$$"
mkdir -p "$WRAPPER_DIR"

# curl wrapper - IPv6 deaktiviert für Tor-Kompatibilität
cat > "$WRAPPER_DIR/curl" << 'EOF'
#!/bin/bash
exec proxychains4 -q /usr/bin/curl -4 "$@"
EOF

# git wrapper  
cat > "$WRAPPER_DIR/git" << 'EOF'
#!/bin/bash
exec proxychains4 -q /usr/bin/git "$@"
EOF

# wget wrapper - IPv6 deaktiviert für Tor-Kompatibilität
cat > "$WRAPPER_DIR/wget" << 'EOF'
#!/bin/bash
exec proxychains4 -q /usr/bin/wget --inet4-only "$@"
EOF

# npm wrapper
cat > "$WRAPPER_DIR/npm" << 'EOF'
#!/bin/bash
exec proxychains4 -q /usr/bin/npm "$@"
EOF

# ssh wrapper
cat > "$WRAPPER_DIR/ssh" << 'EOF'
#!/bin/bash
exec proxychains4 -q /usr/bin/ssh "$@"
EOF

# traceroute wrapper
cat > "$WRAPPER_DIR/traceroute" << 'EOF'
#!/bin/bash
exec proxychains4 -q /usr/sbin/traceroute "$@"
EOF

# nslookup wrapper
cat > "$WRAPPER_DIR/nslookup" << 'EOF'
#!/bin/bash
exec proxychains4 -q /usr/bin/nslookup "$@"
EOF

# dig wrapper
cat > "$WRAPPER_DIR/dig" << 'EOF'
#!/bin/bash
exec proxychains4 -q /usr/bin/dig "$@"
EOF

# telnet wrapper
cat > "$WRAPPER_DIR/telnet" << 'EOF'
#!/bin/bash
exec proxychains4 -q /usr/bin/telnet "$@"
EOF

# === DEFENSIVE SECURITY TOOLS ===
# Nur für legitime Sicherheitsanalysen verwenden!

# nmap wrapper (Netzwerk-Scanning für Sicherheitsaudits)
cat > "$WRAPPER_DIR/nmap" << 'EOF'
#!/bin/bash
echo "⚠️  NMAP über Tor - Nur für autorisierte Sicherheitsaudits!"
exec proxychains4 -q /usr/local/bin/nmap "$@"
EOF

# gobuster wrapper (Directory/File Enumeration)
cat > "$WRAPPER_DIR/gobuster" << 'EOF'
#!/bin/bash
echo "⚠️  Gobuster über Tor - Nur für autorisierte Penetrationstests!"
exec proxychains4 -q gobuster "$@"
EOF

# sqlmap wrapper (SQL Injection Testing)
cat > "$WRAPPER_DIR/sqlmap" << 'EOF'
#!/bin/bash
echo "⚠️  SQLMap über Tor - Nur für autorisierte Vulnerability Assessments!"
exec proxychains4 -q sqlmap "$@"
EOF

# hydra wrapper (Password Testing - nur für eigene Systeme)
cat > "$WRAPPER_DIR/hydra" << 'EOF'
#!/bin/bash
echo "⚠️  Hydra über Tor - Nur für autorisierte Sicherheitstests eigener Systeme!"
exec proxychains4 -q hydra "$@"
EOF

# john wrapper (Password Recovery)
cat > "$WRAPPER_DIR/john" << 'EOF'
#!/bin/bash
echo "ℹ️  John the Ripper - Password Recovery Tool"
exec /usr/local/bin/john "$@"
EOF

# Mache alle ausführbar
chmod +x "$WRAPPER_DIR"/*

# Erstelle .zshrc für Tor-Session
cat > "$WRAPPER_DIR/.zshrc" << 'EOF'
# Tor-Shell Konfiguration
export PS1="🧅[TOR] %1~ %# "

# Hilfsbefehle
alias checkip='curl https://check.torproject.org/api/ip'
alias myip='curl -s http://icanhazip.com'
alias normalip='echo "Normale IP:" && /usr/bin/curl -s http://icanhazip.com'

# Security Tools Hilfe
alias sechelp='echo "Verfügbare Security Tools:"; echo "🔍 nmap - Netzwerk-Scanning"; echo "📁 gobuster - Directory Enumeration"; echo "💉 sqlmap - SQL Injection Testing"; echo "🔐 hydra - Password Testing"; echo "🔓 john - Password Recovery"; echo ""; echo "⚠️  Nur für autorisierte Tests verwenden!"'

# Defensive Security Aliases
alias vuln-scan='echo "Starte Vulnerability Scan..."; nmap -sV --script vuln'
alias port-scan='nmap -sS -O'
alias web-enum='gobuster dir -w /usr/share/wordlists/dirb/common.txt -u'

echo "🔥 Tor-Shell mit Security Tools aktiv!"
echo "Teste mit: checkip | Hilfe: sechelp"
echo "⚠️  Nur für autorisierte Sicherheitstests verwenden!"
echo ""
EOF

# Erstelle .zshenv für PATH-Setup
cat > "$WRAPPER_DIR/.zshenv" << EOF
export PATH="$WRAPPER_DIR:\$PATH"
EOF

# Starte Shell mit Tor-Wrappern
echo "Starte Tor-Shell mit Wrapper-PATH..."
cd "$WRAPPER_DIR"
ZDOTDIR="$WRAPPER_DIR" exec zsh

# Cleanup (wird nur erreicht wenn Shell beendet wird)
rm -rf "$WRAPPER_DIR" 2>/dev/null