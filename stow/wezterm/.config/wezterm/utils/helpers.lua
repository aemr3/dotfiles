local wezterm = require("wezterm")

return {
	is_dark = function()
		local appearance = wezterm.gui.get_appearance()
		return appearance:find("Dark")
	end,
	get_random_entry = function(tbl)
		local keys = {}
		for k, _ in ipairs(tbl) do
			table.insert(keys, k)
		end
		math.randomseed(os.time())
		local random_key = keys[math.random(1, #keys)]
		return tbl[random_key]
	end,
	get_op_key = function(key)
		local handler = io.popen("/opt/homebrew/bin/op read '" .. key .. "'")
		if not handler then
			return nil
		end
		local value = handler:read("*a")
		handler:close()
		return value:gsub("%s+", "")
	end,
	http_get = function(url)
		local handler = io.popen("curl -s '" .. url .. "'")
		if not handler then
			return nil
		end
		local response = handler:read("*a")
		handler:close()
		return response
	end,
	get_hw_id = function()
		local handler = io.popen("sysctl hw.model | awk '{print $2}'")
		if not handler then
			return nil
		end
		local response = handler:read("*a")
		handler:close()
		return response:gsub("%s+", "")
	end,
}
