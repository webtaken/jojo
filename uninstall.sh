#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/ram-monitor.sh"

crontab -l 2>/dev/null | grep -vF "$SCRIPT_PATH" | crontab -

echo "Removed cron entry for $SCRIPT_PATH"
