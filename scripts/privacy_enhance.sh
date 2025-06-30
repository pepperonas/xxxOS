#!/bin/bash

# Erweiterte Privacy-Funktionen für xxxOS
# (c) 2025 Martin Pfeffer - MIT License

# DNS-Cache leeren
clear_dns_cache() {
    echo "🧹 Leere DNS-Cache..."
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder 2>/dev/null
    echo "✅ DNS-Cache geleert"
}

# Hostname randomisieren
randomize_hostname() {
    echo "🔀 Randomisiere Hostname..."
    
    # Aktuellen Hostname speichern, falls noch nicht gespeichert
    if [ ! -f "$HOME/.xxxos/original_hostname" ]; then
        mkdir -p "$HOME/.xxxos"
        hostname > "$HOME/.xxxos/original_hostname"
        echo "💾 Original-Hostname gespeichert: $(hostname)"
    fi
    
    RANDOM_NAME="mac-$(openssl rand -hex 4)"
    sudo scutil --set ComputerName "$RANDOM_NAME"
    sudo scutil --set LocalHostName "$RANDOM_NAME"
    sudo scutil --set HostName "$RANDOM_NAME"
    echo "✅ Neuer Hostname: $RANDOM_NAME"
}

# Hostname wiederherstellen
restore_hostname() {
    echo "🔄 Stelle Original-Hostname wieder her..."
    
    if [ -f "$HOME/.xxxos/original_hostname" ]; then
        ORIGINAL_NAME=$(cat "$HOME/.xxxos/original_hostname")
        sudo scutil --set ComputerName "$ORIGINAL_NAME"
        sudo scutil --set LocalHostName "$ORIGINAL_NAME"
        sudo scutil --set HostName "$ORIGINAL_NAME"
        echo "✅ Hostname wiederhergestellt: $ORIGINAL_NAME"
        
        # Datei löschen nach Wiederherstellung
        rm -f "$HOME/.xxxos/original_hostname"
    else
        echo "⚠️  Keine Original-Hostname-Datei gefunden"
        echo "   Verwende Standard: MacBookPro"
        sudo scutil --set ComputerName "MacBookPro"
        sudo scutil --set LocalHostName "MacBookPro"
        sudo scutil --set HostName "MacBookPro"
    fi
}

