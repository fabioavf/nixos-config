# /etc/nixos/hosts/fabio-macbook/configuration.nix
# MacBook configuration - Intel laptop

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # Hardware
    ./hardware-configuration.nix
  ];

  # Machine identification
  networking.hostName = "fabio-macbook";

  # Install git globally for root user and custom packages
  environment.systemPackages = with pkgs; [
    git
    # Flake packages (MacBook)
    inputs.quickshell.packages.x86_64-linux.default
    inputs.claude-desktop.packages.x86_64-linux.default
    # Custom packages (claude-code available on laptop too)
    inputs.self.packages.x86_64-linux.claude-code
    # MacBook audio driver
    inputs.self.packages.x86_64-linux.snd-hda-macbookpro
  ];

  # System state version
  system.stateVersion = "25.05";
}
