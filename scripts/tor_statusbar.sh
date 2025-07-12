#!/bin/bash

# xxxOS Tor Status Bar Plugin for BitBar/SwiftBar
# Shows Tor connection status in macOS menu bar
# File should be named: tor_status.5s.sh (updates every 5 seconds)

# Get script directory and set absolute paths
# Use hardcoded path since SwiftBar runs from different location
XXXOS_DIR="/Users/martin/WebstormProjects/xxxOS"
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

# Get location (city/country) for current IP
get_location() {
    local ip="$1"
    if [ "$ip" = "Unknown" ]; then
        echo "Unknown"
        return
    fi
    
    local location_info
    if tor_connected; then
        location_info=$(curl -4 -s --connect-timeout 3 --socks5 localhost:9050 "http://ip-api.com/json/${ip}?fields=city,country" 2>/dev/null)
    else
        location_info=$(curl -4 -s --connect-timeout 3 "http://ip-api.com/json/${ip}?fields=city,country" 2>/dev/null)
    fi
    
    if [ -n "$location_info" ] && echo "$location_info" | grep -q '"city"'; then
        local city=$(echo "$location_info" | grep -o '"city":"[^"]*' | cut -d'"' -f4)
        local country=$(echo "$location_info" | grep -o '"country":"[^"]*' | cut -d'"' -f4)
        
        if [ -n "$city" ] && [ -n "$country" ]; then
            echo "$city, $country"
        elif [ -n "$country" ]; then
            echo "$country"
        else
            echo "Unknown"
        fi
    else
        echo "Unknown"
    fi
}

# Main status check
if tor_running; then
    if tor_connected; then
        # Tor is running and we're connected through it
        echo "🧅"
        echo "---"
        echo "✅ Verbunden via Tor | color=green"
        
        # Tor info from API - IPv4 erzwingen
        tor_info=$(curl -4 -s --connect-timeout 2 --socks5 localhost:9050 https://check.torproject.org/api/ip 2>/dev/null)
        if [ -n "$tor_info" ]; then
            tor_ip=$(echo "$tor_info" | grep -o '"IP":"[^"]*' | cut -d'"' -f4)
            if [ -n "$tor_ip" ]; then
                echo "🌐 IP: $tor_ip | color=green"
                tor_location=$(get_location "$tor_ip")
                echo "📍 Standort: $tor_location | color=green"
            fi
        fi
    else
        # Tor is running but not connected
        echo "🟡"
        echo "---"
        echo "⚠️  Tor läuft, aber nicht verbunden | color=orange"
        
        if proxy_enabled; then
            echo "✅ System-Proxy aktiviert | color=green"
        else
            echo "❌ System-Proxy deaktiviert | color=red"
        fi
        
        current_ip=$(get_ip)
        echo "🌐 Echte IP: $current_ip | color=orange"
        current_location=$(get_location "$current_ip")
        echo "📍 Standort: $current_location | color=orange"
    fi
else
    # Tor is not running
    echo "⚫"
    echo "---"
    echo "❌ Tor ist nicht aktiv | color=red"
    current_ip=$(get_ip)
    echo "🌐 Echte IP: $current_ip | color=red"
    current_location=$(get_location "$current_ip")
    echo "📍 Standort: $current_location | color=red"
fi

echo "---"

# Quick actions
echo "🚀 Tor Aktionen"
echo "-- Tor starten | bash='$TOR_CONTROL' param1=start terminal=false refresh=true"
echo "-- Tor stoppen | bash='$TOR_CONTROL' param1=stop terminal=false refresh=true"
echo "---"
echo "🔒 System-weites Tor"
echo "-- Browser/Apps aktivieren | bash='$TOR_CONTROL' param1=full-on terminal=false refresh=true"
echo "-- Browser/Apps deaktivieren | bash='$TOR_CONTROL' param1=full-off terminal=false refresh=true"
echo "---"
echo "🛡️  Transparentes Tor"
echo "-- Alles über Tor (sudo) | bash='$XXXOS_MAIN' param1=tor param2=trans-on terminal=true refresh=true"
echo "-- Transparentes Tor aus (sudo) | bash='$XXXOS_MAIN' param1=tor param2=trans-off terminal=true refresh=true"
echo "---"

# Privacy status - Vereinfachte Befehle
echo "🔒 Privacy"
echo "-- Status anzeigen | bash='$WRAPPER' param1=status terminal=true refresh=false"
echo "-- 🔥 Privacy ON | bash='$WRAPPER' param1=privacy-on terminal=true refresh=false"
echo "-- 🌐 Privacy OFF | bash='$WRAPPER' param1=privacy-off terminal=true refresh=false"
echo "---"

# Additional info
echo "📊 Details"
echo "-- Tor Status | bash='$WRAPPER' param1=tor-status terminal=true refresh=false"
echo "-- Transparentes Tor Status | bash='$WRAPPER' param1=tor-transparent-status terminal=true refresh=false"
echo "-- IP Info | bash='$WRAPPER' param1=ipinfo terminal=true refresh=false"
echo "-- Security Check | bash='$WRAPPER' param1=security-full terminal=true refresh=false"
echo "---"

# Settings
echo "⚙️  Einstellungen"
echo "-- 🔄 Neuer Standort (Exit Node) | bash='$TOR_CONTROL' param1=new-identity terminal=false refresh=true"
echo "-- xxxOS öffnen | bash='$WRAPPER' param1=xxxos terminal=true refresh=false"
echo "-- Terminal Tor-Konfiguration | bash='$WRAPPER' param1=tor-terminal terminal=true refresh=false"
echo "---"
echo "Aktualisieren | refresh=true"