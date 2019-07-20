{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.status-notifier-watcher;

in

{
  options = {
    services.status-notifier-watcher = {
      enable = mkEnableOption "Status Notifier Watcher";

      package = mkOption {
        default = pkgs.haskellPackages.status-notifier-item;
        defaultText = "pkgs.haskellPackages.status-notifier-item";
        type = types.package;
        example = literalExample "pkgs.haskellPackages.status-notifier-item";
        description = "The package to use for the status notifier watcher binary.";
      };
    };
  };

    # systemd.services.taffybar = {
      # serviceConfig = {
        # Type = "simple";
        # User = "anpryl";
        # Group = "anpryl";
        # ExecStart = "${cfg.package}/bin/taffybar";
        # # Restart = "on-failure";
      # };
      # environment.DISPLAY = ":0";
      # wantedBy = [ "graphical-session.target" ];
      # description = "Taffybar desktop bar";
      # after = [ "graphical-session-pre.target" ];
      # partOf = [ "graphical-session.target" ];
    # };
  config = mkIf cfg.enable {
    systemd.services.status-notifier-watcher = {
      serviceConfig = {
        Type = "simple";
        User = "anpryl";
        Group = "anpryl";
        ExecStart = "${cfg.package}/bin/status-notifier-watcher";

      };
      description = "SNI watcher";
      after = [ "graphical-session-pre.target" ];
      partOf = [ "graphical-session.target" ];
      # before = [ "taffybar.service" ];
      wantedBy = [ "graphical-session.target" ];
        # WantedBy = [ "graphical-session.target" "taffybar.service" ];
    };
  };
}
