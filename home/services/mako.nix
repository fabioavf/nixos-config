# /etc/nixos/home/services/mako.nix
# Mako notification daemon configuration

{ config, lib, pkgs, ... }:

{
  # Enable mako notification daemon
  services.mako = {
    enable = true;
    
    settings = {
      # Appearance
      background-color = "#1e1e2e";
      text-color = "#cdd6f4";
      border-color = "#89b4fa";
      progress-color = "#313244";
      
      # Geometry
      width = 400;
      height = 150;
      margin = "10";
      padding = "15";
      border-size = 2;
      border-radius = 8;
      
      # Behavior
      default-timeout = 5000;
      ignore-timeout = true;
      max-visible = 5;
      sort = "-time";
      
      # Position
      anchor = "top-right";
      
      # Font
      font = "Sans 11";
      
      # Icon settings
      icon-path = "${pkgs.adwaita-icon-theme}/share/icons/Adwaita";
      max-icon-size = 48;
      
      # Grouping
      group-by = "app-name";
    };
    
    # Extra configuration for different urgency levels
    extraConfig = ''
      [urgency=low]
      border-color=#6c7086
      default-timeout=3000
      
      [urgency=normal]
      border-color=#89b4fa
      default-timeout=5000
      
      [urgency=critical]
      border-color=#f38ba8
      text-color=#f38ba8
      default-timeout=0
      
      [app-name="Firefox"]
      default-timeout=8000
      
      [app-name="Discord"]
      default-timeout=4000
      
      [summary="Volume"]
      default-timeout=2000
      
      [summary="Brightness"]
      default-timeout=2000
    '';
  };
  
  # Add notification tools
  home.packages = with pkgs; [
    libnotify  # notify-send command
    mako       # mako tools (makoctl)
  ];
}