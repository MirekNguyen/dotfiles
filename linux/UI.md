# UI style: liquid glass

One look across the Linux desktop, modelled on Apple's Liquid Glass and the
Human Interface Guidelines. Follow this when styling a new surface or changing an
existing one, so the pieces keep looking like one system.

| Surface | Files |
| --- | --- |
| Bar (waybar) | `config/waybar/style.css`, `config/waybar/colors-{dark,light}.css` |
| Notification center and toasts (swaync) | `config/swaync/style.css`, `config/swaync/colors-{dark,light}.css`, `config/swaync/config.json` |
| Dock (nwg-dock-hyprland) | `config/nwg-dock-hyprland/style.css`, `quickshell/DockEdge.qml` (shows it from the bottom edge) |
| Volume/brightness popup (swayosd) | `swayosd/style.css` |
| Window corner buttons (quickshell) | `quickshell/WindowActions.qml` |
| Launcher (rofi) | `rofi/colors-{dark,light}.rasi`, `scripts/rofi-toggle.sh`, `~/.config/rofi/config.rasi` (not in the repo) |
| Lock screen (hyprlock) | `config/hypr/hyprlock/hyprlock.conf` |
| Windows, blur, shadows (Hyprland) | `config/hypr/hyprland/appearance.lua`, `config/hypr/hyprland/rules.lua` |

## Principles

- **Glass is a layer above content.** Bars, panels, popups and toasts are
  glass. App windows are opaque.
- **One edge per surface.** Only the outermost glass surface has a 1px border.
  Everything inside it (cards, buttons, inputs, selected rows) is a borderless
  fill. Never nest outlined boxes, because that gives the double border.
- **Readable first.** The tint is strong enough that the text stays readable
  over any wallpaper or window. The blur makes it look like glass; the tint
  keeps the text readable.
- **Concentric corners.** Inner radius = outer radius - padding.
- **Capsules for controls.** Buttons, toggles, switches, sliders, workspace pills
  and the bar itself are fully rounded (`border-radius: 999px` or half the
  height).
- **Same tokens everywhere.** Use only the palette names below; don't add raw
  colors in a stylesheet, except white for knobs and text on the accent color.

## Palette

