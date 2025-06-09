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
  
  # Add Flatpak desktop files to XDG paths so launchers can find them
  environment.sessionVariables = {
    XDG_DATA_DIRS = [
      "/var/lib/flatpak/exports/share"
      "/home/fabio/.local/share/flatpak/exports/share"
    ];
  };
  
  # CoreCtrl configuration for AMD GPU control
  programs.corectrl.enable = true;
  hardware.amdgpu.overdrive.enable = true;  # Updated option name
  
  # Add user to corectrl group
  users.users.fabio.extraGroups = [ "corectrl" ];
}
