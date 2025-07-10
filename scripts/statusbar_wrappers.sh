#!/bin/bash

# Wrapper scripts für StatusBar - halten Terminal offen
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XXXOS_DIR="$(dirname "$SCRIPT_DIR")"

# Funktion um Terminal offen zu halten
keep_terminal_open() {
    echo ""
    echo "Drücke Enter zum Schließen oder Cmd+W..."
    read -r
}

case "$1" in
    "status")
        "$XXXOS_DIR/xxxos.sh" status
        keep_terminal_open
        ;;
    "privacy-on")
        "$XXXOS_DIR/xxxos.sh" privacy-on
        keep_terminal_open
        ;;
    "privacy-off")
        "$XXXOS_DIR/xxxos.sh" privacy-off
        keep_terminal_open
        ;;
    "privacy-ultra")
        echo "⚠️  Ultra Privacy Mode wurde vereinfacht."
        echo "Verwende stattdessen: privacy-on"
        echo ""
        "$XXXOS_DIR/xxxos.sh" privacy-on
        keep_terminal_open
        ;;
    "tor-status")
        "$XXXOS_DIR/scripts/tor_control.sh" status
        keep_terminal_open
        ;;
    "tor-transparent-status")
        "$XXXOS_DIR/scripts/tor_transparent.sh" status
        keep_terminal_open
        ;;
    "ipinfo")
        "$XXXOS_DIR/xxxos.sh" ipinfo
        keep_terminal_open
        ;;
    "security-full")
        "$XXXOS_DIR/xxxos.sh" security full
        keep_terminal_open
        ;;
    "xxxos")
        cd "$XXXOS_DIR" && ./xxxos.sh
        ;;
    "tor-terminal")
        echo "🔒 Tor-Terminal Konfiguration"
        echo "=========================="
        echo ""
        echo "Nach transparentem Tor aktivieren:"
        echo "  ./xxxos.sh tor trans-on"
        echo ""
        echo "Dann in neuer Terminal-Session:"
        echo "  source /tmp/tor_shell_config"
        echo "  curl https://check.torproject.org/api/ip"
        echo ""
        echo "Verfügbare Tor-Befehle:"
        echo "  curl, git, gobuster, nmap, sqlmap"
        echo ""
        keep_terminal_open
        ;;
    *)
        echo "Usage: $0 [status|privacy-on|privacy-off|tor-status|ipinfo|xxxos|tor-terminal]"
        echo ""
        echo "Vereinfachte xxxOS StatusBar-Wrapper"
        ;;
esac