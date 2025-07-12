#!/bin/bash

echo "=== DEBUG WRAPPER ==="
echo "1. Checking sudoers file..."
if [ -f "/etc/sudoers.d/xxxos" ]; then
    echo "✅ Sudoers file exists"
else
    echo "❌ Sudoers file missing"
    exit 1
fi

echo "2. Testing sudo without password..."
if sudo -n dscacheutil -flushcache >/dev/null 2>&1; then
    echo "✅ Sudo works without password"
    echo "3. Skipping cache helper - running xxxOS directly"
    ./xxxos.sh privacy-off
else
    echo "❌ Sudo requires password"
    echo "3. Would start cache helper..."
fi