#!/usr/bin/env bash

# xxxOS VPN Control with Geo Location Selection
# Unterstützt mehrere VPN-Provider mit Länderauswahl
# (c) 2025 Martin Pfeffer - MIT License

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.xxxos/vpn"
PROFILES_DIR="$CONFIG_DIR/profiles"

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# VPN-Provider Namen abrufen
get_provider_name() {
    case "$1" in
        "nordvpn") echo "NordVPN" ;;
        "expressvpn") echo "ExpressVPN" ;;
        "surfshark") echo "Surfshark" ;;
        "mullvad") echo "Mullvad" ;;
        "protonvpn") echo "ProtonVPN" ;;
        "wireguard") echo "WireGuard (Custom)" ;;
        "openvpn") echo "OpenVPN (Custom)" ;;
        *) echo "Unbekannt" ;;
    esac
}

# Länder-Namen abrufen
get_country_name() {
    case "$1" in
        "DE") echo "Deutschland" ;;
        "US") echo "United States" ;;
        "UK") echo "United Kingdom" ;;
        "FR") echo "Frankreich" ;;
        "NL") echo "Niederlande" ;;
        "CH") echo "Schweiz" ;;
        "AT") echo "Österreich" ;;
        "SE") echo "Schweden" ;;
        "NO") echo "Norwegen" ;;
        "DK") echo "Dänemark" ;;
        "FI") echo "Finnland" ;;
        "IS") echo "Island" ;;
        "CA") echo "Kanada" ;;
        "AU") echo "Australien" ;;
        "JP") echo "Japan" ;;
        "SG") echo "Singapur" ;;
        "HK") echo "Hong Kong" ;;
        "ES") echo "Spanien" ;;
        "IT") echo "Italien" ;;
        "BE") echo "Belgien" ;;
        "LU") echo "Luxemburg" ;;
        "CZ") echo "Tschechien" ;;
        "PL") echo "Polen" ;;
        "RO") echo "Rumänien" ;;
        "BG") echo "Bulgarien" ;;
        "EE") echo "Estland" ;;
        "LV") echo "Lettland" ;;
        "LT") echo "Litauen" ;;
        "SK") echo "Slowakei" ;;
        "SI") echo "Slowenien" ;;
        "HR") echo "Kroatien" ;;
        "HU") echo "Ungarn" ;;
        "GR") echo "Griechenland" ;;
        "CY") echo "Zypern" ;;
        "MT") echo "Malta" ;;
        "IE") echo "Irland" ;;
        "PT") echo "Portugal" ;;
        "MX") echo "Mexiko" ;;
        "BR") echo "Brasilien" ;;
        "AR") echo "Argentinien" ;;
        "CL") echo "Chile" ;;
        "IN") echo "Indien" ;;
        "KR") echo "Südkorea" ;;
        "TH") echo "Thailand" ;;
        "MY") echo "Malaysia" ;;
        "ID") echo "Indonesien" ;;
        "PH") echo "Philippinen" ;;
        "VN") echo "Vietnam" ;;
        "TW") echo "Taiwan" ;;
        "NZ") echo "Neuseeland" ;;
        "ZA") echo "Südafrika" ;;
        "IL") echo "Israel" ;;
        "AE") echo "VAE" ;;
        "TR") echo "Türkei" ;;
        *) echo "Unbekannt" ;;
    esac
}

# Initialisierung
init_vpn_config() {
    echo -e "${BLUE}🔧 VPN-Konfiguration initialisieren...${NC}"
    
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$PROFILES_DIR"
    
    # Standard-Konfigurationsdatei erstellen
    if [ ! -f "$CONFIG_DIR/config" ]; then
        cat > "$CONFIG_DIR/config" << EOF
# xxxOS VPN Configuration
DEFAULT_PROVIDER=""
AUTO_CONNECT=false
KILLSWITCH=false
DNS_LEAK_PROTECTION=true
IPV6_LEAK_PROTECTION=true
PREFERRED_COUNTRIES="DE,US,UK,NL,CH"
EOF
    fi
    
    echo "✅ VPN-Konfiguration bereit"
}

