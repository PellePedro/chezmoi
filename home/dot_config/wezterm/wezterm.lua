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

-- Title
function basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local pane = tab.active_pane

	local index = ""
	if #tabs > 1 then
		index = string.format("%d: ", tab.tab_index + 1)
	end

	local process = basename(pane.foreground_process_name)

	return { {
		Text = " " .. index .. process .. " ",
	} }
end)

-- Startup
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

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

config.native_macos_fullscreen_mode = true

-- config.font = wezterm.font 'JetBrainsMono Nerd Font'
-- config.font = wezterm.font("MonoLisa")
config.font_size = 20.0
config.color_scheme = color_scheme_for_appearance(wezterm.gui.get_appearance())
config.line_height = 1.2
-- config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

config.native_macos_fullscreen_mode = true

config.window_background_opacity = 0.9
config.text_background_opacity = 0.7

-- Tab bar
config.enable_tab_bar = true
config.show_tab_index_in_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 25

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
		key = "w",
		mods = "CMD",
		action = wezterm.action.CloseCurrentPane({ confirm = false }),
	},
	{
		key = "d",
		mods = "CMD",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "d",
		mods = "CMD|SHIFT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "t",
		mods = "CTRL",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
}

-- Return config to WezTerm
return config
