#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/ram-monitor.sh"

chmod +x "$SCRIPT_PATH"

CRON_LINE="* * * * * $SCRIPT_PATH >/dev/null 2>&1"

( crontab -l 2>/dev/null | grep -vF "$SCRIPT_PATH" ; echo "$CRON_LINE" ) | crontab -

echo "Installed cron entry (runs every minute):"
echo "  $CRON_LINE"