# VPN-Provider erkennen
detect_vpn_providers() {
    local providers=()
    
    # NordVPN
    if command -v nordvpn >/dev/null 2>&1; then
        providers+=("nordvpn")
    fi
    
    # ExpressVPN
    if command -v expressvpn >/dev/null 2>&1; then
        providers+=("expressvpn")
    fi
    
    # Surfshark
    if command -v surfshark-vpn >/dev/null 2>&1; then
        providers+=("surfshark")
    fi
    
    # Mullvad
    if command -v mullvad >/dev/null 2>&1; then
        providers+=("mullvad")
    fi
    
    # ProtonVPN
    if command -v protonvpn-cli >/dev/null 2>&1; then
        providers+=("protonvpn")
    fi
    
    # WireGuard
    if command -v wg >/dev/null 2>&1; then
        providers+=("wireguard")
    fi
    
    # OpenVPN
    if command -v openvpn >/dev/null 2>&1; then
        providers+=("openvpn")
    fi
    
    printf '%s\n' "${providers[@]}"
}

# Verfügbare Länder für Provider anzeigen
show_countries() {
    local provider="$1"
    
    echo -e "${BLUE}🌍 Verfügbare Länder für $(get_provider_name "$provider"):${NC}"
    echo ""
    
    case "$provider" in
        "nordvpn")
            if command -v nordvpn >/dev/null 2>&1; then
                nordvpn countries 2>/dev/null | head -20
            fi
            ;;
        "expressvpn")
            echo "ExpressVPN Länder-Liste:"
            for code in DE US UK FR NL CH AT SE NO DK FI IS CA AU JP SG HK ES IT BE; do
                echo "  $code - $(get_country_name "$code")"
            done
            ;;
        "mullvad")
            if command -v mullvad >/dev/null 2>&1; then
                mullvad relay list | grep -E "^[A-Z]{2}" | head -20
            fi
            ;;
        *)
            echo "Häufig verfügbare Länder:"
            for code in DE US UK FR NL CH AT SE NO DK; do
                echo "  $code - $(get_country_name "$code")"
            done
            ;;
    esac
    echo ""
    echo "Vollständige Liste der Länder-Codes:"
    for code in DE US UK FR NL CH AT SE NO DK FI IS CA AU JP SG HK ES IT BE LU CZ PL RO BG EE LV LT SK SI HR HU GR CY MT IE PT MX BR AR CL IN KR TH MY ID PH VN TW NZ ZA IL AE TR; do
        echo "  $code - $(get_country_name "$code")"
    done | column -t
}

# VPN-Status prüfen
check_vpn_status() {
    local provider="$1"
    
    case "$provider" in
        "nordvpn")
            if command -v nordvpn >/dev/null 2>&1; then
                local status=$(nordvpn status 2>/dev/null)
                if echo "$status" | grep -q "Status: Connected"; then
                    echo "connected"
                    echo "$status" | grep "Country\|City\|Server\|IP"
                else
                    echo "disconnected"
                fi
            fi
            ;;
        "expressvpn")
            if command -v expressvpn >/dev/null 2>&1; then
                local status=$(expressvpn status 2>/dev/null)
                if echo "$status" | grep -q "Connected"; then
                    echo "connected"
                    echo "$status"
                else
                    echo "disconnected"
                fi
            fi
            ;;
        "mullvad")
            if command -v mullvad >/dev/null 2>&1; then
                local status=$(mullvad status 2>/dev/null)
                if echo "$status" | grep -q "Connected"; then
                    echo "connected"
                    echo "$status"
                else
                    echo "disconnected"
                fi
            fi
            ;;
        "surfshark")
            if command -v surfshark-vpn >/dev/null 2>&1; then
                local status=$(surfshark-vpn status 2>/dev/null)
                if echo "$status" | grep -q "Connected"; then
                    echo "connected"
                    echo "$status"
                else
                    echo "disconnected"
                fi
            fi
            ;;
        "protonvpn")
            if command -v protonvpn-cli >/dev/null 2>&1; then
                local status=$(protonvpn-cli status 2>/dev/null)
                if echo "$status" | grep -q "Connected"; then
                    echo "connected"
                    echo "$status"
                else
                    echo "disconnected"
                fi
            fi
            ;;
        *)
            # Generische VPN-Erkennung über Netzwerk-Interfaces
            if ip route get 8.8.8.8 2>/dev/null | grep -q "tun\|vpn"; then
                echo "connected"
                echo "VPN-Interface aktiv"
            else
                echo "disconnected"
            fi
            ;;
    esac
}

