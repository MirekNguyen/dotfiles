--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Liquid glass for the rofi launcher.
--
-- rofi cannot blur its own backdrop -- it only draws a translucent fill. The
-- frosted effect has to come from the compositor, and Hyprland does not blur
-- layer surfaces unless told to. Without this rule the panel is merely
-- see-through, which is what made it look washed out.
--
-- ignore_alpha keeps the blur off nearly-transparent pixels, so the rounded
-- corners stay clean instead of showing a blurred square behind them.
--
-- no_anim is what stops the text appearing to jump while typing. Narrowing the
-- search shrinks the panel (measured: 383px tall on "g", 143px on "git"), and
-- the "layers" animation eases that resize over several frames -- so every
-- keystroke that drops a result slides the whole panel. Typing within a stable
-- result count looks fine, which is exactly the tell. This makes resizes snap
-- instantly; the panel still shrinks, it just no longer animates doing it.
hl.layer_rule({
    name         = "rofi-glass",
    match        = { namespace = "^rofi$" },
    blur         = true,
    ignore_alpha = 0.2,
    no_anim      = true,
})

-- Liquid glass for the waybar bar, same reasoning as rofi above: GTK cannot
-- blur what is behind a layer surface, so the compositor has to do it. The bar
-- itself is transparent and its inner box carries the tint (linux/waybar/style.css).
hl.layer_rule({
    name         = "waybar-glass",
    match        = { namespace = "^waybar$" },
    blur         = true,
    ignore_alpha = 0.2,
})

-- Liquid glass for swaync. Two namespaces: the control center panel, and the
-- floating toasts, which are a separate surface and would otherwise sit
-- unblurred over the desktop.
hl.layer_rule({
    name         = "swaync-cc-glass",
    match        = { namespace = "^swaync-control-center$" },
    blur         = true,
    ignore_alpha = 0.2,
})

hl.layer_rule({
    name         = "swaync-notifications-glass",
    match        = { namespace = "^swaync-notification-window$" },
    blur         = true,
    ignore_alpha = 0.2,
})

hl.layer_rule({
    name         = "nwg-dock-glass",
    match        = { namespace = "^nwg-dock$" },
    blur         = true,
    ignore_alpha = 0.2,
})

hl.layer_rule({
    name         = "swayosd-glass",
    match        = { namespace = "^swayosd$" },
    blur         = true,
    ignore_alpha = 0.2,
})

-- Games and fullscreen video keep the screen on. Controller input does not
-- count as activity to hypridle, so without this a long cutscene or a game
-- played on a pad would get the display turned off.
hl.window_rule({
    name  = "idle-inhibit-fullscreen",
    match = { class = ".*" },

    idle_inhibit = "fullscreen",
})

-- App -> workspace assignments, ported from config/aerospace/aerospace.toml.
-- Same numbering as on macOS so muscle memory carries over:
--   1 browser   2 terminal   3 comms/office   4 meetings   5 media   6 games
--
-- Matching is on the window class (`hyprctl clients` shows it), anchored and
-- case-insensitive where apps are inconsistent -- Spotify reports "Spotify"
-- even though its .desktop file says StartupWMClass=spotify.
--
-- Only apps installed here are active; the rest are left commented with their
-- likely Linux class so they can be switched on after installing.
local appWorkspaces = {
    { ws = 1, class = "^(helium)$" },
    { ws = 2, class = "^(kitty)$" },
    { ws = 3, class = "^(discord)$" },            -- macOS: Telegram/WhatsApp/Messenger slot
    { ws = 3, class = "^(org\\.telegram\\.desktop)$" },
    { ws = 4, class = "^(teams-for-linux)$" },
    { ws = 5, class = "^([Ss]potify)$" },
    { ws = 5, class = "^(mpv)$" },
    { ws = 6, class = "^([Ss]team)$" },
    { ws = 6, class = "^(net.nullsum.JelliumDesktop)$" },  -- macOS: Jellyfin
    -- { ws = 1, class = "^(zen)$" },
    -- { ws = 3, class = "^(org.telegram.desktop)$" },
    -- { ws = 3, class = "^(thunderbird)$" },     -- macOS: Mail/Outlook
    -- { ws = 3, class = "^(jetbrains-phpstorm)$" },
    -- { ws = 5, class = "^(com.moonlight_stream.Moonlight)$" },
}

for _, rule in ipairs(appWorkspaces) do
    hl.window_rule({
        name  = "ws" .. rule.ws .. "-" .. rule.class:gsub("[^%w]", ""),
        match = { class = rule.class },

        -- AeroSpace moves the window *and* follows it, which is what the
        -- plain (non-silent) form does too.
        workspace = tostring(rule.ws),
    })
end

-- Steam games inherit their own classes (steam_app_NNNN), so they land on
-- whatever workspace is active -- usually 6, since Steam is launched from there.

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})
