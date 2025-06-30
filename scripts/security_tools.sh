#!/bin/bash

# xxxOS Security Tools Suite
# Defensive Security-Analyse-Funktionen

# Farben
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Banner
show_security_banner() {
    echo -e "${BLUE}"
    echo "🛡️  xxxOS SECURITY TOOLS"
    echo "========================"
    echo -e "${NC}"
}

# System Security Check
system_security_check() {
    echo -e "${BLUE}🔍 System Security Analysis${NC}"
    echo "============================"
    echo ""
    
    # Firewall Status
    echo -e "${YELLOW}[1] Firewall Status:${NC}"
    local fw_status=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null | grep "enabled")
    if [ -n "$fw_status" ]; then
        echo "    ✅ Firewall ist aktiviert"
        local stealth=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode 2>/dev/null | grep "enabled")
        if [ -n "$stealth" ]; then
            echo "    ✅ Stealth-Modus aktiviert"
        else
            echo "    ⚠️  Stealth-Modus deaktiviert"
        fi
    else
        echo "    ❌ Firewall ist deaktiviert!"
    fi
    echo ""
    
    # SIP Status
    echo -e "${YELLOW}[2] System Integrity Protection:${NC}"
    local sip_status=$(csrutil status | grep -o "enabled\|disabled")
    if [ "$sip_status" = "enabled" ]; then
        echo "    ✅ SIP ist aktiviert"
    else
        echo "    ⚠️  SIP ist deaktiviert"
    fi
    echo ""
    
    # Gatekeeper Status
    echo -e "${YELLOW}[3] Gatekeeper Status:${NC}"
    local gatekeeper_status=$(spctl --status 2>/dev/null | grep -o "enabled\|disabled")
    if [ "$gatekeeper_status" = "enabled" ]; then
        echo "    ✅ Gatekeeper ist aktiviert"
    else
        echo "    ❌ Gatekeeper ist deaktiviert!"
    fi
    echo ""
    
    # FileVault Status
    echo -e "${YELLOW}[4] FileVault Verschlüsselung:${NC}"
    local filevault_status=$(fdesetup status | grep -o "On\|Off")
    if [ "$filevault_status" = "On" ]; then
        echo "    ✅ FileVault ist aktiviert"
    else
        echo "    ❌ FileVault ist deaktiviert!"
    fi
    echo ""
    
    # Suspicious Processes
    echo -e "${YELLOW}[5] Verdächtige Prozesse:${NC}"
    local suspicious_count=$(ps aux | grep -E "(nc -l|/bin/sh|python -m SimpleHTTPServer|python3 -m http.server)" | grep -v grep | wc -l)
    if [ $suspicious_count -eq 0 ]; then
        echo "    ✅ Keine verdächtigen Prozesse gefunden"
    else
        echo "    ⚠️  $suspicious_count verdächtige Prozesse gefunden!"
        ps aux | grep -E "(nc -l|/bin/sh|python -m SimpleHTTPServer|python3 -m http.server)" | grep -v grep | head -5
    fi
    echo ""
}

# Network Security Scan
network_security_scan() {
    echo -e "${BLUE}🌐 Network Security Scan${NC}"
    echo "========================"
    echo ""
    
    # Offene Ports
    echo -e "${YELLOW}[1] Offene Ports (Listening):${NC}"
    echo "    Scanne lokale Ports..."
    lsof -i -P | grep LISTEN | awk '{print "    Port " $9 " - " $1}' | sort -u
    echo ""
    
    # Aktive Verbindungen
    echo -e "${YELLOW}[2] Aktive Netzwerkverbindungen:${NC}"
    local connection_count=$(netstat -an | grep ESTABLISHED | wc -l)
    echo "    Gefunden: $connection_count aktive Verbindungen"
    
    # Zeige verdächtige ausgehende Verbindungen
    echo ""
    echo -e "${YELLOW}[3] Ausgehende Verbindungen:${NC}"
    netstat -an | grep ESTABLISHED | grep -v "127.0.0.1" | head -10
    echo ""
}

