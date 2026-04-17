#!/usr/bin/env bash
# Bootstrap installer for jojo.
# Usage:  curl -fsSL https://raw.githubusercontent.com/webtaken/jojo/main/install.sh | bash
set -euo pipefail

REPO="webtaken/jojo"
BRANCH="main"
SCRIPT_URL="https://raw.githubusercontent.com/$REPO/$BRANCH/jojo"
SOUND_URL="https://raw.githubusercontent.com/$REPO/$BRANCH/fahhh.mp3"
TARGET_DIR="$HOME/.local/bin"
TARGET="$TARGET_DIR/jojo"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/jojo"

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

mkdir -p "$TARGET_DIR" "$DATA_DIR"

echo "Downloading jojo..."
curl -fsSL "$SCRIPT_URL" -o "$TARGET"
chmod +x "$TARGET"

echo "Downloading alert sound..."
curl -fsSL "$SOUND_URL" -o "$DATA_DIR/fahhh.mp3"

if ! command -v ffplay >/dev/null 2>&1 \
  && ! command -v mpg123 >/dev/null 2>&1 \
  && ! command -v paplay >/dev/null 2>&1; then
  echo "NOTE: no MP3 player found (ffplay / mpg123 / paplay)."
  echo "      Notifications will still fire, but silently."
  echo "      Install one with: sudo apt install ffmpeg"
fi

echo "Running jojo install..."
"$TARGET" install
