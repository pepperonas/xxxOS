# xxxOS Sudo-Free Setup

Diese Anleitung erklärt, wie du xxxOS ohne ständige Passwort-Eingaben verwenden kannst.

## 🚀 Schnellstart

1. **Installiere die sudoers-Konfiguration:**
   ```bash
   ./scripts/xxxos_sudoers_setup.sh
   ```
   (Du musst nur EINMAL dein Passwort eingeben)

2. **Teste die Installation:**
   ```bash
   ./test_setup.sh
   ```

3. **Fertig!** Ab jetzt funktionieren alle xxxOS-Befehle ohne Passwort.

## 🔄 Automatischer SwiftBar-Neustart

SwiftBar wird automatisch neugestartet nach:
- Tor Start/Stop
- VPN-Verbindungen
- Hostname-Änderungen
- IPv6-Änderungen
- Transparentem Tor

## 🛡️ Was wird installiert?

Die sudoers-Konfiguration erlaubt passwortlose Ausführung für:
- MAC-Adresse ändern
- Hostname ändern
- DNS-Cache leeren
- Netzwerkeinstellungen
- Tor-Service steuern
- SwiftBar neustarten
- Firewall-Einstellungen
- ProxyChains konfigurieren

## 🗑️ Deinstallation

Falls du die passwortlose Konfiguration entfernen möchtest:
```bash
sudo rm /etc/sudoers.d/xxxos
```

## ⚠️ Sicherheitshinweis

Diese Konfiguration erhöht den Komfort, reduziert aber die Sicherheit.
Verwende sie nur auf vertrauenswürdigen Systemen.