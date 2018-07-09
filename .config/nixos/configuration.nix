{ lib, config, pkgs, ... }:
let
  importNixPkgs = { fetchPkgs ? pkgs, rev, sha256 }:
    import (fetchNixPkgs { inherit fetchPkgs rev sha256; }) {
      config = config.nixpkgs.config;
    };
  fetchNixPkgs = { fetchPkgs, rev, sha256 }:
    fetchPkgs.fetchFromGitHub {
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

powerManagement = {
  enable = false;
  cpuFreqGovernor =
    lib.mkIf config.services.tlp.enable (lib.mkForce null);
  # powerDownCommands = ''
  # '';
  # powerUpCommands = ''
    # ${pkgs.rfkill}/bin/rfkill block bluetooth
    # ${pkgs.rfkill}/bin/rfkill unblock bluetooth
  # '';
  # resumeCommands = ''
    # ${pkgs.rfkill}/bin/rfkill block bluetooth
    # ${pkgs.rfkill}/bin/rfkill unblock bluetooth
    # systemctl restart bluetooth.service
  # '';
};

boot = {
  kernelPackages = pkgs.linuxPackages_latest;

  cleanTmpDir = true;
  initrd.availableKernelModules = [ "hid-logitech-hidpp" ];

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
  bumblebee = {
    enable         = false;
    connectDisplay = true;
    group          = "video";
  };
  trackpoint = {
    enable       = true;
    emulateWheel = true;
    sensitivity  = 400;
    speed        = 500;
  };
  # trackpoint = {
    # enable       = true;
    # emulateWheel = true;
    # sensitivity  = 100;
    # speed        = 400;
  # };

  pulseaudio = with pkgs; {
    enable       = true;
    package      = pulseaudioFull;
    support32Bit = true;
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
    nixpkgs1709 = fetchPkgs: importNixPkgs {
      rev = "e984f9e48e193f4b772565d930fc8631178ac9cc";
      sha256 = "10sbyna5p03x7h6mc5cfl4dh8cd2ah4n8zxqnlm6asbjrr6n8xs7";
      inherit fetchPkgs;
    };
    stConfigured =
      self: super: {
        st =
          let stNix = super.callPackage ./st-config.nix {};
          in super.st.override {
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
          steeloverseer = (nixpkgs1709 super).haskellPackages.steeloverseer;
        };
      };
    };
    neovimAlias = self: super: {
      neovim = super.neovim.override { vimAlias = true; };
    };
    patchedTelegram = self: super: {
      tdesktop = self.unstable.tdesktop;
    };
    stackage2nix =
      import (builtins.fetchTarball https://github.com/typeable/nixpkgs-stackage/archive/master.tar.gz);
    patchedSlock = self: super: {
      slock = (nixpkgs1709 super).slock.overrideAttrs (oldAttrs: {
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

    withUnstable =
      let
        unstableTar = builtins.fetchTarball http://nixos.org/channels/nixos-unstable/nixexprs.tar.xz;
        masterTar = builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/master.tar.gz;
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
      neovimAlias
      patchedSlock
      patchedTelegram
      stConfigured
      stackage2nix
      steeloverseer1709
      withUnstable
    ];
    config = {
      allowUnfree = true;
    };
  };

environment.systemPackages = with pkgs;
    [
      google-play-music-desktop-player
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
      # dropbox
      ffmpeg
      fzf
      gcc
      gitAndTools.gitFull
      git-crypt
      gnumake
      go
      gccgo
      google-chrome
      rfkill
      htop
      httpie
      imagemagick
      iotop
      jq
      xorg.xhost
      keepassx-reboot
      libnotify
      mkpasswd
      neovim
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
      python35Packages.requests
      libva-full
      libva-utils
      qt5.qtwebkit
      unstable.skype
      slock
      speedtest_cli
      st
      tldr
      udiskie
      unzip
      vifm
      wget
      openssl
      awscli
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
      xcompmgr
      feh
      sshpass
      shared_mime_info
      cloc
      elmPackages.elm
      # mysqlWorkbench
      # mysql57
      apvlv
      ranger

      gimp
      pinta

      go2nix
      tdesktop

      traceroute

      nix-prefetch-scripts

      # xautolock

      perlPackages.locallib
      perlPackages.Appcpanminus
      perlPackages.PathTiny
      perlPackages.DBDmysql

      nodePackages.node2nix

      firefox

      rambox
      unstable.ansible
      unstable.vlc
      unstable.dep
      unstable.docker
      unstable.docker_compose
      unstable.kubernetes
      unstable.vagrant

      gdb
      haskellPackages.hasktags
      # haskellPackages.hindent
      # haskellPackages.hpack
      # haskellPackages.hlint
      haskellPackages.steeloverseer
      haskellPackages.taffybar
      haskellPackages.una
      (haskell.lib.dontCheck haskellPackages.elocrypt)
      # stackage2nix
      ghc
      # stack
      # cabal-install
      pgadmin
      pgmanage
      cabal2nix

      vscode
      # zlib
      # transmission_gtk

      nmap-graphical

      nixops
      disnix
      patchelf

      wineFull
      winetricks

      dunst # notification
      xkblayout-state # current layout cli
      clipit # clipboard history
      xbanish # disable cursor while typing
      # xxkb # language

      # mosh
      # wicd
      # powertop
      # apvlv
      # copyq
      # transmission
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

environment.variables = with pkgs;
  lib.mkAfter { GOROOT = [ "${go.out}/share/go" ]; };

networking = {
  hostName              = "anpryl-t460p";
  networkmanager.enable = true;
  firewall.enable       = false;
};

systemd.services.nixos-upgrade.path = with pkgs;
  [ gnutar xz.bin gzip config.nix.package.out ];

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
  transmission.enable    = true;
  udisks2.enable         = true;
  upower.enable          = true;
  # redshift = {
    # enable = true;
    # latitude = "47";
    # longitude = "32";
    # temperature.day = 5500;
    # temperature.night = 3700;
  # };
  plex = {
    enable       = true;
    openFirewall = true;
    user         = "anpryl";
    group        = "anpryl";
  };
  pgmanage = {
    enable = false;
    port = 9090;
    connections = {
      "idcardevprod" = "hostaddr=159.69.33.180 port=5432";
    };
    allowCustomConnections = true;
  };
  postgresql = {
    enable      = true;
    enableTCPIP = true;
  };
  journald.extraConfig = "SystemMaxUse=100M";
};

security.sudo.wheelNeedsPassword = false;

# https://wiki.archlinux.org/index.php/Power_management#Sleep_hooks
# https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/security/physlock.nix - as example
# TODO make service for all users (systemd.user.services)
systemd.services.lockOnSuspend = {
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
  enable                 = true;
  autorun                = true;
  exportConfiguration    = true;
  enableCtrlAltBackspace = true;
  layout                 = "us,ru";
  videoDrivers           = [ "intel" ];
  # videoDrivers           = [ "nvidia" "intel" ];

  # doesn't work :(
  xkbOptions             = "caps:ctrl_modifier,grp:toggle,terminate:ctrl_alt_bksp";

  xautolock = {
    enable = true;
    locker = "/run/wrappers/bin/slock";
    time   = 15;
    notify = 10;
    notifier = "${pkgs.libnotify}/bin/notify-send \"Locking in 10 seconds\"";
    killer = "${pkgs.systemd}/bin/systemctl suspend";
    killtime = 30;
  };

  displayManager = {
      # we can move this programs to systemd services
      # dropbox as docker container
      # sudo ${pkgs.rfkill}/bin/rfkill block bluetooth && \
      # sudo ${pkgs.rfkill}/bin/rfkill unblock bluetooth && \
      # ${coreutils}/bin/sleep 30 && ${dropbox}/bin/dropbox &
    sessionCommands = lib.mkAfter ''
      ${xlibs.setxkbmap}/bin/setxkbmap -option caps:ctrl_modifier &
      ${xlibs.setxkbmap}/bin/setxkbmap -option grp:toggle &
      ${xlibs.setxkbmap}/bin/setxkbmap -option terminate:ctrl_alt_bksp &
      ${xlibs.xsetroot}/bin/xsetroot -cursor_name left_ptr &
      ${networkmanagerapplet}/bin/nm-applet &
      ${pasystray}/bin/pasystray &
      ${dunst}/bin/dunst &
      ${clipit}/bin/clipit &

      ${blueman}/bin/blueman-applet &

      ${coreutils}/bin/sleep 30 && ${xbanish}/bin/xbanish &
      ${coreutils}/bin/sleep 30 && ${udiskie}/bin/udiskie -taP &
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
          "docker-compose"
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
      liveRestore      = false;
      package          = pkgs.unstable.docker;
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
      extraGroups    = [
        "anpryl"
        "wheel"
        "networkmanager"
        "audio"
        "docker"
        "vboxusers"
        "power"
        "video"
        "transmission"
      ];
    };
  };

  system =
  let
    version = "18.03";
  in {
    stateVersion = version;
    autoUpgrade = {
      enable      = false;
      channel     = "https://nixos.org/channels/nixos-" + version;
      dates       = "10:00";
    };
  };

  nix = {
    # Add args to to delete only old gc
    gc.automatic      = false;
    gc.dates          = "11:00";
    useSandbox        = true;
    autoOptimiseStore = true;
  };
}