The source of truth is `config/waybar/colors-{dark,light}.css`. The dock and
swayosd link to it (their `colors.css` symlinks to waybar's), and swaync imports it.
`rofi/colors-*.rasi` and swaync's `:root` variables repeat the same values,
because those can't read GTK `@define-color`. Change all of them together.

Values follow Apple's system colors (label, fill, systemBlue, systemRed).

| Token | Use | Dark | Light |
| --- | --- | --- | --- |
| `glass-bg` | Tint of a glass surface | `rgba(30,30,32,0.72)` | `rgba(246,246,248,0.72)` |
| `glass-edge` | The single 1px edge | `rgba(255,255,255,0.14)` | `rgba(0,0,0,0.10)` |
| `fill` | Cards, buttons, inputs inside glass | `rgba(120,120,128,0.24)` | `rgba(120,120,128,0.12)` |
| `fill-hover` | Hover | `rgba(120,120,128,0.36)` | `rgba(120,120,128,0.20)` |
| `fill-active` | Selected / current, slider troughs | `rgba(120,120,128,0.48)` | `rgba(120,120,128,0.28)` |
| `fg-primary` | Primary text and icons | `#ffffff` | `#1c1c1e` |
| `fg-secondary` | Secondary text (window title, time, labels) | `rgba(235,235,245,0.60)` | `rgba(60,60,67,0.60)` |
| `fg-dim` | Disabled / empty | `rgba(235,235,245,0.30)` | `rgba(60,60,67,0.30)` |
| `accent` | On toggles, slider fill | `#0a84ff` | `#007aff` |
| `urgent` | Urgent workspace, critical notification edge | `#ff453a` | `#ff3b30` |

rofi names: `bg-base` = `glass-bg`, `bg-input` = `fill`, `bg-hover` =
`fill-hover`, `border-glass` = `glass-edge`.

In light mode the edge is a dark hairline: a white rim vanishes against light
glass.

## Typography

Font: **Adwaita Sans** (a fork of Inter, the closest installed font to SF Pro) for
all text. **Iosevka Nerd Font** comes second in the font list and only supplies
the icon glyphs:

```css
font-family: "Adwaita Sans", "Iosevka Nerd Font";
```

Use `font-feature-settings: "tnum"` wherever numbers change (clock,
percentages), so the layout doesn't shift.

| Role | Size | Weight | Where |
| --- | --- | --- | --- |
| Large title | 20px | bold | Notification center "Notifications" |
| Headline | 15px | 600 | Notification summary, now-playing title, OSD label |
| Body | 14px | 400-500 | Bar text, notification body, default |
| Footnote | 13px | 400-600 | Group headers, subtitles, small buttons |
| Caption | 12px | 400 | Notification time |

Sizes are in logical px (the monitor runs at scale 2). Don't go below 12px.

Icon glyphs are larger than the text next to them, because a Nerd Font glyph
looks small at text size:

| Icon | Size |
| --- | --- |
| Bar icons inline with text | 14px (text size) |
| Bar icon-only module (notifications bell) | 16px |
| Slider icons (brightness, volume) | 20px |
| Quick-setting toggle glyphs | 22px |
| swayosd icon | 22px |
| Notification image / app icon | 64px / 24px |

The lock screen is the exception: white text in both modes, and hyprlock sizes
are physical, not logical. `font_size` is in points at 96 dpi on the 2x
monitor, so 1 logical px is about 1.5 `font_size`. Clock 180 semibold (digits
about 85 logical px tall), day 32 semibold (about 21px), date 26 regular (about 17px).

## Shape and spacing

Every screen-level surface has the same 17px corners, set by the capsule bar
(34px tall). Anything inside one is concentric: its radius is 17 minus its inset.

| Element | Radius | Notes |
| --- | --- | --- |
| Bar | 17px (capsule) | 34px tall, 12px from the top and sides |
| Windows | 17px | Hyprland `rounding`; `gaps_out` 12, `gaps_in` 6 |
| Notification center panel, toasts | 17px | 1px edge + 7px padding; toast content 16px (17 - 1 edge) |
| Cards inside the panel | 12px | cards sit 12px in, 8px apart, content 16px inside |
| Images and boxes inside a card | 6px | album art, notification image, per-app volume box |
| Dock | 17px | 58px tiles 6px in and 6px apart, 11px corners; 42px icons |
| Launcher window / input, rows, tabs | 17 / 9px | 8px padding (scripts/rofi-toggle.sh) |
| swayosd | 17px | |
| Bar pills | 12px (capsule) | 24px tall, 4px inside the bar, 6px apart |
| Tooltips, tray menu | 12px | |
| Controls (buttons, toggles, switches, slider knobs) | 999px | |

Touch targets: at least 44px tall where possible (quick toggles are 52px,
switch and slider knobs 20-22px on a full-width row).

Placement: one 12px margin everywhere. The bar sits 12px from the top and
sides, windows 12px from the screen edges, the bar and each other, and the
notification center and toasts 12px below the bar and from the right edge, so
their right edges line up with the bar's. The dock floats 12px above the bottom.

## Material: blur

Clients can't blur what's behind them; **Hyprland does it** through the layer
rules in `config/hypr/hyprland/rules.lua` (`blur = true`,
`ignore_alpha = 0.2`). Every glass surface needs:

1. A transparent window background, with the tint on an inner box
   (`window#waybar > box`, `#box`, `.control-center`, `.notification`).
2. A layer rule matching its namespace (`hyprctl layers` shows it).

Blur strength is global: `decoration.blur` in `appearance.lua` (size 8,
3 passes).

**GTK4 apps (swaync, swayosd):** GTK 4.22+ registers each surface with the
`ext-background-effect` protocol. Hyprland then ignores the layer rule and
blurs only what GTK asks for, which is nothing. So they're started with
`GDK_WAYLAND_DISABLE=ext_background_effect_manager_v1` (`autostart.lua`).
Don't use CSS `backdrop-filter` instead: swaync draws toasts inside an
opacity node, and GTK can't pass a blur region through one, so toasts would
stay unblurred. Restart these apps the same way when testing:

```sh
pkill -x swaync; GDK_WAYLAND_DISABLE=ext_background_effect_manager_v1 swaync &
```

## Windows

Windows are opaque, with a hairline instead of a colored frame:

- `border_size = 1`, active `rgba(ffffff59)`, inactive `rgba(ffffff1f)`
- soft macOS-style shadow: range 24, offset `0 6`, `0x55000000`
  (inactive `0x33000000`)

## Components

**Bar.** Capsule glass with a pill for each module (4px vertical margin, 13px
radius). Workspaces: `fg-secondary`, empty ones `fg-dim`, current one on
`fill-active`, urgent on `urgent` with white text. Hover is `fill-hover`.
Window title and media are `fg-secondary`, weight normal.

**Notification center.** From top to bottom: quick settings (4 capsule
toggles per row; on = `accent` with white glyph), brightness, volume, now
playing, then the "Notifications" title with Clear, Do Not Disturb, and the
list. Each widget is a `fill` card with no border. The title, DND and the list
have no card of their own. Switches: `fill-active` track, `accent` when on, white knob.
Sliders: 6px `fill-active` trough, `accent` fill, white 20px knob with a small
shadow. The scrollbar is a thin `fill-active` capsule.

**Notifications.** The card is `.notification`. Its `.notification-row` and
`.notification-background` wrappers are transparent and used only for layout.
Inside the center, cards are a `fill` with no border. Toasts are their own glass
surface (`glass-bg` + `glass-edge`). Critical toasts get an `urgent` edge.
Summary 15/600, body 14 `fg-primary`, time 12 `fg-secondary`. Close button and
action buttons are `fill` capsules.

**Dock.** Glass box, icon tiles with `fill-hover` on hover and `fill-active`
while pressed. Running apps get a 4px systemGray (`#8e8e93`) dot inside the
tile under the icon, two for several windows, readable on both glass tints.
Tooltips match the bar's.

**swayosd.** Capsule glass, `fg-primary` label, 6px progress bar with a
`fill-active` trough and a `fg-primary` fill.

**Launcher.** Glass window with the single edge. Search field, message box and
selected row are borderless fills (`bg-input`, `bg-hover`). The inner outlines
in `config.rasi` are overridden in `rofi-toggle.sh`.

**Lock screen.** Hours and minutes stacked in the center, day and date under
them, and a capsule password field (220x40 logical) near the bottom with an
"Enter Password" placeholder at 70% white and centered dots. The field is a
light frosted glass fill (`rgba(255,255,255,0.15)`) with a 1px white edge at 30%. Same palette in both
modes: white text with a soft shadow over the wallpaper, blurred and dimmed to
70%. Following light mode gave dark text on a dark wallpaper. Positions are in %
of the screen.

To preview it without locking your session, run a nested `Hyprland --config
<minimal.lua>` window and make it fullscreen. Then run hyprlock inside it
(`WAYLAND_DISPLAY=wayland-2`) on a copy of the config with every `font_size`,
`size`, `outline_thickness` and `shadow_size` halved: the nested output is
1920x1080 physical. Screenshot it with `grim` from the outer session; screencopy
inside a locked session only returns white. Kill that hyprlock afterwards: it
outlives the nested compositor, and while it runs, hypridle's
`pidof hyprlock || hyprlock` guard blocks the real lock.

## Light and dark

darkman runs `local/share/darkman/theme-switch.sh`, which repoints the
`colors.css` / `colors.rasi` symlinks and reloads waybar (SIGUSR2) and swaync
(`--reload-css`). rofi picks up the new colors the next time it opens. The dock
and swayosd only read their colors when they start. hyprlock does not switch.

Keep token names identical in both variants. When adding a color, add it to
both waybar files, swaync's `:root` blocks if swaync's built-in stylesheet uses
it, and both rofi files if the launcher needs it.

## Adding a new surface

1. Transparent window; put `glass-bg` + 1px `glass-edge` + a radius on the
   inner box.
2. Import the shared palette; use tokens only.
3. Adwaita Sans plus the Nerd Font fallback; sizes from the type scale.
4. Inner elements: borderless fills, capsule controls, concentric radii.
5. Add a `blur` + `ignore_alpha = 0.2` layer rule for its namespace. If it's
   GTK4, start it with `GDK_WAYLAND_DISABLE=ext_background_effect_manager_v1`.
6. If it should follow light/dark, hook it into `theme-switch.sh`.
7. Check it in both modes over a busy wallpaper and over a light window.
