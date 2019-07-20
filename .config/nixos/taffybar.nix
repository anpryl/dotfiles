{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.taffybar;

in

{
  options = {
    services.taffybar = {
      enable = mkEnableOption "Taffybar";
      package = mkOption {
        default = pkgs.taffybar;
        defaultText = "pkgs.taffybar";
        type = types.package;
        example = literalExample "pkgs.taffybar";
        description = "The package to use for the Taffybar binary.";
      };
    };
  };

  config = mkIf config.services.taffybar.enable {
    systemd.services.taffybar = {
      serviceConfig = {
        Type = "simple";
        User = "anpryl";
        Group = "anpryl";
        ExecStart = "${cfg.package}/bin/taffybar";
        # Restart = "on-failure";
      };
      environment.DISPLAY = ":0";
      wantedBy = [ "graphical-session.target" ];
      description = "Taffybar desktop bar";
      after = [ "graphical-session-pre.target" ];
      partOf = [ "graphical-session.target" ];
    };
  };
}
