{ lib, config, pkgs, ... }:
let
  importNixPkgs = rev:
    import (fetchNixPkgs rev) {
      config = config.nixpkgs.config;
    };
  fetchNixPkgs = rev:
    builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
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

powerManagement = {
  enable = true;
  powertop.enable = true;
  cpuFreqGovernor =
    lib.mkIf config.services.tlp.enable (lib.mkForce null);
};

boot = {
  cleanTmpDir = true;
  initrd.availableKernelModules = [ "hid-logitech-hidpp" ];
  tmpOnTmpfs = false;

  kernelModules = [
    "hid-logitech-hidpp"
    "kvm-intel"
    "intel_pstate"
    "tp_smapi"
    "tpacpi-bat"
  ];

  extraModulePackages = [ config.boot.kernelPackages.acpi_call ];

  kernel.sysctl = {
    "vm.swappiness" = lib.mkDefault 1;
    "fs.inotify.max_user_watches"   = 1048576;   # default:  8192
    "fs.inotify.max_user_instances" =    1024;   # default:   128
    "fs.inotify.max_queued_events"  =   32768;   # default: 16384
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
  bluetooth = {
    enable          = true;
    powerOnBoot     = true;
    extraConfig = "
      # [General]
      # Enable=Source,Sink,Media,Socket

      # Set idle timeout (in minutes) before the connection will
      # be disconnect (defaults to 0 for no timeout)
      IdleTimeout=2

      # Enable HID protocol handling in userspace input profile
      # Defaults to false(hidp handled in hidp kernel module)
      # UserspaceHID=true
    ";
  };
  nvidiaOptimus.disable = true;
  bumblebee.enable = false;
  trackpoint = {
    enable       = true;
    emulateWheel = true;
    sensitivity  = 255;
    speed        = 255;
  };

  pulseaudio = with pkgs; {
    enable       = true;
    package      = pulseaudioFull;
    support32Bit = false;
    configFile   = writeTextFile {
      name = "default.pa";
      text = import ./pulseaudio.nix;
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

nixpkgs =
  let
    nixpkgs1709 = importNixPkgs "e984f9e48e193f4b772565d930fc8631178ac9cc";
    nixpkgs1803 = importNixPkgs "5d19e3e78fb89f01e7fb48acc341687e54d6888f";
    stConfigured = self: super: {
        st =
          let stNix = super.callPackage ./st-config.nix {};
          in nixpkgs1803.st.override {
            conf    = stNix.config;
            patches = [
              (super.writeTextFile {
                name = "st-no-bold.patch";
                text = stNix.noBoldPatch;
              })
            ];
          };
      };
    steeloverseer1709 = self: super: {
      haskellPackages = super.haskellPackages.override {
        overrides = hpkgsNew: hpkgsOld: rec {
          steeloverseer = nixpkgs1709.haskellPackages.steeloverseer;
        };
      };
    };
    neovimAlias = self: super: {
      neovim = self.unstable.neovim.override { vimAlias = true; };
    };
    stackage2nix = import
      builtins.fetchTarball 
      https://github.com/typeable/nixpkgs-stackage/archive/master.tar.gz;
    patchedSlock = self: super: {
      slock = nixpkgs1709.slock.overrideAttrs (oldAttrs: {
        patches = [
          (super.fetchpatch {
            name   = "slock-dpms";
            url    = "https://tools.suckless.org/slock/patches/slock-dpms-20170923-fa11589.diff";
            sha256 = "1581ghqynq5v6ysri0d805f8vavfvswdzkgc0x6fmkd7svif0sq1";
          })
          (super.fetchpatch {
            name   = "slock-mediakeys";
            url    = "https://tools.suckless.org/slock/patches/slock-mediakeys-20170111-2d2a21a.diff";
            sha256 = "18gf1blh1m56m0n1px6ly0wxp0bpdhjjxyvb8wm5mzfpnnn6gqsz";
          })
          (super.fetchpatch {
            name   = "slock-capscolor";
            url    = "https://tools.suckless.org/slock/patches/slock-capscolor.diff";
            sha256 = "05nwlvchvnvvqmx1vz1b7vzpcl889lyg59j25pqnaqs01dnn1w0d";
          })
          (super.fetchpatch {
            name   = "slock-quickcancel";
            url    = "https://tools.suckless.org/slock/patches/slock-quickcancel-20160619-65b8d52.diff";
            sha256 = "0f7pzcr0mj2kccqv8mpizvflqraj2llcn62ayrqf1fjvlr39183v";
          })
        ];
      });
    };

    haskellPackagesXmonad = self: super: {
      haskellPackagesXmonad = nixpkgs1709.haskellPackages;
    };

    # taffybar2 = self: super: {
      # haskellPackages = super.haskellPackages.override {
        # overrides = hpkgsNew: hpkgsOld: {
          # taffybar2 = hpkgsNew.callPackage ./taffybar.nix {};
        # };
      # };
    # };

    # taffybar2 = self: super: {
      # haskell = super.haskell // {
        # packages = super.haskell.packages // {
          # ghc844 = super.haskell.packages.ghc844.override {
            # overrides = hpkgsNew: hpkgsOld: {
              # taffybar2 = hpkgsNew.callPackage ./taffybar.nix {};
            # };
          # };
        # };
      # };
    # };

    plexUnstable = self: super: {
      plex = self.unstable.plex;
    };

    slackDark = self: super: {
      slack = self.master.slack.override { darkMode = true; };
    };

    dockerUnstable = self: super: {
      docker         = self.unstable.docker;
      docker_compose = self.unstable.docker_compose;
    };

    golangMaster = self: super: {
      go      = self.master.go;
      dep     = self.master.dep;
      gccgo   = self.master.gccgo;
      go2nix  = self.master.go2nix;
      dep2nix = self.master.dep2nix;
    };

    withUnstable =
      let
        unstableTar = builtins.fetchTarball
          https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz;
        masterTar = builtins.fetchTarball
          https://github.com/NixOS/nixpkgs/archive/master.tar.gz;
      in
      self: super: {
        master = import masterTar {
          config = config.nixpkgs.config;
        };
        unstable = import unstableTar {
          config = config.nixpkgs.config;
        };
      };
  in
  {
    overlays = [
      # plexUnstable
      # stackage2nix
      haskellPackagesXmonad
      dockerUnstable
      golangMaster
      neovimAlias
      patchedSlock
      stConfigured
      steeloverseer1709
      slackDark
      withUnstable
    ];
    config = {
      allowUnfree = true;
      allowBroken = true;
    };
  };

environment.systemPackages = with pkgs;
  [
    unstable.google-play-music-desktop-player
    ag
    arandr
    bluez
    bluez-tools
    blueman
    ctags
    tmate
    # dfilemanager
    libreoffice-fresh
    # direnv
    ffmpeg
    fzf
    gcc
    gitAndTools.gitFull
    mercurialFull
    xorg.xev
    git-crypt
    gnumake
    unstable.unetbootin
    google-chrome
    chromium
    hicolor-icon-theme
    breeze-icons
    # plasma5.breeze-gtk
    # faba-mono-icons
    # numix-icon-theme-circle
    # gnome3.adwaita-icon-theme
    # gnome-breeze
    # plasma5.breeze-qt5
    # gnome2.gnome_icon_theme
    # mate.mate-icon-theme
    # dzen2
    # stalonetray
    conky
    rfkill
    insomnia
    htop
    httpie
    imagemagick
    iotop
    jq
    xorg.xhost
    libnotify
    mkpasswd
    neovim
    networkmanager
    networkmanagerapplet # network tray
    # wicd
    # wpa_supplicant_gui
    # wpa_supplicant
    thunderbird
    ntfs3g
    paprefs     # pulseaudio
    pasystray   # pulseaudio tray
    pavucontrol # pulseaudio
    python35Packages.youtube-dl
    libva-full
    libva-utils
    qt5.qtwebkit
    speedtest_cli
    st
    tldr
    udiskie
    unzip
    vifm
    wget
    openssl
    xclip
    xorg.xwininfo
    yadm
    tree
    zsh
    zsh-autoenv
    acpi
    xorg.libXinerama
    httpie
    file
    lsof
    tig
    bfg-repo-cleaner

    zip
    apg
    xcompmgr
    sshpass
    shared_mime_info
    cloc
    # elmPackages.elm
    # mysqlWorkbench
    # mysql57
    apvlv
    ranger

    # gimp
    pinta
    # nomacs
    # hdparm
    feh
    gwenview # image viewer

    # unstable.rq
    # unstable.ripgrep
    # unstable.fd
    # unstable.bat

    # wkhtmltopdf

    qbittorrent

    unstable.tdesktop

    slack
    unstable.skype
    unstable.viber

    traceroute

    nix-prefetch-scripts

    perlPackages.locallib
    perlPackages.Appcpanminus
    perlPackages.PathTiny
    perlPackages.DBDmysql

    p7zip

    nodePackages.node2nix

    go
    dep
    gccgo
    go2nix
    dep2nix

    remmina
    gnome3.nautilus

    unstable.firefox

    # unstable.ansible
    vlc
    vagrant
    gparted
    winusb

    docker_compose
    docker
    gdb

    mupdf
    shellcheck
    unstable.cabal2nix
    haskellPackages.hasktags
    haskellPackages.steeloverseer
    # haskellPackages.taffybar
    # haskell.packages.ghc822.taffybar
    haskellPackagesXmonad.taffybar
    haskellPackages.una
    haskellPackages.threadscope
    (haskell.lib.dontCheck haskellPackages.elocrypt)
    unstable.ghc

    pgadmin

    nmap-graphical

    # nixops
    # disnix
    patchelf

    # wineFull
    # winetricks

    python3Full

    i7z
    powertop
    borgbackup

    dunst # notification
    xkblayout-state # current layout cli
    clipit # clipboard history
    xbanish # disable cursor while typing
    # xxkb # language

    # mosh
    # wicd
    # apvlv
    # copyq
    # mpv
    # cmplayer
    # tpacpi-bat
    # easystroke
    # krusader
    # speedcrunch
    # jdownloader2
    # rsnapshot
    # newsbeuter
  ];

environment.variables = with pkgs;
  lib.mkAfter { GOROOT = [ "${go.out}/share/go" ]; };

networking = {
  hostName        = "anpryl-t460p";
  firewall.enable = false;
  networkmanager  = {
    enable         = true;
    wifi.powersave = true;
  };
};

systemd.services.nixos-upgrade.path = with pkgs;
  [ gnutar xz.bin gzip config.nix.package.out ];

services = {
  acpid = {
    enable = true;
    powerEventCommands = "${pkgs.systemd}/bin/systemctl suspend";
  };
  pgmanage = {
    enable = true;
    connections = {
      idcardev = "hostaddr=159.69.33.180 port=5432 dbname=idcardev sslmode=allow";
      idcarprod = "hostaddr=159.69.33.180 port=5432 dbname=idcarprod sslmode=allow";
      surechain_test = "hostaddr=127.0.0.1 port=5432 dbname=surechain_test sslmode=allow";
    };
  };
  udev.packages = [ pkgs.gnome3.gnome-settings-daemon ];
  gnome3 = {
    gnome-keyring.enable = true;
  };
  autorandr.enable            = true;
  dbus.enable                 = true;
  # fprintd.enable              = true;
  locate.enable               = true;
  nixosManual.showManual      = true;
  openntpd.enable             = true;
  openssh.enable              = true;
  printing.enable             = false;
  dbus.packages = [ pkgs.gnome3.dconf pkgs.system-config-printer ];
  logind.extraConfig = ''
    KillUserProcesses=no
  '';
  # borgbackup.jobs = {
    # rootBackup = {
      # paths = "/";
      # exclude = [ "/nix" ];
      # repo = "/run/media/anpryl/Passport/borgbackup";
      # encryption = {
        # mode = "repokey";
        # passCommand = "cat /home/anpryl/borg/pass";
      # };
      # compression = "lzma";
      # startAt = "weekly";
      # doInit = false;
    # };
  # };
  tlp = {
    enable = true;
    extraConfig = "
      CPU_HWP_ON_AC=performance
      CPU_HWP_ON_BAT=balance_power
      CPU_BOOST_ON_AC=0
      CPU_BOOST_ON_BAT=0
      CPU_MIN_PERF_ON_AC=0
      CPU_MAX_PERF_ON_AC=100
      CPU_MIN_PERF_ON_BAT=0
      CPU_MAX_PERF_ON_BAT=100
      CPU_SCALING_GOVERNOR_ON_AC=performance
      CPU_SCALING_GOVERNOR_ON_BAT=powersave
      SCHED_POWERSAVE_ON_AC=0
      SCHED_POWERSAVE_ON_BAT=1
      ENERGY_PERF_POLICY_ON_AC=performance
      ENERGY_PERF_POLICY_ON_BAT=power
      SATA_LINKPWR_ON_AC=max_performance
      SATA_LINKPWR_ON_BAT=med_power_with_dipm min_power
      PCIE_ASPM_ON_AC=performance
      PCIE_ASPM_ON_BAT=powersave
      WOL_DISABLE=Y
    ";
  };
  udisks2.enable         = true;
  upower.enable          = true;
  redshift = {
    enable = true;
    # provider = "geoclue2";
    latitude = "47";
    longitude = "32";
    # temperature.day = 5500;
    # temperature.night = 3700;
  };
  plex = {
    enable       = true;
    user         = "anpryl";
    group        = "anpryl";
  };
  postgresql = {
    enable      = false;
    enableTCPIP = true;
  };
  journald.extraConfig = "SystemMaxUse=100M";
};

security.sudo.wheelNeedsPassword = false;

# https://wiki.archlinux.org/index.php/Power_management#Sleep_hooks
# https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/security/physlock.nix - as example
# TODO make service for all users (systemd.user.services)
systemd.services.lock-on-suspend = {
  description = "Lock on suspend";
  serviceConfig = {
    Type = "forking";
    User = "anpryl";
    ExecStart = "/run/wrappers/bin/slock";
    # ExecStartPost = "${pkgs.coreutils}/bin/sleep 1";
  };
  environment.DISPLAY = ":0";
  before = [ "suspend.target" ];
  wantedBy = [ "suspend.target" ];
};

services.xserver = with pkgs; {
  enable                 = true;
  autorun                = true;
  exportConfiguration    = true;
  enableCtrlAltBackspace = true;
  layout                 = "us,ru";
  videoDrivers           = [ "intel" ];
  # videoDrivers           = [ "nvidia" ];
  # videoDrivers           = [ "intel" "nvidia" ];

  # doesn't work :(
  xkbOptions             = "caps:ctrl_modifier,grp:toggle,terminate:ctrl_alt_bksp";

  xautolock = {
    enable = true;
    locker = "/run/wrappers/bin/slock";
    time   = 30;
    extraOptions = [ "-detectsleep" ];
    enableNotifier = true;
    notify = 30;
    notifier = "${libnotify}/bin/notify-send \"Locking in 30 seconds\"";
    killer = "${systemd}/bin/systemctl suspend";
    killtime = 120;
  };

  displayManager = {
      # we can move this programs to systemd services
      # dropbox as docker container
      # sudo ${pkgs.rfkill}/bin/rfkill block bluetooth && \
      # sudo ${pkgs.rfkill}/bin/rfkill unblock bluetooth && \
      # ${coreutils}/bin/sleep 30 && ${dropbox}/bin/dropbox &
      # ${xorg.xorgserver}/bin/cvt 1920 1080 60 &&
      # ${xorg.xrandr}/bin/xrandr --newmode "1920x1080_60.00" 173.00 1920 2048 2248 2576 1080 1083 1088 1120 -hsync +vsync &&
      # ${xorg.xrandr}/bin/xrandr --addmode eDP-1 1920x1080_60.00 &&
      # ${autorandr}/bin/autorandr -c &
      # "xdg-settings set default-web-browser chromium.desktop";
    sessionCommands = lib.mkAfter ''
      ${xlibs.setxkbmap}/bin/setxkbmap -option caps:ctrl_modifier &
      ${xlibs.setxkbmap}/bin/setxkbmap -option grp:toggle &
      ${xlibs.setxkbmap}/bin/setxkbmap -option terminate:ctrl_alt_bksp &
      ${xlibs.xsetroot}/bin/xsetroot -cursor_name left_ptr &
      ${networkmanagerapplet}/bin/nm-applet &
      ${pasystray}/bin/pasystray &
      ${dunst}/bin/dunst &
      ${clipit}/bin/clipit &
      ${pulseaudioFull}/bin/pulseaudio -k &
      ${blueman}/bin/blueman-applet &
      ${coreutils}/bin/sleep 30 && ${xbanish}/bin/xbanish &
      ${coreutils}/bin/sleep 30 && ${udiskie}/bin/udiskie -taP &
    '';
    slim = {
      enable      = true;
      defaultUser = "anpryl";
      theme = fetchurl {
        url    = "https://github.com/Hinidu/nixos-solarized-slim-theme/archive/1.2.tar.gz";
        sha256 = "f8918f56e61d4b8f885a4dfbf1285aeac7d7e53a7458e32942a759fedfd95faf";
      };
    };
  };
  # desktopManager = {
    # gnome3.enable = true;
    # default = "none";
  # };
  windowManager = {
    default = "xmonad";
    xmonad = {
      enable                 = true;
      enableContribAndExtras = true;
      haskellPackages        = pkgs.haskellPackagesXmonad;
      extraPackages = hpkgs: [
        hpkgs.taffybar
      ];
    };
  };
};

  programs = {
    vim.defaultEditor = true;
    ssh.startAgent    = true;
    slock.enable      = true;
    thefuck.enable    = true;
    light.enable      = true;
    qt5ct.enable      = true;
    dconf.enable      = true;
    tmux = {
      enable                        = true;
      clock24                       = true;
      baseIndex                     = 1;
      keyMode                       = "vi";
      shortcut                      = "a";
      customPaneNavigationAndResize = false;
    };
    zsh = {
      enable                    = true;
      promptInit                = "";
      zsh-autoenv.enable        = true;
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
          "docker-compose"
          "httpie"
          "jsontools"
          "systemd"
          "tmux"
          "vagrant"
          "vi-mode"
          # "autoenv"
          "zsh-autoenv"
          "colorize"
          "colored-man-pages"
          "go"
          "stack"
        ];
      };

    };
  };

  virtualisation = {
    # virtualbox = {
      # guest = {
        # enable = true;
      # };
      # host = {
        # enable              = true;
        # enableHardening     = false;
        # enableExtensionPack = true;
        # headless            = false;
      # };
    # };
    docker = {
      enable           = true;
      enableOnBoot     = true;
      autoPrune.enable = true;
      liveRestore      = false;
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
      anpryl = {
        # gid = 1000;
      };
    };
    users.anpryl = {
      uid            = 1000;
      home           = "/home/anpryl";
      group          = "anpryl";
      createHome     = true;
      shell          = "${pkgs.zsh}/bin/zsh";
      extraGroups    = [
        "anpryl"
        "wheel"
        "networkmanager"
        "audio"
        "docker"
        "vboxusers"
        "power"
        "video"
      ];
    };
  };

  system =
  let
    version = "18.09";
  in {
    stateVersion = version;
    autoUpgrade = {
      enable      = false;
      channel     = "https://nixos.org/channels/nixos-" + version;
      dates       = "10:00";
    };
  };

  nix = {
    gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 30d";
    };
    useSandbox        = true;
    autoOptimiseStore = true;
  };
}
