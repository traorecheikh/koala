#!/bin/bash

# Script to generate SHA-256 checksum for APK file
# Usage: ./generate_checksum.sh [path/to/apk]

APK_PATH="${1:-build/app/outputs/flutter-apk/app-release.apk}"

if [ ! -f "$APK_PATH" ]; then
    echo "Error: APK file not found at $APK_PATH"
    exit 1
fi

echo "Generating SHA-256 checksum for: $APK_PATH"
echo ""

# Generate checksum
if command -v sha256sum &> /dev/null; then
    CHECKSUM=$(sha256sum "$APK_PATH" | awk '{print $1}')
elif command -v shasum &> /dev/null; then
    CHECKSUM=$(shasum -a 256 "$APK_PATH" | awk '{print $1}')
else
    echo "Error: No SHA-256 utility found (sha256sum or shasum)"
    exit 1
fi

echo "SHA-256 Checksum: $CHECKSUM"
echo ""
echo "Update version.json with this checksum:"
echo "  \"checksum\": \"$CHECKSUM\""
echo ""

# Optionally update version.json automatically
read -p "Update version.json automatically? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -f "version.json" ]; then
        # Create backup
        cp version.json version.json.backup

        # Update checksum (requires jq)
        if command -v jq &> /dev/null; then
            jq --arg checksum "$CHECKSUM" '.checksum = $checksum' version.json > version.json.tmp
            mv version.json.tmp version.json
            echo "version.json updated successfully!"
            echo "Backup saved as version.json.backup"
        else
            echo "jq not found. Please update version.json manually."
        fi
    else
        echo "version.json not found in current directory"
    fi
fi

