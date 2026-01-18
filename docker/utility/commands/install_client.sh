#!/usr/bin/env bash
set -e

# =========================
# CONFIGURATION
# =========================

GITHUB_OWNER="KangerTechx"
GITHUB_REPO="wow-5.4.8"
GITHUB_RELEASE_TAG="client-mop-5.4.8"

BASE_DIR="$(cd "$(dirname "$0")/../../.." && pwd)"
DOWNLOADS_DIR="$BASE_DIR/app/downloads"
CLIENT_DIR="$BASE_DIR/app/client"

mkdir -p "$DOWNLOADS_DIR" "$CLIENT_DIR"

# =========================
# FICHIERS GITHUB
# =========================

GITHUB_FILES=(
  "wow-5.4.8.zip"
  "Wow.zip"
  "Wow-64.zip"
  "_Wow.zip"
  "_Wow-64.zip"
  "Interface.zip"
  "Data-Cache.zip"
  "Data-Interface.zip"
  "enUS.zip"
  "frFR.zip"
  "Data-1.zip"
  "Data-2.zip"
  "Data-3.zip"
  "expansion1.zip"
  "expansion3.zip"
  "expansion4.zip"
  "model.zip"
  "Config.wtf"
)

# =========================
# AWS S3
# =========================

S3_BASE_URL="https://s3.eu-north-1.amazonaws.com/wow-5.4.8"

declare -A S3_FILES=(
  ["expansion2.zip"]="$S3_BASE_URL/expansion2.zip"
  ["sound.zip"]="$S3_BASE_URL/sound.zip"
  ["texture.zip"]="$S3_BASE_URL/texture.zip"
  ["world.zip"]="$S3_BASE_URL/world.zip"
)

# =========================
# STRUCTURE EXTRACTION
# =========================

EXTRACT_ORDER=(
  "wow-5.4.8.zip"
  "Wow.zip"
  "Wow-64.zip"
  "_Wow.zip"
  "_Wow-64.zip"
  "Interface.zip"
  "Data-Cache.zip"
  "Data-Interface.zip"
  "Data-1.zip"
  "Data-2.zip"
  "Data-3.zip"
  "expansion1.zip"
  "expansion2.zip"
  "expansion3.zip"
  "expansion4.zip"
  "model.zip"
  "sound.zip"
  "texture.zip"
  "world.zip"
  "enUS.zip"
  "frFR.zip"
)

declare -A EXTRACT_STRUCTURE=(
  ["wow-5.4.8.zip"]="."
  ["Wow.zip"]="wow-5.4.8"
  ["Wow-64.zip"]="wow-5.4.8"
  ["_Wow.zip"]="wow-5.4.8"
  ["_Wow-64.zip"]="wow-5.4.8"
  ["Interface.zip"]="wow-5.4.8"
  ["Data-Cache.zip"]="wow-5.4.8/Data"
  ["Data-Interface.zip"]="wow-5.4.8/Data"
  ["enUS.zip"]="wow-5.4.8/Data"
  ["frFR.zip"]="wow-5.4.8/Data"
  ["Data-1.zip"]="wow-5.4.8/Data"
  ["Data-2.zip"]="wow-5.4.8/Data"
  ["Data-3.zip"]="wow-5.4.8/Data"
  ["expansion1.zip"]="wow-5.4.8/Data"
  ["expansion2.zip"]="wow-5.4.8/Data"
  ["expansion3.zip"]="wow-5.4.8/Data"
  ["expansion4.zip"]="wow-5.4.8/Data"
  ["model.zip"]="wow-5.4.8/Data"
  ["sound.zip"]="wow-5.4.8/Data"
  ["texture.zip"]="wow-5.4.8/Data"
  ["world.zip"]="wow-5.4.8/Data"
)

# =========================
# DÉPLACEMENTS
# =========================

declare -A MOVE_FILES=(
  ["Config.wtf"]="wow-5.4.8/WTF"
)

# =========================
# FONCTIONS
# =========================

download_file() {
  local url="$1"
  local dest="$2"
  echo "⬇️  $dest"
  curl -L --progress-bar "$url" -o "$dest"
}

# =========================
# GITHUB DOWNLOAD (CORRIGÉ)
# =========================

echo "🚀 Téléchargement depuis GitHub..."

if [[ "$GITHUB_RELEASE_TAG" == "latest" ]]; then
  API_URL="https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases/latest"
else
  API_URL="https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases/tags/$GITHUB_RELEASE_TAG"
fi

RELEASE_JSON=$(curl -s "$API_URL")

# ➜ Parsing des assets UNE SEULE FOIS
declare -A GITHUB_ASSETS
while read -r name url; do
  GITHUB_ASSETS["$name"]="$url"
done < <(
  echo "$RELEASE_JSON" | jq -r '.assets[] | "\(.name) \(.browser_download_url)"'
)

for file in "${GITHUB_FILES[@]}"; do
  URL="${GITHUB_ASSETS[$file]}"

  if [[ -z "$URL" ]]; then
    echo "⚠️  $file introuvable sur GitHub"
    continue
  fi

  download_file "$URL" "$DOWNLOADS_DIR/$file"
done

# =========================
# AWS S3 DOWNLOAD
# =========================

echo -e "\n🚀 Téléchargement depuis AWS S3..."

for file in "${!S3_FILES[@]}"; do
  download_file "${S3_FILES[$file]}" "$DOWNLOADS_DIR/$file"
done

# =========================
# EXTRACTION
# =========================

echo -e "\n📦 Extraction des fichiers..."

for zip in "${EXTRACT_ORDER[@]}"; do
  SRC="$DOWNLOADS_DIR/$zip"

  if [[ ! -f "$SRC" ]]; then
    echo "❌ $zip introuvable"
    continue
  fi

  DEST="$CLIENT_DIR/${EXTRACT_STRUCTURE[$zip]}"
  mkdir -p "$DEST"

  echo "📦 Extraction de $zip"
  unzip -oq "$SRC" -d "$DEST"
  rm -f "$SRC"
done

# =========================
# DÉPLACEMENT DES FICHIERS
# =========================

echo -e "\n📁 Déplacement des fichiers de configuration..."

for file in "${!MOVE_FILES[@]}"; do
  SRC="$DOWNLOADS_DIR/$file"
  DEST_DIR="$CLIENT_DIR/${MOVE_FILES[$file]}"

  if [[ ! -f "$SRC" ]]; then
    echo "⚠️  $file introuvable"
    continue
  fi

  mkdir -p "$DEST_DIR"
  mv "$SRC" "$DEST_DIR/"
  echo "📄 $file déplacé"
done

echo -e "\n✅ Installation terminée avec succès."
