# /etc/nixos/modules/development/editors.nix
# Text editors and IDEs

{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Modern editors
    zed-editor
    neovim
    
    # Terminal
    alacritty
  ];
}
