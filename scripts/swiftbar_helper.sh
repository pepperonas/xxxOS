#!/bin/bash

# SwiftBar Helper Functions für xxxOS
# Stellt Funktionen zum automatischen Neustarten von SwiftBar bereit

SWIFTBAR_APP="/Applications/SwiftBar.app"

# Funktion zum Neustarten von SwiftBar
restart_swiftbar() {
    # Prüfe ob SwiftBar installiert ist
    if [ ! -d "$SWIFTBAR_APP" ]; then
        return 0  # SwiftBar nicht installiert, nichts zu tun
    fi
    
    # Prüfe ob SwiftBar läuft
    if pgrep -f "SwiftBar" >/dev/null 2>&1; then
        # SwiftBar läuft - neu starten
        sudo killall SwiftBar 2>/dev/null
        sleep 0.5
        open "$SWIFTBAR_APP" 2>/dev/null &
    else
        # SwiftBar läuft nicht - nur starten
        open "$SWIFTBAR_APP" 2>/dev/null &
    fi
}

# Funktion zum Aktualisieren des SwiftBar-Plugins
refresh_swiftbar() {
    # Prüfe ob SwiftBar läuft
    if pgrep -f "SwiftBar" >/dev/null 2>&1; then
        # Sende Refresh-Signal an SwiftBar (funktioniert nur wenn SwiftBar läuft)
        osascript -e 'tell application "SwiftBar" to refresh' 2>/dev/null || true
    fi
}

# Funktion zum stillen Neustarten (ohne Ausgabe)
silent_restart_swiftbar() {
    restart_swiftbar >/dev/null 2>&1
}

# Export der Funktionen für andere Skripte
export -f restart_swiftbar
export -f refresh_swiftbar
export -f silent_restart_swiftbar