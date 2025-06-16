# /etc/nixos/system/core/secrets.nix
# Secrets management with sops-nix

{ config, lib, pkgs, ... }:

{
  # Sops configuration
  sops = {
    defaultSopsFile = ./../../secrets/secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
  };
}
