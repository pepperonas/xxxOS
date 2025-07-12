#!/bin/bash

# Tor Control Script für macOS
# Usage: ./tor_control.sh {start|stop|status|proxy-on|proxy-off|full-on|full-off}

# SwiftBar Helper einbinden
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/swiftbar_helper.sh" ]; then
    source "$SCRIPT_DIR/swiftbar_helper.sh"
fi

# Netzwerk-Interface automatisch erkennen (meist "Wi-Fi")
NETWORK_SERVICE=$(networksetup -listallnetworkservices | grep -E "(Wi-Fi|WiFi)" | head -1)

if [ -z "$NETWORK_SERVICE" ]; then
    echo "⚠️  Warnung: Wi-Fi Interface nicht gefunden. Verwende 'Wi-Fi'"
    NETWORK_SERVICE="Wi-Fi"
fi

start_tor() {
    echo "🚀 Starte Tor..."
    brew services start tor
    sleep 3
    
    if lsof -i :9050 > /dev/null 2>&1; then
        echo "✅ Tor läuft auf Port 9050"
        # Teste Verbindung
        local test_result=$(curl --socks5 localhost:9050 --connect-timeout 5 -s https://check.torproject.org/api/ip 2>/dev/null | grep '"IsTor":true')
        if [ -n "$test_result" ]; then
            echo "✅ Tor-Verbindung erfolgreich getestet"
        else
            echo "❌ Tor-Verbindung fehlgeschlagen"
        fi
    else
        echo "❌ Tor konnte nicht gestartet werden"
    fi
}

stop_tor() {
    echo "🛑 Stoppe Tor..."
    
    # Prüfe ob Tor als root läuft
    if brew services list | grep "tor" | grep -q "root"; then
        echo "⚠️  Tor läuft als root - verwende sudo"
        sudo brew services stop tor
    else
        brew services stop tor
    fi
    
    killall tor 2>/dev/null
    sudo killall tor 2>/dev/null
    sleep 1
    
    # Prüfe, ob Tor wirklich gestoppt ist
    if ! pgrep -x "tor" > /dev/null 2>&1 && ! netstat -an | grep -E "\.9050.*LISTEN" > /dev/null 2>&1; then
        echo "✅ Tor gestoppt"
    else
        echo "❌ Tor läuft noch - versuche forciertes Stoppen"
        sudo pkill -f tor 2>/dev/null
        sleep 2
        if ! pgrep -x "tor" > /dev/null 2>&1; then
            echo "✅ Tor forciert gestoppt"
            # SwiftBar neustarten
            silent_restart_swiftbar
        else
            echo "❌ Tor konnte nicht gestoppt werden"
            # SwiftBar neustarten
            silent_restart_swiftbar
        fi
    fi
}

enable_system_proxy() {
    echo "🔒 Aktiviere systemweiten SOCKS-Proxy..."
    
    # SOCKS5-Proxy für Tor setzen
    networksetup -setsocksfirewallproxy "$NETWORK_SERVICE" 127.0.0.1 9050
    networksetup -setsocksfirewallproxystate "$NETWORK_SERVICE" on
    
    # Auch HTTP/HTTPS-Proxy über Polipo oder direkt über Tor setzen (falls unterstützt)
    # Viele macOS-Apps nutzen HTTP-Proxy statt SOCKS
    echo "🌐 Konfiguriere zusätzliche Proxy-Einstellungen..."
    
    # HTTP-Proxy deaktivieren um SOCKS zu forcieren
    networksetup -setwebproxystate "$NETWORK_SERVICE" off
    networksetup -setsecurewebproxystate "$NETWORK_SERVICE" off
    
    echo "✅ Systemweiter SOCKS5-Proxy aktiviert für: $NETWORK_SERVICE"
    echo "📌 Wichtig: Nicht alle Apps respektieren System-Proxy-Einstellungen"
    echo "   → Safari, Chrome: ✅ Funktioniert"
    echo "   → Terminal (curl, wget): ❌ Braucht explizite SOCKS5-Config"
    echo "   → Für Terminal: Verwende proxychains4 oder torcurl"
    
}

disable_system_proxy() {
    echo "🔓 Deaktiviere systemweiten SOCKS-Proxy..."
    networksetup -setsocksfirewallproxystate "$NETWORK_SERVICE" off
    
    # Stelle sicher, dass alle Proxy-Einstellungen deaktiviert sind
    networksetup -setwebproxystate "$NETWORK_SERVICE" off 2>/dev/null
    networksetup -setsecurewebproxystate "$NETWORK_SERVICE" off 2>/dev/null
    
    echo "✅ Systemweiter Proxy deaktiviert für: $NETWORK_SERVICE"
    echo "🌐 Normale Internet-Verbindung wiederhergestellt"
    
}

show_status() {
    echo "📊 Tor Status:"
    echo "=============="
    
    # Service Status
    local service_status=$(brew services list | grep tor | awk '{print $2}')
    echo "Service: $service_status"
    
    # Port Check (nur aktive LISTEN-Verbindungen)
    if netstat -an | grep -E "\.9050.*LISTEN" > /dev/null 2>&1; then
        echo "Port 9050: ✅ Aktiv"
    else
        echo "Port 9050: ❌ Inaktiv"
    fi
    
    # Proxy Status
    local proxy_state=$(networksetup -getsocksfirewallproxy "$NETWORK_SERVICE" | grep "Enabled: Yes")
    if [ -n "$proxy_state" ]; then
        echo "System-Proxy: ✅ Aktiviert"
        networksetup -getsocksfirewallproxy "$NETWORK_SERVICE" | grep -E "(Server|Port)"
    else
        echo "System-Proxy: ❌ Deaktiviert"
    fi
    
    # Connection Test - Mit korrekter SOCKS5 und IPv4
    echo ""
    echo "🔍 Verbindungstest:"
    local current_ip=$(curl -4 -s --connect-timeout 5 --socks5 localhost:9050 https://check.torproject.org/api/ip 2>/dev/null | jq -r '.IP' 2>/dev/null || echo "Fehler")
    local is_tor=$(curl -4 -s --connect-timeout 5 --socks5 localhost:9050 https://check.torproject.org/api/ip 2>/dev/null | jq -r '.IsTor' 2>/dev/null || echo "false")
    
    if [ "$is_tor" = "true" ]; then
        echo "Aktuelle IP: $current_ip (🔒 über Tor)"
    else
        echo "Aktuelle IP: $current_ip (🌐 direkte Verbindung)"
    fi
}

test_connection() {
    echo "🧪 Teste Tor-Verbindung..."
    
    # Direkt über SOCKS5 - IPv4 erzwingen
    echo "Test 1: Direkter SOCKS5-Test"
    local socks_result=$(curl -4 --socks5 localhost:9050 --connect-timeout 10 -s https://check.torproject.org/api/ip 2>/dev/null)
    if echo "$socks_result" | grep -q '"IsTor":true'; then
        echo "✅ SOCKS5: Funktioniert"
        echo "$socks_result" | jq . 2>/dev/null || echo "$socks_result"
    else
        echo "❌ SOCKS5: Fehlgeschlagen"
    fi
    
    echo ""
    echo "Test 2: ProxyChains-Test"
    if command -v proxychains4 > /dev/null 2>&1; then
        local proxy_result=$(proxychains4 curl -4 --connect-timeout 10 -s https://check.torproject.org/api/ip 2>/dev/null)
        if echo "$proxy_result" | grep -q '"IsTor":true'; then
            echo "✅ ProxyChains: Funktioniert"
            echo "$proxy_result" | jq . 2>/dev/null || echo "$proxy_result"
        else
            echo "❌ ProxyChains: Fehlgeschlagen"
        fi
    else
        echo "⚠️  ProxyChains nicht installiert"
    fi
    
    echo ""
    echo "Test 3: System-Proxy-Test (funktioniert nicht mit curl)"
    local system_result=$(curl --connect-timeout 10 -s https://check.torproject.org/api/ip 2>/dev/null)
    echo "ℹ️  Curl nutzt System-Proxy nicht. Teste mit Safari:"
    echo "   → Öffne Safari und gehe zu: https://check.torproject.org"
    echo "   → Oder nutze: proxychains4 curl https://check.torproject.org/api/ip"
}

# Neue Tor Identity anfordern
new_identity() {
    echo "🔄 Fordere neue Tor-Identität an..."
    
    # Prüfe ob Tor läuft
    if ! pgrep -x "tor" > /dev/null 2>&1; then
        echo "❌ Tor läuft nicht. Starte Tor zuerst."
        return 1
    fi
    
    # Sende SIGHUP an Tor Prozess für neue Circuit
    if pkill -HUP tor 2>/dev/null; then
        echo "✅ Signal gesendet. Warte auf neue Verbindung..."
        sleep 3
        
        # Teste neue Verbindung
        local new_ip=$(curl -4 -s --connect-timeout 5 --socks5 localhost:9050 http://icanhazip.com 2>/dev/null)
        if [ -n "$new_ip" ]; then
            echo "✅ Neue IP-Adresse: $new_ip"
            
            # Hole Standort Info
            local location_info=$(curl -4 -s --connect-timeout 3 --socks5 localhost:9050 "http://ip-api.com/json/${new_ip}?fields=city,country" 2>/dev/null)
            if [ -n "$location_info" ] && echo "$location_info" | grep -q '"city"'; then
                local city=$(echo "$location_info" | grep -o '"city":"[^"]*' | cut -d'"' -f4)
                local country=$(echo "$location_info" | grep -o '"country":"[^"]*' | cut -d'"' -f4)
                echo "📍 Neuer Standort: $city, $country"
            fi
        else
            echo "⚠️  Konnte neue IP nicht abrufen"
        fi
    else
        echo "❌ Fehler beim Senden des Signals"
        return 1
    fi
}

case "$1" in
    start)
        start_tor
        ;;
    stop)
        stop_tor
        ;;
    status)
        show_status
        ;;
    proxy-on)
        enable_system_proxy
        ;;
    proxy-off)
        disable_system_proxy
        ;;
    full-on)
        start_tor
        sleep 2
        enable_system_proxy
        echo ""
        test_connection
        ;;
    full-off)
        disable_system_proxy
        stop_tor
        ;;
    test)
        test_connection
        ;;
    new-identity|newnym)
        new_identity
        ;;
    *)
        echo "🔧 Tor Control Script"
        echo "===================="
        echo "Usage: $0 {start|stop|status|proxy-on|proxy-off|full-on|full-off|test|new-identity}"
        echo ""
        echo "Befehle:"
        echo "  start      - Nur Tor-Service starten"
        echo "  stop       - Nur Tor-Service stoppen"
        echo "  proxy-on   - Nur System-Proxy aktivieren"
        echo "  proxy-off  - Nur System-Proxy deaktivieren"
        echo "  full-on    - Tor starten + System-Proxy aktivieren"
        echo "  full-off   - Tor stoppen + System-Proxy deaktivieren"
        echo "  status     - Status anzeigen"
        echo "  test       - Verbindung testen"
        echo "  new-identity - Neue Tor-Identität (neuer Exit Node)"
        echo ""
        echo "Erkanntes Netzwerk-Interface: $NETWORK_SERVICE"
        ;;
esac