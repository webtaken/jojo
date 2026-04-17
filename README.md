# jojo

Desktop notification (with sound) when RAM usage crosses a threshold. Works on **Linux** and **macOS**. Edge-triggered — fires **once** per crossing, then resets when RAM drops back below.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/webtaken/jojo/main/install.sh | bash
```

This downloads `jojo` + the alert sound, installs to `~/.local/bin/`, and registers with the right scheduler for your OS:

| OS | Scheduler | Config location |
|----|-----------|-----------------|
| Linux | `cron` | user crontab |
| macOS | `launchd` | `~/Library/LaunchAgents/com.webtaken.jojo.plist` |

If `~/.local/bin` isn't on your `PATH`, the installer will tell you how to add it.

## Usage

```bash
jojo set threshold 75   # persist threshold (1-99, percent)
jojo set delay 5        # persist check interval (1-59, minutes)
jojo set repeat 15      # re-notify every N min while above threshold (0 disables)
jojo get                # show all values
jojo status             # show usage, threshold, delay, repeat, state
jojo check              # run the check manually
jojo uninstall          # remove binary and scheduler entry
jojo help               # list all commands
```

Defaults: **threshold 80%**, **delay 1 minute**, **repeat 10 minutes**. Changing `delay` auto-updates your scheduler entry. Set `repeat 0` to restore edge-only behavior (one notification per crossing).

One-off override: `RAM_THRESHOLD=1 jojo check`.

## How it works

- **Linux**: reads `/proc/meminfo` (`MemTotal` / `MemAvailable`).
- **macOS**: reads `sysctl hw.memsize` and `vm_stat` (`active + wired + compressed` pages).
- Stores last seen state (`OK` / `ALERT`) in `~/.cache/jojo/state`.
- On the `OK → ALERT` transition only: sends a desktop notification (`notify-send` / `osascript`) and plays `fahhh.mp3` (`ffplay` / `mpg123` / `paplay` / `afplay`).

## Requirements

- **Linux**: `awk`, `crontab`, `notify-send` (`libnotify-bin`). Sound is optional (`ffplay` / `mpg123` / `paplay`).
- **macOS**: all built-in — `launchctl`, `osascript`, `afplay`, `sysctl`, `vm_stat`.
