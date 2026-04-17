#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/ram-monitor.sh"

chmod +x "$SCRIPT_PATH"

CRON_LINE="* * * * * $SCRIPT_PATH >/dev/null 2>&1"

# `|| true` so a missing-crontab or no-match grep doesn't abort under pipefail
existing="$(crontab -l 2>/dev/null | grep -vF "$SCRIPT_PATH" || true)"

if [[ -n "$existing" ]]; then
  printf '%s\n%s\n' "$existing" "$CRON_LINE" | crontab -
else
  printf '%s\n' "$CRON_LINE" | crontab -
fi

echo "Installed cron entry (runs every minute):"
echo "  $CRON_LINE"
