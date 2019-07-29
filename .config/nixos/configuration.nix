{ lib, config, pkgs, ... }:
let
  importWithConfig = x:
    import x { config = config.nixpkgs.config; };
  importNixPkgs = rev:
    importWithConfig (fetchNixPkgs rev);
  fetchNixPkgs = rev:
    builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
  hardware =
    builtins.fetchTarball "https://github.com/NixOS/nixos-hardware/archive/master.tar.gz";
in
{
imports = [
  "${hardware}/lenovo/thinkpad/t460s"
];

time = {
  timeZone                 = "Europe/Kiev";
  hardwareClockInLocalTime = false;
};

fileSystems."/".options = [
  "noatime"
  "nodiratime"
  # "discard"
];

powerManagement = {
  enable = true;
  powertop.enable = true;
  cpuFreqGovernor =
    lib.mkIf config.services.tlp.enable (lib.mkForce null);
};

zramSwap.enable = false;

boot = {
  cleanTmpDir = true;
  initrd.availableKernelModules = [ "hid-logitech-hidpp" ];
  tmpOnTmpfs = false;
  kernelPackages = pkgs.linuxPackages_latest;

  kernelModules = [
    "hid-logitech-hidpp"
    "kvm-intel"
    "intel_pstate"
    "tp_smapi"
    "tpacpi-bat"
  ];

  extraModulePackages = [ config.boot.kernelPackages.acpi_call ];

  kernel.sysctl = {
    "vm.swappiness"                 = lib.mkDefault 1;
    "fs.inotify.max_user_watches"   = 1048576; # default:  8192
    "fs.inotify.max_user_instances" = 1024;    # default:   128
    "fs.inotify.max_queued_events"  = 32768;   # default: 16384
  };

  loader.timeout = 1;
  loader.grub = {
    enable                = true;
    version               = 2;
    efiSupport            = true;
    # efiInstallAsRemovable = true;
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
  # bumblebee = {
    # enable = true;
    # connectDisplay = true;
    # pmMethod = "bbswitch";
    # driver = "nvidia";
    # group = "video";
  # };
  trackpoint = {
    enable       = false;
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
    # extraPackages32 = [ pkgs.linuxPackages.nvidia_x11.lib32 ];
    extraPackages = with pkgs; [
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        # linuxPackages.nvidia_x11.out
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
      slock = super.slock.overrideAttrs (oldAttrs: {
        patches = [
          (super.fetchpatch {
            name   = "slock-capscolor";
            url    = "https://tools.suckless.org/slock/patches/capscolor/slock-capscolor-20170106-2d2a21a.diff";
            sha256 = "1mpzcc6lxwjdhp5kcmrnqqxfx8mcqxn93qb1iqsfn9pcabrzb4bx";
          })
          # (super.fetchpatch {
            # name   = "slock-dpms";
            # url    = "https://tools.suckless.org/slock/patches/dpms/slock-dpms-20170923-fa11589.diff";
            # sha256 = "1581ghqynq5v6ysri0d805f8vavfvswdzkgc0x6fmkd7svif0sq1";
          # })
          # These patches can't be applied :(
          # (super.fetchpatch {
            # name   = "slock-quickcancel";
            # url    = "https://tools.suckless.org/slock/patches/quickcancel/slock-quickcancel-20160619-65b8d52.diff";
            # sha256 = "0f7pzcr0mj2kccqv8mpizvflqraj2llcn62ayrqf1fjvlr39183v";
          # })
          # (super.fetchpatch {
            # name   = "slock-mediakeys";
            # url    = "https://tools.suckless.org/slock/patches/mediakeys/slock-mediakeys-20170111-2d2a21a.diff";
            # sha256 = "18gf1blh1m56m0n1px6ly0wxp0bpdhjjxyvb8wm5mzfpnnn6gqsz";
          # })
          # (super.fetchpatch {
            # name   = "slock-pam";
            # url    = "https://tools.suckless.org/slock/patches/pam_auth/slock-pam_auth-20190207-35633d4.diff";
            # sha256 = "0544fpd80hmpbkkbxl1pk487mdapaij5599b91jl90170ikhnp9v";
          # })
        ];
      });
    };

    telegramUnstable =
      # https://github.com/msva/mva-overlay/
      # https://github.com/msva/mva-overlay/tree/master/net-im/telegram-desktop
      let wideBaloonsPatch = builtins.fetchurl {
            url = "https://raw.githubusercontent.com/msva/mva-overlay"
                + "/14e639a87511ea40bff97e4c46100030c1412f05"
                + "/net-im/telegram-desktop/files/patches/9999/conditional"
                + "/wide-baloons/0001_baloons-follows-text-width-on-adaptive-layout.patch";
            sha256 = "12ibh0wfc8jg6hj5dqbvnbzwwjyl86fz65ypvckn8d9msbf0i826";
          };
          telegram = # 1.7.0
          (importNixPkgs "a6388e030a235bc7336ff6bf80775d104c678608").tdesktopPackages.stable;
      in
      self: super: {
        # tdesktop = self.unstable.tdesktop;
        tdesktop = telegram.overrideAttrs (attrs: {
          patches = [ wideBaloonsPatch ] ++ attrs.patches;
        });
    };

    plexUnstable = self: super: {
      plex = self.unstable.plex;
    };

    slackDark =
      let
        oldDarkSlack =
          importNixPkgs "ce6edcdb0b203c17752957f384430d89721a589a";
      in
      self: super: {
        slack = oldDarkSlack.slack.override {
          darkMode = true;
          darkModeCssUrl =
            "https://cdn.rawgit.com/rossmckelvie/slack-night-mode/master/css/raw/black.css";
        };
      };

    dockerUnstable = self: super: {
      docker         = self.unstable.docker;
      docker_compose = self.unstable.docker_compose;
    };

    pulseaudioUnstable = self: super: {
      paprefs        = self.unstable.paprefs;
      pasystray      = self.unstable.pasystray;
      pavucontrol    = self.unstable.pavucontrol;
      pulseaudioFull = self.unstable.pulseaudioFull;
    };

    golangUnstable = self: super: {
      go            = self.unstable.go;
      dep           = self.unstable.dep;
      gccgo         = self.unstable.gccgo;
      go2nix        = self.unstable.go2nix;
      vgo2nix       = self.unstable.vgo2nix;
      dep2nix       = self.unstable.dep2nix;
      gotools       = self.unstable.gotools;
      golangci-lint = self.unstable.golangci-lint;
    };

    bluetoothUnstable = self: super: {
      bluez       = self.unstable.bluez;
      bluez-tools = self.unstable.bluez-tools;
      blueman     = self.unstable.blueman;
    };

    cbatticonUnstable = self: super: {
      cbatticon = self.unstable.cbatticon;
    };

    withMasterAndUnstable =
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
    dunstUnstable = self: super: {
      dunst = self.unstable.dunst;
    };
    unclutterUnstable = self: super: {
      unclutter-xfixes = self.unstable.unclutter-xfixes;
    };
    powertopUnstable = self: super: {
      powertop = self.unstable.powertop;
    };
  in
  {
    overlays = [
      # plexUnstable
      # stackage2nix
      # bluetoothUnstable
      cbatticonUnstable
      dockerUnstable
      dunstUnstable
      golangUnstable
      neovimAlias
      patchedSlock
      powertopUnstable
      pulseaudioUnstable
      slackDark
      stConfigured
      steeloverseer1709
      telegramUnstable
      withMasterAndUnstable
      unclutterUnstable
    ];
    config = {
      allowUnfree = true;
      allowBroken = true;
    };
  };

appstream.enable = true;

environment.variables = with pkgs;
  lib.mkAfter { GOROOT = [ "${go.out}/share/go" ]; };

environment.systemPackages = with pkgs;
  [
    unstable.google-play-music-desktop-player
    ag
    arandr
    ctags
    tmate
    bluez
    bluez-tools
    blueman
    # dfilemanager
    libreoffice-fresh
    cbatticon
    ffmpeg
    fzf
    gitAndTools.gitFull
    mercurialFull
    xorg.xev
    git-crypt
    gnumake
    breeze-icons
    plasma5.breeze-gtk
    plasma5.breeze-qt5
    hicolor-icon-theme
    gnome3.adwaita-icon-theme
    # adapta-gtk-theme
    # faba-mono-icons
    # numix-icon-theme-circle
    # gnome-breeze
    # gnome2.gnome_icon_theme
    # mate.mate-icon-theme
    conky
    rfkill
    unstable.insomnia
    unstable.htop
    unstable.httpie
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
    acpi
    direnv
    xorg.libXinerama
    file
    lsof
    tig
    # bfg-repo-cleaner

    gnupg

    # master.terraform

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

    # bumblebee

    plantuml

    virtmanager

    wireguard
    wireguard-tools
    openvpn

    pciutils

    # gimp
    pinta
    # nomacs
    unstable.hdparm
    unstable.smartmontools
    feh
    # gwenview # image viewer

    unstable.dbeaver
    unstable.postgresql
    # unstable.konversation
    unstable.qbittorrent

    unstable.sublime-merge

    # unstable.python35Packages.youtube-dl
    # unstable.rq
    # unstable.ripgrep
    # unstable.fd
    # unstable.bat

    # stack
    # stack2nix
    # hpack

    slack
    zoom-us
    # unstable.discord
    unstable.skype
    # master.viber
    tdesktop

    traceroute

    nix-prefetch-scripts

    perlPackages.locallib
    perlPackages.Appcpanminus
    perlPackages.PathTiny
    perlPackages.DBDmysql

    p7zip

    master.nodePackages.node2nix

    go
    dep
    gccgo
    go2nix
    vgo2nix
    dep2nix
    gotools
    # golangci-lint

    # remmina
    gnome3.nautilus # filemanager

    xdotool

    unstable.google-chrome
    unstable.chromium
    # unstable.firefox
    firefox

    vlc

    # vagrant

    gparted
    winusb
    unstable.unetbootin

    docker_compose
    docker
    gdb

    mupdf
    shellcheck
    unstable.cabal2nix
    haskellPackages.hasktags
    haskellPackages.steeloverseer
    haskellPackages.status-notifier-item
    haskellPackages.una
    taffybar
    # haskell.packages.ghc822.taffybar
    # haskellPackagesXmonad.tcompile")affybar
    # haskellPackages.threadscope
    # (master.haskell.lib.dontCheck master.haskellPackages.elocrypt)
    # unstable.ghc

    unstable.polybar

    stalonetray
    nmap-graphical

    # nixops
    # disnix
    patchelf

    # wineFull
    # winetricks

    # python3Full

    i7z
    powertop
    borgbackup

    dunst # notification
    xkblayout-state # current layout cli
    clipit # clipboard history
    unclutter-xfixes # disable cursor while typing
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

networking = {
  hostName        = "anpryl-t460p";
  firewall.enable = false;
  hosts = {
    # "172.31.85.198" = [ "api.coins.asia" ];
  };
  networkmanager  = {
    enable         = true;
    wifi.powersave = true;
  };
};

services = {
  openvpn.servers = {
    coins = {
      config = "config /home/anpryl/coins/client.ovpn";
    };
  };
  fstrim.enable = true;
  acpid = {
    enable = true;
    powerEventCommands = "${pkgs.systemd}/bin/systemctl suspend";
    lidEventCommands = "/run/wrappers/bin/slock";
  };
  udev.packages = [ pkgs.gnome3.gnome-settings-daemon ];
  gnome3.gnome-keyring.enable = true;
  autorandr.enable            = true;
  dbus = {
    enable                 = true;
    packages = [
      pkgs.gnome3.dconf
      # pkgs.system-config-printer
      pkgs.upower
      pkgs.vlc
      pkgs.qt5ct
    ];
  };
  # fprintd.enable              = true;
  locate.enable               = true;
  nixosManual.showManual      = true;
  openntpd.enable             = true;
  openssh.enable              = true;
  printing.enable             = false;
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
    enable       = false;
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
security.pam.services.slim.enableGnomeKeyring = true;

systemd.services.nixos-upgrade.path = with pkgs;
  [ gnutar xz.bin gzip config.nix.package.out ];

# https://wiki.archlinux.org/index.php/Power_management#Sleep_hooks
# https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/security/physlock.nix - as example
# TODO make service for all users (systemd.user.services)
systemd.services.lock-on-suspend = {
  description = "Lock on suspend";
  serviceConfig = {
    Type = "forking";
    User = "anpryl";
    ExecStart = "/run/wrappers/bin/slock";
    ExecStartPost = "${pkgs.coreutils}/bin/sleep 1";
  };
  environment.DISPLAY = ":0";
  before = [ "suspend.target" ];
  wantedBy = [ "suspend.target" ];
};

services.xserver = with pkgs; {
  enable = true;
  libinput.enable = true;
  synaptics.enable = false;
  config = ''
    Section "InputClass"
      Identifier     "Enable libinput for TrackPoint"
      MatchIsPointer "on"
      Driver         "libinput"
    EndSection
  '';
  autorun                = true;
  exportConfiguration    = true;
  enableCtrlAltBackspace = true;
  layout                 = "us,ru";
  videoDrivers           = [ "intel" ];
  # videoDrivers           = [ "nvidia" ];
  # videoDrivers           = [  "nvidia" "intel" ];

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
      # ${stalonetray}/bin/stalonetray &

      # ${coreutils}/bin/sleep 5 && ${networkmanagerapplet}/bin/nm-applet &
    sessionCommands = lib.mkAfter ''
      /run/current-system/sw/bin/xset -dpms
      /run/current-system/sw/bin/xset s off
      ${xlibs.setxkbmap}/bin/setxkbmap -option caps:ctrl_modifier &
      ${xlibs.setxkbmap}/bin/setxkbmap -option grp:toggle &
      ${xlibs.setxkbmap}/bin/setxkbmap -option terminate:ctrl_alt_bksp &
      ${xlibs.xsetroot}/bin/xsetroot -cursor_name left_ptr &
      ${pulseaudioFull}/bin/pulseaudio -k &
      ${coreutils}/bin/sleep 5 && ${cbatticon}/bin/cbatticon &
      ${coreutils}/bin/sleep 5 && ${pasystray}/bin/pasystray &
      ${coreutils}/bin/sleep 5 && ${dunst}/bin/dunst &
      ${coreutils}/bin/sleep 5 && ${clipit}/bin/clipit &
      ${coreutils}/bin/sleep 5 && ${blueman}/bin/blueman-applet &
      ${coreutils}/bin/sleep 30 && ${unclutter-xfixes}/bin/unclutter &
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
      # haskellPackages        = haskellPackages;
      extraPackages = hpkgs: [
        hpkgs.taffybar
      ];
    };
  };
};

  programs = {
    wavemon.enable = true;
    nm-applet.enable = true;
    iotop.enable      = true;
    adb.enable        = true;
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
          "colorize"
          "colored-man-pages"
          "go"
          "stack"
        ];
      };

    };
  };

  virtualisation = {
    libvirtd.enable = true;
    virtualbox = {
      # guest = {
        # enable = true;
      # };
      # host = {
        # enable              = true;
        # enableHardening     = false;
        # enableExtensionPack = false;
        # headless            = false;
      # };
    };
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
        "adbusers"
        "wheel"
        "networkmanager"
        "audio"
        "docker"
        "vboxusers"
        "power"
        "video"
        "libvirtd"
        "qemu-libvirtd"
      ];
    };
  };

  system = {
    autoUpgrade = {
      enable      = false;
      dates       = "23:00";
    };
  };

  nix = {
    gc = {
      automatic = false;
      dates     = "weekly";
      options   = "--delete-older-than 30d";
    };
    useSandbox        = true;
    autoOptimiseStore = true;
  };
}
