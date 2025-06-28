#!/bin/bash

# xxxOS Tor Shell Wrapper
# Startet eine Shell mit echtem Tor-Routing

echo "🧅 Starte Tor-Shell..."

# Prüfe ob Tor läuft
if ! lsof -i :9050 > /dev/null 2>&1; then
    echo "⚠️  Tor läuft nicht! Starte mit: ./xxxos tor start"
    exit 1
fi

# Teste Tor
TOR_IP=$(proxychains4 -q curl -s https://check.torproject.org/api/ip 2>/dev/null | grep -o '"IP":"[^"]*' | cut -d'"' -f4)
echo "✅ Tor-IP: $TOR_IP"
echo ""

# Erstelle Wrapper-Skripte für alle Befehle
WRAPPER_DIR="/tmp/xxxos_tor_wrappers_$$"
mkdir -p "$WRAPPER_DIR"

# curl wrapper
cat > "$WRAPPER_DIR/curl" << 'EOF'
#!/bin/bash
exec proxychains4 -q /usr/bin/curl "$@"
EOF

# git wrapper  
cat > "$WRAPPER_DIR/git" << 'EOF'
#!/bin/bash
exec proxychains4 -q /usr/bin/git "$@"
EOF

# wget wrapper
cat > "$WRAPPER_DIR/wget" << 'EOF'
#!/bin/bash
exec proxychains4 -q /usr/bin/wget "$@"
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

echo "🔥 Tor-Shell aktiv!"
echo "Teste mit: checkip"
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