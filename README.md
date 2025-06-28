# xxxOS

Privacy and anonymity utilities for macOS.

## Overview

xxxOS provides a comprehensive suite of command-line tools for enhancing privacy on macOS systems:

- **MAC Address Spoofing**: Randomize your network interface's MAC address
- **Tor Control**: Manage Tor service and system-wide proxy settings
- **Enhanced Privacy**: DNS management, firewall control, browser data cleaning, and more
- **Ultra Privacy Mode**: One-command maximum anonymity configuration

## Installation

### Prerequisites

1. macOS operating system
2. Homebrew package manager
3. Install required dependencies:

```bash
# Install Tor
brew install tor

# Install OpenSSL (usually pre-installed)
brew install openssl

# Install ProxyChains for terminal routing (required for Tor Shell)
brew install proxychains-ng

# Install wget for reliable proxy routing
brew install wget

# Optional: Install jq for better status output
brew install jq
```

### Setup

```bash
# Clone or download xxxOS
cd /path/to/xxxOS

# Make scripts executable
chmod +x xxxos
chmod +x scripts/*.sh

# Run initial setup (installs ProxyChains configuration)
./xxxos proxychains
```

## Usage

### Quick Start with xxxos

The main control script `xxxos` provides easy access to all privacy features:

```bash
# Show help
./xxxos help

# Check overall privacy status
./xxxos status

# Basic privacy mode (MAC + Tor)
./xxxos privacy on

# Ultra privacy mode (ALL features + ProxyChains)
./xxxos privacy ultra

# Check privacy status
./xxxos privacy status
```

### Individual Features

#### MAC Address Spoofing

```bash
# Change MAC address (requires sudo)
./xxxos mac
```

#### Tor Control

```bash
# Tor management
./xxxos tor start          # Start Tor service
./xxxos tor stop           # Stop Tor service
./xxxos tor status         # Check status
./xxxos tor full-on        # Start Tor + enable system proxy
./xxxos tor full-off       # Stop Tor + disable system proxy
./xxxos tor test           # Test connection
```

#### Enhanced Privacy Features

```bash
# DNS and network
./xxxos enhance dns-clear      # Clear DNS cache
./xxxos enhance dns-privacy    # Set privacy DNS (Cloudflare)
./xxxos enhance hostname       # Randomize hostname

# Browser privacy
./xxxos enhance browser-clear  # Clear browser data (with confirmation)

# System security
./xxxos enhance firewall       # Enable firewall with stealth mode
./xxxos enhance block-tracking # Block tracking domains

# All enhanced features
./xxxos enhance all           # Activate all privacy features

# ProxyChains setup
./xxxos proxychains           # Setup ProxyChains for terminal use
```

### Tor Shell Usage

After running `./xxxos privacy ultra`, you get access to a dedicated Tor shell:

```bash
# Start Tor shell (all commands route through Tor automatically)
torshell

# In Tor shell:
checkip                       # Shows Tor status {"IsTor":true}
myip                         # Shows current Tor IP
curl https://example.com     # Automatically via Tor
git clone https://...        # Automatically via Tor
wget https://...             # Automatically via Tor
exit                         # Exit Tor shell

# Individual Tor commands (from normal shell)
torcheck                     # Check Tor connection status
torcurl https://example.com  # Single curl command via Tor
```

## Privacy Modes

### Basic Privacy Mode (`./xxxos privacy on`)
1. Changes MAC address to random value
2. Starts Tor service
3. Enables system-wide SOCKS proxy
4. Tests Tor connection

### Ultra Privacy Mode (`./xxxos privacy ultra`)
Activates ALL privacy features:
1. **MAC Address Spoofing** - Random hardware address
2. **DNS Cache Clearing** - Removes DNS history
3. **Hostname Randomization** - Changes system identifier
4. **Browser Data Cleaning** - Clears history, cookies, cache (with confirmation)
5. **Firewall Activation** - Stealth mode enabled
6. **Privacy DNS** - Cloudflare (1.1.1.1)
7. **Tracking Protection** - Blocks ad/tracking domains
8. **Location Services** - Disabled
9. **Tor Network** - Full anonymization
10. **ProxyChains Setup** - Terminal command routing through Tor
11. **Tor Shell** - Dedicated shell where all commands use Tor automatically

## Features Details

