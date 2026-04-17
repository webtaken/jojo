#!/usr/bin/env bash
# Bootstrap installer for jojo.
# Usage:  curl -fsSL https://raw.githubusercontent.com/webtaken/jojo/main/install.sh | bash
set -euo pipefail

REPO="webtaken/jojo"
BRANCH="main"
SCRIPT_URL="https://raw.githubusercontent.com/$REPO/$BRANCH/jojo"
TARGET_DIR="$HOME/.local/bin"
TARGET="$TARGET_DIR/jojo"

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "Error: jojo only supports Linux." >&2
  exit 1
fi

for cmd in curl awk crontab notify-send; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: required command '$cmd' not found." >&2
    case "$cmd" in
      notify-send) echo "  Install with: sudo apt install libnotify-bin" >&2 ;;
      crontab)     echo "  Install with: sudo apt install cron" >&2 ;;
      curl)        echo "  Install with: sudo apt install curl" >&2 ;;
    esac
    exit 1
  fi
done

mkdir -p "$TARGET_DIR"

echo "Downloading jojo..."
curl -fsSL "$SCRIPT_URL" -o "$TARGET"
chmod +x "$TARGET"

echo "Running jojo install..."
"$TARGET" install
