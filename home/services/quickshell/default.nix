# Lumin - Quickshell Bar for Niri
# Material 3 inspired, responsive status bar

{ config, pkgs, inputs, ... }:

{
  # Link Lumin configuration to home directory
  home.file.".config/quickshell/lumin".source = ./.;
  
  # Systemd service for Lumin
  systemd.user.services.lumin-bar = {
    Unit = {
      Description = "Lumin - Material 3 Quickshell Bar for Niri";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      Wants = [ "niri.service" ];
    };
    
    Service = {
      Type = "simple";
      ExecStart = "${inputs.quickshell.packages.${pkgs.system}.quickshell}/bin/quickshell -c %h/.config/quickshell/lumin";
      Restart = "on-failure";
      RestartSec = 3;
      
      # Environment for Material 3 and Qt
      Environment = [
        # Ensure Material 3 support
        "QT_STYLE_OVERRIDE="
        "QT_QUICK_CONTROLS_STYLE=Material"
        
        # Wayland configuration
        "WAYLAND_DISPLAY=wayland-1"
        "XDG_SESSION_TYPE=wayland"
        
        # Ensure Niri IPC works
        "NIRI_SOCKET=${config.xdg.runtimeDir}/niri/niri.sock"
      ];
      
      # Working directory
      WorkingDirectory = "%h/.config/quickshell/lumin";
    };
    
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
  
  # Enable quickshell package
  home.packages = [
    inputs.quickshell.packages.${pkgs.system}.quickshell
  ];
}