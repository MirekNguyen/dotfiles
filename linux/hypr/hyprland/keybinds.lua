---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal    = "kitty"
local fileManager = "nautilus"
local menu        = "hyprlauncher"
local browser     = "helium-browser"
-- Toggle script rather than "rofi -show drun": pressing SUPER+SPACE again while
-- the launcher is open should close it, the way Cmd+Space does on macOS.
local launcher    = os.getenv("HOME") .. "/.config/dotfiles/linux/scripts/rofi-toggle.sh"


---------------------
---- KEYBINDINGS ----
---------------------

-- Mirrors the AeroSpace (macOS) bindings in config/aerospace/aerospace.toml
local mainMod = "ALT"      -- AeroSpace's `alt-`
local monMod  = "CTRL + SHIFT" -- AeroSpace's `ctrl-shift-` (monitor commands)

-- Launchers / window actions
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind("SUPER" .. " + SPACE", hl.dsp.exec_cmd(launcher))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
-- macOS Cmd+Q: quit the whole app. Lives here rather than in xremap because no
-- single keystroke means "quit" across Linux apps -- see linux/scripts/quit-app.sh.
hl.bind("SUPER + Q", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/dotfiles/linux/scripts/quit-app.sh"))

-- Lock screen on Cmd+Ctrl+Q, as on macOS. Goes through loginctl so hypridle's
-- lock_cmd is the single place that starts hyprlock (and guards duplicates).
-- xremap has no Super-q entry, so this reaches Hyprland in every app.
hl.bind("SUPER + CTRL + Q", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))

-- Manual light/dark toggle. darkman also switches on its own at sunrise/sunset;
-- this is the override, equivalent to flipping macOS's appearance by hand.
--
-- On ALT+SHIFT+T rather than SHIFT+T: xremap claims Super-Shift-t for
-- reopen-closed-tab, which is the more valuable macOS binding, and xremap runs
-- below the compositor so it would win.
hl.bind("SUPER + ALT + SHIFT + T", hl.dsp.exec_cmd("darkman toggle"))

-- Clipboard history on Cmd+Alt+Shift+C, matching the macOS muscle memory.
-- SUPER+SHIFT+V is unavailable regardless: xremap claims it for
-- paste-without-formatting and runs below the compositor, so a bind there would
-- never fire.
hl.bind("SUPER + ALT + SHIFT + C", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/dotfiles/linux/scripts/rofi-clipboard.sh"))

-- Screenshots, following macOS semantics:
--   Cmd+Shift+3        whole screen  -> file
--   Cmd+Shift+4        drag a region -> file
--   Cmd+Shift+5        active window -> file
-- Adding Ctrl copies to the clipboard instead of writing a file, as on macOS.
--
-- These combos are safe from xremap: its Super-3/Super-4 entries require Shift
-- *not* to be held, so Super+Shift+N passes through to Hyprland untouched.
--
-- hyprshot copies every capture to the clipboard as well; the file-saving
-- variants get a macOS-style name in ~/Pictures/Screenshots. -m active pins
-- output/window mode to the focused monitor/window instead of asking for a
-- click. -z freezes the screen while dragging a region, like macOS.
-- The filename is computed by sh at press time, hence sh -c.
local shotFile = "-o ~/Pictures/Screenshots -f \"Screenshot $(date '+%Y-%m-%d at %H.%M.%S').png\""
local function hyprshot(args)
    return hl.dsp.exec_cmd("sh -c 'hyprshot " .. (args:gsub("'", "'\\''")) .. "'")
end
hl.bind("SUPER + SHIFT + 3", hyprshot("-m active -m output " .. shotFile))
hl.bind("SUPER + SHIFT + 4", hyprshot("-z -m region " .. shotFile))
hl.bind("SUPER + SHIFT + 5", hyprshot("-m active -m window " .. shotFile))
hl.bind("SUPER + CTRL + SHIFT + 3", hyprshot("-m active -m output --clipboard-only"))
hl.bind("SUPER + CTRL + SHIFT + 4", hyprshot("-z -m region --clipboard-only"))

-- `alt-f` = fullscreen
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

-- `alt-slash` / `alt-comma` = layout toggles
-- dwindle has no accordion, so comma toggles a tabbed group instead
hl.bind(mainMod .. " + slash", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + comma", hl.dsp.group.toggle())

-- `alt-hjkl` = focus
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

-- `alt-shift-hjkl` = move window
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

-- `alt-shift-minus` / `alt-shift-equal` = resize smart -/+ 50
hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.window.resize({ x = -50, y = -50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + equal", hl.dsp.window.resize({ x = 50,  y = 50,  relative = true }), { repeating = true })

-- `alt-1..6` = workspace, `alt-shift-1..6` = move node to workspace
-- (AeroSpace only uses 1-6; 7-0 are here anyway and cost nothing)
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- `alt-tab` = workspace back and forth
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "previous" }))

-- `ctrl-shift-j/k` = focus monitor next/prev, `ctrl-shift-1/2` = focus monitor N
hl.bind(monMod .. " + J", hl.dsp.focus({ monitor = "+1" }))
hl.bind(monMod .. " + K", hl.dsp.focus({ monitor = "-1" }))
hl.bind(monMod .. " + 1", hl.dsp.focus({ monitor = 0 }))
hl.bind(monMod .. " + 2", hl.dsp.focus({ monitor = 1 }))

-- `alt-shift-tab` = move current workspace to the next monitor
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.workspace.move({ monitor = "+1" }))

-- Scratchpad. On ALT rather than SUPER: xremap claims SUPER+S for Cmd+S (save),
-- and it grabs keys below the compositor, so a SUPER+S bind here would never fire.
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
