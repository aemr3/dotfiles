local wezterm = require("wezterm")
local act = wezterm.action
local b = require("config/background")
local w = require("config/wallpaper")
local h = require("utils/helpers")
local k = require("utils/keys")
local mini = h.get_hw_id():find("^Macmini") ~= nil

return {
	harfbuzz_features = { "zero", "ss01", "cv05" },
	set_environment_variables = {
		PATH = "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:" .. os.getenv("PATH"),
	},
	background = {
		w.get_wallpaper(),
		b.get_background(),
	},
	enable_tab_bar = false,
	initial_cols = 160,
	initial_rows = 48,
	font_size = 12.0,
	font = wezterm.font_with_fallback({
		{ family = "FiraCode Nerd Font", weight = mini and "Bold" or "Medium" },
		{ family = "JetBrainsMono Nerd Font", weight = mini and "Bold" or "DemiBold" },
	}),
	native_macos_fullscreen_mode = true,
	window_decorations = "RESIZE",
	audible_bell = "Disabled",
	visual_bell = {
		fade_in_function = "EaseIn",
		fade_in_duration_ms = 150,
		fade_out_function = "EaseOut",
		fade_out_duration_ms = 150,
	},
	colors = {
		visual_bell = "#202020",
	},
	window_padding = mini and {
		top = 10,
		bottom = 10,
	} or {
		top = 0,
		bottom = 0,
	},
	mouse_bindings = {
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "CTRL",
			action = act.OpenLinkAtMouseCursor,
		},
	},
	keys = {
		k.cmd_to_tmux_prefix("h", "h"),
		k.cmd_to_tmux_prefix("j", "j"),
		k.cmd_to_tmux_prefix("k", "k"),
		k.cmd_to_tmux_prefix("l", "l"),
		k.cmd_to_tmux_prefix("1", "1"),
		k.cmd_to_tmux_prefix("2", "2"),
		k.cmd_to_tmux_prefix("3", "3"),
		k.cmd_to_tmux_prefix("4", "4"),
		k.cmd_to_tmux_prefix("5", "5"),
		k.cmd_to_tmux_prefix("6", "6"),
		k.cmd_to_tmux_prefix("7", "7"),
		k.cmd_to_tmux_prefix("8", "8"),
		k.cmd_to_tmux_prefix("9", "9"),
		k.cmd_to_tmux_prefix("t", "c"),
		k.cmd_to_tmux_prefix("w", "x"),
		k.cmd_to_tmux_prefix("d", "-"),
		k.cmd_to_tmux_prefix("D", "|"),
		k.cmd_to_tmux_prefix("o", "u"),
		k.cmd_to_tmux_prefix("m", "m"),
		k.cmd_key(
			"T",
			act.Multiple({ act.SendKey({ key = " " }), act.SendKey({ key = "d" }), act.SendKey({ key = "x" }) })
		),
		k.cmd_key("s", act.SendKey({ mods = "CTRL", key = "s" })),
		k.cmd_key("b", act.SendKey({ mods = "ALT", key = "b" })),
		k.cmd_key("a", act.SendKey({ mods = "ALT", key = "a" })),
		k.cmd_key(
			"x",
			act.Multiple({ act.SendKey({ key = " " }), act.SendKey({ key = "b" }), act.SendKey({ key = "d" }) })
		),
		k.cmd_key("UpArrow", act.SendKey({ mods = "CTRL", key = "j" })),
		k.cmd_key("DownArrow", act.SendKey({ mods = "CTRL", key = "k" })),
		k.cmd_key("LeftArrow", act.SendKey({ mods = "CTRL", key = "h" })),
		k.cmd_key("RightArrow", act.SendKey({ mods = "CTRL", key = "l" })),
		k.cmd_key(
			"R",
			wezterm.action_callback(function()
				w.get_wallpaper()
				wezterm.reload_configuration()
			end)
		),
		k.ctrl_key(
			"F",
			act.Multiple({
				act.ToggleFullScreen,
				wezterm.action_callback(function()
					wezterm.reload_configuration()
				end),
			})
		),
		k.cmd_key("p", act.Multiple({ act.SendKey({ key = " " }), act.SendKey({ key = "p" }) })),
		k.key_table("SHIFT", "Enter", act.SendKey({ key = "\x0a" })),
	},
}
