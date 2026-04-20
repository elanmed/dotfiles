# Desktop Entry Overrides

GNOME Shell automatically focuses existing app windows instead of launching new ones.
MATE and rofi don't do this -- they just run the Exec command blindly. These overrides
reimplement that behavior per-app using wmctrl.

## How it works

1. A focus wrapper script in `~/.local/bin/` tries to focus an existing window, falling
   back to launching the app if none is found.
2. A local `.desktop` file in `~/.local/share/applications/` overrides the system one
   (same filename takes precedence) and points Exec to the wrapper script.

## Adding a new app

Find the system desktop file:

    find /usr/share/applications /var/lib/flatpak/exports/share/applications -iname "*appname*"

Copy it to the local override directory (keep the same filename):

    cp /path/to/appname.desktop ~/.local/share/applications/appname.desktop

Create a focus wrapper in `~/.local/bin/`:

    #!/bin/bash
    wmctrl -x -a wm.class.here || appname

The WM class can be found by running `wmctrl -l -x` while the app is open.

Make it executable and update the Exec line in the local desktop file:

    sed -i 's|^Exec=.*|Exec=appname-focus|' ~/.local/share/applications/appname.desktop

## Current overrides

| App     | Desktop file                   | Wrapper script |
| ------- | ------------------------------ | -------------- |
| Brave   | com.brave.Browser.desktop      | brave-focus    |
| WezTerm | org.wezfurlong.wezterm.desktop | wezterm-focus  |

## Custom desktop entries

These don't override anything -- they add actions to rofi that MATE doesn't expose by default.

| Name     | Desktop file     | Command            |
| -------- | ---------------- | ------------------ |
| Suspend  | suspend.desktop  | systemctl suspend  |
| Shutdown | shutdown.desktop | systemctl poweroff |
| Restart  | restart.desktop  | systemctl reboot   |

## Flatpak note

Flatpak apps export their desktop files to `/var/lib/flatpak/exports/share/applications/`.
Rofi scans this path via `$XDG_DATA_DIRS`. A local file with the same name in
`~/.local/share/applications/` overrides it.
