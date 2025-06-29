# xxxOS

**Privacy & Anonymity Tools for macOS**

A comprehensive suite of command-line tools for enhancing privacy and anonymity on macOS systems.

## 🎯 Overview

xxxOS provides powerful privacy tools with an intuitive interface:

- **🧅 Tor Integration**: Complete Tor service management with proxy configuration
- **🔀 MAC Address Spoofing**: Randomize network interface MAC addresses
- **🛡️ Enhanced Privacy**: DNS management, firewall control, and tracking protection
- **🔒 Ultra Privacy Mode**: One-command maximum anonymity configuration
- **🔍 Security Analysis**: Defensive security tools and vulnerability scanning
- **📊 Privacy Level Tracking**: Real-time privacy status monitoring with scoring
- **🌐 StatusBar Integration**: macOS menu bar status for Tor connection
- **🕵️ TorShell**: Proxified terminal environment with custom icons

## 📦 Installation

### Prerequisites

**Required:**
- macOS (tested on macOS 15.5+)
- Homebrew package manager
- Administrator privileges (sudo access)

**Install Dependencies:**

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Tor
brew install tor

# Install jq for JSON parsing (optional but recommended)
brew install jq

# Install ProxyChains4 (optional - for terminal proxying)
brew install proxychains-ng
```

### Download & Setup

```bash
# Clone the repository
git clone https://github.com/your-username/xxxOS.git
cd xxxOS

