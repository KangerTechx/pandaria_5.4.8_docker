#!/bin/bash
set -e

DOWNLOADS=/app/downloads
TARGET=/app/client/wow-5.4.8/WTF

mkdir -p "$TARGET"

if [ -f "$DOWNLOADS/Config.wtf" ]; then
  mv "$DOWNLOADS/Config.wtf" "$TARGET/"
  echo "📄 Config.wtf déplacé"
fi
