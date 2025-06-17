# Lumin - Quickshell Bar for Niri
# Material 3 inspired, responsive status bar

{ config, pkgs, inputs, ... }:

{
  # Link Lumin configuration to home directory
  home.file.".config/quickshell/lumin".source = ./.;
  
  # Systemd service for Lumin (DISABLED - using Niri spawn-at-startup instead)
  # The bar is now launched directly by Niri at startup for better environment integration
  # systemd.user.services.lumin-bar = {
  #   Unit = {
  #     Description = "Lumin - Material 3 Quickshell Bar for Niri";
  #     After = [ "graphical-session.target" "niri.service" ];
  #     PartOf = [ "graphical-session.target" ];
  #     Wants = [ "niri.service" ];
  #   };
  #   
  #   Service = {
  #     Type = "simple";
  #     ExecStart = "${inputs.quickshell.packages.${pkgs.system}.quickshell}/bin/quickshell -c lumin";
  #     Restart = "on-failure";
  #     RestartSec = 3;
  #   };
  #   
  #   Install = {
  #     WantedBy = [ "graphical-session.target" ];
  #   };
  # };
  
  # Enable quickshell package
  home.packages = [
    inputs.quickshell.packages.${pkgs.system}.quickshell
  ];
}