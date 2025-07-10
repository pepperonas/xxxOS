#!/bin/bash

# Erweiterte Privacy-Funktionen für xxxOS
# (c) 2025 Martin Pfeffer - MIT License
# Vereinfachte Version - Hauptfunktionen sind in xxxos.sh implementiert

# Pfad zum Hauptskript
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XXXOS_MAIN="$(dirname "$SCRIPT_DIR")/xxxos.sh"

# Hostname wiederherstellen (spezielle Funktion)
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
        echo "   Verwende Standard: MacBook"
        sudo scutil --set ComputerName "MacBook"
        sudo scutil --set LocalHostName "MacBook"
        sudo scutil --set HostName "MacBook"
    fi
}

# Browser-Cache und Cookies löschen (optional - nicht in privacy-on/off)
clear_browser_data() {
    echo "🗑️  Browser-Daten löschen"
    echo "========================"
    echo ""
    echo "⚠️  WARNUNG: Diese Aktion löscht Browserverlauf und Cookies!"
    echo ""
    echo "💡 Hinweis: Das vereinfachte xxxOS (privacy-on) löscht KEINE Browser-Daten."
    echo "   Passwörter und Verläufe bleiben erhalten für bessere Benutzerfreundlichkeit."
    echo ""
    read -p "Trotzdem fortfahren? (j/N): " -n 1 -r
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

# Legacy-Wrapper für Kompatibilität (leiten alle auf Hauptskript um)
clear_dns_cache() {
    echo "ℹ️  DNS-Cache wird vom Hauptskript verwaltet."
    echo "Verwende: ./xxxos.sh privacy-on"
}

set_hostname_lisa() {
    echo "ℹ️  Hostname wird vom Hauptskript verwaltet."
    echo "Verwende: ./xxxos.sh privacy-on"
}

enable_firewall() {
    echo "ℹ️  Firewall wird vom Hauptskript verwaltet."
    echo "Verwende: ./xxxos.sh privacy-on"
}

set_privacy_dns() {
    echo "ℹ️  DNS-Einstellungen werden vom Hauptskript verwaltet."
    echo "Verwende: ./xxxos.sh privacy-on"
}

block_tracking() {
    echo "ℹ️  Tracking-Schutz wird vom Hauptskript verwaltet."
    echo "Verwende: ./xxxos.sh privacy-on"
}

disable_location() {
    echo "ℹ️  Ortungsdienste werden vom Hauptskript verwaltet."
    echo "Verwende: ./xxxos.sh privacy-on"
}

# Legacy-Funktionen
randomize_hostname() {
    set_hostname_lisa
}

hostname() {
    set_hostname_lisa
}

# Vereinfachtes Hauptmenü
case "$1" in
    hostname-restore)
        restore_hostname
        ;;
    browser-clear)
        clear_browser_data
        ;;
    webrtc-info)
        show_webrtc_info
        ;;
    # Legacy-Support (leitet auf Hauptskript um)
    dns-clear|hostname|hostname-lisa|firewall|dns-privacy|block-tracking|location-off|all)
        echo "ℹ️  Diese Funktionen wurden ins Hauptskript integriert."
        echo "💡 Verwende: $XXXOS_MAIN privacy-on"
        echo ""
        echo "Soll das Hauptskript gestartet werden? (j/N)"
        read -p "> " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Jj]$ ]]; then
            "$XXXOS_MAIN"
        fi
        ;;
    *)
        echo "🔒 Erweiterte Privacy-Funktionen (Vereinfacht)"
        echo "=============================================="
        echo ""
        echo "💡 Die meisten Funktionen sind jetzt im Hauptskript:"
        echo "   ./xxxos.sh privacy-on    - Aktiviert alle Privacy-Funktionen"
        echo "   ./xxxos.sh privacy-off   - Deaktiviert Privacy-Funktionen"
        echo ""
        echo "Verfügbare spezielle Funktionen:"
        echo "  hostname-restore  - Original-Hostname wiederherstellen"
        echo "  browser-clear     - Browser-Daten löschen (⚠️  nicht empfohlen)"
        echo "  webrtc-info       - WebRTC-Leak Schutz Information"
        echo ""
        echo "🚀 Starte das Hauptskript für alle Privacy-Funktionen:"
        echo "   $XXXOS_MAIN"
        ;;
esac