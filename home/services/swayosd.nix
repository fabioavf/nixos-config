# /etc/nixos/home/services/swayosd.nix
# SwayOSD on-screen display service configuration

{ config, lib, pkgs, ... }:

{
  # Enable swayosd service (Home Manager will handle the systemd service)
  services.swayosd = {
    enable = true;
  };
  
  # SwayOSD configuration
  xdg.configFile."swayosd/swayosd.conf".text = 
    let
      display = if (config.networking.hostName or "") == "fabio-macbook" then "eDP-1" else "HDMI-A-3";
      backlightDevice = if (config.networking.hostName or "") == "fabio-macbook" then "intel_backlight" else "amdgpu_bl1";
    in
    ''
      [osd]
      # Display settings
      display = ${display}
      
      # Position (0.0 = top/left, 1.0 = bottom/right)
      anchor = top-center
      margin-top = 50
      
      # Appearance
      background-color = rgba(30, 30, 46, 0.9)
      text-color = rgba(205, 214, 244, 1.0)
      border-color = rgba(137, 180, 250, 0.8)
      border-width = 2
      border-radius = 12
      
      # Size
      width = 400
      height = 80
      padding = 20
      
      # Font
      font-family = Sans
      font-size = 14
      
      # Animation
      fade-in-duration = 200
      fade-out-duration = 500
      timeout = 2000
      
      # Progress bar settings
      progress-bar-height = 6
      progress-bar-background-color = rgba(49, 50, 68, 1.0)
      progress-bar-color = rgba(137, 180, 250, 1.0)
      progress-bar-border-radius = 3
      
      # Icons
      icon-size = 32
      
      [volume]
      # Volume-specific settings
      max-volume = 100
      
      [brightness]
      # Brightness-specific settings
      device = ${backlightDevice}
    '';
  
  # Install SwayOSD package
  home.packages = with pkgs; [
    swayosd
  ];
}