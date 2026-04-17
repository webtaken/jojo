#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ram-monitor"
CONFIG_FILE="$CONFIG_DIR/config"
STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/ram-monitor"
STATE_FILE="$STATE_DIR/state"
DEFAULT_THRESHOLD=80

load_threshold() {
  if [[ -n "${RAM_THRESHOLD:-}" ]]; then
    echo "$RAM_THRESHOLD"
    return
  fi
  if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"
    echo "${THRESHOLD:-$DEFAULT_THRESHOLD}"
    return
  fi
  echo "$DEFAULT_THRESHOLD"
}

read_usage() {
  awk '/^MemTotal:/     {total=$2}
       /^MemAvailable:/ {avail=$2}
       END              {printf("%d", (total-avail)*100/total)}' /proc/meminfo
}

cmd_check() {
  local threshold usage prev_state new_state
  threshold=$(load_threshold)

  # notify-send needs these when invoked from cron (no inherited graphical env)
  export DISPLAY="${DISPLAY:-:0}"
  export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"

  mkdir -p "$STATE_DIR"
  usage=$(read_usage)

  prev_state="OK"
  [[ -f "$STATE_FILE" ]] && prev_state=$(<"$STATE_FILE")

  if (( usage >= threshold )); then
    new_state="ALERT"
  else
    new_state="OK"
  fi

  if [[ "$new_state" != "$prev_state" ]]; then
    if [[ "$new_state" == "ALERT" ]]; then
      notify-send -u critical "RAM high" "Memory usage at ${usage}% (threshold ${threshold}%)"
    fi
    echo "$new_state" > "$STATE_FILE"
  fi
}

cmd_set() {
  local value="${1:-}"
  if ! [[ "$value" =~ ^[1-9][0-9]?$ ]]; then
    echo "error: threshold must be an integer between 1 and 99" >&2
    exit 1
  fi
  mkdir -p "$CONFIG_DIR"
  printf 'THRESHOLD=%s\n' "$value" > "$CONFIG_FILE"
  echo "Threshold set to ${value}%"
}

cmd_get() {
  printf '%s%%\n' "$(load_threshold)"
}

cmd_status() {
  local threshold usage state
  threshold=$(load_threshold)
  usage=$(read_usage)
  state="OK"
  [[ -f "$STATE_FILE" ]] && state=$(<"$STATE_FILE")
  printf 'usage:     %s%%\nthreshold: %s%%\nstate:     %s\n' "$usage" "$threshold" "$state"
}

cmd_help() {
  cat <<EOF
Usage: ram-monitor.sh [command]

Commands:
  check           Run the threshold check (default; called by cron)
  set <percent>   Persist threshold (1-99). Example: set 75
  get             Print the current threshold
  status          Print current usage, threshold, and state
  help            Show this message

Environment:
  RAM_THRESHOLD   One-off override; takes precedence over the persisted value
EOF
}

case "${1:-check}" in
  check)           cmd_check ;;
  set)             shift; cmd_set "${1:-}" ;;
  get)             cmd_get ;;
  status)          cmd_status ;;
  help|-h|--help)  cmd_help ;;
  *) echo "unknown command: $1" >&2; cmd_help >&2; exit 1 ;;
esac
