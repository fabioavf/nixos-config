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
      
      # Material 3 appearance matching waybar
      background-color = rgba(43, 41, 48, 0.95)
      text-color = rgba(230, 224, 233, 1.0)
      border-color = rgba(73, 69, 79, 0.6)
      border-width = 1
      border-radius = 12
      
      # Size
      width = 380
      height = 72
      padding = 16
      
      # Material 3 typography
      font-family = Roboto
      font-size = 13
      
      # Smooth Material animations
      fade-in-duration = 200
      fade-out-duration = 400
      timeout = 2000
      
      # Material 3 progress bar
      progress-bar-height = 4
      progress-bar-background-color = rgba(73, 69, 79, 1.0)
      progress-bar-color = rgba(208, 188, 255, 1.0)
      progress-bar-border-radius = 2
      
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