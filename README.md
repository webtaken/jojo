# ram-monitor

Desktop notification when Linux RAM usage crosses a threshold. Edge-triggered — fires once per crossing, resets when RAM drops back below.

## Usage

```bash
./install.sh      # installs a cron entry that runs every minute
./uninstall.sh    # removes the cron entry
```

### Configure the threshold

```bash
./ram-monitor.sh set 75     # persist threshold to 75%
./ram-monitor.sh get        # show current threshold
./ram-monitor.sh status     # show usage, threshold, state
./ram-monitor.sh help       # list all commands
```

The persisted value is stored at `~/.config/ram-monitor/config`. Default is 80%. `RAM_THRESHOLD=<n>` as an env var overrides the persisted value for one-off runs.

## How it works

- Reads `MemTotal` and `MemAvailable` from `/proc/meminfo` and computes real memory pressure.
- Stores last seen state (`OK` / `ALERT`) in `~/.cache/ram-monitor/state`.
- Only sends `notify-send` on the `OK → ALERT` transition.

## Test it manually

```bash
RAM_THRESHOLD=1  ./ram-monitor.sh check   # forces an ALERT notification
RAM_THRESHOLD=99 ./ram-monitor.sh check   # resets state back to OK
```
