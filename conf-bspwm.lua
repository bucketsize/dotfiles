#!/usr/bin/env lua
require("luarocks.loader")

local Sh = require("minilib.shell")

return {
	{
		path = "bspwm",
		depends = {
			"bspwm",
			"sxhkd",
			"feh",
			"lxpolkit",
			"tint2",
			"picom",
			"dunst",
			"lemonbar",
			["ictl"] = { method = "github", resource = "bucketsize/ictl" },
			["m360"] = { method = "github", resource = "bucketsize/m360" },
		},
		configure = function()
			Sh.util.ln("$(pwd)/bspwm", "~/.config/bspwm")
		end,
		install = function() end,
	},
	{
		path = "sxhkd",
		configure = function()
			Sh.util.ln("$(pwd)/sxhkd", "~/.config/sxhkd")
		end,
		depends = { "sxhkd" },
		installer = function() end,
	},
	{
		path = "picom",
		configure = function()
			Sh.util.ln("$(pwd)/picom", "~/.config/picom")
		end,
		depends = { "picom" },
		installer = function() end,
	},
	{
		path = "tint2",
		configure = function()
			Sh.util.ln("$(pwd)/tint2", "~/.config/tint2")
		end,
		depends = { "tint2" },
		installer = function() end,
	},
}
