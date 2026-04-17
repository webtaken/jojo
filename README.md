# jojo

Desktop notification when Linux RAM usage crosses a threshold. Edge-triggered — fires **once** per crossing, then resets when RAM drops back below.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/webtaken/jojo/main/install.sh | bash
```

This downloads `jojo` to `~/.local/bin/`, adds a cron entry that runs every minute, and warns if `~/.local/bin` isn't on your `PATH`.

## Usage

```bash
jojo set threshold 75   # persist threshold (1-99, percent)
jojo set delay 5        # persist check interval (1-59, minutes)
jojo get                # show both values
jojo status             # show usage, threshold, delay, state
jojo check              # run the check manually
jojo uninstall          # remove binary and cron entry
jojo help               # list all commands
```

Defaults: **threshold 80%**, **delay 1 minute**. Changing `delay` auto-updates your cron entry.

One-off override: `RAM_THRESHOLD=1 jojo check`.

## How it works

- Reads `MemTotal` and `MemAvailable` from `/proc/meminfo` and computes real memory pressure.
- Stores last seen state (`OK` / `ALERT`) in `~/.cache/jojo/state`.
- Only sends `notify-send` on the `OK → ALERT` transition — no repeat spam.

## Requirements

- Linux (tested on Ubuntu)
- `awk`, `crontab`, `notify-send` (the last one comes from `libnotify-bin` on Debian/Ubuntu)
