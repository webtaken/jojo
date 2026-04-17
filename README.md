# ram-monitor

Desktop notification when Linux RAM usage crosses a threshold. Edge-triggered — fires once per crossing, resets when RAM drops back below.

## Usage

```bash
./install.sh      # installs a cron entry that runs every minute
./uninstall.sh    # removes the cron entry
```

Default threshold is 80%. Override with an env var in the crontab line, e.g. `RAM_THRESHOLD=90`.

## How it works

- Reads `MemTotal` and `MemAvailable` from `/proc/meminfo` and computes real memory pressure.
- Stores last seen state (`OK` / `ALERT`) in `~/.cache/ram-monitor/state`.
- Only sends `notify-send` on the `OK → ALERT` transition.

## Test it manually

```bash
RAM_THRESHOLD=1 ./ram-monitor.sh   # forces an ALERT notification
RAM_THRESHOLD=99 ./ram-monitor.sh  # resets state back to OK
```
