#!/usr/bin/env lua
require("luarocks.loader")

local Sh = require("minilib.shell")
local Pr = require("minilib.process")

return {
	{
		path = "chromium",
		depends = { "chromium" },
		configure = function()
			-- note; only works on arch linux
			Sh.util.ln("$(pwd)/chromium/chromium-flags.conf", "~/.config/chromium-flags.conf")

			-- other distros; custom entrypoint
			Sh.util.mkdir("~/.local/share/applications")
			Sh.util.ln("$(pwd)/chromium/chromium-accel.desktop", "~/.local/share/applications/chromium-accel.desktop")
		end,
	},
	{
		path = "firefox",
		configure = function()
			Pr.pipe()
				.add(Sh.exec('find -L ~/.mozilla/ ~/snap -name "xulstore.json" | grep -v backup'))
				.add(Sh.echo())
				.add(function(x)
					if x then
						local _, p = Sh.util.split_path(x)
						Sh.util.cp("$(pwd)/firefox/user.js", p)
					end
				end)
				.run()
		end,
		depends = { "firefox|0|pkg,flatpak" },
		installer = function() end,
	},
	{
		path = "ictl",
		configure = function()
			Sh.util.sh([[
			[ -d ~/.config/ictl ] || mkdir -v -p ~/.config/ictl
			[ -f ~/.config/ictl/config.json ] || cp -v $(pwd)/ictl/config.json ~/.config/ictl/
		]])
		end,
		depends = {
			"xterm|1",
			"xrandr|1",
			"fzf|1",
			"wmctrl|1",
			"pactl|1",
			"feh|1",
			"curl|1",
		},
		installer = function()
			Sh.util.ln("$(pwd)/ictl/wallpaper-1.jpg", "~/Pictures/wallpaper-1.jpg")
		end,
	},
	{
		path = "m360",
		configure = function()
			Sh.util.sh([[
			[ -d ~/.config/m360 ] || mkdir -v -p ~/.config/m360
			[ -f ~/.config/m360/config.json ] || cp -v $(pwd)/m360/config.json ~/.config/m360/
		]])
		end,
		depends = { "python3", "pactl|1", "curl|1" },
		installer = function() end,
	},
	{
		path = "mangohud",
		configure = function()
			Sh.util.ln("$(pwd)/mangohud", "~/.config/MangoHud")
		end,
		depends = {
			"mangohud",
		},
		installer = function() end,
	},
	{
		path = "nvim",
		configure = function()
			Sh.util.mkdir("~/.config/nvim")
			Sh.util.ln("$(pwd)/nvim", "~/.config/nvim")
			if
				Sh.util.path_exists("~/.var/app/io.neovim.nvim/config/user-dirs.dirs")
				and not Sh.util.path_exists("~/.var/app/io.neovim.nvim/config/nvim/init.lua")
			then
				Sh.util.ln("~/.config/nvim", "~/.var/app/io.neovim.nvim/config/nvim")
			end
		end,
		depends = { "neovim", "ripgrep" },
		installer = function() end,
	},
	{
		path = "vim",
		configure = function()
			Sh.util.ln("$(pwd)/vim/vimrc", "~/.vimrc")
		end,
		depends = { "vim" },
		installer = function() end,
	},
	{
		path = "mpd",
		configure = function()
			Sh.util.mkdir("~/.mpd")
			Sh.util.ln("$(pwd)/mpd", "~/.config/mpd")

			-- going to disable automatic root start of mpd
			Sh.util.sh("sudo systemctl disable mpd")
		end,
		depends = { "mpd", "mpc" },
		installer = function() end,
	},
	{
		path = "ympd",
		configure = function() end,
		depends = {
			"mpd",
		},
		installer = function()
			if not Sh.util.file_exists("~/.local/bin/ympd") then
				local cmd = string.format(
					[[
				if [ -d ~/ympd ]; then
				cd ~/ympd
				git pull
				else
				git clone https://github.com/notandy/ympd.git
				cd ~/ympd
				fi
				export LIBDIR=/usr/lib/$%s-linux-gnu
				make ympd
				strip ympd
				cp -vf ympd ~/.local/bin/
				]],
					Sh.util.arch()
				)
				Sh.util.sh(cmd)
			end
		end,
	},
	{
		path = "mpv",
		configure = function()
			Sh.util.ln("$(pwd)/mpv", "~/.config/mpv")
		end,
		depends = { "mpv" },
		installer = function() end,
	},
}
