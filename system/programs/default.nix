# /etc/nixos/system/programs/default.nix
# System-wide program configurations

{ config, lib, pkgs, ... }:

{
  imports = [
    ./fonts.nix
    ./audio.nix
    ./gaming.nix
    ./theming.nix
  ];

  programs = {
    # make HM-managed GTK stuff work
    dconf.enable = true;
    seahorse.enable = true;
    adb.enable = true;
  };
  
  services.udev.packages = [pkgs.android-udev-rules];
}
