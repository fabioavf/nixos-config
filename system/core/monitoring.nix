# /etc/nixos/system/core/monitoring.nix
{
  pkgs,
  ...
}:
{
  # System metrics and logs
  services.journald.extraConfig = ''
    SystemMaxUse=1G
    MaxRetentionSec=7day
  '';

  # Automatic updates for security patches
  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
    allowReboot = false; # Set to true if you want automatic reboots
  };

  environment.systemPackages = with pkgs; [
    btop # Better htop
    iotop # I/O monitoring
    nethogs # Network monitoring per process
    ncdu # Disk usage analyzer
    bandwhich # Network utilization per process
  ];
}
