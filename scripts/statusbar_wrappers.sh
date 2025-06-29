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
        "$XXXOS_DIR/xxxos.sh" privacy on
        keep_terminal_open
        ;;
    "privacy-off")
        "$XXXOS_DIR/xxxos.sh" privacy off
        keep_terminal_open
        ;;
    "privacy-ultra")
        "$XXXOS_DIR/xxxos.sh" privacy ultra
        keep_terminal_open
        ;;
    "tor-status")
        "$XXXOS_DIR/scripts/tor_control.sh" status
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
    "torshell")
        cd "$XXXOS_DIR" && torshell
        ;;
    *)
        echo "Usage: $0 [status|privacy-on|privacy-off|privacy-ultra|tor-status|ipinfo|security-full|xxxos|torshell]"
        ;;
esac