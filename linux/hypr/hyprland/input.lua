---------------
---- INPUT ----
---------------

hl.config({
    input = {
        -- English first, Czech QWERTY second; Ctrl+Space cycles between them
        -- (the macOS "next input source" shortcut). Binds resolve against the
        -- first layout, so ALT+1..6 etc. keep working while Czech is active.
        kb_layout  = "us,cz",
        kb_variant = ",qwerty",
        kb_model   = "",
        kb_options = "grp:ctrl_space_toggle",
        kb_rules   = "",

        follow_mouse = 1,

        -- Key repeat. Hyprland's defaults (600 ms / 25 per sec) make holding
        -- j/k in neovim feel sluggish. repeat_rate is repeats *per second*, so
        -- higher is faster -- inverted from macOS's KeyRepeat interval.
        --
        -- 200 ms is short enough to feel instant, but stays above the ~150 ms
        -- range where fast typing starts producing unintended double letters.
        -- 50/sec (20 ms apart) is fluid without overshooting the line you want.
        repeat_delay = 200,
        repeat_rate  = 50,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})
