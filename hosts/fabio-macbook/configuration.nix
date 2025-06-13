# /etc/nixos/hosts/fabio-macbook/configuration.nix
# MacBook Pro 13" 2017 configuration - lightweight and battery-optimized

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # Hardware
    ./hardware-configuration.nix
    ../../modules/hardware/intel-mac.nix
    
    # System modules (shared)
    ../../modules/system/boot.nix
    ../../modules/system/networking.nix
    ../../modules/system/locale.nix
    ../../modules/system/nix.nix
    ../../modules/system/users.nix
    ../../modules/system/security.nix
    ../../modules/system/monitoring.nix
    ../../modules/system/performance.nix
    ../../modules/system/secrets.nix
    ../../modules/system/home-manager.nix
    
    # Environment (laptop)
    ../../modules/environment/hyprland.nix
    ../../modules/environment/audio.nix
    ../../modules/environment/fonts.nix
    ../../modules/environment/theming.nix
    ../../modules/environment/apps.nix      # Common apps
    ../../modules/environment/laptop.nix    # MacBook-specific apps
    
    # NOTE: No gaming.nix - only moonlight-qt in laptop.nix
    # NOTE: No desktop.nix - heavy desktop apps excluded
    
    # Development environment (shared)
    ../../modules/development/languages.nix
    ../../modules/development/editors.nix
    ../../modules/development/shell.nix
    
    # NOTE: No rocm.nix - Intel graphics only
    
    # Services (minimal)
    ../../modules/services/openssh.nix
    
    # NOTE: No duckdns.nix - desktop only
    # NOTE: No filesystems.nix - no additional drives on MacBook
  ];

  # Machine identification
  networking.hostName = "fabio-macbook";

  # System state version
  system.stateVersion = "25.05";
}