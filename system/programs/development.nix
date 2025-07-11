# /etc/nixos/system/programs/development.nix
# System-wide development tools and dependencies

{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    # ========================================
    # System-wide Development Dependencies
    # ========================================
    gcc                     # C/C++ compiler (system dependency)
    openssl                 # Cryptographic library (system dependency)

    # ========================================
    # System-level Network Tools
    # ========================================
    wget                    # Basic download tool
    curl                    # HTTP client
    rsync                   # File synchronization

    gh                      # GitHub CLI

    # ========================================
    # Container Runtime (System Service)
    # ========================================
    docker                  # Container runtime
    docker-compose          # Container orchestration
  ];

  virtualisation.docker.enable = true;
}
