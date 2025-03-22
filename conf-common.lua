#!/usr/bin/env lua
require("luarocks.loader")

local Sh = require("minilib.shell")
local M = require("minilib.monad")
--local T = require("task")
local Home = os.getenv("HOME")

return {
	{
		path = "xresources",
		configure = function()
			Sh.util.ln("$(pwd)/Xresources", "~/.config/xresources.d")
			Sh.util.ln("$(pwd)/Xresources/Xresources", "~/.Xresources")
			Sh.util.sh([[
			sudo cp -vf $(pwd)/Xresources/40*.conf /etc/X11/xorg.conf.d/
		]])
		end,
		dependsOn = function()
			return Sh.file_exists({ "xrdb" })
		end,
		depends = {
			"xrdb",
		},
		installer = function() end,
	},
	{
		path = "misc",
		configure = function()
			local function setup_bell()
				Sh.util.sh([[
		pcnobell=$(grep -Po "^set bell-style none" /etc/inputrc)
		if [ "$pcnobell" = "" ]; then
			echo "disabling pc bell"
			echo "set bell-style none" | sudo tee /etc/inputrc
		else
			echo "not disabling pc bell"
		fi
	]])
			end

			local function setup_dirs()
				local dirs = {
					["~/.config"] = {},
					["~/.cache"] = {},
					["~/.theme"] = {},
					["~/.wlprs"] = {},
					["~/.local/bin"] = {},
				}
				for k, _ in pairs(dirs) do
					Sh.util.mkdir(k)
				end
			end

			local function setup_bins()
				if not Sh.util.path_exists("~/.profile") then
					Sh.util.cp("$(pwd)/misc/profile", "~/.profile")
				end
				Sh.util.append(
					[[
# conf-m/misc
export PATH=~/.local/bin:~/.luarocks/bin:~/.bucketsize/scripts:/usr/sbin:$PATH
		]],
					"~/.profile"
				)
			end

			setup_dirs()
			setup_bell()
			setup_bins()
		end,
		depends = {},
		installer = function() end,
	},
	{
		path = "fontconfig",
		configure = function()
			Sh.util.ln("$(pwd)/fontconfig", "~/.config/fontconfig")
		end,
		depends = { "fontconfig|1" },
		installer = function() end,
	},
	{
		path = "fonts",
		configure = function() end,
		depends = { "fontconfig|1", "curl|1" },
		installer = function()
			local d = Sh.util.test(Home .. "/.fonts")
			if d == nil or d == "file" then
				Sh.util.rm(Home .. "/.fonts")
				Sh.util.mkdir(Home .. "/.fonts")
			end

			Sh.util.sh([[mkdir -p /var/tmp/conf-m-cache/]])

			local fonts = {
				-- {
				-- 	url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Agave.zip",
				-- 	name = "agave",
				-- 	ext = "zip",
				-- 	cp = "agave\\ regular\\ Nerd\\ Font\\ Complete.ttf " .. "agave\\ regular\\ Nerd\\ Font\\ Complete\\ Mono.ttf ",
				-- },
				{
					url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/DejaVuSansMono.zip",
					name = "dejavusansmono",
					path = "/var/tmp/conf-m-cache",
					ext = "zip",
					cp = "DejaVu\\ Sans\\ Mono*Complete\\ Mono.ttf",
					dest = "~/.fonts/",
				},
				{
					url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/DroidSansMono.zip",
					name = "droidsansmono",
					path = "/var/tmp/conf-m-cache",
					ext = "zip",
					cp = "Droid\\ Sans\\ Mono\\ Nerd\\ Font\\ Complete.otf "
						.. "Droid\\ Sans\\ Mono\\ Nerd\\ Font\\ Complete\\ Mono.otf ",
					dest = "~/.fonts/",
				},
				-- {
				-- 	url = "https://github.com/sunaku/tamzen-font/archive/refs/tags/Tamzen-1.11.5.tar.gz",
				-- 	name = "tamzen",
				-- 	ext = "tar.gz",
				-- 	cp = "/tmp/tamzen-font-Tamzen-1.11.5/otb/Tamzen*.otb",
				-- },
			}

			-- FIXME
			-- M.List.of(fonts):fmap(T.geturl):fmap(T.extract)

			Sh.util.sh([[
			cd ~/.fonts
			rm fonts.dir fonts.scale
			mkfontdir
			mkfontscale
			xset +fp "$HOME/.fonts"
			xset fp rehash
			fc-cache -fv
			]])
		end,
	},
	{
		path = "gtkrc",
		configure = function()
			Sh.util.ln("$(pwd)/gtk/gtkrc-2.0", "~/.gtkrc-2.0")

			Sh.util.mkdir("~/.config/gtk-3.0")
			Sh.util.ln("$(pwd)/gtk/gtk.css", "~/.config/gtk-3.0/gtk.css")
			Sh.util.ln("$(pwd)/gtk/settings.ini", "~/.config/gtk-3.0/settings.ini")
		end,
		depends = {},
		installer = function() end,
	},
	{
		path = "qt5ct",
		configure = function()
			Sh.util.ln("$(pwd)/qt5ct", "~/.config/qt5ct")
		end,
		depends = { "qt5ct" },
		installer = function() end,
	},
}
