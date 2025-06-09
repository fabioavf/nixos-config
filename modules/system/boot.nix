# /etc/nixos/modules/system/boot.nix
# Boot configuration

{ config, lib, pkgs, ... }:

{
  # Use the systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Uncomment to use LTS kernel
  # boot.kernelPackages = pkgs.linuxPackages_lts;
}