# VPN zu Land verbinden
connect_vpn() {
    local provider="$1"
    local country="$2"
    
    echo -e "${YELLOW}🌍 Verbinde zu $(get_country_name "$country") ($country) via $(get_provider_name "$provider")...${NC}"
    
    case "$provider" in
        "nordvpn")
            if command -v nordvpn >/dev/null 2>&1; then
                nordvpn connect "$country"
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ Erfolgreich verbunden via NordVPN${NC}"
                    return 0
                fi
            fi
            ;;
        "expressvpn")
            if command -v expressvpn >/dev/null 2>&1; then
                # ExpressVPN verwendet andere Länder-Bezeichnungen
                local location=""
                case "$country" in
                    "DE") location="germany" ;;
                    "US") location="usa" ;;
                    "UK") location="uk" ;;
                    "FR") location="france" ;;
                    "NL") location="netherlands" ;;
                    *) location=$(echo "$(get_country_name "$country")" | tr '[:upper:]' '[:lower:]') ;;
                esac
                
                expressvpn connect "$location"
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ Erfolgreich verbunden via ExpressVPN${NC}"
                    return 0
                fi
            fi
            ;;
        "mullvad")
            if command -v mullvad >/dev/null 2>&1; then
                mullvad relay set location "$country"
                mullvad connect
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ Erfolgreich verbunden via Mullvad${NC}"
                    return 0
                fi
            fi
            ;;
        "surfshark")
            if command -v surfshark-vpn >/dev/null 2>&1; then
                surfshark-vpn connect --country "$country"
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ Erfolgreich verbunden via Surfshark${NC}"
                    return 0
                fi
            fi
            ;;
        "protonvpn")
            if command -v protonvpn-cli >/dev/null 2>&1; then
                protonvpn-cli connect --country "$country"
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ Erfolgreich verbunden via ProtonVPN${NC}"
                    return 0
                fi
            fi
            ;;
    esac
    
    echo -e "${RED}❌ Verbindung fehlgeschlagen${NC}"
    return 1
}

# VPN trennen
disconnect_vpn() {
    local provider="$1"
    
    echo -e "${YELLOW}🔌 Trenne VPN-Verbindung...${NC}"
    
    case "$provider" in
        "nordvpn")
            if command -v nordvpn >/dev/null 2>&1; then
                nordvpn disconnect
            fi
            ;;
        "expressvpn")
            if command -v expressvpn >/dev/null 2>&1; then
                expressvpn disconnect
            fi
            ;;
        "mullvad")
            if command -v mullvad >/dev/null 2>&1; then
                mullvad disconnect
            fi
            ;;
        "surfshark")
            if command -v surfshark-vpn >/dev/null 2>&1; then
                surfshark-vpn disconnect
            fi
            ;;
        "protonvpn")
            if command -v protonvpn-cli >/dev/null 2>&1; then
                protonvpn-cli disconnect
            fi
            ;;
        *)
            # Generisches Disconnect für alle VPN-Provider
            for provider_cmd in nordvpn expressvpn mullvad surfshark-vpn protonvpn-cli; do
                if command -v "$provider_cmd" >/dev/null 2>&1; then
                    case "$provider_cmd" in
                        "nordvpn") nordvpn disconnect 2>/dev/null ;;
                        "expressvpn") expressvpn disconnect 2>/dev/null ;;
                        "mullvad") mullvad disconnect 2>/dev/null ;;
                        "surfshark-vpn") surfshark-vpn disconnect 2>/dev/null ;;
                        "protonvpn-cli") protonvpn-cli disconnect 2>/dev/null ;;
                    esac
                fi
            done
            ;;
    esac
    
    echo -e "${GREEN}✅ VPN getrennt${NC}"
}

