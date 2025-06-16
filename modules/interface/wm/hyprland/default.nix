# /etc/nixos/modules/interface/wm/hyprland/default.nix
# Hyprland window manager system configuration

{ config, lib, pkgs, inputs, ... }:

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
    grim                   # Screenshot tool
    slurp                  # Screen area selection
    wl-clipboard           # Wayland clipboard utilities (wl-copy, wl-paste)
    hyprpaper              # Hyprland's native wallpaper manager
    swww                   # Animated wallpaper daemon
    
    # System tray and utilities
    pavucontrol           # Audio control
    brightnessctl         # Brightness control
    udiskie               # Auto-mount removable media
    playerctl             # Media player control
    
    # Polkit agents for authentication
    kdePackages.polkit-kde-agent-1
    hyprpolkitagent       # Hyprland's polkit agent
    
    # Clipboard manager
    clipse
    
    # Idle and lock management
    hypridle              # Idle daemon
    hyprlock              # Screen locker
    
    # Network management
    networkmanagerapplet  # nm-applet
    
    # Game streaming
    sunshine              # Game streaming server
  ];

  # Systemd user service for quickshell
  systemd.user.services.quickshell = {
    enable = true;
    description = "Quickshell Desktop Shell";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "/home/fabio/.config/quickshell/fabios-qs/utils/quickshell-wrapper.sh";
      Restart = "on-failure";
      RestartSec = 3;
      Environment = [
        # Unset the problematic Qt style that breaks QtQuick.Controls
        "QT_STYLE_OVERRIDE="
      ];
    };
  };
}