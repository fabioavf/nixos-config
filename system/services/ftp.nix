# /etc/nixos/system/services/ftp.nix
# FTP server for transferring Switch games to CFW Switch running DBI
{
  config,
  lib,
  pkgs,
  ...
}:
{
  # vsftpd - Very Secure FTP Daemon
  services.vsftpd = {
    enable = true;

    # Security settings
    forceLocalLoginsSSL = false; # DBI doesn't support SSL
    forceLocalDataSSL = false;

    # Allow anonymous access (read-only) - DBI often uses anonymous
    anonymousUser = true;
    anonymousUploadEnable = false;
    anonymousMkdirEnable = false;
    anonymousUmask = "077";

    # Local user settings (if you prefer authenticated access)
    localUsers = true;
    writeEnable = false; # Read-only for safety

    # Directory settings
    chrootlocalUser = true;

    # Connection settings
    allowWriteableChroot = false;

    # Custom configuration for DBI compatibility
    extraConfig = ''
      # Enable anonymous access
      anonymous_enable=YES
      anon_other_write_enable=NO

      # Basic settings
      listen=YES
      listen_ipv6=NO

      # Directory listing settings
      dirmessage_enable=YES
      use_localtime=YES
      xferlog_enable=YES
      connect_from_port_20=YES

      # Performance settings
      idle_session_timeout=600
      data_connection_timeout=120

      # Security settings
      ascii_upload_enable=NO
      ascii_download_enable=NO

      # Anonymous root directory
      anon_root=/mnt/hd/Emuladores/NSW

      # Allow browsing
      dirlist_enable=YES
      download_enable=YES

      # Passive mode configuration (important for DBI)
      pasv_enable=YES
      pasv_min_port=40000
      pasv_max_port=40100
      pasv_promiscuous=YES

      # Port 20 needs to be used for active mode
      port_enable=YES

      # Logging
      xferlog_file=/var/log/vsftpd.log
      log_ftp_protocol=YES

      # Hide dot files
      hide_file={.*}

      # Set max clients
      max_clients=10
      max_per_ip=5

      # Banner
      ftpd_banner=Switch Game Server - DBI Compatible
    '';
  };

  # Create FTP user for authenticated access (optional)
  users.users.ftpuser = {
    isNormalUser = false;
    isSystemUser = true;
    group = "ftpusers";
    home = "/mnt/hd/Emuladores/NSW";
    shell = pkgs.bash;
    createHome = false;
  };

  users.groups.ftpusers = { };

  # Ensure the NSW directory exists and has proper permissions
  systemd.tmpfiles.rules = [
    "d /mnt/hd/Emuladores/NSW 0755 nobody nogroup - -"
  ];
}
