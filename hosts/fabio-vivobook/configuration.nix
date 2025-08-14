# /etc/nixos/hosts/fabio-vivobook/configuration.nix
# Vivobook configuration - AMD Ryzen development laptop

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # Hardware
    ./hardware-configuration.nix
  ];

  # Machine identification
  networking.hostName = "fabio-vivobook";

  # Install git globally for root user and custom packages
  environment.systemPackages = with pkgs; [
    git
    # Flake packages (Vivobook)
    # inputs.claude-desktop.packages.x86_64-linux.default
  ];

  # System state version
  system.stateVersion = "25.05";
}