# Make scripts executable
chmod +x xxxos.sh
chmod +x scripts/*.sh

# Optional: Add to PATH for global access
echo 'export PATH="$PATH:$(pwd)"' >> ~/.zshrc
source ~/.zshrc
```

### Quick Test

```bash
# Run xxxOS
./xxxos.sh

# Check status
./xxxos.sh status

# Quick help
./xxxos.sh help
```

## 🚀 Usage

### Interactive Mode

```bash
./xxxos.sh
```

Launches the main menu with all available functions.

### Command Line Mode

```bash
# Status and Information
./xxxos.sh status              # Complete privacy status overview
./xxxos.sh ipinfo              # Detailed IP information and location

# Tor Control
./xxxos.sh tor start           # Start Tor service
./xxxos.sh tor stop            # Stop Tor service
./xxxos.sh tor status          # Tor connection status
./xxxos.sh tor full-on         # Start Tor + enable system proxy
./xxxos.sh tor full-off        # Stop Tor + disable proxy
./xxxos.sh tor test            # Test Tor connection

# Privacy Modes
./xxxos.sh privacy on          # Basic privacy (MAC + Tor)
./xxxos.sh privacy off         # Disable privacy features
./xxxos.sh privacy status      # Privacy status overview
./xxxos.sh privacy ultra       # Maximum privacy configuration

# MAC Address Spoofing
./xxxos.sh mac                 # Randomize MAC address (requires sudo)

# Enhanced Privacy Features
./xxxos.sh enhance dns-clear      # Clear DNS cache
./xxxos.sh enhance hostname       # Randomize hostname
./xxxos.sh enhance browser-clear  # Clear browser data
./xxxos.sh enhance firewall       # Enable firewall + stealth mode
./xxxos.sh enhance dns-privacy    # Set privacy DNS servers
./xxxos.sh enhance block-tracking # Block tracking domains
./xxxos.sh enhance all           # Enable all privacy features

# Security Analysis
./xxxos.sh security system     # System security analysis
./xxxos.sh security network    # Network security scan
./xxxos.sh security dns        # DNS security check
./xxxos.sh security privacy    # Privacy audit
./xxxos.sh security vuln       # Vulnerability assessment
./xxxos.sh security full       # Complete security analysis

# Additional Tools
./xxxos.sh proxychains         # Setup ProxyChains4 for terminal
./xxxos.sh more                # Additional tools and settings
```

## 🔧 Main Menu Functions

### 1) Status - Privacy Overview
- **Real-time privacy level scoring** (0-10 points)
- **MAC address status** with randomization indicator
- **Tor service status** and connection verification
- **Firewall configuration** and stealth mode
- **DNS server privacy** assessment
- **System identification** (hostname)
- **Tracking protection** status
- **Location services** status

**Privacy Level System:**
- **🟩 MAXIMUM** (9-10 points): Tor active + all privacy features
- **🟩 HOCH** (7-8 points): Tor active + most features
- **🟨 MITTEL** (4-6 points): Tor active + basic features  
- **🟨 NIEDRIG** (2-3 points): Some features without Tor
- **🟥 MINIMAL** (1 point): Very few protections
- **🟥 KEINE** (0 points): No privacy protections

*Note: Without Tor active, maximum level is limited to "NIEDRIG"*

### 2) IP Info - Network Information
- **Current public IP address** and geolocation
- **ISP and organization** information
- **Tor connection verification** via check.torproject.org
- **DNS leak testing** and resolver information
- **WebRTC leak detection** warnings
- **VPN/Proxy detection** status

### 3) Privacy - Privacy Modes

**Available Modes:**
- **`on`**: Basic Privacy
  - Randomize MAC address
  - Start Tor service
  - Enable system proxy
  
- **`off`**: Disable Privacy
  - Stop Tor service  
  - Disable system proxy
  - Keep MAC address as-is
  
- **`status`**: Show current privacy configuration

- **`ultra`**: Maximum Privacy
  - All features from basic mode
  - Set privacy DNS servers (Cloudflare/Quad9)
  - Enable firewall with stealth mode
  - Clear DNS cache
  - Randomize hostname
  - Block tracking domains
  - Clear browser data

### 4) Tor - Tor Network Control

**Actions:**
- **`start`**: Start Tor service only
- **`stop`**: Stop Tor service and kill processes  
- **`status`**: Detailed Tor connection status
- **`proxy-on`**: Enable system-wide SOCKS proxy
- **`proxy-off`**: Disable system proxy
- **`full-on`**: Start Tor + enable proxy (recommended)
- **`full-off`**: Stop everything
- **`test`**: Test Tor connection and show exit node

**Technical Details:**
- Uses Homebrew Tor service management
- SOCKS5 proxy on port 9050
- Configures macOS network settings
- Verifies connection via Tor Project API

### 5) MAC - MAC Address Spoofing

**Features:**
- **Automatic interface detection** (defaults to en0/Wi-Fi)
- **OpenSSL-based randomization** for realistic MAC addresses
- **Temporary Wi-Fi disconnection** during change process
- **Vendor prefix preservation** option
- **Requires sudo privileges**

**Process:**
1. Detect active network interface
2. Generate random MAC address
3. Temporarily disable Wi-Fi
4. Apply new MAC address
5. Re-enable Wi-Fi
6. Verify change successful

### 6) Enhance - Extended Privacy Features

**Individual Functions:**
- **`dns-clear`**: Flush system DNS cache
- **`hostname`**: Set random hostname  
- **`browser-clear`**: Clear Safari/Chrome data
- **`firewall`**: Enable macOS firewall + stealth mode
- **`dns-privacy`**: Configure Cloudflare/Quad9 DNS
- **`block-tracking`**: Update hosts file with ad/tracker blocks
- **`all`**: Apply all enhancement features

**DNS Privacy Servers:**
- Cloudflare: 1.1.1.1, 1.0.0.1
- Quad9: 9.9.9.9, 149.112.112.112

### 7) ProxyChains - Terminal Proxying

**Setup:**
- Installs and configures ProxyChains4
- Creates wrapper scripts for common tools
- Provides `torshell` command for proxified terminal
- Supports curl, wget, ssh, nmap, and more

**TorShell Features:**
- Isolated terminal environment
- All traffic routed through Tor
- Custom shell prompt with Tor indicator
- Built-in connection testing commands
- Support for security tools

### 8) Security - Security Analysis Tools

**Analysis Types:**
- **`system`**: System security assessment
  - Firewall status and configuration
  - System Integrity Protection (SIP)
  - Gatekeeper and XProtect status
  - FileVault encryption status
  - Suspicious process detection
  
- **`network`**: Network security scan
  - Open port scanning
  - Network interface analysis
  - Active connection monitoring
  - Firewall rule assessment
  
- **`dns`**: DNS security analysis
  - DNS server security assessment
  - DNS leak testing
  - DNSSEC validation check
  - DNS over HTTPS status
  
- **`privacy`**: Privacy audit
  - Location services assessment
  - Application permissions audit
  - Privacy-sensitive file analysis
  - Tracking protection verification
  
- **`vuln`**: Vulnerability assessment
  - System update status
  - Known vulnerability checks
  - Security configuration review
  - Outdated software detection
  
- **`full`**: Complete security analysis (all above)

### 9) Help - Documentation

Shows complete command-line usage and examples.

### 99) More - Additional Tools

**Current Tools:**
- **TorShell Icon Changer**: Customize your TorShell prompt
  - 12 different icons available
  - Interactive selection or direct setting
  - Icons: 🧅🔒🛡️🕶️🕵️🎭👤🌐⚡🔐🥷👻

**Usage:**
```bash
# Interactive icon selection
./xxxos.sh more
→ 1 (torshell-icon)

# Direct icon setting
./scripts/torshell_icon.sh set 11  # Sets ninja icon 🥷
```

## 🍎 macOS StatusBar Integration

### SwiftBar Setup

**Install SwiftBar:**
```bash
brew install --cask swiftbar
```

**Install Tor Status Plugin:**
```bash
# Copy plugin to SwiftBar directory
cp scripts/tor_statusbar.sh ~/Library/Application\ Support/SwiftBar/Plugins/tor_status.5s.sh

# Or if you use custom plugin directory:
cp scripts/tor_statusbar.sh /your/swiftbar/plugins/tor_status.5s.sh
```

**StatusBar Features:**
- **🧅 TOR** - Connected and active
- **🟡 TOR** - Running but not connected
- **⚫ TOR** - Offline

**Dropdown Menu:**
- Current IP and Tor status
- Quick Tor start/stop actions
- Privacy mode controls
- Security analysis access
- Direct xxxOS launcher

## 🔐 Security Considerations

**Permissions Required:**
- **Sudo access**: Required for MAC address changes
- **Network configuration**: For system proxy settings
- **Firewall management**: For security enhancements

**Privacy Notes:**
- MAC spoofing requires Wi-Fi disconnection
- System proxy affects Safari but not all applications
- DNS changes affect all network traffic
- Firewall changes require administrator privileges

**Limitations:**
- Some applications bypass system proxy
- VPN software may conflict with Tor
- Corporate networks may block Tor
- Browser fingerprinting still possible

## 🛠️ Advanced Configuration

### Custom DNS Servers

Edit `scripts/privacy_enhance.sh` to add custom DNS servers:

```bash
# Add your preferred DNS servers
DNS_SERVERS=("1.1.1.1" "1.0.0.1" "your.custom.dns")
```

### ProxyChains Configuration

Customize `~/.proxychains/proxychains.conf`:

```
[ProxyList]
socks5 127.0.0.1 9050
# Add additional proxies here
```

### TorShell Customization

Modify TorShell environment in `scripts/torshell_wrapper.sh`:

```bash
# Add custom aliases
alias myip='curl --socks5 localhost:9050 http://icanhazip.com'
alias checkip='curl --socks5 localhost:9050 https://check.torproject.org/api/ip'
```

## 🔧 Troubleshooting

### Common Issues

**Tor won't start:**
```bash
# Check if Tor is already running
pgrep tor

# Force kill and restart
brew services stop tor
killall tor
brew services start tor
```

**MAC address won't change:**
```bash
# Check interface name
networksetup -listallhardwareports

# Run with correct interface
sudo ./scripts/mac_spoofer.sh en1  # if not en0
```

**StatusBar not showing:**
```bash
# Refresh SwiftBar
# Click SwiftBar icon → "Refresh All"

# Check plugin location
ls -la ~/Library/Application\ Support/SwiftBar/Plugins/
```

**Permission denied errors:**
```bash
# Make scripts executable
chmod +x xxxos.sh scripts/*.sh

# For MAC spoofing, ensure sudo access
sudo ./xxxos.sh mac
```

### Debug Mode

Enable verbose output:

```bash
# Set debug flag
export XXXOS_DEBUG=1
./xxxos.sh status
```

## 📁 Project Structure

```
xxxOS/
├── xxxos.sh                    # Main control script
├── README.md                   # This documentation
├── CLAUDE.md                   # AI assistant instructions
├── scripts/
│   ├── tor_control.sh         # Tor service management
│   ├── mac_spoofer.sh         # MAC address randomization
│   ├── privacy_enhance.sh     # Enhanced privacy features
│   ├── proxychains_setup.sh   # ProxyChains configuration
│   ├── security_tools.sh      # Security analysis tools
│   ├── torshell_wrapper.sh    # TorShell environment
│   ├── torshell_icon.sh       # TorShell icon customization
│   ├── tor_statusbar.sh       # StatusBar plugin
│   └── statusbar_wrappers.sh  # StatusBar action wrappers
```

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Test thoroughly on macOS
4. Submit a pull request

## ⚖️ License

MIT License - See LICENSE file for details.

## ⚠️ Disclaimer

This software is for educational and legitimate privacy purposes only. Users are responsible for complying with local laws and regulations. The authors are not responsible for any misuse of this software.

## 🔗 Resources

- [Tor Project](https://www.torproject.org/)
- [Homebrew](https://brew.sh/)
- [SwiftBar](https://swiftbar.app/)
- [ProxyChains](https://github.com/haad/proxychains)
- [macOS Privacy Guide](https://github.com/drduh/macOS-Security-and-Privacy-Guide)

---

**Built with ❤️ for macOS Privacy**