# /etc/nixos/system/default.nix
# Platform-specific module organization

let
  # Common modules for all systems
  common = [
    # Core system functionality
    ./core/boot.nix
    ./core/locale.nix
    ./core/nix.nix
    ./core/users.nix
    ./core/security.nix
    ./core/monitoring.nix
    ./core/performance.nix
    ./core/secrets.nix
    ./core/home-manager.nix
    ./core/xkb-cedilla.nix

    # Network (common to all)
    ./network/default.nix

    # Programs (common to all)
    ./programs
    ./programs/fonts.nix
    ./programs/audio.nix
    ./programs/theming.nix
    ./programs/gui.nix
    ./programs/development.nix

    # Services (common to all)
    ./services
    ./services/openssh.nix
  ];

  # Desktop-specific modules (fabio-nixos)
  desktop = common ++ [
    # Desktop hardware
    ./hardware/amd.nix

    # Desktop-specific programs
    ./programs/gaming.nix
    ./programs/desktop-heavy.nix

    # Desktop-specific services
    ./services/filesystems.nix
    ./services/duckdns.nix
  ];

  # Laptop-specific modules (fabio-macbook)
  laptop = common ++ [
    # MacBook hardware
    ./hardware/macbook-audio.nix
    ./programs/bluetooth.nix
    ./hardware/intel-graphics.nix
    
    # No gaming, desktop-heavy apps, filesystem mounts, or DuckDNS for laptop
  ];
in {
  inherit desktop laptop;
}
