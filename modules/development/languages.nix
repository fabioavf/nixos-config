# /etc/nixos/modules/development/languages.nix
# Programming languages and development tools

{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # System development
    gcc
    
    # JavaScript/TypeScript
    nodejs
    bun
    
    # Python
    pyenv
    
    # Rust
    rustc
    cargo
  ];
}
