# Media services configuration - Desktop only
# Jellyfin media server with automated torrent management

{ config, lib, pkgs, ... }:

lib.mkIf (config.networking.hostName == "fabio-nixos") {
  # Create media system user and group
  users.groups.media = {
    gid = 993;
  };
  
  users.users.media = {
    isSystemUser = true;
    uid = 993;
    group = "media";
    extraGroups = [ "video" "render" "audio" ];
    home = "/var/lib/media";
    createHome = true;
  };

  # Media directory structure
  systemd.tmpfiles.rules = [
    "d /mnt/hd/media 0755 media media -"
    "d /mnt/hd/media/tv 0755 media media -"
    "d /mnt/hd/media/movies 0755 media media -"
    "d /mnt/hd/media/downloads 0755 media media -"
    "d /mnt/hd/media/downloads/complete 0755 media media -"
    "d /mnt/hd/media/downloads/incomplete 0755 media media -"
    "d /mnt/hd/media/torrents 0755 media media -"
    "d /var/lib/jellyfin 0755 media media -"
    "d /var/lib/sonarr 0755 media media -"
    "d /var/lib/radarr 0755 media media -"
    "d /var/lib/prowlarr 0755 media media -"
    "d /var/lib/bazarr 0755 media media -"
    "d /var/lib/qbittorrent 0755 media media -"
  ];

  # Jellyfin media server
  services.jellyfin = {
    enable = true;
    user = "media";
    group = "media";
    dataDir = "/var/lib/jellyfin";
    configDir = "/var/lib/jellyfin/config";
    logDir = "/var/lib/jellyfin/log";
    cacheDir = "/var/lib/jellyfin/cache";
    openFirewall = false; # We'll handle firewall manually
  };

  # Hardware transcoding support for AMD GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
      mesa.drivers
      amdvlk
    ];
  };

  # Sonarr for TV series automation
  services.sonarr = {
    enable = true;
    user = "media";
    group = "media";
    dataDir = "/var/lib/sonarr";
    openFirewall = false;
  };

  # Radarr for movies automation
  services.radarr = {
    enable = true;
    user = "media";
    group = "media";
    dataDir = "/var/lib/radarr";
    openFirewall = false;
  };

  # Prowlarr for indexer management
  services.prowlarr = {
    enable = true;
    openFirewall = false;
  };

  # Bazarr for subtitle automation
  services.bazarr = {
    enable = true;
    user = "media";
    group = "media";
    openFirewall = false;
  };

  # qBittorrent torrent client (manual systemd service)
  systemd.services.qbittorrent-nox = {
    description = "qBittorrent headless torrent client";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "forking";
      User = "media";
      Group = "media";
      ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox --daemon --webui-port=8080";
      Restart = "on-failure";
      RestartSec = 5;
      
      # Security settings
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ "/var/lib/qbittorrent" "/mnt/hd/media" ];
      
      # Working directory
      WorkingDirectory = "/var/lib/qbittorrent";
    };
  };

  # Additional packages for media processing
  environment.systemPackages = with pkgs; [
    mediainfo
    ffmpeg
    unrar
    p7zip
    qbittorrent-nox
  ];

  # Systemd service dependencies and ordering
  systemd.services.jellyfin.after = [ "network.target" ];
  systemd.services.sonarr.after = [ "network.target" ];
  systemd.services.radarr.after = [ "network.target" ];
  systemd.services.prowlarr.after = [ "network.target" ];
  systemd.services.bazarr.after = [ "network.target" "sonarr.service" "radarr.service" ];

  # Ensure services start on boot (qbittorrent-nox already has wantedBy in its definition)
  systemd.services.jellyfin.wantedBy = [ "multi-user.target" ];
  systemd.services.sonarr.wantedBy = [ "multi-user.target" ];
  systemd.services.radarr.wantedBy = [ "multi-user.target" ];
  systemd.services.prowlarr.wantedBy = [ "multi-user.target" ];
  systemd.services.bazarr.wantedBy = [ "multi-user.target" ];
}