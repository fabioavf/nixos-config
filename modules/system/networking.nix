# /etc/nixos/modules/system/networking.nix
# Networking configuration

{ config, lib, pkgs, ... }:

{
  networking = {
    hostName = "fabio-nixos";
    networkmanager.enable = true;
  };
}
