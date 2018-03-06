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

{ lib, config, pkgs, ... }:
let 
  importNixPkgs = { rev, sha256 }:
    import (fetchNixPkgs { inherit rev sha256; }) { 
      config = config.nixpkgs.config; 
    };
  fetchNixPkgs = { rev, sha256 }:
    pkgs.fetchFromGitHub {
      inherit rev sha256;
      owner = "NixOS";
      repo  = "nixpkgs-channels";
    };
in
{

time = {
  timeZone                 = "Europe/Kiev";
  hardwareClockInLocalTime = false;
};

fileSystems."/".options = [ 
  "noatime" 
  "nodiratime" 
  "discard" 
];

powerManagement.cpuFreqGovernor =
  lib.mkIf config.services.tlp.enable (lib.mkForce null);

boot = {
  cleanTmpDir = true;
  initrd.availableKernelModules = [ "hid-logitech-hidpp" ];

  kernelPackages = pkgs.linuxPackages_latest;

  kernelModules = [ 
    "hid-logitech-hidpp" 
    "kvm-intel" 
    "intel_pstate" 
    "tp_smapi" 
  ];

  kernel.sysctl = {
      "vm.swappiness" = lib.mkDefault 1;
  };

  loader.timeout = 1;
  loader.grub = {
    enable                = true;
    version               = 2;
    efiSupport            = true;
    efiInstallAsRemovable = true;
    device                = "nodev";
  };
};

hardware = {
  cpu.intel.updateMicrocode = true;
  bluetooth.enable          = true;
  nvidiaOptimus.disable     = false;
  bumblebee = {
    enable         = true;
    connectDisplay = true;
    group          = "video";
  };
  trackpoint = {
    enable       = true;
    emulateWheel = true;
    sensitivity  = 200;
    speed        = 500;
  };

  pulseaudio = with pkgs; {
    enable       = true;
    package      = pulseaudioFull;
    support32Bit = true;
    configFile   = writeTextFile {
      name = "default.pa";
      text = (import ./pulseaudio.nix).config;
    };
  };
  opengl = {
    driSupport      = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
    ];
  };
};

sound = {
  enable           = true;
  mediaKeys.enable = true;
};

security.sudo.wheelNeedsPassword = false;

