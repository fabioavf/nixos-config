# /etc/nixos/system/programs/development.nix
# System-wide development tools and dependencies

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    # ========================================
    # System-wide Development Dependencies
    # ========================================
    gcc # C/C++ compiler (system dependency)
    openssl # Cryptographic library (system dependency)
    cargo
    rustup
    rustc
    pkg-config
    uv
    yarn
    openjdk
    nixd

    # ========================================
    # System-level Network Tools
    # ========================================
    wget # Basic download tool
    curl # HTTP client
    rsync # File synchronization
    nmap
    simple-mtpfs
    libmtp

    gh # GitHub CLI

    # Claude Code
    claude-code

    # ========================================
    # Container Runtime (System Service)
    # ========================================
    docker # Container runtime
    docker-compose # Container orchestration
  ];

  programs.nix-ld = {
    enable = true;
  };

  virtualisation.docker.enable = true;
}
