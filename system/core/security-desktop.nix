# /etc/nixos/system/core/security-desktop.nix
# Desktop-specific firewall rules (fabio-nixos)
{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Additional firewall rules for desktop services
  networking.firewall = {
    # Media server and service ports
    allowedTCPPorts = [
      # Media servers
      8096 # Jellyfin HTTP
      8920 # Jellyfin HTTPS
      8989 # Sonarr
      7878 # Radarr
      9696 # Prowlarr
      8181 # qBittorrent
      6767 # Bazarr

      # FTP for Switch game transfers
      21 # FTP control port for DBI
      20 # FTP data port (active mode)
    ];

    # Port ranges for desktop services
    allowedTCPPortRanges = [
      # Gaming - Steam
      {
        from = 27015;
        to = 27030;
      }
      {
        from = 27036;
        to = 27037;
      }
      # Gaming - Epic Games
      {
        from = 5795;
        to = 5847;
      }
      # Sunshine streaming
      {
        from = 47984;
        to = 48010;
      }
      # FTP passive mode
      {
        from = 40000;
        to = 40100;
      }
    ];

    # UDP port ranges for desktop services
    allowedUDPPortRanges = [
      # Gaming - Steam
      {
        from = 27000;
        to = 27100;
      }
      {
        from = 3478;
        to = 4380;
      }
      # Sunshine streaming
      {
        from = 47998;
        to = 48010;
      }
    ];
  };

  # Sunshine streaming service permissions
  services.udev.extraRules = ''
    # Allow access to DRM devices for video capture
    KERNEL=="card[0-9]*", GROUP="video", MODE="0664"
    KERNEL=="renderD[0-9]*", GROUP="render", MODE="0664"
    # Allow access to input devices for controller support
    KERNEL=="event[0-9]*", GROUP="input", MODE="0664"
    KERNEL=="js[0-9]*", GROUP="input", MODE="0664"
  '';
}
