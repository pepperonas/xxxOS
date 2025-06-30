#!/bin/bash

# xxxOS Tor Status Bar Plugin for BitBar/SwiftBar
# Shows Tor connection status in macOS menu bar
# File should be named: tor_status.5s.sh (updates every 5 seconds)

# Get script directory and set relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XXXOS_DIR="$(dirname "$SCRIPT_DIR")"
TOR_CONTROL="$XXXOS_DIR/scripts/tor_control.sh"
XXXOS_MAIN="$XXXOS_DIR/xxxos.sh"
WRAPPER="$XXXOS_DIR/scripts/statusbar_wrappers.sh"

# Check if Tor is running
tor_running() {
    pgrep -x "tor" > /dev/null 2>&1 || netstat -an | grep -E "\.9050.*LISTEN" > /dev/null 2>&1
}

# Check if we're connected through Tor - IPv4 erzwingen
tor_connected() {
    local result=$(curl -4 -s --connect-timeout 2 --socks5 localhost:9050 https://check.torproject.org/api/ip 2>/dev/null | grep -o '"IsTor":true' 2>/dev/null)
    [ -n "$result" ]
}

# Check if system proxy is enabled
proxy_enabled() {
    networksetup -getsocksfirewallproxy "Wi-Fi" 2>/dev/null | grep "Enabled: Yes" > /dev/null 2>&1
}

# Get current IP - IPv4 erzwingen
get_ip() {
    if tor_connected; then
        curl -4 -s --connect-timeout 2 --socks5 localhost:9050 http://icanhazip.com 2>/dev/null || echo "Unknown"
    else
        curl -4 -s --connect-timeout 2 http://icanhazip.com 2>/dev/null || echo "Unknown"
    fi
}

# Main status check
if tor_running; then
    if tor_connected; then
        # Tor is running and we're connected through it
        echo "🧅 TOR"
        echo "---"
        echo "✅ Verbunden via Tor | color=green"
        current_ip=$(get_ip)
        echo "🌐 IP: $current_ip | color=green"
        
        # Tor info from API - IPv4 erzwingen
        tor_info=$(curl -4 -s --connect-timeout 2 --socks5 localhost:9050 https://check.torproject.org/api/ip 2>/dev/null)
        if [ -n "$tor_info" ]; then
            tor_ip=$(echo "$tor_info" | grep -o '"IP":"[^"]*' | cut -d'"' -f4)
            [ -n "$tor_ip" ] && echo "🧅 Tor IP: $tor_ip | color=green"
        fi
    else
        # Tor is running but not connected
        echo "🟡 TOR"
        echo "---"
        echo "⚠️  Tor läuft, aber nicht verbunden | color=orange"
        
        if proxy_enabled; then
            echo "✅ System-Proxy aktiviert | color=green"
        else
            echo "❌ System-Proxy deaktiviert | color=red"
        fi
        
        current_ip=$(get_ip)
        echo "🌐 Echte IP: $current_ip | color=orange"
    fi
else
    # Tor is not running
    echo "⚫ TOR"
    echo "---"
    echo "❌ Tor ist nicht aktiv | color=red"
    current_ip=$(get_ip)
    echo "🌐 Echte IP: $current_ip | color=red"
fi

echo "---"

# Quick actions
echo "🚀 Aktionen"
echo "-- Tor starten | bash='$TOR_CONTROL' param1=start terminal=false refresh=true"
echo "-- Tor stoppen | bash='$TOR_CONTROL' param1=stop terminal=false refresh=true"
echo "-- Tor + Proxy aktivieren | bash='$TOR_CONTROL' param1=full-on terminal=false refresh=true"
echo "-- Tor + Proxy deaktivieren | bash='$TOR_CONTROL' param1=full-off terminal=false refresh=true"
echo "---"

# Privacy status
echo "🔒 Privacy"
echo "-- Status anzeigen | bash='$WRAPPER' param1=status terminal=true refresh=false"
echo "-- Privacy Mode ON | bash='$WRAPPER' param1=privacy-on terminal=true refresh=false"
echo "-- Privacy Mode OFF | bash='$WRAPPER' param1=privacy-off terminal=true refresh=false"
echo "-- Ultra Privacy Mode | bash='$WRAPPER' param1=privacy-ultra terminal=true refresh=false"
echo "---"

# Additional info
echo "📊 Details"
echo "-- Tor Status | bash='$WRAPPER' param1=tor-status terminal=true refresh=false"
echo "-- IP Info | bash='$WRAPPER' param1=ipinfo terminal=true refresh=false"
echo "-- Security Check | bash='$WRAPPER' param1=security-full terminal=true refresh=false"
echo "---"

# Settings
echo "⚙️  Einstellungen"
echo "-- xxxOS öffnen | bash='$WRAPPER' param1=xxxos terminal=true refresh=false"
echo "-- Tor Shell | bash='$WRAPPER' param1=torshell terminal=true refresh=false"
echo "---"
echo "Aktualisieren | refresh=true"