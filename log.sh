#!/bin/bash

set -euo pipefail

# Configuration
LOG_FILE="/var/log/AdFlux/app.log"

# 0. Root Privilege Check
if [ "$EUID" -ne 0 ]; then
    echo -e "\033[33m[Privilege]\033[0m Requesting root access..."
    sudo bash "$0" "$@"
    exit $?
fi

tail -n 64 -f "$LOG_FILE"