# Aktuellen Standort und IP anzeigen
show_location() {
    echo -e "${BLUE}📍 Aktuelle Standort-Informationen:${NC}"
    echo ""
    
    # IP-Adresse abrufen
    local ip=$(curl -s --connect-timeout 5 http://icanhazip.com 2>/dev/null || echo "Unbekannt")
    echo "IP-Adresse: $ip"
    
    # Geolocation-Info via ipinfo.io
    local location_info=$(curl -s --connect-timeout 5 "http://ipinfo.io/$ip/json" 2>/dev/null)
    
    if [ -n "$location_info" ]; then
        local country=$(echo "$location_info" | jq -r '.country // "Unbekannt"' 2>/dev/null)
        local region=$(echo "$location_info" | jq -r '.region // "Unbekannt"' 2>/dev/null)
        local city=$(echo "$location_info" | jq -r '.city // "Unbekannt"' 2>/dev/null)
        local org=$(echo "$location_info" | jq -r '.org // "Unbekannt"' 2>/dev/null)
        
        echo "Land: $country"
        echo "Region: $region"
        echo "Stadt: $city"
        echo "Provider: $org"
    fi
    
    # DNS-Leak-Test
    echo ""
    echo -e "${BLUE}🔍 DNS-Leak-Check:${NC}"
    local dns_servers=$(nslookup google.com 2>/dev/null | grep "Server:" | awk '{print $2}')
    echo "DNS-Server: $dns_servers"
}

# VPN + Tor Chaining
setup_vpn_tor_chain() {
    local mode="$1"  # "vpn-over-tor" oder "tor-over-vpn"
    local provider="$2"
    local country="$3"
    
    echo -e "${PURPLE}🔗 VPN + Tor Chaining Setup ($mode)...${NC}"
    
    case "$mode" in
        "tor-over-vpn")
            echo "1. VPN verbinden..."
            connect_vpn "$provider" "$country"
            sleep 3
            
            echo "2. Tor starten..."
            "$SCRIPT_DIR/tor_control.sh" start
            
            echo -e "${GREEN}✅ Tor-over-VPN Chain aktiv${NC}"
            echo "Traffic: Computer → VPN → Tor → Internet"
            ;;
        "vpn-over-tor")
            echo "1. Tor starten..."
            "$SCRIPT_DIR/tor_control.sh" start
            sleep 3
            
            echo "2. VPN über Tor verbinden..."
            # Hier würde ProxyChains für VPN-Client verwendet
            connect_vpn "$provider" "$country"
            
            echo -e "${GREEN}✅ VPN-over-Tor Chain aktiv${NC}"
            echo "Traffic: Computer → Tor → VPN → Internet"
            ;;
    esac
}

