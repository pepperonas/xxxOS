# xxxOS

**Privacy & Anonymity Suite für macOS**

Eine umfassende Sammlung von Tools zur Verbesserung der Privatsphäre und Anonymität unter macOS.

## 🎯 Überblick

xxxOS bietet mächtige Privacy-Tools mit intuitiver Bedienung:

- **🧅 Tor Integration**: Vollständige Tor-Service-Verwaltung mit Proxy-Konfiguration
- **🔀 MAC-Adress-Spoofing**: Randomisierung der Netzwerk-Interface MAC-Adressen  
- **🛡️ Erweiterte Privatsphäre**: DNS-Management, Firewall-Kontrolle und Tracking-Schutz
- **🔒 Privacy Modi**: Ein-Kommando Privatsphäre-Konfiguration
- **🔍 Sicherheitsanalyse**: Defensive Sicherheitstools und Vulnerability-Scanning
- **📊 Privacy-Level-Tracking**: Echtzeit-Privatsphäre-Status-Monitoring
- **🌍 VPN Geo-Selection**: Multi-Provider VPN mit Länderauswahl
- **🌐 StatusBar Integration**: macOS Menüleisten-Status für Tor-Verbindung mit Exit-Node-Standort
- **🔄 Automatische Hostname-Wiederherstellung**: Original-Hostname wird beim Deaktivieren wiederhergestellt

## 📦 Installation

### Voraussetzungen

**Erforderlich:**
- macOS (getestet auf macOS 15.5+)
- Homebrew Package Manager
- Administrator-Rechte (sudo-Zugang)

**Abhängigkeiten installieren:**

```bash
# Homebrew installieren (falls noch nicht vorhanden)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Tor installieren
brew install tor

# jq für JSON-Parsing (optional aber empfohlen)
brew install jq

# ProxyChains4 (optional - für Terminal-Proxying)
brew install proxychains-ng

# SwiftBar für StatusBar-Integration
brew install --cask swiftbar
```

### Download & Setup

```bash
# Repository klonen
git clone https://github.com/your-username/xxxOS.git
cd xxxOS

# Scripts ausführbar machen
chmod +x xxxos.sh
chmod +x scripts/*.sh
```

### Quick Test

```bash
# xxxOS starten
./xxxos.sh

# Status prüfen
./xxxos.sh status

# Hilfe anzeigen
./xxxos.sh help
```

### Optional: Password-less Setup

Um nicht ständig das Passwort eingeben zu müssen:

```bash
# Setup-Script ausführen (erfordert einmalig Passwort)
./scripts/xxxos_sudoers_setup.sh

# Später entfernen mit:
sudo rm /etc/sudoers.d/xxxos
```

**Hinweis:** Dies erhöht den Komfort, reduziert aber die Sicherheit. Nur für persönliche Rechner empfohlen.

## 🚀 Verwendung

### Interaktiver Modus

```bash
./xxxos.sh
```

Startet das Hauptmenü mit allen verfügbaren Funktionen.

### Kommandozeilen-Modus

```bash
# Status und Information
./xxxos.sh status              # Vollständige Privacy-Status-Übersicht
./xxxos.sh help                # Hilfe anzeigen

# Privacy Modi
./xxxos.sh privacy-on          # Maximale Privatsphäre aktivieren
./xxxos.sh privacy-off         # Normale Einstellungen wiederherstellen

# Tor-Kontrolle
./xxxos.sh tor start           # Tor-Service starten
./xxxos.sh tor stop            # Tor-Service stoppen
./xxxos.sh tor status          # Tor-Verbindungsstatus
./xxxos.sh tor full-on         # Tor starten + System-Proxy aktivieren
./xxxos.sh tor full-off        # Tor stoppen + Proxy deaktivieren
./xxxos.sh tor test            # Tor-Verbindung testen

# MAC-Adress-Spoofing
./xxxos.sh mac                 # MAC-Adresse randomisieren (benötigt sudo)

# Zusätzliche Tools
./xxxos.sh proxychains         # ProxyChains4 für Terminal einrichten
./xxxos.sh security <type>     # Sicherheitsanalyse
./xxxos.sh vpn <action>        # VPN-Kontrolle
```

## 🔧 Hauptmenü-Funktionen

### 1) Privacy On - Maximale Privatsphäre

**Was wird aktiviert:**
- **MAC-Adresse randomisieren**: Neue zufällige MAC-Adresse für WLAN
- **Hostname ändern**: Temporärer Hostname "Lisa" (original wird gespeichert)
- **Firewall aktivieren**: macOS Firewall mit Stealth-Mode
- **Privacy DNS**: Cloudflare DNS (1.1.1.1, 1.0.0.1)
- **Tracking-Domains blockieren**: Hosts-Datei mit Werbeblocker-Listen
- **Location Services deaktivieren**: Standortdienste ausschalten
- **Tor-Netzwerk aktivieren**: Vollständige Tor-Integration mit System-Proxy

