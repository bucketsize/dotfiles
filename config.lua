local dejavu_sans_mono = "DejaVuSansMono Nerd Font Mono"
local agave_mono = "agave Nerd Font Mono"

return {

	-- latest def is considered --

	home = os.getenv("HOME"),
	font = "DejaVu",
	font_size = "11",
	font_monospace = dejavu_sans_mono,
	font_monospace_size = "9",
	font_family_monospace = dejavu_sans_mono,
	font_family_monospace_alt = dejavu_sans_mono,
	font_family_serif = "DejaVu Serif",
	font_family_serif_alt = "Liberation Serif",
	font_family_sans = "DejaVu Sans",
	font_family_sans_alt = "Libaration Sans",
	openbox_theme = "Nightmare", --"Arc-Dark", --"Nightmare",
	gtk_theme = "Flat-Remix-GTK-Magenta-Dark", --"Flat-Remix-GTK-Magenta-Dark", --"Arc", --"Adwaita-Dark",
	gtk_theme_isdark = "1",
	gtk_icon_theme = "HighContrast", --"gnome", --"Arc", --"Adwaita",
	gtk_cursor_theme = "Adwaita", --"Arc", --"Adwaita",
	dock_position = "Top",
	font_conky = agave_mono,
	font_conky_size = "10",

	-- window border colors
	color_normal = "#644832",
	color_active = "#ba4824",
	color_active_pre = "#884824",
	color_urgent = "#2448aa",

	groups = {
		openbox = {
			Xresources = {},
			xinit = {},
			autostart = {},
			openbox = {},
			sxhkd = {},
			tint2 = {},
			lemonbar = {},
			picom = {},
		},
		bspwm = {
			Xresources = {},
			xinit = {},
			autostart = {},
			bspwm = {},
			sxhkd = {},
			tint2 = {},
			lemonbar = {},
			picom = {},
		},
		common = {
			fonts = {},
			fontconfig = {},
			gtk = {},
			-- qt5ct = {},
			dunst = {},
			-- firefox = {},-- custom
			chromium = {},
			-- qutebrowser = {}, -- bad browser, user chromium or firefox
			-- vim = {},
			-- lspd = {}, -- custom
			-- nvim = {}, -- custom
			-- mpd = {},  -- custom
			-- ympd = {}, -- custom
			mpv = {},
			-- mxctl = {},
			ictl = {},
			-- frmad = {},
			m360 = {},
			-- fseer = {}, -- pilot - abandoned
			-- conky = {},
			-- pipewire = {}, -- custom, ignore if pulseaudio works fine
			alacritty = {},
			-- ["qterminal.org"] = {},
			tmux = {},
			mangohud = {},
		},
		sys = {
			["tlp.d"] = {},
			["rules.d"] = {},
			["sysctl.d"] = {},
			["modprobe.d"] = {},
			["misc"] = {},
			tz = {},
			-- greetd = {},
		},
		weston = {
			weston = {},
			foot = {},
			triggerhappy = {},
		},
		qtile = {
			qtile = {},
		},
		sway = {
			sway = {},
			waybar = {},
			foot = {},
		},
	},
}
