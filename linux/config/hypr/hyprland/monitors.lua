------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

-- One scale for every monitor. env.lua derives the X11 apps' scale from it,
-- so changing it here is all that's needed.
local scale = 2

hl.monitor({
    output   = "",
    mode     = "3840x2160@240",
    position = "auto",
    scale    = tostring(scale),
})

-- HDMI-A-1 is a dummy plug used only for Sunshine. It stays off so the cursor
-- can't wander onto it, except while streaming, when DP-1 is off instead.
-- linux/sunshine/display.sh toggles the flag file and reloads.
local streaming = io.open(os.getenv("XDG_RUNTIME_DIR") .. "/sunshine-streaming")
if streaming then
    streaming:close()
    hl.monitor({ output = "DP-1", disabled = true })
    hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60", position = "auto", scale = tostring(scale) })
else
    hl.monitor({ output = "HDMI-A-1", disabled = true })
end

return { scale = scale }
