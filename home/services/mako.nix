# /etc/nixos/home/services/mako.nix
# Mako notification daemon configuration

{ config, lib, pkgs, ... }:

{
  # Enable mako notification daemon
  services.mako = {
    enable = true;
    
    settings = {
      # Material 3 appearance matching waybar
      background-color = "#2B2930";
      text-color = "#E6E0E9";
      border-color = "#49454F";
      progress-color = "#D0BCFF";
      
      # Geometry with Material 3 elevation
      width = 400;
      height = 120;
      margin = "12";
      padding = "16";
      border-size = 1;
      border-radius = 12;
      
      # Behavior
      default-timeout = 5000;
      ignore-timeout = true;
      max-visible = 5;
      sort = "-time";
      
      # Position
      anchor = "top-right";
      
      # Material 3 typography
      font = "Roboto 12";
      
      # Icon settings
      icon-path = "${pkgs.adwaita-icon-theme}/share/icons/Adwaita";
      max-icon-size = 48;
      
      # Grouping
      group-by = "app-name";
    };
    
    # Extra configuration for different urgency levels with Material 3 colors
    extraConfig = ''
      [urgency=low]
      border-color=#938F99
      background-color=#36343B
      default-timeout=3000
      
      [urgency=normal]
      border-color=#D0BCFF
      background-color=#381E72
      text-color=#E8DEF8
      default-timeout=5000
      
      [urgency=critical]
      border-color=#F2B8B5
      background-color=#49191C
      text-color=#FFB4AB
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