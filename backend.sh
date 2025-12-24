#!/bin/bash

set -euo pipefail

# 0. Root Privilege Check
if [ "$EUID" -ne 0 ]; then
    echo -e "\033[33m[Privilege]\033[0m Requesting root access..."
    sudo bash "$0" "$@"
    exit $?
fi

# Load utils
source ./utils.sh

# Configuration
REPO="USST-JavaWeb-251-AdFlux/AdFlux-Backend"
TARGET_DIR="/var/www/AdFlux/backend"
JAR_FILE="app.jar"
SCREEN_NAME="AdFlux"
LOG_FILE="/var/log/AdFlux/app.log"

# 1. Download
download_latest_release "$REPO" "$JAR_FILE"
unzip -tq "$JAR_FILE"

# 2. Cleanup & Stop Service
echo -e "\033[34m[Info]\033[0m Deploying to $TARGET_DIR..."
EXISTING_SESSIONS=$(screen -list | grep -E "[0-9]+\\.${SCREEN_NAME}" | awk '{print $1}' || true)
if [ -n "$EXISTING_SESSIONS" ]; then
    echo -e "\033[34m[Info]\033[0m Closing existing screen session: $EXISTING_SESSIONS"
    screen -S "$SCREEN_NAME" -X quit
fi
mkdir -p "$TARGET_DIR"
mv "$JAR_FILE" "$TARGET_DIR/$JAR_FILE"

# 3. Start Service
echo -e "\033[34m[Info]\033[0m Starting Backend service in screen..."
mkdir -p "$(dirname "$LOG_FILE")"
: > "$LOG_FILE"
cd "$TARGET_DIR"
screen -dmS "$SCREEN_NAME" bash -c "java -jar $JAR_FILE --spring.profiles.active=prod >> $LOG_FILE 2>&1"

echo -e "\033[32m[Success]\033[0m Deployment completed successfully."
