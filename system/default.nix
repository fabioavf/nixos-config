let
  desktop = [
    ./core/boot.nix
    ./core/locale.nix
    ./core/nix.nix
    ./core/users.nix
    ./core/security.nix
    ./core/monitoring.nix
    ./core/performance.nix
    ./core/secrets.nix
    ./core/home-manager.nix

    ./hardware/amd.nix

    ./network/default.nix

    ./programs
    ./programs/fonts.nix
    ./programs/audio.nix
    ./programs/gaming.nix
    ./programs/theming.nix

    ./services
    ./services/openssh.nix
    ./services/filesystems.nix
    ./services/duckdns.nix
  ];

  laptop =
    desktop
    ++ [
      ./hardware/macbook-audio.nix
    ];
in {
  inherit desktop laptop;
}
