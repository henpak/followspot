#!/usr/bin/env bash
# Records the README screenshots and GIFs into docs/images/.
#
# Usage: scripts/record-demo.sh
#
# Requirements:
#   - Followspot installed in ~/Applications (scripts/build-app.sh)
#   - ffmpeg (brew install ffmpeg)
#   - Screen Recording and Accessibility permission for your terminal app
#
# Your Followspot settings are backed up, reset to the defaults for the recording
# and restored afterwards. Don't touch mouse or keyboard while it runs (about a minute).
set -euo pipefail

cd "$(dirname "$0")/.."

BUNDLE_ID="io.github.henpak.followspot"
APP="${FOLLOWSPOT_INSTALL_DIR:-$HOME/Applications}/Followspot.app"
OUT="docs/images"
WORK="$(mktemp -d)"
BACKUP="$WORK/settings.plist"

command -v ffmpeg >/dev/null || { echo "ffmpeg is required (brew install ffmpeg)" >&2; exit 1; }
[[ -d "$APP" ]] || { echo "$APP not found; run scripts/build-app.sh first" >&2; exit 1; }

restart_app() {
    pkill -x Followspot 2>/dev/null && sleep 0.7 || true
    open "$APP"
    sleep 2
}

restore() {
    echo "==> Restoring your settings"
    defaults delete "$BUNDLE_ID" 2>/dev/null || true
    if [[ -s "$BACKUP" ]]; then
        defaults import "$BUNDLE_ID" "$BACKUP"
    fi
    restart_app
    rm -rf "$WORK"
}

echo "==> Backing up settings and starting Followspot with defaults"
defaults export "$BUNDLE_ID" "$BACKUP" 2>/dev/null || true
trap restore EXIT
defaults delete "$BUNDLE_ID" 2>/dev/null || true
defaults write "$BUNDLE_ID" migratedFromLegacyDomain -bool true
restart_app

echo "==> Compiling recorder"
swiftc -O -o "$WORK/recorder" docs/demo/record.swift

echo "==> Recording (hands off mouse and keyboard)"
"$WORK/recorder" "$WORK"

echo "==> Converting"
mkdir -p "$OUT"
for clip in clicks highlight spotlight halo; do
    # Drop the first second (recorder warm-up), 20 fps, 960 px wide, optimized palette.
    ffmpeg -loglevel error -y -ss 1 -i "$WORK/$clip.mov" \
        -vf "fps=20,scale=960:-1:flags=lanczos,split[a][b];[a]palettegen=stats_mode=diff[p];[b][p]paletteuse=dither=sierra2_4a" \
        "$OUT/$clip.gif"
done
for still in hero menu; do
    if [[ -f "$WORK/$still.png" ]]; then
        cp "$WORK/$still.png" "$OUT/$still.png"
    fi
done
ls -lh "$OUT"