### Network Privacy
- **MAC Spoofing**: Cryptographically random MAC addresses
- **DNS Management**: Cache clearing and privacy-focused DNS servers
- **Hostname Randomization**: Prevents device fingerprinting
- **Firewall**: macOS firewall with stealth mode

### Browser Privacy
- Supports Safari, Chrome, and Firefox
- Clears browsing history, cookies, and cache
- Preserves saved passwords
- Requires user confirmation before deletion

### Tor Integration
- Manages Tor service via Homebrew
- Configures macOS system proxy settings
- Auto-detects Wi-Fi network interface
- SOCKS5 proxy on port 9050
- Connection testing via check.torproject.org

### Tracking Protection
- Blocks common tracking domains via hosts file
- Includes Google Analytics, Facebook, DoubleClick, etc.
- Creates automatic backups before modification

### ProxyChains Integration
- Configures ProxyChains for reliable Tor routing
- Handles macOS-specific networking limitations
- Provides wrapper scripts for seamless command-line usage
- Includes dedicated Tor shell with automatic routing

### Tor Shell Features
- **Automatic Routing**: All network commands (`curl`, `git`, `wget`, etc.) automatically use Tor
- **Visual Indicators**: Prompt shows `🧅[TOR]` to indicate Tor mode
- **Built-in Commands**: `checkip` for connection testing, `myip` for IP display
- **Session Management**: Clean entry/exit with session preservation
- **Command Compatibility**: Works with standard tools without syntax changes

## Technical Details

- **MAC Spoofing**: Uses OpenSSL for secure random generation, ensures unicast addresses
- **Tor Integration**: Leverages macOS `networksetup` for system-wide proxy configuration
- **Network Interface**: Defaults to `en0` (Wi-Fi), auto-detection for Tor proxy
- **ProxyChains Configuration**: Custom config optimized for Tor routing at `/opt/homebrew/etc/proxychains.conf`
- **Tor Shell Implementation**: Uses PATH manipulation with wrapper scripts in `/tmp/tor_wrappers/`
- **Command Routing**: `curl` requests routed through `wget` for reliable proxy support

## Project Structure

```
xxxOS/
├── xxxos                           # Main control script
├── scripts/
│   ├── mac_spoofer.sh             # MAC address randomization
│   ├── tor_control.sh             # Tor service management
│   ├── privacy_enhance.sh         # Enhanced privacy features
│   ├── proxychains_setup.sh       # ProxyChains configuration
│   └── torshell_wrapper.sh        # Alternative Tor shell implementation
├── CLAUDE.md                      # Development guidance
└── README.md                      # This file
```

## Security Recommendations

For maximum anonymity:
1. Use **Tor Browser** instead of regular browsers
2. Disable **WebRTC** in your browser (prevents IP leaks)
3. Disable **JavaScript** when possible
4. Consider using **Tails OS** for critical operations
5. Use the **Tor Shell** (`torshell`) for command-line operations
6. Regularly clear browser data and cookies
7. Avoid logging into personal accounts while anonymous
8. Test your anonymity with `checkip` before sensitive operations
9. Use `./xxxos status` to verify all privacy features are active

## Limitations

- System proxy settings affect Safari and system apps, but not all applications
- Some command-line tools may bypass ProxyChains (use Tor Shell for reliable routing)
- MAC address changes are temporary and reset on reboot
- Some websites may block Tor exit nodes
- Browser fingerprinting can still identify you (use Tor Browser)
- WebRTC can leak your real IP (must be disabled manually)
- Browser data clearing requires manual confirmation for safety

## Known Issues

- `curl` on macOS may bypass ProxyChains in some configurations
- **Solution**: Use the Tor Shell (`torshell`) for guaranteed Tor routing
- Tor Shell uses `wget` as backend for reliable proxy routing
- Browser data clearing requires manual confirmation for safety (prevents accidental data loss)

## Dependencies

**Required:**
- Tor (via Homebrew)
- ProxyChains-NG (via Homebrew) 
- wget (via Homebrew)
- OpenSSL (usually pre-installed)

**Optional:**
- jq (for better JSON output formatting)

**System Requirements:**
- macOS (tested on Apple Silicon and Intel)
- Homebrew package manager
- Administrator privileges (for MAC spoofing and system configuration)

## Author

Martin Pfeffer (2025)

## License

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