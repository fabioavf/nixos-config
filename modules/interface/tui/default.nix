# /etc/nixos/modules/interface/tui/default.nix
# Common terminal-based tools and utilities

{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
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
    
    # Claude Code (custom package)
    claude-code
    
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