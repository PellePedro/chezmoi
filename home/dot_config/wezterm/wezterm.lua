-- Helper function:
-- returns color scheme dependant on operating system theme setting (dark/light)
local function color_scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Tokyo Night"
	else
		return "Tokyo Night Light (Gogh)"
	end
end

-- Pull in WezTerm API
local wezterm = require("wezterm")

-- Initialize actual config
local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Appearance
config.font = wezterm.font_with_fallback({
	{ family = "JetBrainsMono Nerd Font Mono", weight = "DemiBold" },
	{ family = "MonoLisa", weight = "DemiBold" },
})

-- config.font = wezterm.font 'JetBrainsMono Nerd Font'
-- config.font = wezterm.font("MonoLisa")
config.font_size = 20.0
config.color_scheme = color_scheme_for_appearance(wezterm.gui.get_appearance())
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.native_macos_fullscreen_mode = false

config.window_background_opacity = 0.9
config.text_background_opacity = 0.7

-- Keybindings
config.keys = {
	-- Default QuickSelect keybind (CTRL-SHIFT-Space) gets captured by something
	-- else on my system
	{
		key = "A",
		mods = "CTRL|SHIFT",
		action = wezterm.action.QuickSelect,
	},
	{
		key = "|",
		mods = "LEADER|SHIFT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "-",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
}

-- Return config to WezTerm
return config
