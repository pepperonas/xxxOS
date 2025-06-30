#!/usr/bin/env bash

# xxxOS StatusBar Installer
# Automatische Installation und Konfiguration von SwiftBar mit Tor-Plugin
# (c) 2025 Martin Pfeffer - MIT License

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XXXOS_DIR="$(dirname "$SCRIPT_DIR")"
TOR_STATUSBAR_SCRIPT="$SCRIPT_DIR/tor_statusbar.sh"

# SwiftBar Pfade
SWIFTBAR_APP="/Applications/SwiftBar.app"
SWIFTBAR_PLUGINS_DIR="$HOME/Library/Application Support/SwiftBar/Plugins"
PLUGIN_TARGET="$SWIFTBAR_PLUGINS_DIR/tor_status.5s.sh"

echo -e "${BLUE}🍎 xxxOS StatusBar Installer${NC}"
echo "==============================="
echo ""

# Prüfe ob SwiftBar bereits installiert ist
check_swiftbar_installed() {
    if [ -d "$SWIFTBAR_APP" ]; then
        echo -e "${GREEN}✅ SwiftBar bereits installiert${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  SwiftBar nicht gefunden${NC}"
        return 1
    fi
}

# Prüfe ob Homebrew verfügbar ist
check_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Homebrew verfügbar${NC}"
        return 0
    else
        echo -e "${RED}❌ Homebrew nicht installiert${NC}"
        echo ""
        echo "Homebrew wird benötigt für die SwiftBar-Installation."
        echo "Installiere Homebrew mit:"
        echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        return 1
    fi
}

# SwiftBar installieren
install_swiftbar() {
    echo -e "${BLUE}📦 Installiere SwiftBar...${NC}"
    
    if ! check_homebrew; then
        return 1
    fi
    
    if brew install --cask swiftbar; then
        echo -e "${GREEN}✅ SwiftBar erfolgreich installiert${NC}"
        return 0
    else
        echo -e "${RED}❌ SwiftBar-Installation fehlgeschlagen${NC}"
        return 1
    fi
}

# Plugin-Verzeichnis erstellen
create_plugin_directory() {
    echo -e "${BLUE}📁 Erstelle Plugin-Verzeichnis...${NC}"
    
    if mkdir -p "$SWIFTBAR_PLUGINS_DIR"; then
        echo -e "${GREEN}✅ Plugin-Verzeichnis erstellt: $SWIFTBAR_PLUGINS_DIR${NC}"
        return 0
    else
        echo -e "${RED}❌ Konnte Plugin-Verzeichnis nicht erstellen${NC}"
        return 1
    fi
}

# Tor-Plugin kopieren
install_tor_plugin() {
    echo -e "${BLUE}🧅 Installiere Tor-StatusBar-Plugin...${NC}"
    
    if [ ! -f "$TOR_STATUSBAR_SCRIPT" ]; then
        echo -e "${RED}❌ Tor-StatusBar-Skript nicht gefunden: $TOR_STATUSBAR_SCRIPT${NC}"
        return 1
    fi
    
    # Plugin-Verzeichnis erstellen falls nötig
    if ! create_plugin_directory; then
        return 1
    fi
    
    # Plugin kopieren
    if cp "$TOR_STATUSBAR_SCRIPT" "$PLUGIN_TARGET"; then
        echo -e "${GREEN}✅ Plugin kopiert nach: $PLUGIN_TARGET${NC}"
    else
        echo -e "${RED}❌ Plugin-Kopierung fehlgeschlagen${NC}"
        return 1
    fi
    
    # Ausführbar machen
    if chmod +x "$PLUGIN_TARGET"; then
        echo -e "${GREEN}✅ Plugin ausführbar gemacht${NC}"
        return 0
    else
        echo -e "${RED}❌ Konnte Plugin nicht ausführbar machen${NC}"
        return 1
    fi
}

