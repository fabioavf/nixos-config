# /etc/nixos/modules/desktop/hyprland.nix
# Hyprland window manager configuration

{ config, lib, pkgs, ... }:

{
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # XDG portal for screen sharing, file picking, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Enable graphics support
  hardware.graphics = {
    enable = true;
  };

  # Wayland/Hyprland system packages
  environment.systemPackages = with pkgs; [
    # Wayland utilities
    wofi                    # Application launcher
    wl-clipboard           # Clipboard manager
    grim                   # Screenshot tool
    slurp                  # Screen area selection
    swww                   # Wallpaper daemon
    
    # System tray and utilities
    networkmanagerapplet   # Network manager applet
    pavucontrol           # Audio control
    brightnessctl         # Brightness control
    udiskie               # Auto-mount removable media
    
    # Polkit agent for authentication
    kdePackages.polkit-kde-agent-1
    
    # Idle management
    hypridle
    
    # Clipboard manager
    clipse
  ];
}
