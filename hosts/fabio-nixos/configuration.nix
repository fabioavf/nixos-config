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
    
    # Interface modules (desktop)
    ../../modules/interface/tui/default.nix  # Terminal tools
    ../../modules/interface/gui/default.nix  # GUI apps
    ../../modules/interface/gui/desktop-heavy.nix  # Desktop-specific apps  
    ../../modules/interface/wm/hyprland/default.nix  # Window manager
    
    # Environment (system-wide)
    ../../modules/environment/audio.nix
    ../../modules/environment/fonts.nix
    ../../modules/environment/gaming.nix
    ../../modules/environment/theming.nix
    
    # Development environment
    ../../modules/interface/tui/editors.nix
    ../../modules/development/shell.nix
    ../../modules/development/rocm.nix
    
    # Services
    ../../modules/services/openssh.nix
    ../../modules/services/filesystems.nix
    ../../modules/services/duckdns.nix
  ];

  # Machine identification
  networking.hostName = "fabio-nixos";

  # Install git globally for root user
  environment.systemPackages = with pkgs; [
    git
  ];

  # System state version
  system.stateVersion = "25.05";
}
