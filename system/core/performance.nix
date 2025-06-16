# /etc/nixos/system/core/performance.nix
{ config, lib, pkgs, ... }:
{
  # SSD optimizations
  services.fstrim.enable = true;
  
  # Optimize for desktop workload (desktop gets performance, laptop will override)
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  
  # Memory optimization (laptop can override)
  boot.kernel.sysctl = {
    "vm.swappiness" = lib.mkDefault 10;
    "vm.vfs_cache_pressure" = lib.mkDefault 50;
  };
  
  # AMD GPU settings moved to system/hardware/amd.nix
  
  # Performance packages are in monitoring.nix (iotop, etc.)
}
