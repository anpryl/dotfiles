# For basic install
#
# boot = {
  # loader.timeout = 1;
  # loader.grub = {
    # enable = true;
    # version = 2;
    # efiSupport = true;
    # efiInstallAsRemovable = true;
    # device = "nodev";
  # };
# };
# boot.initrd.availableKernelModules = [ "hid-logitech-hidpp" ];
  # boot.initrd.luks.devices = [
    # {
      # name = "root";
      # device = "/dev/disk/by-uuid/ecfe150a-a74f-4533-9ede-bc69c7e7f7be";
      # preLVM = true;
      # allowDiscards = true; 
    # }
  # ];
# 
# environment.systemPackages = with pkgs; [
  # wget vim udiskie yadm git
# ];

# desktopManager.plasma5 = {
  # enable = true;
# };


{ config, pkgs, ... }:
let 
  importNixPkgs = { rev, sha256 }:
  import (fetchNixPkgs { inherit rev sha256; }) { 
    config = config.nixpkgs.config; 
  };

  fetchNixPkgs = { rev, sha256 }:
  pkgs.fetchFromGitHub {
    inherit rev sha256;
    owner = "NixOS";
    repo = "nixpkgs-channels";
  };
in
{

time = {
  timeZone = "Europe/Kiev";
  hardwareClockInLocalTime = false;
};

fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

boot = {
  cleanTmpDir = true;
  initrd.availableKernelModules = [ "hid-logitech-hidpp" ];

  kernelModules = [ "hid-logitech-hidpp" "kvm-intel" "intel_pstate" ];

  loader.timeout = 1;
  loader.grub = {
    enable = true;
    version = 2;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
};

hardware = {
  cpu.intel.updateMicrocode = true;
  nvidiaOptimus.disable = false;
  bluetooth.enable = true;
  pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };
  opengl = {
    driSupport = true;
    driSupport32Bit = true;
    s3tcSupport = true;
  };
};

sound = {
  enable = true;
  mediaKeys.enable = true;
  mediaKeys.volumeStep = "10%";
};

security.sudo.wheelNeedsPassword = false;

networking.hostName = "anpryl"; # Define your hostname.

  # Add unstable channel
  # sudo nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixos-unstable
  # sudo nix-channel --update
  nixpkgs.config = with pkgs;
  {
    allowUnfree = true;
    packageOverrides = pkgs: {
      unstable = import <nixos-unstable> {
        # pass the nixpkgs config to the unstable alias
        # to ensure `allowUnfree = true;` is propagated:
        config = config.nixpkgs.config;
      };
    };
  };


  environment.systemPackages = with pkgs;
    let 
      stcfg = (import ./st-config.nix {});
      st' = st.override { 
        conf = stcfg.config; 
        patches = [ ./st-no-bold.patch ];
      }; 
      neovim' = neovim.override { vimAlias = true; };
      # https://github.com/NixOS/nixpkgs/issues/31060
      dropbox' = (importNixPkgs {
        rev = "85f0eef69cb29572184c315f575120158b4fb617";
        sha256 = "1f3ahjd7jzh0vpg5s2rfl9mbskl6q8yl1xslpgkb4w7f1nyd5snc";
      }).dropbox;
    in 
      [
	google-play-music-desktop-player
        # services.redshift
        ag
        arandr
        bluez
        bluez-tools
        cabal2nix
        ctags
        dfilemanager
        direnv
        dropbox
        ffmpeg
        fzf
        gcc
        gitAndTools.gitFull
        gnumake
        go
        google-chrome
        haskellPackages.hasktags
        haskellPackages.steeloverseer
        haskellPackages.stylish-haskell
        haskellPackages.taffybar
        haskellPackages.una
        mesa_noglu
        htop
        httpie
        iotop
        jq
        keepass
        keepassx
        imagemagick
        libnotify
        mkpasswd
        mosh
        qt5.qtwebkit
        neovim'
        networkmanager
        xorg.xwininfo
        networkmanagerapplet
        nix-repl
        ntfs3g
        paprefs     # pulseaudio
        pasystray   # pulseaudio
        pavucontrol # pulseaudio
        # powertop
        python3
        python35Packages.youtube-dl
        skype
        slock
        speedtest_cli
        st'
        tldr
        udiskie
        unstable.firefox
        unstable.rambox
        unstable.steam
        unstable.viber
        unzip
        vifm
        wget
        xclip
        yadm
        zsh
      ];

  environment.variables = with pkgs; lib.mkAfter { GOROOT = [ "${go.out}/share/go" ]; };

  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  services = {
    acpid.enable = true;
    printing.enable        = true;
    dbus.enable            = true;
    locate.enable          = true;
    upower.enable          = true;
    udisks2.enable         = true;
    nixosManual.showManual = true;
    openntpd.enable        = true;
    openssh.enable         = true;
    journald.extraConfig   = "SystemMaxUse=50M";
  };

  # powerManagement.powertop.enable = true;

  services.xserver = with pkgs; {
    enable              = true;
    autorun             = true;
    exportConfiguration = true;
    layout              = "us,ru";
    videoDrivers        = [ "nvidia" "intel" ];
    xkbOptions          = "ctrl:nocaps,grp:alt_space_toggle,terminate:ctrl_alt_bksp";

    xautolock = {
      enable = true;
      locker = "slock";
      time = 10;
    };

    displayManager = {
        # check xkbOptions later
      sessionCommands = lib.mkAfter ''
        ${xlibs.setxkbmap}/bin/setxkbmap -option ctrl:nocaps &
        ${xlibs.setxkbmap}/bin/setxkbmap -option grp:alt_space_toggle &
        ${xlibs.setxkbmap}/bin/setxkbmap -option terminate:ctrl_alt_bksp &
        ${xlibs.xsetroot}/bin/xsetroot -cursor_name left_ptr &
        ${networkmanagerapplet}/bin/nm-applet &
        ${pasystray}/bin/pasystray &
        ${coreutils}/bin/sleep 30 && ${udiskie}/bin/udiskie -taP &
        ${coreutils}/bin/sleep 30 && ${dropbox}/bin/dropbox &
      '';
      slim = {
        enable = true;
        defaultUser = "anpryl";
        theme = fetchurl {
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
    slock.enable = true;
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

  virtualisation = {
    virtualbox = {
      host = {
        enable = true;
        enableHardening = true;
        headless = true;
      };
      # guest = {
        # enable = true;
      # };
    };
    docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune.enable = true;
    };
  };

  i18n = {
    consoleFont   = "SauceCodePro";
    defaultLocale = "en_US.UTF-8";
  };

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    enableDefaultFonts = true;
    fontconfig = {
      enable = true;
      ultimate = {
        enable = true;
      };
      defaultFonts = {
        monospace = ["SauceCodePro"];
        serif = ["Roboto"];
        sansSerif = ["Open sans"];
      };
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
    extraGroups = [ "wheel" "networkmanager" "audio" "docker" "vboxusers" ];
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