**Technische Details:**
- MAC-Adresse: OpenSSL-basierte Randomisierung
- DNS-Cache wird geleert
- System-weiter SOCKS5-Proxy auf Port 9050
- Automatische Tor-Verbindungsüberprüfung

### 2) Privacy Off - Normale Einstellungen

**Was wird wiederhergestellt:**
- **Tor deaktivieren**: Service stoppen und System-Proxy deaktivieren
- **Original-Hostname**: Automatische Wiederherstellung des ursprünglichen Namens
- **DNS-Einstellungen**: Zurück zu Standard-DNS-Servern
- **Tracking-Blocks entfernen**: Hosts-Datei bereinigen

**Hinweis:** MAC-Adresse bleibt aus Sicherheitsgründen geändert

### 3) Status - Privacy-Übersicht

**Angezeigt wird:**
- **🧅 Tor-Status**: Service-Status, Verbindung, Exit-Node-Info
- **🔀 MAC-Adresse**: Aktuelle MAC und Änderungsstatus
- **🛡️ Firewall**: Status und Stealth-Mode
- **🌐 DNS-Server**: Aktuelle DNS-Konfiguration
- **🏠 Hostname**: Aktueller System-Name
- **📍 Location Services**: Standortdienste-Status
- **🚫 Tracking-Schutz**: Hosts-Datei-Blocks

**Privacy-Level-System:**
- **🟩 MAXIMUM** (9-10 Punkte): Tor aktiv + alle Features
- **🟩 HOCH** (7-8 Punkte): Tor aktiv + die meisten Features
- **🟨 MITTEL** (4-6 Punkte): Tor aktiv + Basis-Features  
- **🟨 NIEDRIG** (2-3 Punkte): Einige Features ohne Tor
- **🟥 MINIMAL** (1 Punkt): Sehr wenige Schutzmaßnahmen
- **🟥 KEINE** (0 Punkte): Keine Privacy-Schutzmaßnahmen

### 4) MAC - MAC-Adress-Spoofing

**Funktionen:**
- **Automatische Interface-Erkennung** (Standard: en0/Wi-Fi)
- **OpenSSL-basierte Randomisierung** für realistische MAC-Adressen
- **Temporäre Wi-Fi-Trennung** während des Änderungsprozesses
- **Benötigt sudo-Rechte**

**Ablauf:**
1. Aktives Netzwerk-Interface erkennen
2. Zufällige MAC-Adresse generieren
3. Wi-Fi temporär deaktivieren
4. Neue MAC-Adresse anwenden
5. Wi-Fi wieder aktivieren
6. Änderung verifizieren

### 5) Tor - Tor-Netzwerk-Kontrolle

**Aktionen:**
- **`start`**: Nur Tor-Service starten
- **`stop`**: Tor-Service stoppen und Prozesse beenden  
- **`status`**: Detaillierter Tor-Verbindungsstatus
- **`proxy-on`**: System-weiten SOCKS-Proxy aktivieren
- **`proxy-off`**: System-Proxy deaktivieren
- **`full-on`**: Tor starten + Proxy aktivieren (empfohlen)
- **`full-off`**: Alles stoppen
- **`test`**: Tor-Verbindung testen und Exit-Node anzeigen
- **`new-identity`**: Neue Tor-Identität (neuer Exit-Node)

**Technische Details:**
- Verwendet Homebrew Tor-Service-Management
- SOCKS5-Proxy auf Port 9050
- Konfiguriert macOS Netzwerk-Einstellungen
- Verifiziert Verbindung via Tor Project API
- Unterstützt IPv4 und IPv6

### 6) ProxyChains - Terminal-Proxying

**Setup:**
- Installiert und konfiguriert ProxyChains4
- Erstellt Wrapper-Scripts für häufige Tools
- Stellt `proxychains4` Kommando bereit

**Verwendung:**
```bash
# Alle Kommandos über Tor leiten
proxychains4 curl http://icanhazip.com
proxychains4 ssh user@server
proxychains4 nmap target
```

### 7) Security - Sicherheitsanalyse

**Verfügbare Analysen:**
- **`system`**: System-Sicherheitsbewertung
  - Firewall-Status und -Konfiguration
  - System Integrity Protection (SIP)
  - Gatekeeper und XProtect Status
  - FileVault Verschlüsselungsstatus
  
- **`network`**: Netzwerk-Sicherheitsscan
  - Offene Port-Überprüfung
  - Netzwerk-Interface-Analyse
  - Aktive Verbindungsüberwachung
  
