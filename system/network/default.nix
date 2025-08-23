# /etc/nixos/system/network/default.nix
# Networking configuration

{
  config,
  lib,
  pkgs,
  ...
}:

{
  networking = {
    # hostName is set in each host's configuration.nix
    networkmanager.enable = true;
  };

  services.avahi.enable = true;
}
