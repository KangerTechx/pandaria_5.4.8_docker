#!/bin/bash
set -e

DOWNLOADS=/app/downloads
mkdir -p "$DOWNLOADS"

FILES=(
  wow-5.4.8.zip
  Wow.zip
  Wow-64.zip
  _Wow.zip
  _Wow-64.zip
  Interface.zip
  Data-Cache.zip
  Data-Interface.zip
  enUS.zip
  frFR.zip
  Data-1.zip
  Data-2.zip
  Data-3.zip
  expansion3.zip
  Config.wtf
)

API_URL="https://api.github.com/repos/${WOW_GITHUB_OWNER}/${WOW_GITHUB_REPO}/releases/tags/${WOW_GITHUB_RELEASE}"

echo "📡 GitHub release : $WOW_GITHUB_RELEASE"

ASSETS=$(wget -qO- "$API_URL" | jq -r '.assets[] | "\(.name)|\(.browser_download_url)"')

for file in "${FILES[@]}"; do
  url=$(echo "$ASSETS" | grep "^$file|" | cut -d'|' -f2)

  if [ -z "$url" ]; then
    echo "⚠️ $file introuvable"
    continue
  fi

  echo "⬇️ $file"
  wget -q --show-progress "$url" -O "$DOWNLOADS/$file"
done
