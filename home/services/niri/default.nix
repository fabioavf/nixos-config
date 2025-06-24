# /etc/nixos/home/services/niri/default.nix
# Niri window manager configuration entry point

{ inputs, ... }:

{
  imports = [
    inputs.niri.homeModules.niri
    ./packages.nix
    ./config.nix
    ./input.nix
    ./outputs.nix
    ./layout.nix
    ./keybinds.nix
    ./rules.nix
    ./quickshell.nix
  ];

  # Enable niri
  programs.niri.enable = true;
}
