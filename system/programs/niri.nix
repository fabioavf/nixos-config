# /etc/nixos/system/programs/niri.nix
# Niri window manager system configuration

{ config, lib, pkgs, inputs, ... }:

{
  # Niri system-level support (niri-flake home module handles main config)

  # Enable graphics support
  hardware.graphics = {
    enable = true;
  };

  # Wayland/Niri system packages
  environment.systemPackages = with pkgs; [
    # Wayland utilities (some might be duplicated in home but that's fine)
    grim                   # Screenshot tool
    slurp                  # Screen area selection
    wl-clipboard           # Wayland clipboard utilities (wl-copy, wl-paste)
    swww                   # Animated wallpaper daemon
    
    # System tray and utilities
    pavucontrol           # Audio control
    brightnessctl         # Brightness control
    udiskie               # Auto-mount removable media
    playerctl             # Media player control
    
    # Polkit agents for authentication
    kdePackages.polkit-kde-agent-1
    
    # Clipboard manager
    clipse
    
    # Lock management
    swaylock              # Screen locker (niri compatible)
    
    # Network management
    networkmanagerapplet  # nm-applet
    
    # Launcher
    fuzzel                # App launcher (niri default)
    
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
