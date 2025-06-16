# /hosts/fabio-macbook/configuration.nix
# MacBook configuration

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # Hardware
    ./hardware-configuration.nix
    ../../modules/hardware/macbook-audio.nix
    
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
    
    # Interface modules (laptop/portable)
    ../../modules/interface/tui/default.nix  # Terminal tools
    ../../modules/interface/gui/default.nix  # GUI apps
    ../../modules/interface/wm/niri/default.nix  # Niri window manager
    # Note: Skipping desktop-heavy.nix for laptop
    
    # Environment (system-wide)
    ../../modules/environment/audio.nix
    ../../modules/environment/fonts.nix
    ../../modules/environment/theming.nix
    # Note: Skipping gaming.nix for laptop
    
    # Development environment
    ../../modules/interface/tui/editors.nix
    ../../modules/development/shell.nix
    # Note: Skipping rocm.nix for laptop (AMD-specific)
    
    # Services
    ../../modules/services/openssh.nix
    ../../modules/services/filesystems.nix
    # Note: Skipping duckdns.nix for laptop
  ];

  # Machine identification
  networking.hostName = "fabio-macbook";

  # MacBook-specific hardware optimizations
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      libvdpau-va-gl
    ];
  };

  # MacBook-specific kernel optimizations
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
  };

  # Install git globally for root user
  environment.systemPackages = with pkgs; [
    git
  ];

  # System state version
  system.stateVersion = "25.05";
}