#!/usr/bin/env bash
# Builds Followspot.app from source and installs it (for local development).
#
# Usage: scripts/build-app.sh [--open]
#
# Environment:
#   FOLLOWSPOT_SIGN_IDENTITY  codesign identity (default: "-", ad-hoc signature)
#   FOLLOWSPOT_INSTALL_DIR    install location   (default: ~/Applications)
set -euo pipefail

cd "$(dirname "$0")/.."

APP_NAME="Followspot"
INSTALL_DIR="${FOLLOWSPOT_INSTALL_DIR:-$HOME/Applications}"

scripts/package-app.sh

echo "==> Installing to $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
pkill -x "$APP_NAME" 2>/dev/null && sleep 0.5 || true
rm -rf "${INSTALL_DIR:?}/$APP_NAME.app"
ditto "build/$APP_NAME.app" "$INSTALL_DIR/$APP_NAME.app"

# The app used to be called "Presenter"; remove a leftover copy (settings are migrated on launch).
if [[ -d "$INSTALL_DIR/Presenter.app" ]]; then
    echo "==> Removing old $INSTALL_DIR/Presenter.app"
    pkill -x Presenter 2>/dev/null && sleep 0.5 || true
    rm -rf "${INSTALL_DIR:?}/Presenter.app"
fi

echo "==> Installed: $INSTALL_DIR/$APP_NAME.app"

if [[ "${1:-}" == "--open" ]]; then
    open "$INSTALL_DIR/$APP_NAME.app"
fi
