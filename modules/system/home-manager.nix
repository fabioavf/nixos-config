# /etc/nixos/modules/system/home-manager.nix
# Home Manager integration for user configuration

{ config, lib, pkgs, ... }:

{
  # Home Manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.fabio = import ../users/fabio.nix;
  };
}