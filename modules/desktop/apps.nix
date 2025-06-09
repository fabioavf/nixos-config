# /etc/nixos/modules/desktop/apps.nix
# Desktop applications

{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # File manager
    nautilus
    
    # Communication
    discord
    
    # Media
    spotify
    
    # Productivity
    qbittorrent
    
    # System monitoring and control
    corectrl              # AMD GPU control
    
    # Qt support for applications
    qt6.qt5compat
    libsForQt5.qt5.qtgraphicaleffects
    kdePackages.qt5compat
  ];
  
  # Enable Flatpak
  services.flatpak.enable = true;
}
