# /etc/nixos/home/terminal/default.nix
# Terminal tools, CLI utilities, and development environment

{ pkgs, inputs, ... }:

{
  imports = [
    ./alacritty.nix
  ];
  # Terminal and development packages for user-level management
  home.packages = with pkgs; [
    # ========================================
    # Editors and Terminal (User Preference)
    # ========================================
    zed-editor # Modern editor
    neovim # Terminal editor
    vscode # GUI editor

    # ========================================
    # File Management (Terminal)
    # ========================================
    ranger # Terminal file manager
    fd # Better find
    ripgrep # Better grep
    gtop
    gotop

    # ========================================
    # Network and Download Tools (User-level)
    # ========================================
    aria2 # Multi-connection downloader
    sshfs # Mount remote filesystems

    # ========================================
    # Development Tools (User-specific)
    # ========================================
    # Version control
    git-lfs # Large file support
    glab # GitLab CLI

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

    # Nix
    nil
    nixfmt-rfc-style

    # Qt support
    kdePackages.qtdeclarative

    # Custom packages
    inputs.self.packages.x86_64-linux.claude-code
  ];
}
