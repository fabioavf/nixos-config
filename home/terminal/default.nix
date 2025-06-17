# /etc/nixos/home/terminal/default.nix
# Terminal tools, CLI utilities, and development environment

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./alacritty.nix
  ];
  # Terminal and development packages for user-level management
  home.packages = with pkgs; [
    # ========================================
    # Editors and Terminal (User Preference)
    # ========================================
    zed-editor              # Modern editor
    neovim                  # Terminal editor
    vscode                  # GUI editor
    ghostty
    # alacritty             # Now managed by Home Manager in alacritty.nix

    # ========================================
    # File Management (Terminal)
    # ========================================
    ranger                  # Terminal file manager
    fd                      # Better find
    ripgrep                 # Better grep

    # ========================================
    # Network and Download Tools (User-level)
    # ========================================
    aria2                   # Multi-connection downloader
    sshfs                   # Mount remote filesystems

    # ========================================
    # Development Tools (User-specific)
    # ========================================
    # Version control
    gh                      # GitHub CLI
    git-lfs                 # Large file support
    glab                    # GitLab CLI

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

    # Custom packages
    inputs.self.packages.x86_64-linux.claude-code
  ];
}
