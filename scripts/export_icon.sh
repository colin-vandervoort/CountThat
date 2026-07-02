#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

SVG="logo.svg"
OUT="CountThat/Assets.xcassets/AppIcon.appiconset/logo.png"
ICON_AREA_ID="rect2"

inkscape --export-type=png \
  --export-id="$ICON_AREA_ID" \
  --export-width=1024 \
  --export-height=1024 \
  --export-filename="$OUT" \
  "$SVG"

# Inkscape's PNG writer always includes an alpha channel, even for fully
# opaque content. App Store Connect rejects app icons with an alpha channel,
# so strip it by round-tripping through JPEG (which has none).
TMP_JPG="$(mktemp /tmp/logo_export_XXXX).jpg"
sips -s format jpeg "$OUT" --out "$TMP_JPG" >/dev/null
sips -s format png "$TMP_JPG" --out "$OUT" >/dev/null
rm -f "$TMP_JPG"

sips -g hasAlpha -g pixelWidth -g pixelHeight "$OUT"
echo "Exported and flattened: $OUT"