# Browser-Cache und Cookies löschen
clear_browser_data() {
    echo "🗑️  Browser-Daten löschen"
    echo "========================"
    echo ""
    echo "⚠️  WARNUNG: Diese Aktion wird folgendes löschen:"
    echo ""
    
    # Gefundene Browser anzeigen
    local found_browsers=0
    
    if [ -d ~/Library/Safari ]; then
        echo "  🧭 Safari:"
        echo "     - Browserverlauf"
        echo "     - Downloads-Liste"
        echo "     - Cache-Daten"
        found_browsers=1
    fi
    
    if [ -d ~/Library/Application\ Support/Google/Chrome ]; then
        echo "  🌐 Chrome:"
        echo "     - Browserverlauf"
        echo "     - Cookies"
        echo "     - Cache-Daten"
        found_browsers=1
    fi
    
    if [ -d ~/Library/Application\ Support/Firefox ]; then
        echo "  🦊 Firefox:"
        echo "     - Alle SQLite-Datenbanken"
        echo "     - Cache-Daten"
        found_browsers=1
    fi
    
    if [ $found_browsers -eq 0 ]; then
        echo "❌ Keine unterstützten Browser gefunden."
        return
    fi
    
    echo ""
    echo "⚠️  Gespeicherte Passwörter bleiben erhalten."
    echo ""
    read -p "Möchtest du fortfahren? (j/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Jj]$ ]]; then
        echo "❌ Abgebrochen."
        return
    fi
    
    echo ""
    echo "🗑️  Lösche Browser-Daten..."
    
    # Safari
    if [ -d ~/Library/Safari ]; then
        rm -rf ~/Library/Safari/History.db* 2>/dev/null
        rm -rf ~/Library/Safari/Downloads.plist 2>/dev/null
        rm -rf ~/Library/Caches/com.apple.Safari/* 2>/dev/null
        echo "✅ Safari-Daten gelöscht"
    fi
    
    # Chrome
    if [ -d ~/Library/Application\ Support/Google/Chrome ]; then
        rm -rf ~/Library/Application\ Support/Google/Chrome/Default/History* 2>/dev/null
        rm -rf ~/Library/Application\ Support/Google/Chrome/Default/Cookies* 2>/dev/null
        rm -rf ~/Library/Caches/Google/Chrome/* 2>/dev/null
        echo "✅ Chrome-Daten gelöscht"
    fi
    
    # Firefox
    if [ -d ~/Library/Application\ Support/Firefox ]; then
        find ~/Library/Application\ Support/Firefox/Profiles -name "*.sqlite" -delete 2>/dev/null
        rm -rf ~/Library/Caches/Firefox/* 2>/dev/null
        echo "✅ Firefox-Daten gelöscht"
    fi
}

# Firewall aktivieren
enable_firewall() {
    echo "🔥 Aktiviere Firewall..."
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
    echo "✅ Firewall aktiviert mit Stealth-Modus"
}

# Spotlight-Indizierung deaktivieren
disable_spotlight() {
    echo "🔍 Deaktiviere Spotlight-Indizierung..."
    sudo mdutil -a -i off
    echo "✅ Spotlight deaktiviert"
}

# Spotlight wieder aktivieren
enable_spotlight() {
    echo "🔍 Aktiviere Spotlight-Indizierung..."
    sudo mdutil -a -i on
    echo "✅ Spotlight aktiviert"
}

# Location Services deaktivieren
disable_location() {
    echo "📍 Deaktiviere Ortungsdienste..."
    sudo launchctl unload /System/Library/LaunchDaemons/com.apple.locationd.plist 2>/dev/null
    echo "✅ Ortungsdienste deaktiviert"
}

# WebRTC-Leak Protection Info
show_webrtc_info() {
    echo ""
    echo "⚠️  WebRTC-Leak Schutz:"
    echo "WebRTC kann deine echte IP-Adresse preisgeben, auch wenn du Tor/VPN nutzt!"
    echo ""
    echo "Empfohlene Browser-Einstellungen:"
    echo ""
    echo "🦊 Firefox:"
    echo "   1. Öffne about:config"
    echo "   2. Setze media.peerconnection.enabled auf false"
    echo ""
    echo "🌐 Chrome/Brave:"
    echo "   - Installiere WebRTC Leak Prevent Extension"
    echo ""
    echo "🧅 Tor Browser:"
    echo "   - WebRTC ist bereits deaktiviert"
}

# DNS-Server auf Privacy-fokussierte ändern
set_privacy_dns() {
    echo "🔒 Setze Privacy-DNS-Server..."
    
    # Netzwerk-Interface finden
    NETWORK_SERVICE=$(networksetup -listallnetworkservices | grep -E "(Wi-Fi|WiFi)" | head -1)
    
    # Cloudflare DNS (Privacy-fokussiert)
    networksetup -setdnsservers "$NETWORK_SERVICE" 1.1.1.1 1.0.0.1
    echo "✅ DNS geändert zu Cloudflare (1.1.1.1)"
    echo "   Alternative: Quad9 (9.9.9.9) oder AdGuard (94.140.14.14)"
}

# Tracking-Domains blockieren
block_tracking() {
    echo "🚫 Blockiere bekannte Tracking-Domains..."
    
    # Backup der hosts-Datei
    sudo cp /etc/hosts /etc/hosts.backup.$(date +%Y%m%d)
    
    # Grundlegende Tracking-Domains hinzufügen
    cat << 'EOF' | sudo tee -a /etc/hosts > /dev/null

# xxxOS Privacy Block List
0.0.0.0 google-analytics.com
0.0.0.0 www.google-analytics.com
0.0.0.0 googletagmanager.com
0.0.0.0 www.googletagmanager.com
0.0.0.0 doubleclick.net
0.0.0.0 facebook.com
0.0.0.0 www.facebook.com
0.0.0.0 connect.facebook.net
0.0.0.0 graph.facebook.com
0.0.0.0 pixel.facebook.com
0.0.0.0 analytics.twitter.com
0.0.0.0 amazon-adsystem.com
0.0.0.0 googleadservices.com
0.0.0.0 googlesyndication.com
0.0.0.0 scorecardresearch.com
0.0.0.0 outbrain.com
0.0.0.0 taboola.com
EOF
    
    echo "✅ Tracking-Domains blockiert (Backup in /etc/hosts.backup.*)"
}

# Alle Privacy-Einstellungen aktivieren
enable_all() {
    echo "🛡️  Aktiviere alle Privacy-Funktionen..."
    echo ""
    clear_dns_cache
    randomize_hostname
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    clear_browser_data
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    enable_firewall
    set_privacy_dns
    block_tracking
    disable_location
    show_webrtc_info
}

# Hauptmenü
case "$1" in
    dns-clear)
        clear_dns_cache
        ;;
    hostname)
        randomize_hostname
        ;;
    hostname-restore)
        restore_hostname
        ;;
    browser-clear)
        clear_browser_data
        ;;
    firewall)
        enable_firewall
        ;;
    spotlight-off)
        disable_spotlight
        ;;
    spotlight-on)
        enable_spotlight
        ;;
    location-off)
        disable_location
        ;;
    dns-privacy)
        set_privacy_dns
        ;;
    block-tracking)
        block_tracking
        ;;
    webrtc-info)
        show_webrtc_info
        ;;
    all)
        enable_all
        ;;
    *)
        echo "🔒 Erweiterte Privacy-Funktionen"
        echo "================================"
        echo ""
        echo "Usage: $0 {command}"
        echo ""
        echo "Commands:"
        echo "  dns-clear      - DNS-Cache leeren"
        echo "  hostname       - Hostname randomisieren"
        echo "  browser-clear  - Browser-Daten löschen"
        echo "  firewall       - Firewall mit Stealth-Modus aktivieren"
        echo "  spotlight-off  - Spotlight-Indizierung deaktivieren"
        echo "  spotlight-on   - Spotlight-Indizierung aktivieren"
        echo "  location-off   - Ortungsdienste deaktivieren"
        echo "  dns-privacy    - Privacy-DNS-Server setzen"
        echo "  block-tracking - Tracking-Domains blockieren"
        echo "  webrtc-info    - WebRTC-Leak Schutz Info"
        echo "  all            - Alle Privacy-Funktionen aktivieren"
        ;;
esac