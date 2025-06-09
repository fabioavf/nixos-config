# /etc/nixos/configuration.nix
# Main configuration file - imports only

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # Hardware
    ./hardware-configuration.nix
    
    # System modules
    ./modules/system/boot.nix
    ./modules/system/networking.nix
    ./modules/system/locale.nix
    ./modules/system/nix.nix
    ./modules/system/users.nix
    
    # Desktop environment
    ./modules/desktop/hyprland.nix
    ./modules/desktop/audio.nix
    ./modules/desktop/fonts.nix
    ./modules/desktop/apps.nix
    ./modules/desktop/theming.nix  # Add theming module
    
    # Development environment
    ./modules/development/languages.nix
    ./modules/development/editors.nix
    ./modules/development/shell.nix
    
    # Services
    ./modules/services/openssh.nix
    ./modules/services/filesystems.nix
  ];

  # System state version
  system.stateVersion = "25.05";
}
