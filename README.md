# ROG Power Center

Hardware control GUI for ASUS ROG Strix laptops on Linux. Built with Flutter Desktop.

Designed for the **ROG Strix G614JV** (i9 + RTX 4060), but should work on other ASUS ROG models with `asus-nb-wmi` kernel module.

## Features

- **Power Profiles**: Silent / Daily / Gaming — one-click switching of thermal policy, CPU boost, EPP, PPT limits
- **CPU Control**: Turbo boost toggle, EPP selector (Power → Performance), PL1/PL2 watt sliders
- **GPU Info**: dGPU status, MUX mode, NVIDIA dynamic boost & temp target
- **Battery**: Live charge %, status, power draw, configurable charge limit slider
- **Display**: Panel overdrive toggle (165Hz fast response)
- **Keyboard**: Brightness levels (Off/Low/Med/High), lightbar toggle (requires `asusctl`)
- **Live Monitoring**: CPU temperature, fan RPMs (CPU/GPU/Aux), power consumption — polled every 2s
- **System Tray**: Quick profile switching and boost toggle from tray icon menu
- **Minimize to Tray**: Closing the window keeps the app running in background

## Architecture

```
lib/
├── main.dart                 # Entry point, tray setup, window management
├── app.dart                  # MaterialApp with dark theme (Material 3)
├── models/
│   ├── system_state.dart     # Immutable snapshot of all hardware state
│   └── power_profile.dart    # Profile presets (Silent/Daily/Gaming)
├── services/
│   ├── sysfs_service.dart    # Direct sysfs read/write + pkexec batch helper
│   ├── hardware_monitor.dart # Periodic polling via ChangeNotifier
│   └── profile_manager.dart  # Applies profiles in a single batch write
├── screens/
│   └── home_screen.dart      # Responsive layout (1-col narrow, 2-col wide)
└── widgets/
    ├── profile_selector.dart # Profile buttons with icons
    ├── cpu_card.dart         # Boost, EPP, PL1/PL2 sliders
    ├── gpu_card.dart         # dGPU, MUX, NV boost/temp
    ├── battery_card.dart     # Charge, status, limit slider
    ├── display_card.dart     # Panel overdrive toggle
    ├── keyboard_card.dart    # Brightness, lightbar (via asusctl)
    ├── monitor_card.dart     # Temps, fan RPMs
    └── status_card.dart      # Reusable card + row components
```

## How It Works

All hardware control is done via **direct sysfs reads/writes** — no daemon required.

| Control | Path |
|---|---|
| Thermal policy | `/sys/devices/platform/asus-nb-wmi/throttle_thermal_policy` |
| CPU boost | `/sys/devices/system/cpu/intel_pstate/no_turbo` |
| EPP | `/sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference` |
| PPT PL1/PL2 | `/sys/devices/platform/asus-nb-wmi/ppt_pl1_spl`, `ppt_pl2_sppt` |
| NV boost/temp | `/sys/devices/platform/asus-nb-wmi/nv_dynamic_boost`, `nv_temp_target` |
| Panel overdrive | `/sys/devices/platform/asus-nb-wmi/panel_od` |
| Keyboard LEDs | `/sys/class/leds/asus::kbd_backlight/brightness` |
| Battery | `/sys/class/power_supply/BAT0/` |
| Fans | `/sys/class/hwmon/hwmon8/fan*_input` |
| CPU temp | `/sys/class/hwmon/hwmon7/temp1_input` |

Writes that fail (permission denied) are batched into a **single `pkexec` call** via `~/.local/bin/rog-power-helper`, so at most one password prompt per action.

## Dependencies

- Flutter SDK 3.x
- `libgtk-3-dev`, `clang`, `ninja-build`, `libayatana-appindicator3-dev`, `libstdc++-14-dev`
- GNOME extension `ubuntu-appindicators` (for system tray)
- Optional: `asusctl` (only needed for lightbar control)

## Build

```bash
export PATH="$HOME/flutter/bin:$PATH"
cd ~/projects/rog_power_center
mkdir -p build/native_assets/linux
flutter build linux
```

## Install

```bash
# Copy bundle to local install
mkdir -p ~/.local/share/rog-power-center
cp -r build/linux/x64/release/bundle/* ~/.local/share/rog-power-center/

# Symlink for CLI access
ln -sf ~/.local/share/rog-power-center/rog_power_center ~/.local/bin/rog-power-center
```

The `.desktop` file is already installed at `~/.local/share/applications/rog-power-center.desktop` and autostart at `~/.config/autostart/rog-power-center.desktop`.

## Permissions

Most sysfs paths need root to write. Two mechanisms handle this:

1. **udev rules** (`/etc/udev/rules.d/99-rog-hw-permissions.rules`) — grant user write access to common paths
2. **pkexec batch helper** (`~/.local/bin/rog-power-helper`) — single elevated call for remaining paths, with polkit policy at `/usr/share/polkit-1/actions/com.rogpower.helper.policy` using `auth_admin_keep` (caches auth for a few minutes)

## License

MIT
