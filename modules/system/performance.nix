# /etc/nixos/modules/system/performance.nix
{ config, lib, pkgs, ... }:
{
  # SSD optimizations
  services.fstrim.enable = true;
  
  # Optimize for desktop workload
  powerManagement.cpuFreqGovernor = "performance"; # or "ondemand"
  
  # Memory optimization
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
  };
  
  # AMD GPU specific
  boot.kernelParams = [
    "amd_iommu=on"
    "amdgpu.si_support=1"
    "amdgpu.cik_support=1"
  ];
  
  # Performance packages are in monitoring.nix (iotop, etc.)
}
