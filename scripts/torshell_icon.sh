#!/bin/bash

# xxxOS Tor Shell Icon Changer
# Ändert das Icon in der Tor-Shell Prompt
# (c) 2025 Martin Pfeffer - MIT License

WRAPPER_DIR="/tmp/tor_wrappers"

# Verfügbare Icons
show_icons() {
    echo "🕵️ Tor Shell Icon Changer"
    echo "========================="
    echo ""
    echo "Verfügbare Icons:"
    echo "  1) 🧅  Zwiebel (Original)"
    echo "  2) 🔒  Schloss"
    echo "  3) 🛡️  Schild" 
    echo "  4) 🕶️  Sonnenbrille"
    echo "  5) 🕵️‍♂️  Detective"
    echo "  6) 🎭  Maske"
    echo "  7) 👤  Silhouette"
    echo "  8) 🌐  Globe"
    echo "  9) ⚡  Blitz"
    echo " 10) 🔐  Verschlossen"
    echo " 11) 🥷  Ninja"
    echo " 12) 👻  Geist"
    echo ""
}

# Icon auswählen
get_icon() {
    case "$1" in
        1) echo "🧅" ;;
        2) echo "🔒" ;;
        3) echo "🛡️" ;;
        4) echo "🕶️" ;;
        5) echo "🕵️" ;;
        6) echo "🎭" ;;
        7) echo "👤" ;;
        8) echo "🌐" ;;
        9) echo "⚡" ;;
        10) echo "🔐" ;;
        11) echo "🥷" ;;
        12) echo "👻" ;;
        *) echo "" ;;
    esac
}

# Icon Name für Anzeige
get_icon_name() {
    case "$1" in
        1) echo "Zwiebel" ;;
        2) echo "Schloss" ;;
        3) echo "Schild" ;;
        4) echo "Sonnenbrille" ;;
        5) echo "Detective" ;;
        6) echo "Maske" ;;
        7) echo "Silhouette" ;;
        8) echo "Globe" ;;
        9) echo "Blitz" ;;
        10) echo "Verschlossen" ;;
        11) echo "Ninja" ;;
        12) echo "Geist" ;;
        *) echo "Unbekannt" ;;
    esac
}

# Tor-Shell Konfiguration erstellen
update_torshell_config() {
    local icon="$1"
    local icon_name="$2"
    
    mkdir -p "$WRAPPER_DIR"
    
    cat > "$WRAPPER_DIR/.zshrc" << EOF
export PS1="%{${icon}%}  [TOR] %1~ %#%{ %}"
alias checkip='curl https://check.torproject.org/api/ip'
alias myip='curl http://icanhazip.com'
echo "🔥 Tor-Shell aktiv ($icon_name)! Teste mit: checkip"
EOF
    
    echo "✅ Tor-Shell Icon geändert zu: $icon ($icon_name)"
    echo ""
    echo "Starte die Tor-Shell mit: torshell"
}

# Aktuelles Icon anzeigen
show_current() {
    if [ -f "$WRAPPER_DIR/.zshrc" ]; then
        local current_prompt=$(grep "export PS1=" "$WRAPPER_DIR/.zshrc" | cut -d'"' -f2)
        local current_icon=$(echo "$current_prompt" | cut -d'[' -f1)
        echo "Aktuelles Icon: $current_icon"
        echo ""
    else
        echo "Tor-Shell noch nicht konfiguriert."
        echo ""
    fi
}

# Hauptfunktion
main() {
    case "$1" in
        show)
            show_icons
            show_current
            ;;
        set)
            if [ -z "$2" ]; then
                echo "Fehler: Nummer des Icons angeben"
                echo "Usage: $0 set <1-12>"
                exit 1
            fi
            
            icon=$(get_icon "$2")
            icon_name=$(get_icon_name "$2")
            
            if [ -z "$icon" ]; then
                echo "Fehler: Ungültige Icon-Nummer: $2"
                echo "Verfügbare Nummern: 1-12"
                exit 1
            fi
            
            update_torshell_config "$icon" "$icon_name"
            ;;
        current)
            show_current
            ;;
        *)
            # Interaktiver Modus - zeige Icons und frage nach Auswahl
            show_icons
            show_current
            
            read -p "Welches Icon möchtest du verwenden? (1-12): " choice
            echo ""
            
            if [[ "$choice" =~ ^[1-9]$|^1[0-2]$ ]]; then
                icon=$(get_icon "$choice")
                icon_name=$(get_icon_name "$choice")
                
                echo "Du hast gewählt: $icon ($icon_name)"
                read -p "Bestätigen? (j/N): " confirm
                
                if [[ "$confirm" =~ ^[Jj]$ ]]; then
                    update_torshell_config "$icon" "$icon_name"
                    echo ""
                    echo "🚀 Starte Tor-Shell zum Testen:"
                    echo "   torshell"
                else
                    echo "❌ Abgebrochen."
                fi
            else
                echo "❌ Ungültige Eingabe. Bitte Nummer zwischen 1-12 eingeben."
                exit 1
            fi
            ;;
    esac
}

main "$@"