-- hymission: Mission Control-style
--
-- Source and build live outside the repo, in ~/.local/hyprland/hymission.
-- After a Hyprland update, rebuild it with linux/scripts/hymission-rebuild.sh,
local so = os.getenv("HOME") .. "/.local/hyprland/hymission/build-cmake/libhymission.so"

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
