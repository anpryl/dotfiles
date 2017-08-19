# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Sorry, I need nvidia drivers :(
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/Kiev";
  
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  boot = {
    cleanTmpDir = true;
    loader.grub = {
      version = 2;
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev"; 
      gfxmodeEfi = "1024x768";
    };
  };

  hardware = {
    cpu.intel.updateMicrocode = true;
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
    };
  };

  security.sudo.wheelNeedsPassword = false;

  networking.hostName = "nixos"; # Define your hostname.

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  environment.systemPackages = with pkgs; [
    # google-chrome
    # (pkgs.neovim.override { vimAlias = true; })
    ag
    busybox
    libnotify
    arandr
    gitAndTools.gitFull
    htop
    iotop
    gnumake
    bashInteractive
    vifm
    yadm
    fzf
    ctags
    (pkgs.nerdfonts.override { withFont = "SourceCodePro"; })
    slock
    nethogs
    xclip
    fzf
    stack
    haskellPackages.hasktags
    haskellPackages.taffybar
    haskellPackages.una
    haskellPackages.steeloverseer
    python35Packages.youtube-dl
    wget
    mkpasswd
    ntfs3g
    SDL
    SDL2
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  # Enable CUPS to print documents.

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  services = {
    printing.enable        = true;
    dbus.enable            = true;
    journald.extraConfig   = "SystemMaxUse=50M";
    locate.enable          = true;
    udisks2.enable         = true;
    nixosManual.showManual = true;
    openntpd.enable        = true;
    urxvtd.enable          = true;
  };

  services.xserver = {
    enable = true;
    layout = "us";
    videoDrivers = [ "nvidia" ];
    xkbOptions = "ctrl:nocaps";
    desktopManager.xterm.enable = false;
    desktopManager.default = "none"; 

    displayManager = {
      sessionCommands = ''
        setxkbmap -option ctrl:nocaps	
       # DUAL screen
       # xrandr --output DVI-D-0 --off --output HDMI-0 --mode 2560x1440 --pos 2560x0 --rotate normal --output DVI-I-1 --off --output DVI-I-0 --off --output DP-1 --off --output DP-0 --mode 2560x1440 --pos 0x0 --rotate normal	
       # HDMI
        xrandr --output DVI-D-0 --off --output HDMI-0 --mode 2560x1440 --pos 0x0 --rotate normal --output DVI-I-1 --off --output DVI-I-0 --off --output DP-1 --off --output DP-0 --off
        xrdb -merge ~/.Xresources
      '';
      lightdm.enable = false;
      slim = {
        enable = true;
        defaultUser = "anpryl";
	theme = pkgs.fetchurl {
	  url = "https://github.com/Hinidu/nixos-solarized-slim-theme/archive/1.2.tar.gz";
	  sha256 = "f8918f56e61d4b8f885a4dfbf1285aeac7d7e53a7458e32942a759fedfd95faf";
        };
      };
    };
    windowManager = {
      default = "xmonad";
      xmonad = {
        enable = true;
        enableContribAndExtras = true;
        extraPackages = hpkgs: [
          hpkgs.xmonad-contrib
          hpkgs.xmonad-extras
          hpkgs.taffybar
        ];
      };
    };
  };

  programs = {
    ssh.startAgent = true;
    tmux = {
      enable = true;
      baseIndex = 1; 
      keyMode = "vi";
      newSession = true;
      shortcut = "a";
      customPaneNavigationAndResize = true;
    };
    zsh = {
      enable = true;
      promptInit = "";
      ohMyZsh = {
        enable = true;
        theme = "agnoster";
        plugins = [
          "zsh-completions"
          "nix-zsh-completions"
          "commmon-aliases"
          "tmux"
          "git"
          "cabal"
          "docker"
          "httpie"
          "jsontools"
          "systemd"
          "tmux"
          "vagrant"
          "vi-mode"
          # "autoenv"
          "colorize"
          "colored-man-pages"
          "go"
          "stack"
        ];
      };

    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.anpryl = {
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" ];
    hashedPassword = "$6$su9cWrwt$.ypbFeRUsW1ec82FxvbP0vIqKGEUIKJU1K3aFxhTfuI96D/K7E0du0y6be8UOJ72ZvnPA1DYVLqClLgLKJD5x/";
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system = 
  let
    version = "17.03";
  in {
    stateVersion = version;
    autoUpgrade.enable = true;
    # autoUpgrade.channel = "https://nixos.org/channels/nixos-" + version;
    autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable";
  };

  nix = {
    gc.automatic = true;
    gc.dates = "00:00";
    useSandbox = true;
  };
}
