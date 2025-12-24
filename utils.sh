#!/bin/bash

download_latest_release() {
    local repo=$1
    local output=$2

    echo -e "\033[34m[Info]\033[0m Fetching latest release from $repo..."

    local asset_url
    asset_url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | \
        jq -r '.assets[0].browser_download_url // empty')

    if [ -z "$asset_url" ]; then
        echo -e "\033[31m[Error]\033[0m Failed to get download URL."
        return 1
    fi

    local url="https://ghfast.top/$asset_url"
    curl -L -o "$output" "$url"
}
