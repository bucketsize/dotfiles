# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# example: 
# https://gitlab.com/engmark/root/-/blob/master/configuration.nix

{ config, lib, pkgs, python, ... }:

let
  #nix-gaming = import (builtins.fetchTarball "https://github.com/fufexan/nix-gaming/archive/master.tar.gz");
  startqtile = pkgs.writeShellScriptBin "startqtile" ''
# Session
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=qtile
export XDG_CURRENT_DESKTOP=qtile

# Wayland stuff
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1

#exec qtile start -b wayland $@
exec systemd-cat --identifier=qtile  qtile start -b wayland $@

#
# If you use systemd and want sway output to go to the journal, use this
# instead of the `exec sway $@` above:
#
#    exec systemd-cat --identifier=sway sway $@
#
  '';
	
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # from the web config.tar.gz
      #"${nix-gaming}/modules/pipewireLowLatency.nix"
    ];

  # kernel => nixos-rebuild boot
	boot.kernelPackages = pkgs.linuxPackages_xanmod_stable;
 	#boot.supportedFilesystems = [ "ntfs" ];

	# Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  networking.hostName = "debugger"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.wireless.networks = {
    loco = {
      pskRaw = "9427df94ca70d5b0e4df481f938c74c0362a1496b07005e869f59cdf49b8edb4";
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  networking.firewall.allowedUDPPorts = [  ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # fonts
  fonts.fontconfig.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  services.connman.enable = true;
  
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.dpi = 96;
  services.xserver.videoDrivers = ["modesetting" "intel" "nouveau" "amdgpu"];
  services.xserver.windowManager.openbox.enable = true;
  services.xserver.windowManager.bspwm.enable = true;
  services.xserver.windowManager.qtile.enable = true;
  
  # displaymanager
	services.xserver.autorun = false;  
  services.xserver.displayManager.lightdm.enable = false;

  # Configure keymap in X11
  services.xserver.layout = "us";

  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.tapping = true;
  
  # greetd
	services.greetd = {
		enable = true;
		restart = false;
		settings = {
			terminal = {
				vt = 1;
			};
			default_session = {
				command = "cage -s -- gtkgreet";
				user = "greeter";
			};
		};
	};

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.acpid.enable = true;

	services.avahi = {
		enable = true;
		nssmdns = true;
	};

  services.gvfs.enable = true;
  services.logind.extraConfig = ''
      HandlePowerKey=suspend
    '';

	environment.etc."greetd/environments".text = ''
bash
startx
weston
qtile start -b wayland
startqtile
'';		

	environment.etc."greetd/gtkgreet.css".text = ''
window {
   background-color: rgba(30, 20, 10, 0.8);
   background-size: cover;
   background-position: center;
}

box#body {
   background-color: rgba(50, 50, 50, 0.5);
   border-radius: 10px;
   padding: 50px;
}
'';

  # make pipewire realtime-capable
  security.rtkit.enable = true;

  # pipewire for audio alsa, pulseaudio
  services.pipewire = {
	  enable = true;
	  alsa = {
		  enable = true;
		  support32Bit = true;
	  };
	  jack.enable = true;
	  pulse.enable = true;

	  #lowLatency.enable = true;
	  # defaults (no need to be set unless modified)
	  #lowLatency = {
		#  quantum = 64;
		#  rate = 48000;
	  #};
  };
  
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # dbus	
  services.dbus.enable = true;

  # power management
  services.upower.enable = true;
  services.logind.lidSwitch = "suspend";
  services.thermald.enable = true;
  services.tlp = {
	  enable = true;
	  settings = {
		  START_CHARGE_THRESH_BAT0 = 5;
		  STOP_CHARGE_THRESH_BAT0 = 95;
	  };
  };

  # Enable sound.
  sound.enable = true;

  # For pipewire set false
  hardware.pulseaudio.enable = false;

  # bluetooth
  hardware.bluetooth.enable = true;
 
  # opengl
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
	hardware.opengl.extraPackages = [
		pkgs.intel-compute-runtime
			pkgs.intel-media-driver
			pkgs.libvdpau-va-gl
			pkgs.vaapiIntel
			pkgs.vaapiVdpau
	];

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  # users
  users.mutableUsers = true;
  users.users.jb = {
    description = "JB";
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "power" "audio" ];
    home = "/home/jb";
  };

  nix = {
    extraOptions = ''
      experimental-features = flakes nix-command
      keep-outputs = true
      log-lines = 25
      min-free = ${toString (100 * 1000 * 1000)}
      max-free = ${toString (1000 * 1000 * 1000)}
    '';
    settings = {
      allowed-users = ["@wheel"];
      auto-optimise-store = false;

      # dont build binary
      substituters = [ "https://nix-gaming.cachix.org" ];
      trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
    };
  };

  # lets see where these go
  environment. variables = {
      "TERMINAL" = "alacritty";
      "EDITOR" = "${pkgs.vim}/bin/vim";
      "_JAVA_OPTIONS" = "-Dawt.useSystemAAFontSettings=lcd";
      "_JAVA_AWT_WM_NONREPARENTING" = "1";
  };
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  
  # Proprietary
  nixpkgs.config.allowUnfree = true;

  # env system scope packages
  environment.systemPackages = with pkgs; [
    
		# sys
		microcodeIntel
    lm_sensors
    usbutils
    usb-modeswitch
    connman 
		modemmanager
    inotify-tools
    libnotify
    pciutils
    coreutils
    man-pages man-pages-posix 
    alsa-tools
		alsa-utils
		ntfs3g
		ntfsprogs

		# xorg
		xorg.xinit
    xclip

		# cli
    brightnessctl 
    wget
    iwd
    wmctrl 
    pamixer
    ripgrep
		curl fd 
		
		# term apps 
    alacritty
    tmux
    ranger
    htop
    iotop
		
		# apps
    openbox-menu
		tint2
		xarchiver
    firefox
    neovim 
    picom  
    bluez blueman
    connman-gtk
    wpa_supplicant_gui
    w3m
    feh
    bspwm sxhkd
    dunst
    lemonbar
    triggerhappy
    dmenu
    clipcat
    fzf
    zip
		unzip
  
		# mediaplayer
    mpd
    mpv
    imagemagick 
		adapta-backgrounds
		mate.mate-backgrounds

		# dev
	 	git
    gcc
    cmake
    gnumake 
    openssl
    gnutls 
    (lua5_3.withPackages(ps: with ps; [ busted luafilesystem luaossl cqueues http ]))
    luarocks-nix
    ocaml opam 
    cargo
		python3
		python3.pkgs.pip
		/* (let  */
		/* 	my-python-packages = python-packages: with python-packages; [  */
		/* 		pandas */
		/* 		requests */
		/* 		pip */
		/* 		 #other python packages you want */
		/* 	]; */
		/* 	python-with-my-packages = python3.withPackages my-python-packages; */
		/* in */
		/* python-with-my-packages) */

		# wayland 
		greetd.gtkgreet
		cage 
    startqtile
		weston
    foot
		bemenu
		clipman
		drm_info
		grim
		imv 
		kanshi 
		wev
		wlsunset
		wtype #xdotool like

    # not sure how this works
    # nix-gaming.packages.x86_64-linux.<package>
];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
	  enable = true;
	  enableSSHSupport = true;
  };
  programs.neovim = {
	  defaultEditor = true;
	  enable = true;
	  viAlias = true;
	  vimAlias = true;
  };
  programs.steam = {
	enable = true;
	remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
	dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };


  # List services that you want to enable:
  systemd.user.services = {
    pipewire.wantedBy = [ "default.target" ];
    pipewire-pulse.wantedBy = [ "default.target" ];
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}

