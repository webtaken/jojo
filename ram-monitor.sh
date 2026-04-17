#!/usr/bin/env bash
set -euo pipefail

THRESHOLD="${RAM_THRESHOLD:-80}"
STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/ram-monitor"
STATE_FILE="$STATE_DIR/state"

# notify-send needs these when invoked from cron (no inherited graphical env)
export DISPLAY="${DISPLAY:-:0}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"

mkdir -p "$STATE_DIR"

usage=$(awk '/^MemTotal:/     {total=$2}
             /^MemAvailable:/ {avail=$2}
             END              {printf("%d", (total-avail)*100/total)}' /proc/meminfo)

prev_state="OK"
[[ -f "$STATE_FILE" ]] && prev_state=$(<"$STATE_FILE")

if (( usage >= THRESHOLD )); then
  new_state="ALERT"
else
  new_state="OK"
fi

if [[ "$new_state" != "$prev_state" ]]; then
  if [[ "$new_state" == "ALERT" ]]; then
    notify-send -u critical "RAM high" "Memory usage at ${usage}% (threshold ${THRESHOLD}%)"
  fi
  echo "$new_state" > "$STATE_FILE"
fi
