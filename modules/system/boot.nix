# /etc/nixos/modules/system/boot.nix
# Boot configuration

{ config, lib, pkgs, ... }:

{
  # Use the systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Plymouth boot splash
  boot.plymouth = {
    enable = true;
    theme = "breeze";  # Options: "breeze", "bgrt", "details", "fade-in", "glow", "script", "solar", "spinfinity", "spinner", "text", "tribar"
  };
  
  # Kernel parameters for smooth boot
  boot.kernelParams = [
    "quiet"           # Suppress most boot messages
    "splash"          # Enable splash screen
    "rd.systemd.show_status=false"  # Hide systemd status
    "rd.udev.log_level=3"           # Reduce udev log level
    "udev.log_priority=3"           # Reduce udev log priority
  ];
  
  # AMD GPU early KMS loading moved to modules/hardware/amd.nix
  
  # Uncomment to use LTS kernel
  # boot.kernelPackages = pkgs.linuxPackages_lts;
}
