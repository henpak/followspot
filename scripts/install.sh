#!/usr/bin/env bash
# Installs (or uninstalls) Followspot from GitHub Releases.
#
#   curl -fsSL https://raw.githubusercontent.com/henpak/followspot/main/scripts/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/henpak/followspot/main/scripts/install.sh | bash -s -- --uninstall
#
# Environment:
#   FOLLOWSPOT_VERSION      release to install, e.g. 1.0.0 (default: latest)
#   FOLLOWSPOT_INSTALL_DIR  install location (default: ~/Applications)
#   FOLLOWSPOT_DOWNLOAD_URL base URL that contains Followspot.zip and Followspot.zip.sha256
#                           (overrides FOLLOWSPOT_VERSION; useful for testing, file:// works)
set -euo pipefail

REPO="henpak/followspot"
APP_NAME="Followspot"
BUNDLE_ID="io.github.henpak.followspot"
INSTALL_DIR="${FOLLOWSPOT_INSTALL_DIR:-$HOME/Applications}"
APP_PATH="$INSTALL_DIR/$APP_NAME.app"

info() { printf '==> %s\n' "$*"; }
fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }

quit_running_app() {
    if pgrep -x "$APP_NAME" >/dev/null 2>&1; then
        info "Quitting running $APP_NAME"
        pkill -x "$APP_NAME" || true
        sleep 0.5
    fi
}

uninstall() {
    quit_running_app
    if [[ -d "$APP_PATH" ]]; then
        rm -rf "$APP_PATH"
        info "Removed $APP_PATH"
    else
        info "$APP_PATH is not installed"
    fi
    # Ask only when a terminal is available (stdin is the script itself under `curl | bash`).
    local answer=""
    if { exec 3</dev/tty; } 2>/dev/null; then
        printf 'Also delete Followspot settings (colors, sizes)? [y/N] '
        read -r answer <&3 || answer=""
        exec 3<&-
    fi
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        defaults delete "$BUNDLE_ID" 2>/dev/null || true
        info "Settings deleted"
    else
        info "Settings kept (delete later with: defaults delete $BUNDLE_ID)"
    fi
}

install() {
    [[ "$(uname -s)" == "Darwin" ]] || fail "Followspot runs on macOS only."
    local major
    major="$(sw_vers -productVersion | cut -d. -f1)"
    (( major >= 15 )) || fail "Followspot needs macOS 15 or newer (found $(sw_vers -productVersion))."

    local base
    if [[ -n "${FOLLOWSPOT_DOWNLOAD_URL:-}" ]]; then
        base="${FOLLOWSPOT_DOWNLOAD_URL%/}"
    elif [[ -n "${FOLLOWSPOT_VERSION:-}" ]]; then
        base="https://github.com/$REPO/releases/download/v${FOLLOWSPOT_VERSION#v}"
    else
        base="https://github.com/$REPO/releases/latest/download"
    fi

    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT
    local tmp="$TMP_DIR"

    info "Downloading $APP_NAME from $base"
    curl -fsSL "$base/$APP_NAME.zip" -o "$tmp/$APP_NAME.zip" || fail "Download failed."
    curl -fsSL "$base/$APP_NAME.zip.sha256" -o "$tmp/$APP_NAME.zip.sha256" || fail "Checksum download failed."

    info "Verifying checksum"
    (cd "$tmp" && shasum -a 256 -c "$APP_NAME.zip.sha256" >/dev/null) || fail "Checksum mismatch."

    ditto -x -k "$tmp/$APP_NAME.zip" "$tmp/unpacked"
    [[ -d "$tmp/unpacked/$APP_NAME.app" ]] || fail "Archive does not contain $APP_NAME.app."

    quit_running_app
    info "Installing to $APP_PATH"
    mkdir -p "$INSTALL_DIR"
    rm -rf "$APP_PATH"
    ditto "$tmp/unpacked/$APP_NAME.app" "$APP_PATH"
    xattr -dr com.apple.quarantine "$APP_PATH" 2>/dev/null || true

    info "Starting $APP_NAME – look for the cursor icon in the menu bar"
    open "$APP_PATH"
}

case "${1:-}" in
    "") install ;;
    --uninstall) uninstall ;;
    -h|--help)
        echo "Usage: install.sh [--uninstall]"
        echo "Environment: FOLLOWSPOT_VERSION, FOLLOWSPOT_INSTALL_DIR, FOLLOWSPOT_DOWNLOAD_URL"
        ;;
    *) fail "Unknown option: $1 (use --uninstall or --help)" ;;
esac
