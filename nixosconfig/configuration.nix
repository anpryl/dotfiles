# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

  # imports =
  # [ # Include the results of the hardware scan.
  # ./hardware-configuration.nix
  # /home/anpryl/nixosconfig/configuration.nix
  # ];

time = {
  # timeZone = "Europe/Kiev";
  hardwareClockInLocalTime = false;
};

fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

boot = {
  cleanTmpDir = true;

  loader.timeout = 3;
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
  nvidiaOptimus.disable = false;
  pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };
};

# powerManagement.powertop.enable = true;

security.sudo.wheelNeedsPassword = false;

networking.hostName = "anpryl-desktop"; # Define your hostname.

  # Add unstable channel
  # sudo nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixos-unstable
  # sudo nix-channel --update
  # sudo nix-channel --update nixos-unstable
  nixpkgs.config = with pkgs;
  let
      fetchNixPkgs = { rev, sha256 }:
      fetchFromGitHub {
        inherit sha256 rev;
        owner = "NixOS";
        repo = "nixpkgs-channels";
      };
  in
  {
    allowUnfree = true;
    packageOverrides = pkgs: {
      unstable = import <nixos-unstable> {
        # pass the nixpkgs config to the unstable alias
        # to ensure `allowUnfree = true;` is propagated:
        config = config.nixpkgs.config;
      };

      # https://github.com/NixOS/nixpkgs/issues/31060
      tempDropboxPin = import (fetchNixPkgs {
        rev = "85f0eef69cb29572184c315f575120158b4fb617";
        sha256 = "1f3ahjd7jzh0vpg5s2rfl9mbskl6q8yl1xslpgkb4w7f1nyd5snc";
      }) {
        config = config.nixpkgs.config;
      };
    };
  };


  environment.systemPackages = with pkgs; 
    let 
      st' = pkgs.st.override { conf = builtins.readFile "/home/anpryl/nixosconfig/config.h"; }; 
      neovim' = pkgs.neovim.override { vimAlias = true; };
      dropbox' = tempDropboxPin.dropbox;
    in 
      [
        SDL
        SDL2
        ag
        arandr
        bashInteractive
        busybox
        ctags
        dfilemanager
        direnv
        dropbox'
        fzf
        gitAndTools.gitFull
        gnumake
        google-chrome
	xorg.xhost
        haskellPackages.hasktags
        haskellPackages.steeloverseer
        haskellPackages.taffybar
        haskellPackages.una
        jq
        htop
        iotop
        keepass
        keepassx2
        skype
        pmutils
        shared_mime_info
        exfat-utils
        fuse_exfat
        firefox
        unstable.viber
        libnotify
        mkpasswd
        neovim'
        rambox
        go
        nethogs
        httpie
        networkmanager
        networkmanagerapplet
        ntfs3g
        paprefs     # pulseaudio
        pasystray   # pulseaudio
        pavucontrol # pulseaudio
        python35Packages.youtube-dl
        slock
        st'
        vifm
        wget
        xclip
        yadm
        zsh
      ];

  environment.variables = { GOROOT = [ "${pkgs.go.out}/share/go" ]; };

  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  services = {
    printing.enable        = true;
    dbus.enable            = true;
    locate.enable          = true;
    udisks2.enable         = true;
    nixosManual.showManual = true;
    openntpd.enable        = true;
    urxvtd.enable          = true;
    openssh.enable         = true;
    journald.extraConfig   = "SystemMaxUse=50M";
  };

  services.xserver = {
    enable              = true;
    autorun             = true;
    exportConfiguration = true;
    layout              = "us,ru";
    videoDrivers        = [ "nvidia" ];
    xkbOptions          = "ctrl:nocaps,grp:alt_space_toggle,terminate:ctrl_alt_bksp";

    desktopManager.xterm.enable = false;

    displayManager = {
      sessionCommands = with pkgs; lib.mkAfter ''
        ${xlibs.setxkbmap}/bin/setxkbmap -option ctrl:nocaps &
        ${xlibs.setxkbmap}/bin/setxkbmap -option grp:alt_space_toggle &
        ${xlibs.setxkbmap}/bin/setxkbmap -option terminate:ctrl_alt_bksp &
        ${xlibs.xrdb}/bin/xrdb -merge ${config.users.extraUsers.anpryl.home}/.Xresources 
        ${xlibs.xsetroot}/bin/xsetroot -cursor_name left_ptr &
        ${coreutils}/bin/sleep 30 && ${dropbox}/bin/dropbox &
        ${networkmanagerapplet}/bin/nm-applet &
        ${pasystray}/bin/pasystray &
      '';
      lightdm.enable      = false;
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
      clock24 = true;
      baseIndex = 1;
      keyMode = "vi";
      shortcut = "a";
      customPaneNavigationAndResize = false;
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

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    enableDefaultFonts = true;
    fontconfig = {
      enable = true;
      # defaultFonts = {
        # monospace = ["SauceCodePro"];
        # serif = ["Roboto"];
        # sansSerif = ["Open sans"];
      # };
    };
    fonts = [
      pkgs.corefonts
      (pkgs.nerdfonts.override { withFont = "SourceCodePro"; })
      pkgs.roboto
      pkgs.opensans-ttf
      pkgs.clearlyU
      pkgs.cm_unicode
      pkgs.dejavu_fonts
      pkgs.freefont_ttf
      pkgs.terminus_font
      pkgs.ttf_bitstream_vera
    ];
  };

  users.extraUsers.anpryl = {
    uid = 1000;
    home = "/home/anpryl";
    createHome = true;
    shell = "${pkgs.zsh}/bin/zsh";
    # extraGroups = [ "wheel" "networkmanager" "audio" "adb" "video" "power" "vboxusers" "cdrom" ];
    extraGroups = [ "wheel" "networkmanager" "audio" "docker" ];
    hashedPassword = "$6$su9cWrwt$.ypbFeRUsW1ec82FxvbP0vIqKGEUIKJU1K3aFxhTfuI96D/K7E0du0y6be8UOJ72ZvnPA1DYVLqClLgLKJD5x/";
  };

  system =
  let
    version = "17.09";
  in {
    stateVersion = version;
    autoUpgrade.enable = true;
    autoUpgrade.channel = "https://nixos.org/channels/nixos-" + version;
    copySystemConfiguration = true;
  };

  nix = {
    gc.automatic = true;
    gc.dates = "00:00";
    useSandbox = true;
    autoOptimiseStore = true;
  };
}
