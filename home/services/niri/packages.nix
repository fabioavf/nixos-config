# /etc/nixos/home/services/niri/packages.nix
# Niri-related packages and tools

{ pkgs, ... }:

{
  # All Niri-specific tools and dependencies managed at user level
  home.packages = with pkgs; [
    # ========================================
    # Wayland/Niri Core Tools
    # ========================================
    grim                    # Screenshot tool
    slurp                   # Screen area selection
    wl-clipboard            # Wayland clipboard utilities (wl-copy, wl-paste)
    swaylock                # Screen locker (niri compatible)
    swaybg                  # Simple wallpaper tool (replacing swww)
    fuzzel                  # App launcher (niri default)

    # ========================================
    # System Control and Utilities
    # ========================================
    brightnessctl           # Brightness control
    udiskie                 # Auto-mount removable media

    # ========================================
    # Clipboard and Authentication
    # ========================================
    clipse                  # Clipboard manager
    kdePackages.polkit-kde-agent-1  # Polkit agents for authentication

    # ========================================
    # Network Management
    # ========================================
    networkmanagerapplet    # nm-applet
  ];
}
