#!/bin/bash

# Sudo Cache Helper für xxxOS
# Globaler Sudo-Cache der zwischen Sessions funktioniert

CACHE_PID_FILE="/tmp/.xxxos_sudo_cache.pid"
CACHE_LOCK_FILE="/tmp/.xxxos_sudo_cache.lock"

# Farben
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Prüfe ob bereits eine Cache-Session aktiv ist
is_cache_active() {
    [ -f "$CACHE_PID_FILE" ] && kill -0 "$(cat "$CACHE_PID_FILE")" 2>/dev/null
}

# Starte globalen Sudo-Cache
start_cache() {
    # Prüfe ob bereits aktiv
    if is_cache_active; then
        # Prüfe ob sudo auch wirklich funktioniert
        if sudo -n true 2>/dev/null; then
            echo -e "${GREEN}✅ Sudo-Cache bereits aktiv${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠️  Cache aktiv aber sudo abgelaufen - erneuere...${NC}"
            # Cache stoppen und neu starten
            stop_cache
        fi
    fi
    
    # Lock-Datei erstellen um Doppelstart zu vermeiden
    if ! (set -C; echo $$ > "$CACHE_LOCK_FILE") 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Sudo-Cache wird bereits gestartet...${NC}"
        sleep 2
        if is_cache_active; then
            echo -e "${GREEN}✅ Sudo-Cache ist nun aktiv${NC}"
            return 0
        fi
    fi
    
    echo -e "${YELLOW}🔐 Administrator-Berechtigung erforderlich${NC}"
    echo -e "${BLUE}Diese Berechtigung wird für alle xxxOS-Sessions gecached.${NC}"
    echo ""
    
    # Sudo-Berechtigung anfordern
    if ! sudo -v 2>/dev/null; then
        echo -e "${RED}❌ Sudo-Berechtigung fehlgeschlagen${NC}"
        rm -f "$CACHE_LOCK_FILE"
        return 1
    fi
    
    echo -e "${GREEN}✅ Sudo-Cache gestartet${NC}"
    
    # Hintergrund-Prozess für Cache-Erneuerung
    (
        trap 'rm -f "$CACHE_PID_FILE" "$CACHE_LOCK_FILE"; exit' INT TERM EXIT
        
        # PID speichern
        echo $$ > "$CACHE_PID_FILE"
        
        # Cache alle 4 Minuten erneuern
        while true; do
            if ! sudo -n true 2>/dev/null; then
                echo -e "${RED}❌ Sudo-Cache verloren${NC}"
                break
            fi
            sleep 240
        done
    ) &
    
    # Lock-Datei entfernen
    rm -f "$CACHE_LOCK_FILE"
    
    return 0
}

# Stoppe Sudo-Cache
stop_cache() {
    if [ -f "$CACHE_PID_FILE" ]; then
        local pid=$(cat "$CACHE_PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null
            echo -e "${GREEN}✅ Sudo-Cache gestoppt${NC}"
        fi
        rm -f "$CACHE_PID_FILE"
    fi
    rm -f "$CACHE_LOCK_FILE"
}

# Cache-Status prüfen
check_cache() {
    if is_cache_active; then
        echo -e "${GREEN}✅ Sudo-Cache aktiv${NC}"
        if sudo -n true 2>/dev/null; then
            echo -e "${GREEN}✅ Sudo-Berechtigung verfügbar${NC}"
        else
            echo -e "${RED}❌ Sudo-Berechtigung nicht verfügbar${NC}"
        fi
    else
        echo -e "${RED}❌ Sudo-Cache nicht aktiv${NC}"
    fi
}

# Sudo mit Auto-Cache
cached_sudo() {
    # Prüfe ob Cache aktiv ist
    if ! is_cache_active; then
        echo -e "${BLUE}🔐 Starte Sudo-Cache...${NC}"
        start_cache || return 1
    fi
    
    # Prüfe ob sudo funktioniert
    if ! sudo -n true 2>/dev/null; then
        echo -e "${BLUE}🔐 Sudo-Berechtigung erforderlich...${NC}"
        start_cache || return 1
    fi
    
    # Führe sudo-Befehl aus
    sudo "$@"
}

case "$1" in
    start)
        start_cache
        ;;
    stop)
        stop_cache
        ;;
    status)
        check_cache
        ;;
    cached-sudo)
        shift
        cached_sudo "$@"
        ;;
    "")
        # Default: starte Cache
        start_cache
        ;;
    *)
        echo "Usage: $0 {start|stop|status|cached-sudo <command>}"
        echo ""
        echo "Globaler Sudo-Cache für xxxOS"
        echo ""
        echo "  start        - Starte Sudo-Cache"
        echo "  stop         - Stoppe Sudo-Cache"
        echo "  status       - Prüfe Cache-Status"
        echo "  cached-sudo  - Führe sudo-Befehl mit Auto-Cache aus"
        ;;
esac