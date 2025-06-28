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

# Optional: Install ProxyChains for application-specific proxying
brew install proxychains-ng

# Optional: Install jq for better status output
brew install jq
```

## Usage

### Quick Start with xxxos

The main control script `xxxos` provides easy access to all privacy features:

```bash
# Show help
./xxxos help

# Basic privacy mode (MAC + Tor)
./xxxos privacy on

# Ultra privacy mode (ALL features)
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
4. **Browser Data Cleaning** - Clears history, cookies, cache
5. **Firewall Activation** - Stealth mode enabled
6. **Privacy DNS** - Cloudflare (1.1.1.1)
7. **Tracking Protection** - Blocks ad/tracking domains
8. **Location Services** - Disabled
9. **Tor Network** - Full anonymization

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

## Technical Details

- **MAC Spoofing**: Uses OpenSSL for secure random generation, ensures unicast addresses
- **Tor Integration**: Leverages macOS `networksetup` for system-wide proxy configuration
- **Network Interface**: Defaults to `en0` (Wi-Fi), auto-detection for Tor proxy

## Security Recommendations

For maximum anonymity:
1. Use **Tor Browser** instead of regular browsers
2. Disable **WebRTC** in your browser (prevents IP leaks)
3. Disable **JavaScript** when possible
4. Consider using **Tails OS** for critical operations
5. Use **ProxyChains** for application-specific routing
6. Regularly clear browser data and cookies
7. Avoid logging into personal accounts while anonymous

## Limitations

- System proxy settings affect Safari and system apps, but not all applications
- Command-line tools like `curl` require explicit SOCKS5 configuration
- MAC address changes are temporary and reset on reboot
- Some websites may block Tor exit nodes
- Browser fingerprinting can still identify you (use Tor Browser)
- WebRTC can leak your real IP (must be disabled manually)

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