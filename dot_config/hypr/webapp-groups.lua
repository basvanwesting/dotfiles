-- Mail and calendar replace Omarchy's HEY defaults with tabbed groups of web
-- apps, one window per account: Google mail on the plain key, Microsoft mail on
-- CTRL, and one calendar group. ./webapp-group focuses a group and opens
-- whichever window is missing; it holds the lists and the reasons.
--
-- A file of its own because bindings.lua is Omarchy's to refresh: hyprland.lua
-- loads this one with a line added by hand (README, "Mail and calendar").
local webapp_group = os.getenv 'HOME' .. '/.config/hypr/webapp-group '

o.rebind('SUPER + SHIFT + E', 'Email', webapp_group .. 'mail-google')
o.bind('SUPER + SHIFT + CTRL + E', 'Email (Microsoft)', webapp_group .. 'mail-microsoft')
o.rebind('SUPER + SHIFT + ALT + E', 'New email', webapp_group .. 'mailto:')
o.rebind('SUPER + SHIFT + C', 'Calendar', webapp_group .. 'calendar')