- **`dns`**: DNS-Sicherheitsanalyse
  - DNS-Server-Sicherheitsbewertung
  - DNS-Leak-Tests
  - DNSSEC-Validierung
  
- **`privacy`**: Privacy-Audit
  - Location Services Bewertung
  - Anwendungsberechtigungen-Audit
  - Privacy-sensitive Datei-Analyse
  
- **`vuln`**: Vulnerability-Assessment
  - System-Update-Status
  - Bekannte Schwachstellen-Checks
  - Sicherheitskonfiguration-Review

### 8) VPN - Geo-Location Selection

**Multi-Provider VPN Support:**
- **NordVPN, ExpressVPN, Surfshark** (mit CLI-Clients)
- **Mullvad, ProtonVPN** (mit CLI-Clients)  
- **WireGuard, OpenVPN** (benutzerdefinierte Konfigurationen)

**Features:**
- **50+ Länder** verfügbar für Verbindung
- **Interaktive Länderauswahl** mit Suche
- **Aktuelle Standorterkennung** und IP-Geolocation
- **VPN + Tor-Chaining** für maximale Anonymität
- **Verbindungsstatus-Monitoring**

## 🍎 macOS StatusBar Integration (SwiftBar)

### SwiftBar Setup

**1. SwiftBar installieren:**
```bash
brew install --cask swiftbar
```

**2. Tor Status Plugin installieren:**
```bash
# Plugin in SwiftBar-Verzeichnis kopieren
cp scripts/tor_statusbar.sh ~/Library/Application\ Support/SwiftBar/Plugins/tor_status.5s.sh

# Oder für benutzerdefinierten Plugin-Ordner:
cp scripts/tor_statusbar.sh /your/swiftbar/plugins/tor_status.5s.sh
```

**3. SwiftBar starten und Plugin aktivieren:**
- SwiftBar aus den Anwendungen starten
- Plugin wird automatisch erkannt und alle 5 Sekunden aktualisiert

### StatusBar Features

**Status-Icons:**
- **🧅** - Verbunden via Tor und aktiv
- **🟡** - Tor-Service läuft aber nicht verbunden
- **⚫** - Tor-Service offline

**Dropdown-Menü Informationen:**
- ✅ Tor-Verbindungsstatus
- 🌐 Aktuelle IP-Adresse (mit IPv6-Support)
- 📍 Aktueller Standort (Stadt, Land)
- 🧅 Tor Exit-Node IP-Adresse
- 📍 Exit-Node Standort (Stadt, Land)
- 📶 Internetverbindungsgeschwindigkeit (grob)

**Dropdown-Menü Aktionen:**
- **🚀 Privacy On** - Maximale Privatsphäre aktivieren
- **🌐 Privacy Off** - Normale Einstellungen wiederherstellen
- **📊 Status** - Vollständige Status-Übersicht
- **🧅 Tor Start/Stop** - Tor-Service-Kontrolle
- **🔄 New Identity** - Neue Tor-Identität anfordern
- **🔍 Security Analysis** - Sicherheitstools
- **⚙️ xxxOS** - Hauptmenü öffnen

**Technische Details:**
- **Update-Intervall**: 5 Sekunden
- **API-Aufrufe**: check.torproject.org, ipinfo.io
- **Cache-Mechanismus**: Intelligente Datenabfrage zur Performance-Optimierung
- **Fehlerbehandlung**: Robuste Netzwerk-Fehlerbehandlung
- **IPv6-Support**: Zeigt sowohl IPv4 als auch IPv6-Adressen

### StatusBar Anpassung

**Plugin-Konfiguration:**
```bash
# Plugin-Pfad anpassen (in tor_statusbar.sh)
XXXOS_DIR="/Users/martin/WebstormProjects/xxxOS"

# Update-Intervall ändern (Dateiname)
tor_status.10s.sh  # 10 Sekunden
tor_status.30s.sh  # 30 Sekunden
```

**Fehlerbehandlung:**
```bash
# SwiftBar neu starten
killall SwiftBar && open /Applications/SwiftBar.app

# Plugin manuell testen
./scripts/tor_statusbar.sh

# Log-Ausgabe prüfen
tail -f ~/Library/Logs/SwiftBar/tor_status.5s.sh.log
```

## 🔐 Sicherheitsüberlegungen

**Erforderliche Berechtigungen:**
- **Sudo-Zugang**: Erforderlich für MAC-Adress-Änderungen
- **Netzwerk-Konfiguration**: Für System-Proxy-Einstellungen
- **Firewall-Management**: Für Sicherheitsverbesserungen

**Privacy-Hinweise:**
- MAC-Spoofing erfordert Wi-Fi-Trennung
- System-Proxy betrifft Safari, aber nicht alle Anwendungen
- DNS-Änderungen betreffen allen Netzwerk-Traffic
- **Hostname wird automatisch wiederhergestellt** beim Deaktivieren des Privacy-Modus

