# /etc/nixos/system/programs/development.nix
# Development tools and terminal utilities

{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    # ========================================
    # Editors and Terminal
    # ========================================
    zed-editor          # Modern editor
    neovim              # Terminal editor
    vscode              # GUI editor
    alacritty           # Modern terminal emulator
    
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
    
    # Custom packages
    inputs.self.packages.x86_64-linux.claude-code
    
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
