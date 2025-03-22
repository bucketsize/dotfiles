#!/usr/bin/env lua
require("luarocks.loader")

local Sh = require("minilib.shell")
local Ut = require("minilib.util")
local M = require("minilib.monad")
local T = require("task")
local Home = os.getenv("HOME")

return {
	{
		path = "alacritty",
		depends = {
			"alacritty",
		},
		configure = function()
			Sh.ln("$(pwd)/alacritty", "~/.config/alacritty")
		end,
		installer = function()
			local function build_pack()
				Sh.sh([[
		#sudo apt-get install cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
		#curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

		source "$HOME/.cargo/env"

		build_root=~/ws/alacritty
				if [ -d $build_root ]; then
						cd $build_root
						git pull
				else
						git clone https://github.com/bucketsize/alacritty.git $build_root
						cd $build_root
				fi
				if [ -f target/release/alacritty ]; then
						echo "existing build ..."
				else
						cargo build --release --no-default-features --features=x11
				fi
				tar -czf /tmp/alacritty.$(arch).tar.gz \
						target/release/alacritty \
						extra/logo/alacritty-term.svg \
						extra/linux/Alacritty.desktop
		]])
			end

			local function setup_prebuilt()
				local rel = {
					aarch64 = "https://github.com/bucketsize/alacritty/releases/download/20220211/alacritty.aarch64.tar.gz",
					x86_64 = "https://github.com/bucketsize/alacritty/releases/download/20220723/alacritty.x86_64.tar.gz",
				}
				local arch = Sh.arch()
				if not Sh.file_exists("alacritty") then
					Sh.wget(rel[arch], "/tmp/alacritty.tgz")
					Sh.sh([[
			tar -xvzf /tmp/alacritty.tgz -C /tmp
			mv /tmp/target/release/alacritty ~/.local/bin/
			]])
				end
			end

			if not Sh.file_exists("alacritty") then
				-- build_pack()
				setup_prebuilt()
				Sh.sh([[
			cp $(pwd)/alacritty/bin/* ${HOME}/.local/bin/
			]])
			end
		end,
	},
	{
		path = "ananicy",
		configure = function()
			if not Sh.path_exists("~/ws/ananicy-rules/") then
				Sh.mkdir("~/ws")
				Sh.sh([[
				cd ~/ws
				git clone https://github.com/CachyOS/ananicy-rules.git
			]])
			end
			if not Sh.path_exists("/etc/ananicy-d/") then
				Sh.sh([[
				sudo mkdir /etc/ananicy.d
			]])
			end
			Sh.sh([[
			cd ~/ws
			sudo cp -a ananicy-rules/* /etc/ananicy.d/ 
		]])
		end,
		depends = {
			"git",
			"cmake",
			"g++",
			"build-essential",
			"libsystemd-dev",
		},
		installer = function()
			Sh.sh([[
			mkdir ~/ws
			cd ~/ws
			git clone https://gitlab.com/ananicy-cpp/ananicy-cpp.git
			cd ananicy-cpp
			cmake -B build \
			-DCMAKE_RELEASE_TYPE=Release \
			-S .
			cmake --build build --target ananicy-cpp
			sudo cmake --install build --component Runtime
			sudo systemctl enable --now ananicy-cpp 
		]])
		end,
	},
	{
		path = "autostart",
		depends = { "lua", "luarocks" },
		configure = function()
			-- Sh.ln("$(pwd)/autostart/autostartd", "~/.local/bin/autostartd")
			-- Sh.mkdir("~/.config/systemd/user")
			-- Sh.sh([[
			-- 	ln -sfv $(pwd)/autostart/autostart.service ~/.config/systemd/user/autostart.service
			--     systemctl --user daemon-reload
			--     systemctl --user enable autostart.service
			--     ]])

			Sh.ln("$(pwd)/autostart", "~/.config/autostart")
			-- Sh.sh("chmod -v +x $(pwd)/autostart/autostart")
		end,
	},
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
			Sh.ln("$(pwd)/bspwm", "~/.config/bspwm")
		end,
		install = function() end,
	},
	{
		path = "chromium",
		depends = { "chromium" },
		configure = function()
			-- note; only works on arch linux
			Sh.ln("$(pwd)/chromium/chromium-flags.conf", "~/.config/chromium-flags.conf")

			-- other distros; custom entrypoint
			Sh.mkdir("~/.local/share/applications")
			Sh.ln("$(pwd)/chromium/chromium-accel.desktop", "~/.local/share/applications/chromium-accel.desktop")
		end,
	},
	{
		path = "compton",
		dependsOn = { "compton" },
		configure = function()
			Sh.ln("~/scripts/config/compton", "~/.config/compton")
		end,
	},
	{
		path = "conky",
		configure = function()
			Sh.ln("$(pwd)/conky/line", "~/.config/conky")
			Sh.sh("chmod +x $(pwd)/conky/line/conky-lemonbar.sh")
		end,
		depends = { "conky" },
	},
	{
		path = "dunst",
		configure = function()
			Sh.ln("$(pwd)/dunst", "~/.config/dunst")
		end,
		depends = { "dunst" },
		installer = function() end,
	},
	{
		path = "",
		configure = function()
			Pr.pipe()
				.add(Sh.exec('find -L ~/.mozilla/ ~/snap -name "xulstore.json" | grep -v backup'))
				.add(Sh.echo())
				.add(function(x)
					if x then
						local _, p = Sh.split_path(x)
						Sh.cp("$(pwd)/firefox/user.js", p)
					end
				end)
				.run()
		end,
		depends = { "firefox" },
		installer = function() end,
	},
	{
		path = "fontconfig",
		configure = function()
			Sh.ln("$(pwd)/fontconfig", "~/.config/fontconfig")
		end,
		depends = { "fc-list" },
		installer = function() end,
	},
	{
		path = "fonts",
		configure = function() end,
		depends = { "fc-cache", "curl" },
		installer = function()
			local d = Sh.test(Home .. "/.fonts")
			if d == nil or d == "file" then
				Sh.rm(Home .. "/.fonts")
				Sh.mkdir(Home .. "/.fonts")
			end

			Sh.sh([[mkdir -p /var/tmp/conf-m-cache/]])

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
			M.List.of(fonts):fmap(T.geturl):fmap(T.extract)

			Sh.sh([[
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
		path = "foot",
		configure = function()
			Sh.ln("$(pwd)/foot", "~/.config/foot")
		end,
		depends = { "foot" },
		installer = function() end,
	},
	{
		path = "mxctl",
		configure = function()
			Sh.sh([[
			[ -d ~/.config/mxctl ] \
				|| mkdir -v -p ~/.config/mxctl
			[ -f ~/.config/mxctl/config ] \
				|| cp -v $(pwd)/mxctl/config ~/.config/mxctl/
		]])
		end,
		depends = { "git", "make", "xrandr", "fzf", "wmctrl", "pactl", "feh", "wget" },
		installer = function()
			Sh.github_fetch("bucketsize", "frmad")
			Sh.sh(string.format(
				[[
			export CRYPTO_INCDIR=/usr/include	
			LIBDIR=/usr/lib/%s-linux-gnu
			CRYPTO_LIBDIR=$LIBDIR
			OPENSSL_LIBDIR=$LIBDIR 
			cd ~/frmad && luarocks make --local
		]],
				Sh.arch()
			))
		end,
	},
	{
		path = "opam",
		configure = function() end,
		depends = { "ocaml", "opam", "wget", "tar", "git" },
		installer = function()
			local init_opam = [[ 
	 init_opam() {
		opam env
		if [ ! $? = 0 ]; then
				opam init
				eval $(opam env)
		fi
		if [ "$(which dune)" = "" ]; then
				opam install dune ounit2 ctypes ctypes-foreign stdio --yes
				eval $(opam env)
		fi
		eval $(opam env)
	 }
	 ]]

			function setup_sourcebuild()
				local cmd = init_opam
					.. [[
				cd ~/
				init_opam
				if [ ! -d ~/fseer ]; then
						git clone https://github.com/bucketsize/fseer.git
				fi
				cd ~/fseer
				git checkout master
				git pull
				./build
				./build pack fseer
				./build install fseer
		]]
				Sh.sh(cmd, "fseer sourcebuild")
			end

			function setup_prebuilt()
				local cmd = [[
				pkg=fseer.$(_arch).tar.gz
				cd /tmp
				wget https://github.com/bucketsize/fseer/releases/download/20220210/fseer.$(_arch).tar.gz 
				tar -xvzf $pkg -C ~/.local/bin
		]]
				Sh.sh(cmd, "fseer prebuilt")
			end

			setup_sourcebuild()
		end,
	},
	{
		path = "greetd",
		configure = function()
			Sh.sh([[
		mkdir /etc/greetd
		sudo cp -vf greetd/* /etc/greetd/
		sudo useradd -M -G video greeter
		sudo chmod -R go+r /etc/greetd/

		# when ready, execute
		sudo systemctk disable display-manager
		sudo systemctl enable greetd
		]])
		end,
		depends = { "greetd" },
		installer = function() end,
	},
	{
		path = "gtkrc",
		configure = function()
			Sh.ln("$(pwd)/gtk/gtkrc-2.0", "~/.gtkrc-2.0")

			Sh.mkdir("~/.config/gtk-3.0")
			Sh.ln("$(pwd)/gtk/gtk.css", "~/.config/gtk-3.0/gtk.css")
			Sh.ln("$(pwd)/gtk/settings.ini", "~/.config/gtk-3.0/settings.ini")
		end,
		depends = {},
		installer = function() end,
	},
	{
		path = "hypr",
		configure = function()
			Sh.ln("$(pwd)/hypr", "~/.config/hypr")
		end,
		depends = { "Hyprland", "hyprctl" },
		installer = function()
			Sh.sh([[
			cp $(pwd)/hypr/bin/* ${HOME}/.local/bin/
			]])
		end,
	},
	{
		path = "ictl",
		configure = function()
			Sh.sh([[
			[ -d ~/.config/ictl ] || mkdir -v -p ~/.config/ictl
			[ -f ~/.config/ictl/config.json ] || cp -v $(pwd)/ictl/config.json ~/.config/ictl/
		]])
		end,
		depends = {
			"xterm",
			"xrandr",
			"fzf",
			"wmctrl",
			"pactl",
			"feh",
			"curl",
		},
		installer = function()
			Sh.ln("$(pwd)/ictl/wallpaper-1.jpg", "~/Pictures/wallpaper-1.jpg")
		end,
	},
	{
		path = "lemonbar",
		configure = function() end,
		depends = { "lemonbar" },
		installer = function()
			function setup_xft_sourcebuild()
				local Sh = require("minilib.shell")
				local Ut = require("minilib.util")
				Ut:assert_pkg_exists("xcb")
				Ut:assert_pkg_exists("xcb-randr")
				Ut:assert_pkg_exists("xft")
				Ut:assert_pkg_exists("x11-xcb")
				Ut:assert_pkg_exists("xcb-xinerama")
				local cmd = string.format(
					[[
				if [ -d ~/lemonbar-xft ]; then
						cd ~/lemonbar-xft
						git pull
				else
						cd ~/
						git clone https://gitlab.com/protesilaos/lemonbar-xft.git
						cd ~/lemonbar-xft
				fi
				make
				tar -czf lemonbar.%s.tar.gz lemonbar
				cp -fv lemonbar ~/.local/bin/
				]],
					Sh.arch()
				)
				Sh.sh(cmd, "failed")
			end

			function setup_xft_prebuilt()
				local cmd = [[
				pkg=lemonbar.$(arch).tar.gz
				cd /tmp
				wget https://www.dropbox.com/s/hxuj4yz0x0vvrfj/$pkg 
				tar -xvzf $pkg -C ~/.local/bin
				]]
				Sh.sh(cmd, "failed")
			end
		end,
	},
	{
		path = "login.d",

		-- deprecated, use greetd / agreety
		-- local function setup_autologin()
		-- 	Sh.sh([[
		--     sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
		--     sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf <<EOF
		-- [Service]
		-- ExecStart=
		-- ExecStart=-/sbin/agetty --noissue --autologin jb %I $TERM
		-- Type=idle
		-- EOF
		-- 		]])
		-- end

		configure = function()
			Sh.sh([[
		[ -d /etc/systemd/logind.conf.d ] || sudo mkdir /etc/systemd/logind.conf.d	
		sudo cp -vf logind.d/*.conf /etc/systemd/logind.conf.d/
		]])
		end,
		depends = {
			"udevadm",
		},
		installer = function() end,
	},
	{
		path = "lspd",
		configure = function()
			Sh.mkdir("~/.local/bin")

			Sh.ln("$(pwd)/lspd/lspd-ocaml", "~/.local/bin/lspd-ocaml")
			Sh.ln("$(pwd)/lspd/lspd-java", "~/.local/bin/lspd-java")
		end,
		depends = {},
		installer = function() end,
	},
	{
		path = "lxpanel",
		configure = function()
			Sh.ln("$(pwd)/lxpanel", "$HOME/.config/lxpanel")
		end,
		depends = { "lxpanel" },
		installer = function() end,
	},
	{
		path = "m360",
		configure = function()
			Sh.sh([[
			[ -d ~/.config/m360 ] || mkdir -v -p ~/.config/m360
			[ -f ~/.config/m360/config.json ] || cp -v $(pwd)/m360/config.json ~/.config/m360/
		]])
		end,
		depends = { "python3", "pactl", "curl" },
		installer = function() end,
	},
	{
		path = "mako",
		configure = function()
			Sh.ln("$(pwd)/mako", "~/.config/mako")
		end,
		depends = { "mako" },
		installer = function() end,
	},
	{
		path = "mangohud",
		configure = function()
			Sh.ln("$(pwd)/mangohud", "~/.config/MangoHud")
		end,
		depends = {
			"mangohud",
		},
		installer = function() end,
	},
	{
		path = "mediatomb",
		configure = function() end,
		depends = {
			"mediatomb",
		},
		installer = function() end,
	},
	{
		path = "minilib",
		configure = function() end,
		depends = { "lua", "luarocks" },
		installer = function()
			local arch = Sh.arch()

			Sh.exec([[
			if [ -d ~/minilib ]; then
				cd ~/minilib && git pull
			else
				git clone https://github.com/bucketsize/minilib.git ~/minilib
			fi
		]])

			Sh.exec(string.format(
				[[
		LIBDIR=/usr/lib/%s-linux-gnu
		cd ~/minilib && luarocks make --local CRYPTO_LIBDIR=$LIBDIR OPENSSL_LIBDIR=$LIBDIR
		]],
				arch
			))
		end,
	},
	{
		path = "misc",
		configure = function()
			local function setup_bell()
				Sh.sh([[
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
					Sh.mkdir(k)
				end
			end

			local function setup_bins()
				if not Sh.path_exists("~/.profile") then
					Sh.cp("$(pwd)/misc/profile", "~/.profile")
				end
				Sh.append(
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
		path = "modprobe",
		configure = function() end,
		depends = { "modprobe" },
		installer = function()
			Sh.sh("sudo cp -v $(pwd)/modprobe.d/* /etc/modprobe.d/")
		end,
	},
	{
		path = "mpd",
		configure = function()
			Sh.mkdir("~/.mpd")
			Sh.ln("$(pwd)/mpd", "~/.config/mpd")

			-- going to disable automatic root start of mpd
			Sh.sh("sudo systemctl disable mpd")
		end,
		depends = { "mpd", "mpc" },
		installer = function() end,
	},
	{
		path = "mpv",
		configure = function()
			Sh.ln("$(pwd)/mpv", "~/.config/mpv")
		end,
		depends = { "mpv" },
		installer = function() end,
	},
	{
		path = "mxctl",
		configure = function()
			Sh.sh([[
			[ -d ~/.config/mxctl ] \
				|| mkdir -v -p ~/.config/mxctl
			[ -f ~/.config/mxctl/config ] \
				|| cp -v $(pwd)/mxctl/config ~/.config/mxctl/
		]])
		end,
		dependsOn = function()
			return Sh.file_exists({ "git", "make", "xrandr", "fzf", "wmctrl", "pactl", "feh" })
		end,
		installer = function()
			Sh.github_fetch("bucketsize", "mxctl")
			Sh.sh(string.format(
				[[
			export CRYPTO_INCDIR=/usr/include	
			LIBDIR=/usr/lib/%s-linux-gnu
			CRYPTO_LIBDIR=$LIBDIR
			OPENSSL_LIBDIR=$LIBDIR 
			cd ~/mxctl && luarocks make --local
		]],
				Sh.arch()
			))
		end,
	},
	{
		path = "network",
		configure = function()
			Sh.sh([[
		sudo cp $(pwd)/network/dhcpcd.conf /etc/dhcpcd.conf
		sudo cp $(pwd)/network/wpa_supplicant.conf /etc/wpa_supplicant/ 
		]])
		end,
		depends = {
			"dhcpcd",
			"wpa_supplicant",
		},
		installer = function() end,
	},
	{
		path = "nvim",
		configure = function()
			Sh.mkdir("~/.config/nvim")
			Sh.ln("$(pwd)/nvim", "~/.config/nvim")
			if
				Sh.path_exists("~/.var/app/io.neovim.nvim/config/user-dirs.dirs")
				and not Sh.path_exists("~/.var/app/io.neovim.nvim/config/nvim/init.lua")
			then
				Sh.ln("~/.config/nvim", "~/.var/app/io.neovim.nvim/config/nvim")
			end
		end,
		depends = { "nvim", "rg" },
		installer = function() end,
	},
	{
		path = "openbox",
		configure = function()
			Sh.ln("$(pwd)/openbox", "$HOME/.config/openbox")
		end,
		depends = {
			"openbox",
			"obconf",
			"feh",
			"lxpolkit",
			"tint2",
			"picom",
			"dunst",
			"ictl",
			"m360",
			"lemonbar",
		},
		installer = function()
			-- theme
			Sh.mkdir("~/.themes")

			-- TODO : use release tar.gz
			Sh.sh([[
			cd ~/.themes
			if [ ! -d nord-openbox-theme ]; then 
				git clone https://gitlab.com/the-zero885/nord-openbox-theme.git
			fi
			if [ ! -d arc-openbox ]; then 
				git clone https://github.com/dglava/arc-openbox.git
				cp -a arc-openbox/* ./
			fi
			]])
		end,
	},
	{
		path = "picom",
		configure = function()
			Sh.ln("$(pwd)/picom", "~/.config/picom")
		end,
		depends = { "picom" },
		installer = function() end,
	},
	{
		path = "pulseaudio",
		configure = function()
			Sh.sh([[
		systemctl --user daemon-reload
		systemctl --user --now enable pipewire pipewire-pulse
		systemctl --user --now disable pulseaudio.service pulseaudio.socket
		systemctl --user mask pulseaudio
		]])
		end,
		depends = {
			"pipewire",
			"pipewire-pulse",
			"wireplumber",
		},
		installer = function()
			-- deprecated
			--    Sh.sh [[
			-- sessf=$HOME/.config/pipewire-media-session/with-pulseaudio
			-- servd=$HOME/.config/systemd/user
			--
			-- if [ ! -f $sessf ] ; then
			-- 	echo "installing pulse session [with-pulseaudio] ..."
			-- 	if [ ! -d "$HOME/.config/pipewire-media-session" ]; then
			-- 		mkdir -p $HOME/.config/pipewire-media-session
			-- 	fi
			-- 	touch $sessf
			-- fi
			--
			-- if [ "$(ls $servd/pipewire-pulse.*)" = "" ]; then
			-- 	echo "installing pulse service ..."
			-- 	cp -v /usr/share/doc/pipewire/examples/systemd/user/pipewire-pulse.* $servd/
			-- fi
			-- ]]
			Sh.sh([[
			[ -d ~/.config/pipewire ] \
				|| mkdir ~/.config/pipewire
			[ -d ~/.config/pipewire/media-session.d ] \
				|| cp -rv /usr/share/pipewire/media-session.d/ ~/.config/pipewire/
		]])
		end,
	},
	{
		path = "qt5ct",
		configure = function()
			Sh.ln("$(pwd)/qt5ct", "~/.config/qt5ct")
		end,
		depends = { "qt5ct" },
		installer = function() end,
	},
	{
		path = "qterminal",
		configure = function()
			Sh.ln("$(pwd)/qterminal.org", "~/.config/qterminal.org")
			Sh.ln("$(pwd)/qterminal.org/Popeye.conf", "~/.config/Popeye.conf")
		end,
		installer = function() end,
	},
	{
		path = "qtile",
		configure = function()
			Sh.ln("$(pwd)/qtile", "~/.config/qtile")
		end,
		installer = function() end,
	},
	{
		path = "qutebrowser",
		configure = function()
			Sh.ln("$(pwd)/qutebrowser", "~/.config/qutebrowser")
		end,
		installer = function() end,
	},
	{
		path = "rules.d",
		configure = function()
			Sh.sh([[
		[ -d /etc/udev/rules.d ] || sudo mkdir /etc/udev/rules.d	
		sudo cp -vf rules.d/* /etc/udev/rules.d/
		]])
		end,
		depends = { "udevadm" },
		installer = function() end,
	},
	{
		path = "stterm",
		configure = function()
			if not Sh.path_exists("~/.local/bin/stterm") then
				Sh.sh([[chmod +x $(pwd)/st/bin/stterm]])
			end
		end,
		installer = function()
			Sh.sh([[
			cp $(pwd)/st/bin/* ${HOME}/.local/bin/
			]])
		end,
	},
	{
		path = "swhkd",
		configure = function()
			Sh.ln("$(pwd)/swhkd", "~/.config/swhkd")
		end,
		depends = { "swhkd" },
		installer = function() end,
	},
	{
		path = "sxhkd",
		configure = function()
			Sh.ln("$(pwd)/sxhkd", "~/.config/sxhkd")
		end,
		depends = { "sxhkd" },
		installer = function() end,
	},
	{
		path = "sysctl.d",
		configure = function()
			Sh.sh([[
			sudo cp -vf sysctl.d/*.conf /etc/sysctl.d/
			sudo sysctl -p
		]])
		end,
		depends = {
			"sysctl",
		},
		installer = function() end,
	},
	{
		path = "thermald",
		configure = function()
			Sh.sh([[
			sudo cp -vf thermald/* /etc/thermald/
		]])
			print([[
			# NOTE
			On some systems, thermald.service starts with --adaptive flag.
			This does not honor xml configs and may not work properly. 

			Edit
				/lib/systemd/system/thermald.service
			Then
				systemctl daemon-reload
				systemctl restart thermald 
		]])
		end,
		depends = { "thermald" },
		installer = function() end,
	},
	{
		path = "triggerhappy",
		configure = function()
			Sh.ln("$(pwd)/triggerhappy", "~/.config/triggerhappy")

			if
				Sh.path_exists("/usr/sbin/thd") -- debian non std path for exe
				and (not Sh.path_exists("/usr/bin/thd"))
				and (not Sh.path_exists(Sh.HOME .. "/.local/bin/thd"))
			then
				Sh.ln("/usr/sbin/thd", Sh.HOME .. "/.local/bin/thd")
			end

			if not Ut:haz(Sh.groups(), "input") then
				print("add user to input group ...")
				Sh.sh([[
				sudo usermod $USER -a -G input
			]])
				print("relogin for it to work!")
			end
		end,
		depends = { "thd" },
		installer = function() end,
	},
	{
		path = "datetimectl",
		configure = function()
			Sh.exec([[
			sudo timedatectl set-timezone Asia/Kolkata
		]])
		end,
		depends = { "timedatectl" },
		installer = function() end,
	},
	{
		path = "vim",
		configure = function()
			Sh.ln("$(pwd)/vim/vimrc", "~/.vimrc")
		end,
		depends = { "vim" },
		installer = function() end,
	},
	{
		path = "waybar",
		depends = {
			"waybar",
		},
		configure = function()
			Sh.ln("$(pwd)/waybar", "~/.config/waybar")
		end,
		installer = function()
			Sh.sh([[
			cp $(pwd)/waybar/bin/* ${HOME}/.local/bin/
			]])
		end,
	},
	{
		path = "weston",
		configure = function()
			Sh.ln("$(pwd)/weston/weston.ini", "~/.config/weston.ini")
		end,
		depends = { "weston", "foot" },
		installer = function()
			Sh.sh([[
			cp $(pwd)/weston/bin/* ${HOME}/.local/bin/
			]])
		end,
	},
	{
		path = "xinit",
		configure = function() end,
		depends = {},
		installer = function()
			Sh.sh([[
			sudo mkdir -p /usr/share/xsessions
			sudo cp $(pwd)/xinit/*.desktop /usr/share/xsessions
		]])
		end,
	},
	{
		path = "xmobar",
		configure = function() end,
		depends = { "xmobar" },
		installer = function()
			Sh.ln("$(pwd)/xmobar", "~/.config/xmobar")
		end,
	},
	{
		path = "xmonad",
		configure = function() end,
		depends = {},
		installer = function()
			local packs = {
				{
					name = "xmonad",
					ver = "0.17.0",
					url = "https://github.com/xmonad/xmonad/archive/refs/tags/v0.17.0.tar.gz",
				},
				{
					name = "xmonad-contrib",
					ver = "0.17.0",
					url = "https://github.com/xmonad/xmonad-contrib/archive/refs/tags/v0.17.0.tar.gz ",
				},
				{
					name = "xmobar",
					ver = "0.42",
					url = "https://github.com/jaor/xmobar/archive/refs/tags/0.42.tar.gz",
				},
			}

			local function setup_xmonad()
				local build_dir = os.getenv("HOME") .. "/xmonad-1"
				Sh.mkdir(build_dir)
				Sh.cp("$(pwd)/xmonad/xmonad-stack/*", build_dir)
				for _, p in ipairs(packs) do
					if not Sh.path_exists(build_dir .. "/" .. p.name) then
						local tar = "/tmp/" .. p.name .. ".tar.gz"
						print("getting", p.name, p.ver, tar)
						Sh.wget(p.url, tar)
						Sh.sh(string.format("tar -xvzf %s -C %s", tar, build_dir))
						Sh.mv(
							string.format("%s/%s-%s", build_dir, p.name, p.ver),
							string.format("%s/%s", build_dir, p.name)
						)
					end
				end
				Sh.sh(string.format("cd %s && stack install", build_dir))
			end

			local function setup_xmonad_config()
				Sh.ln(build_dir, "~/.xmonad")
				Sh.ln("$(pwd)/xmonad/xmonad.hs", "~/.xmonad/xmonad.hs")
				Sh.sh("xmonad --recompile")
			end

			setup_xmonad_config()
		end,
	},
	{
		path = "xresources",
		configure = function()
			Sh.ln("$(pwd)/Xresources", "~/.config/xresources.d")
			Sh.ln("$(pwd)/Xresources/Xresources", "~/.Xresources")
			Sh.sh([[
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
		path = "mpd",
		configure = function() end,
		depends = {
			"mpd",
		},
		installer = function()
			if not Sh.file_exists("~/.local/bin/ympd") then
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
					Sh.arch()
				)
				Sh.exec(cmd)
			end
		end,
	},
}
