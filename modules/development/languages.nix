# /etc/nixos/modules/development/languages.nix
# Programming languages and development tools

{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Version control
    gh            # GitHub CLI
    git-lfs       # Large file support
    glab          # GitLab CLI

    # Containers (if needed)
    docker
    docker-compose

    # System development
    gcc
    
    # JavaScript/TypeScript
    nodejs
    bun
    
    # Node2nix for generating Nix packages from npm
    nodePackages.node2nix
    
    # Claude Code (custom package)
    claude-code
    
    # Python
    pyenv
    
    # Rust
    rustc
    cargo
  ];
}
