#!/usr/bin/env bash

# xxxOS StatusBar Launcher
# Startet SwiftBar automatisch wenn Plugin installiert ist
# (c) 2025 Martin Pfeffer - MIT License

# Pfade
SWIFTBAR_APP="/Applications/SwiftBar.app"
PLUGIN_TARGET="$HOME/Library/Application Support/SwiftBar/Plugins/tor_status.5s.sh"

# Prüfe ob Plugin installiert ist
if [ ! -f "$PLUGIN_TARGET" ]; then
    exit 0  # Plugin nicht installiert, nichts zu tun
fi

# Prüfe ob SwiftBar installiert ist
if [ ! -d "$SWIFTBAR_APP" ]; then
    exit 0  # SwiftBar nicht installiert
fi

# Prüfe ob SwiftBar bereits läuft
if pgrep -f "SwiftBar" >/dev/null 2>&1; then
    exit 0  # SwiftBar läuft bereits
fi

# Starte SwiftBar im Hintergrund
open "$SWIFTBAR_APP" 2>/dev/null &

exit 0