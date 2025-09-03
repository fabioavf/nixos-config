# /etc/nixos/system/hardware/amd-laptop.nix
# AMD laptop configuration for Ryzen 7 7730U with integrated graphics
# Vivobook-specific configuration (fabio-vivobook)

{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf (config.networking.hostName == "fabio-vivobook") {
  # ========================================
  # AMD Laptop CPU Configuration
  # ========================================
  boot.kernelParams = [
    # AMD laptop optimizations
    "amd_pstate=guided" # Use AMD P-State driver for better power management
    "amdgpu.si_support=1"
    "amdgpu.cik_support=1"
  ];

  # ========================================
  # Kernel Modules for AMD Laptop
  # ========================================
  boot.kernelModules = [
    "amdgpu"
    "kvm-amd"
  ];
  boot.initrd.kernelModules = [ "amdgpu" ];

  # ========================================
  # AMD Integrated Graphics Configuration
  # ========================================
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # For compatibility

    extraPackages = with pkgs; [
      # AMD integrated graphics drivers
      mesa
      vulkan-loader
      vulkan-tools
      amdvlk
      # VAAPI support for hardware video acceleration
      libva
      mesa
    ];

    extraPackages32 = with pkgs.driversi686Linux; [
      mesa
      amdvlk
    ];
  };

  # ========================================
  # Power Management for Laptop
  # ========================================
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil"; # Better for modern AMD
  };

  # ========================================
  # AMD Graphics Environment Variables
  # ========================================
  environment.sessionVariables = {
    # Use RADV (Mesa) driver for Vulkan
    AMD_VULKAN_ICD = "RADV";
    # Hardware video acceleration
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";
  };

  # ========================================
  # Laptop-specific Hardware Support
  # ========================================
  services.thermald.enable = true; # Thermal management
  services.auto-cpufreq.enable = true; # Automatic CPU frequency scaling

  # ========================================
  # AMD Laptop Performance Tuning
  # ========================================
  boot.kernel.sysctl = {
    # Laptop battery optimizations
    "vm.laptop_mode" = 5;
    "vm.swappiness" = 1; # Lower swappiness for SSD longevity
  };

  # ========================================
  # User Groups for Graphics Access
  # ========================================
  users.users.fabio.extraGroups = [
    "video"
    "render"
  ];
}
