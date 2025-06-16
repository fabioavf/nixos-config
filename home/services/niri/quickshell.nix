# /etc/nixos/home/services/niri/quickshell.nix
# Quickshell desktop shell configuration for Niri

{ config, lib, pkgs, ... }:

{
  # Quickshell systemd user service
  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell Desktop Shell";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    
    Service = {
      ExecStart = "/home/fabio/.config/quickshell/fabios-qs/utils/quickshell-wrapper.sh";
      Restart = "on-failure";
      RestartSec = 3;
      Environment = [
        # Unset the problematic Qt style that breaks QtQuick.Controls
        "QT_STYLE_OVERRIDE="
      ];
    };
    
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}