#!/bin/bash
set -e

DOWNLOADS=/app/downloads
mkdir -p "$DOWNLOADS"

IFS=$'\n'
for entry in $WOW_GDRIVE_FILES; do
  name="${entry%%=*}"
  url="${entry#*=}"

  echo "⬇️ Google Drive : $name"
  wget --content-disposition "$url" -O "$DOWNLOADS/$name"

  if [ ! -s "$DOWNLOADS/$name" ]; then
    echo "❌ Échec téléchargement : $name"
    exit 1
  fi
done
