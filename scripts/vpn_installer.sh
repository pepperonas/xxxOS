#!/bin/bash

# VPN Provider Installer Helper
# Hilft bei der Installation von VPN-Providern für xxxOS

echo "🌍 VPN Provider Installer für xxxOS"
echo "==================================="
echo ""

echo "Verfügbare VPN-Provider:"
echo ""
echo "1) ProtonVPN (Homebrew - einfach)"
echo "2) Mullvad (Direkt-Download)"
echo "3) Tunnelblick (OpenVPN - Homebrew)"
echo "4) WireGuard (Homebrew)"
echo "5) Info über kommerzielle Provider"
echo ""

read -p "Provider wählen (1-5 oder Name): " choice

case "$choice" in
    1|protonvpn|proton)
        echo ""
        echo "📦 Installiere ProtonVPN..."
        if brew install --cask protonvpn; then
            echo "✅ ProtonVPN erfolgreich installiert!"
            echo ""
            echo "Nächste Schritte:"
            echo "1. ProtonVPN öffnen und Account einrichten"
            echo "2. CLI aktivieren: protonvpn-cli login"
            echo "3. Testen: ./xxxos.sh vpn providers"
        else
            echo "❌ Installation fehlgeschlagen"
        fi
        ;;
    2|mullvad)
        echo ""
        echo "📦 Mullvad Installation (Manuell)..."
        echo ""
        echo "1. Öffne: https://mullvad.net/en/download/app/"
        echo "2. Lade 'MullvadVPN-*.pkg' für macOS herunter"
        echo "3. Doppelklick auf .pkg Datei zur Installation"
        echo "4. Nach Installation: Mullvad öffnen und Account einrichten"
        echo ""
        echo "Alternative - Terminal Download:"
        echo "curl -L -o ~/Downloads/MullvadVPN.pkg 'https://cdn.mullvad.net/app/desktop/releases/2025.7/MullvadVPN-2025.7.pkg'"
        echo "sudo installer -pkg ~/Downloads/MullvadVPN.pkg -target /"
        ;;
    3|tunnelblick|openvpn)
        echo ""
        echo "📦 Installiere Tunnelblick (OpenVPN)..."
        if brew install --cask tunnelblick; then
            echo "✅ Tunnelblick erfolgreich installiert!"
            echo ""
            echo "Nächste Schritte:"
            echo "1. OpenVPN-Konfigurationsdateien (.ovpn) von deinem VPN-Provider besorgen"
            echo "2. Dateien in Tunnelblick importieren"
            echo "3. Verbindung testen"
        else
            echo "❌ Installation fehlgeschlagen"
        fi
        ;;
    4|wireguard)
        echo ""
        echo "📦 Installiere WireGuard..."
        if brew install --cask wireguard-tools && brew install --cask wireguard; then
            echo "✅ WireGuard erfolgreich installiert!"
            echo ""
            echo "Nächste Schritte:"
            echo "1. WireGuard-Konfigurationsdateien (.conf) besorgen"
            echo "2. Konfiguration in WireGuard importieren"
            echo "3. Verbindung testen"
        else
            echo "❌ Installation fehlgeschlagen"
        fi
        ;;
    5|info|commercial)
        echo ""
        echo "💡 Kommerzielle VPN-Provider:"
        echo ""
        echo "🔵 NordVPN:"
        echo "   Website: https://nordvpn.com/download/mac/"
        echo "   CLI: Nach Installation verfügbar als 'nordvpn'"
        echo ""
        echo "🔴 ExpressVPN:"
        echo "   Website: https://www.expressvpn.com/setup"
        echo "   CLI: Nach Installation verfügbar als 'expressvpn'"
        echo ""
        echo "🦈 Surfshark:"
        echo "   Website: https://surfshark.com/download/mac"
        echo "   CLI: Nach Installation verfügbar"
        echo ""
        echo "⚡ Diese Provider bieten meist bessere Integration mit xxxOS"
        echo "   da sie eigene CLI-Tools mitbringen."
        ;;
    *)
        echo "❌ Ungültige Auswahl"
        exit 1
        ;;
esac

echo ""
echo "🧪 Nach der Installation teste mit:"
echo "   ./xxxos.sh vpn providers"
echo "   ./xxxos.sh vpn menu"