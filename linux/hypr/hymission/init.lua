-- hymission: Mission Control-style
--
-- The plugin source is cloned into build/ next to this file (gitignored) and
-- built there. After a Hyprland update, rebuild it with rebuild.sh here,
local so = os.getenv("HOME") .. "/.config/hypr/hymission/build/build-cmake/libhymission.so"

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprctl plugin load " .. so)
end)

if hl.plugin and hl.plugin.hymission then
    hl.config({
        plugin = {
            hymission = {
                only_active_workspace  = 1,
                layout_engine          = "natural",
                workspace_strip_anchor = "top",
            },
        },
    })

    hl.bind("XF86LaunchA", hl.plugin.hymission.toggle, { description = "Mission Control" })
    hl.bind("F3", hl.plugin.hymission.toggle, { description = "Mission Control" })
end