# DNS Security Check
dns_security_check() {
    echo -e "${BLUE}🔐 DNS Security Check${NC}"
    echo "====================="
    echo ""
    
    # Aktuelle DNS Server
    echo -e "${YELLOW}[1] Konfigurierte DNS Server:${NC}"
    scutil --dns | grep "nameserver" | sort -u | head -5
    echo ""
    
    # DNS Leak Test
    echo -e "${YELLOW}[2] DNS Leak Test:${NC}"
    echo "    Teste DNS Auflösung..."
    local test_ip=$(dig +short myip.opendns.com @resolver1.opendns.com 2>/dev/null)
    local tor_check=$(curl -s --socks5 localhost:9050 https://check.torproject.org/api/ip 2>/dev/null | jq -r '.IsTor' 2>/dev/null)
    
    if [ "$tor_check" = "true" ]; then
        echo "    ✅ DNS-Anfragen gehen über Tor"
    else
        echo "    ⚠️  DNS-Anfragen gehen NICHT über Tor"
        echo "    Ihre öffentliche IP: $test_ip"
    fi
    echo ""
}

# Privacy Audit
privacy_audit() {
    echo -e "${BLUE}🕵️ Privacy Audit${NC}"
    echo "================"
    echo ""
    
    # Browser Privacy
    echo -e "${YELLOW}[1] Browser-Daten:${NC}"
    local safari_history=$(find ~/Library/Safari -name "History.db" 2>/dev/null | wc -l)
    local chrome_history=$(find ~/Library/Application\ Support/Google/Chrome -name "History" 2>/dev/null | wc -l)
    
    [ $safari_history -gt 0 ] && echo "    ⚠️  Safari-Verlauf vorhanden"
    [ $chrome_history -gt 0 ] && echo "    ⚠️  Chrome-Verlauf vorhanden"
    echo ""
    
    # Clipboard
    echo -e "${YELLOW}[2] Zwischenablage:${NC}"
    local clipboard_size=$(pbpaste | wc -c)
    if [ $clipboard_size -gt 0 ]; then
        echo "    ⚠️  Zwischenablage enthält $clipboard_size Zeichen"
        echo "    Tipp: Leeren mit: pbcopy < /dev/null"
    else
        echo "    ✅ Zwischenablage ist leer"
    fi
    echo ""
    
    # Recent Items
    echo -e "${YELLOW}[3] Zuletzt verwendete Objekte:${NC}"
    local recent_count=$(ls -la ~/Library/Application\ Support/com.apple.sharedfilelist/*.sfl2 2>/dev/null | wc -l)
    if [ $recent_count -gt 0 ]; then
        echo "    ⚠️  $recent_count Listen mit zuletzt verwendeten Objekten"
        echo "    Tipp: Löschen über Systemeinstellungen → Allgemein → Zuletzt benutzte Objekte"
    else
        echo "    ✅ Keine Listen gefunden"
    fi
    echo ""
}

# Vulnerability Check
vulnerability_check() {
    echo -e "${BLUE}🐛 Vulnerability Check${NC}"
    echo "======================"
    echo ""
    
    # macOS Version
    echo -e "${YELLOW}[1] System Version:${NC}"
    sw_vers
    echo ""
    
    # Homebrew Packages
    echo -e "${YELLOW}[2] Veraltete Homebrew-Pakete:${NC}"
    if command -v brew > /dev/null 2>&1; then
        local outdated=$(brew outdated | wc -l)
        if [ $outdated -gt 0 ]; then
            echo "    ⚠️  $outdated veraltete Pakete gefunden"
            brew outdated | head -5
            echo "    Tipp: Aktualisieren mit: brew upgrade"
        else
            echo "    ✅ Alle Pakete sind aktuell"
        fi
    else
        echo "    ℹ️  Homebrew nicht installiert"
    fi
    echo ""
    
    # SSH Keys
    echo -e "${YELLOW}[3] SSH-Schlüssel Sicherheit:${NC}"
    if [ -d ~/.ssh ]; then
        local weak_keys=$(find ~/.ssh -name "*.pub" -exec ssh-keygen -l -f {} \; 2>/dev/null | grep -E "(1024|weak)" | wc -l)
        if [ $weak_keys -gt 0 ]; then
            echo "    ⚠️  $weak_keys schwache SSH-Schlüssel gefunden"
        else
            echo "    ✅ Keine schwachen SSH-Schlüssel gefunden"
        fi
        
        # Permissions check
        local bad_perms=$(find ~/.ssh -type f -name "id_*" ! -name "*.pub" -perm +044 2>/dev/null | wc -l)
        if [ $bad_perms -gt 0 ]; then
            echo "    ❌ $bad_perms private Schlüssel mit unsicheren Berechtigungen!"
        else
            echo "    ✅ SSH-Schlüssel-Berechtigungen sind sicher"
        fi
    else
        echo "    ℹ️  Kein SSH-Verzeichnis gefunden"
    fi
    echo ""
}

# Main menu
case "$1" in
    "system")
        show_security_banner
        system_security_check
        ;;
    "network")
        show_security_banner
        network_security_scan
        ;;
    "dns")
        show_security_banner
        dns_security_check
        ;;
    "privacy")
        show_security_banner
        privacy_audit
        ;;
    "vuln")
        show_security_banner
        vulnerability_check
        ;;
    "full")
        show_security_banner
        system_security_check
        echo ""
        network_security_scan
        echo ""
        dns_security_check
        echo ""
        privacy_audit
        echo ""
        vulnerability_check
        ;;
    *)
        show_security_banner
        echo "Verfügbare Security Checks:"
        echo ""
        echo "  system  - System-Sicherheitsanalyse"
        echo "  network - Netzwerk-Sicherheitsscan"
        echo "  dns     - DNS-Sicherheitscheck"
        echo "  privacy - Privacy-Audit"
        echo "  vuln    - Vulnerability-Check"
        echo "  full    - Komplette Sicherheitsanalyse"
        echo ""
        echo "Verwendung: $0 [system|network|dns|privacy|vuln|full]"
        ;;
esac