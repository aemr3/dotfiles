local wezterm = require("wezterm")
local h = require("utils/helpers")

local get_wallpaper_options = function(path)
	return {
		source = { File = { path = path } },
		height = "Cover",
		width = "Cover",
		horizontal_align = "Left",
		repeat_x = "Repeat",
		repeat_y = "Repeat",
		opacity = 1,
	}
end

return {
	get_wallpaper = function()
		local wallpapers = {}
		local wallpapers_glob = wezterm.config_dir .. "/wallpapers/**"
		for _, v in ipairs(wezterm.glob(wallpapers_glob)) do
			if not string.match(v, "%.DS_Store$") then
				table.insert(wallpapers, v)
			end
		end
		local random = h.get_random_entry(wallpapers)
		wezterm.GLOBAL.wallpaper = get_wallpaper_options(random)
		return wezterm.GLOBAL.wallpaper
	end,
}
