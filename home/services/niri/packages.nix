# /etc/nixos/home/services/niri/packages.nix
# Niri-related packages and tools

{ pkgs, ... }:

{
  # Niri-specific tools
  home.packages = with pkgs; [
    # Wayland/Niri tools
    grim # screenshot tool
    slurp # area selection for screenshots
    wl-clipboard # clipboard utilities
    swww # wallpaper daemon
    swaylock # screen locker
    alacritty # terminal (niri default)
    fuzzel # app launcher (niri default)

    # Additional tools for enhanced experience
    playerctl # media control
    brightnessctl # brightness control
    pamixer # audio control
  ];
}
