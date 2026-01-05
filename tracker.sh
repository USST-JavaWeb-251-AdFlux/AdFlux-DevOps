#!/bin/bash

set -euo pipefail

# 0. Root Privilege Check
if [ "$EUID" -ne 0 ]; then
    echo -e "\033[33m[Privilege]\033[0m Requesting root access..."
    sudo bash "$0" "$@"
    exit $?
fi

# Load utils
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Configuration
REPO="USST-JavaWeb-251-AdFlux/AdFlux-Tracker"
TARGET_DIR="/var/www/AdFlux/tracker"
ZIP_FILE="dist.zip"

# 1. Download
if [ ! -f "$ZIP_FILE" ]; then
    download_latest_release "$REPO" "$ZIP_FILE"
else
    echo -e "\033[34m[Info]\033[0m $ZIP_FILE already exists, skipping download."
fi
unzip -tq "$ZIP_FILE"

# 2. Cleanup & Extract
echo -e "\033[34m[Info]\033[0m Deploying to $TARGET_DIR..."
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"
unzip -q "$ZIP_FILE" -d "$TARGET_DIR"
rm "$ZIP_FILE"

# 3. Permissions
echo -e "\033[34m[Info]\033[0m Setting permissions for nginx..."
chown -R nginx:nginx "$TARGET_DIR"
find "$TARGET_DIR" -type d -exec chmod 755 {} +
find "$TARGET_DIR" -type f -exec chmod 644 {} +

echo -e "\033[32m[Success]\033[0m Deployment completed successfully."
