------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",
    mode     = "3840x2160@240",
    position = "auto",
    scale    = "2",
})

-- HDMI-A-1 is a dummy plug used only for Sunshine. It stays off so the cursor
-- can't wander onto it, except while streaming, when DP-1 is off instead.
-- linux/sunshine/display.sh toggles the flag file and reloads.
local streaming = io.open(os.getenv("XDG_RUNTIME_DIR") .. "/sunshine-streaming")
if streaming then
    streaming:close()
    hl.monitor({ output = "DP-1", disabled = true })
    hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60", position = "auto", scale = "2" })
else
    hl.monitor({ output = "HDMI-A-1", disabled = true })
end
