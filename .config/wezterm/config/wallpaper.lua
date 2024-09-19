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
	save_new_random_image = function()
		local access_key = h.get_op_key("op://Personal/unsplash.com/access_key")
		wezterm.log_error(access_key)
		local response = h.http_get(
			"https://api.unsplash.com/photos/random?orientation=landscape&query=urban&client_id=" .. access_key
		)
		if not response then
			return nil
		end
		local data = wezterm.json_parse(response)
		if not data then
			return nil
		end
		if not data.slug then
			wezterm.log_error("No slug found in response: " .. response)
			return nil
		end
		local image = data.urls.full
		local name = data.slug
		local path = os.getenv("HOME") .. "/Library/Mobile Documents/com~apple~CloudDocs/Wallpapers/" .. name .. ".jpg"
		os.execute("curl -s -o '" .. path .. "' '" .. image .. "'")
		wezterm.GLOBAL.wallpaper = get_wallpaper_options(path)
	end,
	get_wallpaper = function(reset)
		if reset then
			wezterm.GLOBAL.wallpaper = nil
		end
		if wezterm.GLOBAL.wallpaper then
			return wezterm.GLOBAL.wallpaper
		end
		local wallpapers = {}
		local wallpapers_glob = os.getenv("HOME") .. "/Library/Mobile Documents/com~apple~CloudDocs/Wallpapers/**"
		for _, v in ipairs(wezterm.glob(wallpapers_glob)) do
			if not string.match(v, "%.DS_Store$") then
				table.insert(wallpapers, v)
			end
		end
		local random = h.get_random_entry(wallpapers)
		wezterm.GLOBAL.wallpaper = get_wallpaper_options(random)
		return wezterm.GLOBAL.wallpaper
	end,
	delete_current_wallpaper = function()
		local current = wezterm.GLOBAL.wallpaper.source.File.path
		os.execute("rm '" .. current .. "'")
		wezterm.GLOBAL.wallpaper = nil
		return nil
	end,
}
