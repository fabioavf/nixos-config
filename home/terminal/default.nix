# /etc/nixos/home/terminal/default.nix
# Terminal tools and CLI utilities

{ config, lib, pkgs, ... }:

{
  # Terminal packages that are better managed at user level
  home.packages = with pkgs; [
    # ========================================
    # File Management (Terminal)
    # ========================================
    ranger              # Terminal file manager
    fd                  # Better find
    ripgrep             # Better grep
    
    # ========================================
    # Network and Download Tools (Terminal)
    # ========================================
    wget
    curl
    aria2               # Multi-connection downloader
    rsync               # File synchronization
    sshfs               # Mount remote filesystems
    
    # ========================================
    # Development Tools (Terminal)
    # ========================================
    # Version control
    gh                  # GitHub CLI
    git-lfs             # Large file support
    glab                # GitLab CLI
    
    # System development
    gcc
    openssl
    
    # JavaScript/TypeScript
    nodejs
    bun
    
    # Node2nix for generating Nix packages from npm
    nodePackages.node2nix
    
    # Python
    pyenv
    
    # Rust
    rustc
    cargo
    
    # Containers (if needed)
    docker
    docker-compose
  ];
}
