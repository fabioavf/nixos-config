# /etc/nixos/modules/interface/tui/editors.nix
# Text editors and terminal applications

{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Modern editors
    zed-editor          # Modern editor
    neovim              # Terminal editor
    vscode              # GUI editor (but commonly used with terminal workflow)
    
    # Terminal
    alacritty           # Modern terminal emulator
  ];
}