networking.hostName = "anpryl-t460p";

  # Add unstable channel
  # sudo nix-channel --add https://nixos.org/channels/nixos nixos-unstable
  # sudo nix-channel --update
  nixpkgs.config = with pkgs;
  {
    allowUnfree = true;
    # overlays = [];
    # packageOverrides = pkgs: {
      # unstable = import <nixos-unstable> {
        # config = config.nixpkgs.config;
      # };
    # };
  };



  environment.systemPackages = with pkgs;
    let 
      unstableTar = fetchTarball http://nixos.org/channels/nixos-unstable/nixexprs.tar.xz;
      unstable = import unstableTar {
        config = config.nixpkgs.config;
      };
      slock' = slock.overrideDerivation (oldAttrs: {
        patches = [
          (fetchpatch {
            name   = "slock-capscolor";
            url    = "https://tools.suckless.org/slock/patches/slock-capscolor.diff";
            sha256 = "05nwlvchvnvvqmx1vz1b7vzpcl889lyg59j25pqnaqs01dnn1w0d";
          })
          (fetchpatch {
            name   = "slock-dpms";
            url    = "https://tools.suckless.org/slock/patches/slock-dpms-20170923-fa11589.diff";
            sha256 = "1581ghqynq5v6ysri0d805f8vavfvswdzkgc0x6fmkd7svif0sq1";
          })
          (fetchpatch {
            name   = "slock-mediakeys";
            url    = "https://tools.suckless.org/slock/patches/slock-mediakeys-20170111-2d2a21a.diff";
            sha256 = "18gf1blh1m56m0n1px6ly0wxp0bpdhjjxyvb8wm5mzfpnnn6gqsz";
          })
          (fetchpatch {
            name   = "slock-quickcancel";
            url    = "https://tools.suckless.org/slock/patches/slock-quickcancel-20160619-65b8d52.diff";
            sha256 = "0f7pzcr0mj2kccqv8mpizvflqraj2llcn62ayrqf1fjvlr39183v";
          })
        ];
      });
      stNix = callPackage ./st-config.nix {};
      st' = st.override { 
        conf    = stNix.config;
        patches = [ 
          (writeTextFile {
            name = "st-no-bold.patch";
            text = stNix.noBoldPatch;
          })
        ];
      }; 
      neovim' = neovim.override { vimAlias = true; };
      # https://github.com/NixOS/nixpkgs/issues/31060
      dropbox' = (importNixPkgs {
        rev    = "85f0eef69cb29572184c315f575120158b4fb617";
        sha256 = "1f3ahjd7jzh0vpg5s2rfl9mbskl6q8yl1xslpgkb4w7f1nyd5snc";
      }).dropbox;
    in 
      [
	google-play-music-desktop-player
        ag
        arandr
        bluez
        bluez-tools
        cabal2nix
        ctags
        tmate
        dfilemanager
        libreoffice-fresh
        direnv
        dropbox
        ffmpeg
        fzf
        gcc
        gitAndTools.gitFull
        gnumake
        go
        gccgo
        google-chrome
        haskellPackages.hasktags
        haskellPackages.steeloverseer
        haskellPackages.stylish-haskell
        haskellPackages.taffybar
        haskellPackages.una
        htop
        httpie
        imagemagick
        iotop
        jq
        xorg.xhost
        keepassx-reboot
        libnotify
        mkpasswd
        neovim'
        networkmanager
        networkmanagerapplet # network tray
        thunderbird
        nix-repl
        ntfs3g
        paprefs     # pulseaudio
        pasystray   # pulseaudio tray
        pavucontrol # pulseaudio
        python3
        python35Packages.youtube-dl
        qt5.qtwebkit
        skype
        slock'
        speedtest_cli
        st'
        tldr
        udiskie
        unstable.firefox
        unstable.rambox
        unstable.viber
        unstable.vlc
        unzip
        vifm
        wget
        xclip
        xorg.xwininfo
        yadm
        tree
        zsh
        acpi
        xorg.libXinerama
        httpie
        file
        lsof
        gwenview # image viewer
        tig
        bfg-repo-cleaner

        zip
        apg
        unstable.ansible
        sshpass
        cloc
        # elmPackages.elm
        # nodejs
        mysqlWorkbench
        apvlv

        perlPackages.Appcpanminus
        perlPackages.PathTiny
        perlPackages.DBDmysql
        
        unstable.dep

        gdb
        # pdf2htmlEX
        haskellPackages.hpack
        haskellPackages.ghcid
        haskellPackages.stylish-haskell
        haskellPackages.hindent
        haskellPackages.hlint
        unstable.stack
        # stack2nix
        pgadmin
        # stackage2nix
        cabal2nix
        cabal-install
        unstable.ghc
        zlib
        vagrant
        transmission_gtk

        nixops
        disnix
        patchelf

        wineFull

        # mosh
        # wicd
        # powertop
        # dunst - notification
        # xxkb - language
        # haskellPackages.pdf2line
        # apvlv
        # xkblayout-state
        # services.redshift
        # mosh
        # copyq
        # clipit
        # transmission xmonad config
        # mpv
        # cmplayer
        # tpacpi-bat
        # easystroke
        # krusader
        # speedcrunch
        # jdownloader2
        # rsnapshot
        # borge
        # newsbeuter
        # elinks
      ];

  environment.variables = with pkgs; lib.mkAfter { GOROOT = [ "${go.out}/share/go" ]; };

  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  systemd.services.nixos-upgrade.path = with pkgs; [ gnutar xz.bin gzip config.nix.package.out ];

  services = {
    acpid.enable           = true;
    autorandr.enable       = true;
    dbus.enable            = true;
    #fprintd.enable         = true;
    locate.enable          = true;
    nixosManual.showManual = true;
    openntpd.enable        = true;
    openssh.enable         = true;
    printing.enable        = true;
    tlp.enable             = true;
    udisks2.enable         = true;
    upower.enable          = true;
    plex = {
      enable = true;
      openFirewall = true;
      user = "anpryl";
      group = "anpryl";
    };
    pgmanage = {
      enable = false;
      connections = {
          "local" = "hostaddr=127.0.0.1 port=5432 dbname=testdb";
      };
    };
    postgresql = {
      enable = true;
      enableTCPIP = true;
    };
    journald.extraConfig = "SystemMaxUse=50M";
  };

  # powerManagement.powertop.enable = true;

  services.xserver = with pkgs; {
    enable                 = true;
    autorun                = true;
    exportConfiguration    = true;
    enableCtrlAltBackspace = true;
    layout                 = "us,ru";
    videoDrivers           = [ "nvidia" "intel" ];
    xkbOptions             = "ctrl:nocaps,grp:alt_space_toggle,terminate:ctrl_alt_bksp";

    # dpi = 192;
    # xrandrHeads = [
      # {
        # output = "ePD1";
        # primary = false;
        # # monitorConfig = ''
          # # Option "DPI" "192 x 192"
        # # '';
      # }
      # {
        # output = "HDMI1";
        # primary = true;
        # # monitorConfig = ''
          # # Option "DPI" "96 x 96"
        # # '';
      # }
    # ];

    xautolock = {
      enable = true;
      locker = "slock";
      time   = 15;
    };

    displayManager = {
        # check xkbOptions later
        # ${xlibs.setxkbmap}/bin/setxkbmap -option ctrl:nocaps &
        # ${xlibs.setxkbmap}/bin/setxkbmap -option grp:alt_space_toggle &
        # ${xlibs.setxkbmap}/bin/setxkbmap -option terminate:ctrl_alt_bksp &
      sessionCommands = lib.mkAfter ''
        ${xlibs.xsetroot}/bin/xsetroot -cursor_name left_ptr &
        ${networkmanagerapplet}/bin/nm-applet &
        ${pasystray}/bin/pasystray &
        ${coreutils}/bin/sleep 30 && ${udiskie}/bin/udiskie -taP &
        ${coreutils}/bin/sleep 30 && ${dropbox}/bin/dropbox &> /tmp/dropbox_err &
      '';
      slim = {
        enable      = true;
        defaultUser = "anpryl";
        theme       = fetchurl {
          url    = "https://github.com/Hinidu/nixos-solarized-slim-theme/archive/1.2.tar.gz";
          sha256 = "f8918f56e61d4b8f885a4dfbf1285aeac7d7e53a7458e32942a759fedfd95faf";
        };
      };
    };
    windowManager = {
      default = "xmonad";
      xmonad = {
        enable                 = true;
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
    slock.enable   = true;
    thefuck.enable = true;
    light.enable   = true;
    tmux = {
      enable                        = true;
      clock24                       = true;
      baseIndex                     = 1;
      keyMode                       = "vi";
      shortcut                      = "a";
      customPaneNavigationAndResize = false;
    };
    zsh = {
      enable     = true;
      promptInit = "";
      ohMyZsh = {
        enable = true;
        theme  = "agnoster";
        plugins = [
          "zsh-completions"
          "nix-zsh-completions"
          "commmon-aliases"
          "tmux"
          "elm"
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
        enable          = true;
        enableHardening = true;
        headless        = false;
      };
    };
    docker = {
      enable           = true;
      enableOnBoot     = true;
      autoPrune.enable = true;
    };
  };

  i18n = {
    consoleFont   = "SauceCodePro";
    defaultLocale = "en_US.UTF-8";
  };

  fonts = {
    enableFontDir          = true;
    enableGhostscriptFonts = true;
    enableDefaultFonts     = true;
    fontconfig = {
      enable          = true;
      ultimate.enable = true;
      defaultFonts = {
        monospace = ["SauceCodePro"];
        serif     = ["Roboto"];
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

  users = {
    groups = {
      anpryl = {};
    };
    users.anpryl = {
      uid            = 1000;
      home           = "/home/anpryl";
      group          = "anpryl";
      createHome     = true;
      shell          = "${pkgs.zsh}/bin/zsh";
      extraGroups    = [ "anpryl" "wheel" "networkmanager" "audio" "docker" "vboxusers" "power" "video" ];
    };
  };

  system =
  let
    version = "17.09";
  in {
    stateVersion = version;
    autoUpgrade = {
      enable      = true;
      channel     = "https://nixos.org/channels/nixos-" + version;
      dates       = "10:00";
    };
  };

  nix = {
    gc.automatic      = true;
    gc.dates          = "11:00";
    useSandbox        = true;
    autoOptimiseStore = true;
  };
}