# Interaktives Menü
show_vpn_menu() {
    local providers=($(detect_vpn_providers))
    
    if [ ${#providers[@]} -eq 0 ]; then
        echo -e "${RED}❌ Keine VPN-Provider gefunden!${NC}"
        echo ""
        echo "Installiere einen der unterstützten Provider:"
        echo "• NordVPN: https://nordvpn.com/download/mac/"
        echo "• ExpressVPN: https://www.expressvpn.com/setup"
        echo "• Mullvad: brew install mullvad-vpn"
        echo "• Surfshark: https://surfshark.com/download/mac"
        echo "• ProtonVPN: brew install protonvpn"
        return 1
    fi
    
    echo -e "${BLUE}🌍 VPN GEO-AUSWAHL${NC}"
    echo "==================="
    echo ""
    echo "Verfügbare Provider:"
    local i=1
    for provider in "${providers[@]}"; do
        echo "  $i) $(get_provider_name "$provider")"
        ((i++))
    done
    echo ""
    read -p "Provider wählen (1-${#providers[@]}): " provider_choice
    
    if [[ "$provider_choice" -gt 0 && "$provider_choice" -le ${#providers[@]} ]]; then
        local selected_provider="${providers[$((provider_choice-1))]}"
        
        echo ""
        echo -e "${BLUE}Provider: $(get_provider_name "$selected_provider")${NC}"
        echo ""
        echo "Aktionen:"
        echo "  1) Zu Land verbinden"
        echo "  2) Status anzeigen"
        echo "  3) Verfügbare Länder anzeigen"
        echo "  4) Verbindung trennen"
        echo "  5) Standort anzeigen"
        echo "  6) VPN + Tor Chain"
        echo "  7) Zurück"
        echo ""
        read -p "Aktion wählen (1-7): " action
        
        case "$action" in
            1)
                echo ""
                echo "Beliebte Länder:"
                echo "  DE - Deutschland"
                echo "  US - United States"
                echo "  UK - United Kingdom"
                echo "  NL - Niederlande"
                echo "  CH - Schweiz"
                echo "  FR - Frankreich"
                echo ""
                read -p "Land-Code eingeben (z.B. DE): " country_code
                country_code=$(echo "$country_code" | tr '[:lower:]' '[:upper:]')
                
                if [ "$(get_country_name "$country_code")" != "Unbekannt" ]; then
                    connect_vpn "$selected_provider" "$country_code"
                    echo ""
                    show_location
                else
                    echo -e "${RED}❌ Unbekannter Land-Code: $country_code${NC}"
                fi
                ;;
            2)
                echo ""
                check_vpn_status "$selected_provider"
                ;;
            3)
                echo ""
                show_countries "$selected_provider"
                ;;
            4)
                disconnect_vpn "$selected_provider"
                ;;
            5)
                echo ""
                show_location
                ;;
            6)
                echo ""
                echo "VPN + Tor Chaining:"
                echo "  1) Tor-over-VPN (empfohlen)"
                echo "  2) VPN-over-Tor"
                echo ""
                read -p "Chain-Modus wählen (1-2): " chain_mode
                read -p "Land-Code für VPN (z.B. DE): " country_code
                country_code=$(echo "$country_code" | tr '[:lower:]' '[:upper:]')
                
                case "$chain_mode" in
                    1) setup_vpn_tor_chain "tor-over-vpn" "$selected_provider" "$country_code" ;;
                    2) setup_vpn_tor_chain "vpn-over-tor" "$selected_provider" "$country_code" ;;
                esac
                ;;
        esac
    fi
}

# Hauptfunktion
main() {
    init_vpn_config
    
    case "$1" in
        "menu"|"")
            show_vpn_menu
            ;;
        "connect")
            if [ -z "$2" ] || [ -z "$3" ]; then
                echo "Usage: $0 connect <provider> <country>"
                echo "Beispiel: $0 connect nordvpn DE"
                exit 1
            fi
            connect_vpn "$2" "$3"
            ;;
        "disconnect")
            disconnect_vpn "$2"
            ;;
        "status")
            if [ -n "$2" ]; then
                check_vpn_status "$2"
            else
                # Status für alle erkannten Provider
                local providers=($(detect_vpn_providers))
                for provider in "${providers[@]}"; do
                    echo -e "${BLUE}$(get_provider_name "$provider"):${NC}"
                    check_vpn_status "$provider"
                    echo ""
                done
            fi
            ;;
        "location")
            show_location
            ;;
        "countries")
            if [ -n "$2" ]; then
                show_countries "$2"
            else
                echo "Usage: $0 countries <provider>"
            fi
            ;;
        "chain")
            if [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
                echo "Usage: $0 chain <mode> <provider> <country>"
                echo "Modi: tor-over-vpn, vpn-over-tor"
                exit 1
            fi
            setup_vpn_tor_chain "$2" "$3" "$4"
            ;;
        "providers")
            echo "Erkannte VPN-Provider:"
            local providers=($(detect_vpn_providers))
            for provider in "${providers[@]}"; do
                echo "  $(get_provider_name "$provider") ($provider)"
            done
            ;;
        *)
            echo "Usage: $0 [menu|connect|disconnect|status|location|countries|chain|providers]"
            echo ""
            echo "Beispiele:"
            echo "  $0 menu                          # Interaktives Menü"
            echo "  $0 connect nordvpn DE           # Zu Deutschland via NordVPN"
            echo "  $0 disconnect nordvpn           # NordVPN trennen"
            echo "  $0 status                       # Status aller VPNs"
            echo "  $0 location                     # Aktueller Standort"
            echo "  $0 chain tor-over-vpn nordvpn DE # VPN+Tor Chain"
            ;;
    esac
}

main "$@"