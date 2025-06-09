# /etc/nixos/modules/services/filesystems.nix
# Filesystem mounts and configuration

{ config, lib, pkgs, ... }:

{
  # Mount your data partition
  fileSystems."/data" = {
    device = "/dev/nvme0n1p3";
    fsType = "ext4";
    options = [ "defaults" "user" "rw" ];
  };
  
  # Optional: Mount backup drive with UUID (more reliable)
  # fileSystems."/backup" = {
  #   device = "/dev/disk/by-uuid/YOUR-BACKUP-UUID";
  #   fsType = "ext4";
  #   options = [ "defaults" "user" "rw" "noauto" ];
  # };
}
