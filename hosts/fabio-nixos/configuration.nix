# /etc/nixos/hosts/fabio-nixos/configuration.nix
# Desktop configuration - AMD gaming workstation

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # Hardware
    ./hardware-configuration.nix
    ../../modules/hardware/amd.nix
    
    # System modules
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
    
    # Environment (desktop)
    ../../modules/environment/hyprland.nix
    ../../modules/environment/audio.nix
    ../../modules/environment/fonts.nix
    ../../modules/environment/gaming.nix
    ../../modules/environment/apps.nix      # Common apps
    ../../modules/environment/desktop.nix   # Desktop-specific apps
    ../../modules/environment/theming.nix
    
    # Development environment
    ../../modules/development/languages.nix
    ../../modules/development/editors.nix
    ../../modules/development/shell.nix
    ../../modules/development/rocm.nix
    
    # Services
    ../../modules/services/openssh.nix
    ../../modules/services/filesystems.nix
    ../../modules/services/duckdns.nix
  ];

  # Machine identification
  networking.hostName = "fabio-nixos";

  # System state version
  system.stateVersion = "25.05";
}
