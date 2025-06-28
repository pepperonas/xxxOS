# xxxOS

Privacy and anonymity utilities for macOS.

## Overview

xxxOS provides command-line tools for enhancing privacy on macOS systems:

- **MAC Address Spoofing**: Randomize your network interface's MAC address
- **Tor Control**: Manage Tor service and system-wide proxy settings

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

### MAC Address Spoofing

Change your MAC address to a random value:

```bash
sudo ./mac_spoofer.sh
```

**Note**: This will temporarily disconnect your Wi-Fi connection.

### Tor Control

```bash
# Start Tor service
./tor_control.sh start

# Stop Tor service
./tor_control.sh stop

# Check status
./tor_control.sh status

# Enable system-wide SOCKS proxy
./tor_control.sh proxy-on

# Disable system-wide SOCKS proxy
./tor_control.sh proxy-off

# Full setup (start Tor + enable proxy)
./tor_control.sh full-on

# Full teardown (stop Tor + disable proxy)
./tor_control.sh full-off

# Test Tor connection
./tor_control.sh test
```

## Features

### mac_spoofer.sh
- Generates cryptographically random MAC addresses
- Automatically handles Wi-Fi interface toggling
- Validates network interface existence
- Shows before/after MAC addresses

### tor_control.sh
- Manages Tor service via Homebrew
- Configures macOS system proxy settings
- Auto-detects Wi-Fi network interface
- Provides connection testing
- SOCKS5 proxy on port 9050
- Multiple operation modes for flexibility

## Technical Details

- **MAC Spoofing**: Uses OpenSSL for secure random generation, ensures unicast addresses
- **Tor Integration**: Leverages macOS `networksetup` for system-wide proxy configuration
- **Network Interface**: Defaults to `en0` (Wi-Fi), auto-detection for Tor proxy

## Limitations

- System proxy settings affect Safari and system apps, but not all applications
- Command-line tools like `curl` require explicit SOCKS5 configuration
- MAC address changes are temporary and reset on reboot

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