# SwiftBar starten
start_swiftbar() {
    echo -e "${BLUE}🚀 Starte SwiftBar...${NC}"
    
    if [ ! -d "$SWIFTBAR_APP" ]; then
        echo -e "${RED}❌ SwiftBar-App nicht gefunden${NC}"
        return 1
    fi
    
    # Prüfe ob SwiftBar bereits läuft
    if pgrep -f "SwiftBar" >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  SwiftBar läuft bereits - starte neu...${NC}"
        killall SwiftBar 2>/dev/null
        sleep 2
    fi
    
    # SwiftBar starten
    if open "$SWIFTBAR_APP"; then
        echo -e "${GREEN}✅ SwiftBar gestartet${NC}"
        sleep 3
        
        # Prüfe ob SwiftBar läuft
        if pgrep -f "SwiftBar" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ SwiftBar läuft erfolgreich${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠️  SwiftBar möglicherweise nicht gestartet (läuft im Hintergrund)${NC}"
            return 0
        fi
    else
        echo -e "${RED}❌ Konnte SwiftBar nicht starten${NC}"
        return 1
    fi
}

# SwiftBar Auto-Start konfigurieren
setup_autostart() {
    echo -e "${BLUE}⚙️  Konfiguriere Auto-Start...${NC}"
    
    if [ ! -d "$SWIFTBAR_APP" ]; then
        echo -e "${RED}❌ SwiftBar nicht installiert${NC}"
        return 1
    fi
    
    # Prüfe ob bereits als Login-Item konfiguriert
    local login_items=$(osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null)
    
    if echo "$login_items" | grep -q "SwiftBar"; then
        echo -e "${GREEN}✅ SwiftBar bereits als Login-Item konfiguriert${NC}"
    else
        echo -e "${BLUE}📋 Füge SwiftBar als Login-Item hinzu...${NC}"
        
        # SwiftBar als Login-Item hinzufügen
        if osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"$SWIFTBAR_APP\", hidden:false}" 2>/dev/null; then
            echo -e "${GREEN}✅ SwiftBar wird jetzt automatisch beim Start geladen${NC}"
        else
            echo -e "${YELLOW}⚠️  Auto-Start-Konfiguration fehlgeschlagen${NC}"
            echo "Du kannst SwiftBar manuell in den Systemeinstellungen zu den Login-Items hinzufügen:"
            echo "Systemeinstellungen → Benutzer & Gruppen → Login-Items → SwiftBar hinzufügen"
        fi
    fi
    
    return 0
}

# Auto-Start entfernen
remove_autostart() {
    echo -e "${BLUE}🗑️  Entferne Auto-Start...${NC}"
    
    # SwiftBar aus Login-Items entfernen
    if osascript -e 'tell application "System Events" to delete login item "SwiftBar"' 2>/dev/null; then
        echo -e "${GREEN}✅ SwiftBar Auto-Start entfernt${NC}"
    else
        echo -e "${YELLOW}⚠️  SwiftBar nicht in Login-Items gefunden${NC}"
    fi
}

# Plugin-Status prüfen
check_plugin_status() {
    echo -e "${BLUE}🔍 Prüfe Plugin-Status...${NC}"
    
    if [ -f "$PLUGIN_TARGET" ]; then
        echo -e "${GREEN}✅ Plugin installiert: $PLUGIN_TARGET${NC}"
        
        # Prüfe Berechtigung
        if [ -x "$PLUGIN_TARGET" ]; then
            echo -e "${GREEN}✅ Plugin ist ausführbar${NC}"
        else
            echo -e "${YELLOW}⚠️  Plugin nicht ausführbar - korrigiere...${NC}"
            chmod +x "$PLUGIN_TARGET"
        fi
        
        # Teste Plugin
        echo -e "${BLUE}🧪 Teste Plugin...${NC}"
        if "$PLUGIN_TARGET" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Plugin funktioniert${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠️  Plugin-Test fehlgeschlagen (evtl. normale Ausgabe)${NC}"
            return 0
        fi
    else
        echo -e "${RED}❌ Plugin nicht gefunden${NC}"
        return 1
    fi
}

# Plugin deinstallieren
uninstall_plugin() {
    echo -e "${YELLOW}🗑️  Deinstalliere StatusBar-Plugin...${NC}"
    
    if [ -f "$PLUGIN_TARGET" ]; then
        if rm "$PLUGIN_TARGET"; then
            echo -e "${GREEN}✅ Plugin entfernt${NC}"
        else
            echo -e "${RED}❌ Konnte Plugin nicht entfernen${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠️  Plugin bereits entfernt${NC}"
    fi
    
    # SwiftBar neu starten falls läuft
    if pgrep -f "SwiftBar" >/dev/null 2>&1; then
        echo -e "${BLUE}🔄 Starte SwiftBar neu...${NC}"
        killall SwiftBar 2>/dev/null
        sleep 2
        open "$SWIFTBAR_APP" 2>/dev/null
    fi
    
    return 0
}

# Vollständige Installation
full_install() {
    echo -e "${PURPLE}🔧 Starte vollständige StatusBar-Installation...${NC}"
    echo ""
    
    # 1. Prüfe SwiftBar
    if ! check_swiftbar_installed; then
        read -p "SwiftBar installieren? (j/N): " install_swift
        if [[ "$install_swift" =~ ^[jJ]$ ]]; then
            if ! install_swiftbar; then
                echo -e "${RED}❌ Installation abgebrochen${NC}"
                return 1
            fi
        else
            echo -e "${YELLOW}⚠️  Installation abgebrochen - SwiftBar benötigt${NC}"
            return 1
        fi
    fi
    
    echo ""
    
    # 2. Plugin installieren
    if ! install_tor_plugin; then
        echo -e "${RED}❌ Plugin-Installation fehlgeschlagen${NC}"
        return 1
    fi
    
    echo ""
    
    # 3. Auto-Start konfigurieren
    read -p "SwiftBar automatisch beim macOS-Start laden? (J/n): " autostart_choice
    if [[ ! "$autostart_choice" =~ ^[nN]$ ]]; then
        setup_autostart
    fi
    
    echo ""
    
    # 4. SwiftBar starten
    if ! start_swiftbar; then
        echo -e "${YELLOW}⚠️  SwiftBar-Start möglicherweise fehlgeschlagen${NC}"
        echo "Versuche SwiftBar manuell zu starten: open /Applications/SwiftBar.app"
    fi
    
    echo ""
    
    # 5. Status prüfen
    check_plugin_status
    
    echo ""
    echo -e "${GREEN}🎉 Installation abgeschlossen!${NC}"
    echo ""
    echo "Nächste Schritte:"
    echo "1. Schaue in die macOS-Menüleiste nach dem Tor-Icon"
    echo "2. Falls nicht sichtbar: SwiftBar manuell starten"
    echo "3. In SwiftBar-Einstellungen Plugin-Ordner prüfen"
    echo "4. Plugin aktualisiert sich alle 5 Sekunden"
    echo ""
    echo "Troubleshooting:"
    echo "• SwiftBar-Menü → 'Refresh All' zum Neuladen"
    echo "• SwiftBar-Menü → 'Preferences' für Einstellungen"
    echo "• Plugin-Pfad: $PLUGIN_TARGET"
}

# Status anzeigen
show_status() {
    echo -e "${BLUE}📊 StatusBar-Status${NC}"
    echo "=================="
    echo ""
    
    # SwiftBar Status
    if check_swiftbar_installed; then
        if pgrep -f "SwiftBar" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ SwiftBar läuft${NC}"
        else
            echo -e "${YELLOW}⚠️  SwiftBar installiert aber nicht aktiv${NC}"
        fi
    else
        echo -e "${RED}❌ SwiftBar nicht installiert${NC}"
    fi
    
    echo ""
    
    # Plugin Status
    check_plugin_status
    
    echo ""
    echo "Plugin-Pfad: $PLUGIN_TARGET"
    echo "Plugin-Verzeichnis: $SWIFTBAR_PLUGINS_DIR"
}

# Hauptfunktion
main() {
    case "$1" in
        "install"|"")
            full_install
            ;;
        "uninstall")
            uninstall_plugin
            ;;
        "status")
            show_status
            ;;
        "restart")
            echo -e "${BLUE}🔄 Starte SwiftBar neu...${NC}"
            start_swiftbar
            ;;
        "autostart")
            setup_autostart
            ;;
        "no-autostart")
            remove_autostart
            ;;
        "test")
            echo -e "${BLUE}🧪 Teste Plugin...${NC}"
            if [ -f "$PLUGIN_TARGET" ]; then
                "$PLUGIN_TARGET"
            else
                echo -e "${RED}❌ Plugin nicht installiert${NC}"
                exit 1
            fi
            ;;
        *)
            echo "Usage: $0 [install|uninstall|status|restart|autostart|no-autostart|test]"
            echo ""
            echo "Befehle:"
            echo "  install       - Vollständige StatusBar-Installation (Standard)"
            echo "  uninstall     - Plugin entfernen"
            echo "  status        - Installations-Status anzeigen"
            echo "  restart       - SwiftBar neu starten"
            echo "  autostart     - Auto-Start aktivieren"
            echo "  no-autostart  - Auto-Start deaktivieren"
            echo "  test          - Plugin-Output testen"
            echo ""
            echo "Beispiele:"
            echo "  $0                    # Vollständige Installation"
            echo "  $0 install           # Vollständige Installation"
            echo "  $0 status            # Status prüfen"
            echo "  $0 autostart         # Auto-Start aktivieren"
            echo "  $0 uninstall         # Plugin entfernen"
            ;;
    esac
}

main "$@"