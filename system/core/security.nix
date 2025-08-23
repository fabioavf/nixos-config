# /etc/nixos/system/core/security.nix
{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Enable firewall with comprehensive port configuration
  networking.firewall = {
    enable = true;
    # Allow SSH and media services ports
    allowedTCPPorts = [
      22
      55443
    ]
    ++ (lib.optionals (config.networking.hostName == "fabio-nixos") [
      8096 # Jellyfin HTTP
      8920 # Jellyfin HTTPS
      8989 # Sonarr
      7878 # Radarr
      9696 # Prowlarr
      8181 # qBittorrent
      6767 # Bazarr
    ]);
    # Gaming and streaming ports
    allowedTCPPortRanges = [
      # Steam
      {
        from = 27015;
        to = 27030;
      }
      {
        from = 27036;
        to = 27037;
      }
      # Epic Games
      {
        from = 5795;
        to = 5847;
      }
      # Sunshine streaming
      {
        from = 47984;
        to = 48010;
      } # Sunshine HTTPS and Web UI
    ];
    allowedUDPPortRanges = [
      # Steam
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
      } # Sunshine video/audio streaming
    ];
    # Allow ping
    allowPing = true;
  };

  # Additional firewall management tools
  environment.systemPackages = with pkgs; [
    iptables # Direct iptables management
  ];

  # Fail2ban for SSH protection
  services.fail2ban = {
    enable = true;
    bantime = "24h";
    bantime-increment.enable = true;
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
