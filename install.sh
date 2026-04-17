#!/usr/bin/env bash
# Bootstrap installer for jojo (Linux & macOS).
# Usage:  curl -fsSL https://raw.githubusercontent.com/webtaken/jojo/main/install.sh | bash
set -euo pipefail

REPO="webtaken/jojo"
BRANCH="main"
SCRIPT_URL="https://raw.githubusercontent.com/$REPO/$BRANCH/jojo"
SOUND_URL="https://raw.githubusercontent.com/$REPO/$BRANCH/fahhh.mp3"
TARGET_DIR="$HOME/.local/bin"
TARGET="$TARGET_DIR/jojo"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/jojo"

case "$(uname -s)" in
  Linux)  OS="linux" ;;
  Darwin) OS="macos" ;;
  *) echo "Error: jojo supports Linux and macOS only." >&2; exit 1 ;;
esac

check_cmd() {
  local cmd="$1" hint="${2:-}"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: required command '$cmd' not found." >&2
    [[ -n "$hint" ]] && echo "  $hint" >&2
    exit 1
  fi
}

check_cmd curl "Install with: $( [[ $OS == macos ]] && echo 'brew install curl' || echo 'sudo apt install curl' )"
check_cmd awk

if [[ "$OS" == "linux" ]]; then
  check_cmd crontab     "sudo apt install cron"
  check_cmd notify-send "sudo apt install libnotify-bin"
  if ! command -v ffplay >/dev/null 2>&1 \
    && ! command -v mpg123 >/dev/null 2>&1 \
    && ! command -v paplay >/dev/null 2>&1; then
    echo "NOTE: no MP3 player found (ffplay / mpg123 / paplay)."
    echo "      Notifications will still fire, but silently."
    echo "      Install one with: sudo apt install ffmpeg"
  fi
else
  check_cmd launchctl
  check_cmd osascript
  check_cmd afplay
  check_cmd sysctl
  check_cmd vm_stat
fi

mkdir -p "$TARGET_DIR" "$DATA_DIR"

echo "Downloading jojo..."
curl -fsSL "$SCRIPT_URL" -o "$TARGET"
chmod +x "$TARGET"

echo "Downloading alert sound..."
curl -fsSL "$SOUND_URL" -o "$DATA_DIR/fahhh.mp3"

echo "Running jojo install..."
"$TARGET" install
