# /etc/nixos/modules/services/filesystems.nix
# Filesystem mounts and configuration
# Desktop-only mounts (fabio-nixos)

{ config, lib, pkgs, ... }:

lib.mkIf (config.networking.hostName == "fabio-nixos") {
  # Enable udisks2 for disk management (required for GNOME Disks)
  services.udisks2.enable = true;
  
  # Mount your data partition
  fileSystems."/data" = {
    device = "/dev/nvme0n1p3";
    fsType = "ext4";
    options = [ "defaults" "user" "rw" ];
  };
  
  # Mount sdb1 drive with UUID (more reliable than device path)
  fileSystems."/mnt/hd" = {
    device = "/dev/disk/by-uuid/c997d32a-3a0d-43c7-b0b5-1a7ed6fcaa29";
    fsType = "ext4";
    options = [ "defaults" "user" "rw" ];
  };
}
