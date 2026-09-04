# macOS system settings

Most of System Settings is declared in [`flake.nix`](./flake.nix) under
`system.defaults` and applied by `../install/setup.sh` (or `nix-rebuild`).

This file tracks the rest: settings that have **no nix-darwin option** and must
be clicked through once per machine. Everything below is a manual step.

---

## Manual steps

### Keyboard > Keyboard Shortcuts > Modifier Keys

- Caps Lock -> Escape
- Globe -> Caps Lock

> Not declared in the flake on purpose. `system.keyboard.remapCapsLockToEscape`
> uses `hidutil`, which does not survive a reboot or a keyboard hot-plug and can
> fight with this panel. The System Settings mapping is persistent, but it is
> stored per-keyboard under `com.apple.keyboard.modifiermapping.<vendor>-<product>-0`,
> so it cannot be expressed generically. Repeat for each external keyboard.

### Keyboard > Keyboard Shortcuts

- Launchpad & Dock > Turn Dock hiding on/off — `opt+cmd+D`
- Input Sources
  - Select the previous input source — `ctrl+opt+cmd+space`
  - Select next source in input menu — `ctrl+cmd+space`
- Spotlight > Show Spotlight search — `opt+shift+cmd+space`
- Function Keys > Use F1, F2 as standard function keys — off

> Stored as an opaque binary plist in `com.apple.symbolichotkeys`.

### Keyboard > Input Sources

- ABC (U.S.) and Czech — QWERTY
- Vietnamese (VNI)
- Disable all "correct spelling automatically"-style options
- Text replacements — none

> Stored as a nested array in `com.apple.HIToolbox.AppleEnabledInputSources`.

### Keyboard (misc)

- Keyboard brightness — lowest
- Turn keyboard backlight off after inactivity — Never
- Press Globe key to — Do Nothing

### Control Center

- Control Center Modules — disable everything
- Other Modules — disable everything except:
  - Battery — Show in Menu Bar + Show Percentage *(percentage is in the flake)*
  - Fast User Switching — Show in Menu Bar as Icon
- Menu Bar Only — disable everything
- Recent documents, applications and servers — None

> Only the handful of toggles exposed as `system.defaults.controlcenter.*` are
> declared; the per-module menu-bar visibility lives in
> `com.apple.controlcenter` `NSStatusItem Visible <name>` keys.

### Wallpaper

Set manually.

### Trackpad

- Point & Click > Tracking speed — 4
- Silent clicking — on
- Scroll & Zoom — all on
- More Gestures — all off

> Tracking speed (`com.apple.trackpad.scaling`) and silent clicking
> (`ActuationStrength`) are only written once you move the slider, so they are
> not in the flake.

---

## Declared in `flake.nix`

For reference, these are already handled — do **not** set them by hand:

| Area | Options |
| --- | --- |
| Dock | autohide, left orientation, tile size, no magnification/launch anim/recents, empty persistent apps, hot corners |
| Keyboard | `KeyRepeat`, `InitialKeyRepeat`, `ApplePressAndHoldEnabled`, keyboard navigation |
| Menu bar | auto-hide, clock format |
| Text input | all six auto-capitalize / dash / quote / period / spelling / prediction toggles off |
| Trackpad | tap to click, three-finger drag off, right click, click thresholds |
| Finder | column view, desktop volume visibility, status bar |
| Windows | Stage Manager off, tiled window margins, `HideDesktop` |
| Misc | screenshot target, spaces spanning displays, guest login |

## Inspecting current state

```bash
defaults read -g                       # NSGlobalDomain
defaults read com.apple.dock
defaults read com.apple.finder
defaults read com.apple.controlcenter
defaults read com.apple.AppleMultitouchTrackpad
```

Diff those against `flake.nix` when something drifts.
