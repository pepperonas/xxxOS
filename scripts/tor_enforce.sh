#!/usr/bin/env bash

# xxxOS Tor Enforcement
# Erzwingt Tor für alle Netzwerk-Befehle systemweit
# (c) 2025 Martin Pfeffer - MIT License

echo "🔒 Erzwinge Tor für alle Netzwerk-Befehle..."

# Erstelle Tor-Wrapper für alle kritischen Befehle
WRAPPER_DIR="/usr/local/bin"

# curl Wrapper
sudo tee "$WRAPPER_DIR/curl_tor" > /dev/null << 'EOF'
#!/bin/bash
exec /usr/bin/curl --socks5 localhost:9050 -4 "$@"
EOF
sudo chmod +x "$WRAPPER_DIR/curl_tor"

# wget Wrapper  
sudo tee "$WRAPPER_DIR/wget_tor" > /dev/null << 'EOF'
#!/bin/bash
exec /usr/bin/wget --proxy=socks5://localhost:9050 --inet4-only "$@"
EOF
sudo chmod +x "$WRAPPER_DIR/wget_tor"

# git Wrapper
sudo tee "$WRAPPER_DIR/git_tor" > /dev/null << 'EOF'
#!/bin/bash
exec /usr/bin/git -c http.proxy=socks5://localhost:9050 "$@"
EOF
sudo chmod +x "$WRAPPER_DIR/git_tor"

echo "✅ Tor-Wrapper erstellt:"
echo "  curl_tor - curl über Tor"
echo "  wget_tor - wget über Tor" 
echo "  git_tor - git über Tor"
echo ""
echo "Verwende diese Befehle für garantierte Tor-Verbindungen!"