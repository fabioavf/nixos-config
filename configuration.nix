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
    ./modules/system/security.nix
    ./modules/system/monitoring.nix
    ./modules/system/performance.nix
    
    # Desktop environment
    ./modules/desktop/hyprland.nix
    ./modules/desktop/audio.nix
    ./modules/desktop/fonts.nix
    ./modules/desktop/gaming.nix
    ./modules/desktop/apps.nix
    ./modules/desktop/theming.nix
    
    # Development environment
    ./modules/development/languages.nix
    ./modules/development/editors.nix
    ./modules/development/shell.nix
    ./modules/development/rocm.nix
    
    # Services
    ./modules/services/openssh.nix
    ./modules/services/filesystems.nix
    ./modules/services/duckdns.nix
  ];

  # Sops configuration
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
  };

  # System state version
  system.stateVersion = "25.05";
}
