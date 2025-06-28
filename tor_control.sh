#!/bin/bash

# Tor Control Script für macOS
# Usage: ./tor_control.sh {start|stop|status|proxy-on|proxy-off|full-on|full-off}

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
    brew services stop tor
    killall tor 2>/dev/null
    sleep 1
    
    if ! lsof -i :9050 > /dev/null 2>&1; then
        echo "✅ Tor gestoppt"
    else
        echo "❌ Tor läuft noch"
    fi
}

enable_system_proxy() {
    echo "🔒 Aktiviere systemweiten SOCKS-Proxy..."
    networksetup -setsocksfirewallproxy "$NETWORK_SERVICE" 127.0.0.1 9050
    networksetup -setsocksfirewallproxystate "$NETWORK_SERVICE" on
    echo "✅ Systemweiter Proxy aktiviert für: $NETWORK_SERVICE"
}

disable_system_proxy() {
    echo "🔓 Deaktiviere systemweiten SOCKS-Proxy..."
    networksetup -setsocksfirewallproxystate "$NETWORK_SERVICE" off
    echo "✅ Systemweiter Proxy deaktiviert für: $NETWORK_SERVICE"
}

show_status() {
    echo "📊 Tor Status:"
    echo "=============="
    
    # Service Status
    local service_status=$(brew services list | grep tor | awk '{print $2}')
    echo "Service: $service_status"
    
    # Port Check
    if lsof -i :9050 > /dev/null 2>&1; then
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
    
    # Connection Test
    echo ""
    echo "🔍 Verbindungstest:"
    local current_ip=$(curl -s --connect-timeout 5 https://check.torproject.org/api/ip 2>/dev/null | jq -r '.IP' 2>/dev/null || echo "Fehler")
    local is_tor=$(curl -s --connect-timeout 5 https://check.torproject.org/api/ip 2>/dev/null | jq -r '.IsTor' 2>/dev/null || echo "false")
    
    if [ "$is_tor" = "true" ]; then
        echo "Aktuelle IP: $current_ip (🔒 über Tor)"
    else
        echo "Aktuelle IP: $current_ip (🌐 direkte Verbindung)"
    fi
}

test_connection() {
    echo "🧪 Teste Tor-Verbindung..."
    
    # Direkt über SOCKS5
    echo "Test 1: Direkter SOCKS5-Test"
    local socks_result=$(curl --socks5 localhost:9050 --connect-timeout 10 -s https://check.torproject.org/api/ip 2>/dev/null)
    if echo "$socks_result" | grep -q '"IsTor":true'; then
        echo "✅ SOCKS5: Funktioniert"
        echo "$socks_result" | jq . 2>/dev/null || echo "$socks_result"
    else
        echo "❌ SOCKS5: Fehlgeschlagen"
    fi
    
    echo ""
    echo "Test 2: ProxyChains-Test"
    if command -v proxychains4 > /dev/null 2>&1; then
        local proxy_result=$(proxychains4 curl --connect-timeout 10 -s https://check.torproject.org/api/ip 2>/dev/null)
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
    *)
        echo "🔧 Tor Control Script"
        echo "===================="
        echo "Usage: $0 {start|stop|status|proxy-on|proxy-off|full-on|full-off|test}"
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
        echo ""
        echo "Erkanntes Netzwerk-Interface: $NETWORK_SERVICE"
        ;;
esac