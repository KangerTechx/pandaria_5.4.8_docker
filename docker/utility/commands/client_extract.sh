#!/bin/bash
set -e

DOWNLOADS=/app/downloads
CLIENT=/app/client

declare -A MAP=(
  [wow-5.4.8.zip]="."
  [Wow.zip]="wow-5.4.8"
  [Wow-64.zip]="wow-5.4.8"
  [_Wow.zip]="wow-5.4.8"
  [_Wow-64.zip]="wow-5.4.8"
  [Interface.zip]="wow-5.4.8"
  [Data-Cache.zip]="wow-5.4.8/Data"
  [Data-Interface.zip]="wow-5.4.8/Data"
  [enUS.zip]="wow-5.4.8/Data"
  [frFR.zip]="wow-5.4.8/Data"
  [Data-1.zip]="wow-5.4.8/Data"
  [Data-2.zip]="wow-5.4.8/Data"
  [Data-3.zip]="wow-5.4.8/Data"
  [expansion1.zip]="wow-5.4.8/Data"
  [expansion2.zip]="wow-5.4.8/Data"
  [expansion3.zip]="wow-5.4.8/Data"
  [expansion4.zip]="wow-5.4.8/Data"
  [model.zip]="wow-5.4.8/Data"
  [sound.zip]="wow-5.4.8/Data"
  [texture.zip]="wow-5.4.8/Data"
  [world.zip]="wow-5.4.8/Data"
)

for zip in "${!MAP[@]}"; do
  src="$DOWNLOADS/$zip"
  dst="$CLIENT/${MAP[$zip]}"

  [ -f "$src" ] || continue

  echo "📦 Extraction $zip → $dst"
  mkdir -p "$dst"
  unzip -q "$src" -d "$dst"
  rm "$src"
done