**Einschränkungen:**
- Einige Anwendungen umgehen System-Proxy
- VPN-Software kann mit Tor kollidieren
- Unternehmens-Netzwerke können Tor blockieren
- Browser-Fingerprinting bleibt möglich

## 🛠️ Erweiterte Konfiguration

### Custom DNS Server

`scripts/privacy_enhance.sh` bearbeiten für eigene DNS-Server:

```bash
# Bevorzugte DNS-Server hinzufügen
DNS_SERVERS=("1.1.1.1" "1.0.0.1" "your.custom.dns")
```

### ProxyChains Konfiguration

`~/.proxychains/proxychains.conf` anpassen:

```
[ProxyList]
socks5 127.0.0.1 9050
# Weitere Proxies hier hinzufügen
```

### VPN Provider Setup

**VPN-Clients installieren:**
```bash
# NordVPN (von Website herunterladen)
# https://nordvpn.com/download/mac/

# Mullvad
brew install mullvad-vpn

# ProtonVPN
brew install protonvpn
```

## 🔧 Troubleshooting

### Häufige Probleme

**Tor startet nicht:**
```bash
# Prüfen ob Tor bereits läuft
pgrep tor

# Forciertes Beenden und Neustart
brew services stop tor
killall tor
brew services start tor
```

**MAC-Adresse ändert sich nicht:**
```bash
# Interface-Name prüfen
networksetup -listallhardwareports

# Mit korrektem Interface ausführen
sudo ./scripts/mac_spoofer.sh en1  # falls nicht en0
```

**StatusBar zeigt nichts:**
```bash
# SwiftBar refreshen
# SwiftBar-Icon klicken → "Refresh All"

# Plugin-Speicherort prüfen
ls -la ~/Library/Application\ Support/SwiftBar/Plugins/
```

**Permission denied Fehler:**
```bash
# Scripts ausführbar machen
chmod +x xxxos.sh scripts/*.sh

# Für MAC-Spoofing sudo verwenden
sudo ./xxxos.sh mac
```

### Debug-Modus

Verbose-Output aktivieren:

```bash
# Debug-Flag setzen
export xxxOS_DEBUG=1
./xxxos.sh status
```

## 📁 Projekt-Struktur

```
xxxOS/
├── xxxos.sh                    # Haupt-Kontroll-Script
├── README.md                   # Diese Dokumentation
├── CLAUDE.md                   # KI-Assistent Anweisungen
├── scripts/
│   ├── tor_control.sh          # Tor-Service-Management
│   ├── mac_spoofer.sh          # MAC-Adress-Randomisierung
│   ├── privacy_enhance.sh      # Erweiterte Privacy-Features
│   ├── proxychains_setup.sh    # ProxyChains-Konfiguration
│   ├── security_tools.sh       # Sicherheitsanalyse-Tools
│   ├── tor_statusbar.sh        # StatusBar-Plugin
│   ├── statusbar_wrappers.sh   # StatusBar-Action-Wrapper
│   ├── statusbar_launcher.sh   # StatusBar-Launcher
│   ├── vpn_control.sh          # VPN Geo-Selection
│   ├── swiftbar_helper.sh      # SwiftBar-Hilfsfunktionen
│   ├── sudo_cache_helper.sh    # Sudo-Caching
│   ├── tor_transparent.sh      # Transparenter Tor-Proxy
│   └── xxxos_sudoers_setup.sh  # Sudoers-Setup für passwordless
└── test_setup.sh               # Test-Script für Setup-Verifikation
```

## 🤝 Beitragen

Beiträge willkommen! Bitte:

1. Repository forken
2. Feature-Branch erstellen
3. Gründlich unter macOS testen
4. Pull Request senden

## ⚖️ Lizenz

MIT License

Copyright (c) 2025 Martin Pfeffer

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## ⚠️ Haftungsausschluss

Diese Software ist nur für Bildungs- und legitime Privacy-Zwecke bestimmt. Benutzer sind dafür verantwortlich, lokale Gesetze und Vorschriften einzuhalten. Die Autoren sind nicht verantwortlich für Missbrauch dieser Software.

## 🔗 Ressourcen

- [Tor Project](https://www.torproject.org/)
- [Homebrew](https://brew.sh/)
- [SwiftBar](https://swiftbar.app/)
- [ProxyChains](https://github.com/haad/proxychains)
- [macOS Privacy Guide](https://github.com/drduh/macOS-Security-and-Privacy-Guide)

---

**xxxOS v2.0 - Erstellt 2025 von Martin Pfeffer mit ❤️ für macOS Privacy**