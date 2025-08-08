# /etc/nixos/system/services/default.nix
# System services configuration

{ config, lib, pkgs, ... }:

{
  imports = [
    ./openssh.nix
    ./filesystems.nix
    ./duckdns.nix
    ./media.nix
  ];
}
