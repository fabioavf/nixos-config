# /etc/nixos/modules/system/secrets.nix
# Secrets management with sops-nix

{ config, lib, pkgs, ... }:

{
  # Sops configuration
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
  };
}