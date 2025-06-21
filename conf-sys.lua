#!/usr/bin/env lua
require("luarocks.loader")

local Sh = require("minilib.shell")
local M = require("minilib.monad")
local Home = os.getenv("HOME")

return {
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
			Sh.util.sh([[
		[ -d /etc/systemd/logind.conf.d ] || sudo mkdir /etc/systemd/logind.conf.d	
		sudo cp -vf logind.d/*.conf /etc/systemd/logind.conf.d/
		]])
		end,
		depends = {
			"systemd-udev",
		},
		installer = function() end,
	},
	{
		path = "modprobe",
		configure = function() end,
		depends = { "modprobe" },
		installer = function()
			Sh.util.sh("sudo cp -v $(pwd)/modprobe.d/* /etc/modprobe.d/")
		end,
	},
	{
		path = "network",
		configure = function()
			Sh.util.sh([[
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
		path = "pipewire",
		configure = function()
			Sh.util.sh([[
		systemctl --user daemon-reload
		systemctl --user --now enable pipewire pipewire-pulse
		systemctl --user --now disable pulseaudio.service pulseaudio.socket
		systemctl --user mask pulseaudio
		]])
		end,
		depends = {
			"pipewire|1",
			"pipewire-pulse|1",
			"wireplumber|1",
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
			Sh.util.sh([[
			[ -d ~/.config/pipewire ] \
				|| mkdir ~/.config/pipewire
			[ -d ~/.config/pipewire/media-session.d ] \
				|| cp -rv /usr/share/pipewire/media-session.d/ ~/.config/pipewire/
		]])
		end,
	},
	{
		path = "rules.d",
		configure = function()
			Sh.util.sh([[
		[ -d /etc/udev/rules.d ] || sudo mkdir /etc/udev/rules.d	
		sudo cp -vf rules.d/* /etc/udev/rules.d/
		]])
		end,
		depends = {
			"systemd-udev",
		},
		installer = function() end,
	},
	{
		path = "sysctl.d",
		configure = function()
			Sh.util.sh([[
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
			Sh.util.sh([[
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
		depends = { "thermald|1" },
		installer = function() end,
	},
	{
		path = "datetimectl",
		configure = function()
			Sh.util.sh([[
			sudo timedatectl set-timezone Asia/Kolkata
		]])
		end,
		depends = { "timedatectl|1" },
		installer = function() end,
	},
}
