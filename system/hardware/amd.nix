# /etc/nixos/system/hardware/amd.nix
# Consolidated AMD hardware configuration for RX 5600/5700 XT (Navi 10/RDNA1)
# Desktop-only configuration (fabio-nixos)

{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf (config.networking.hostName == "fabio-nixos") {
  # ========================================
  # Kernel Parameters - Consolidated from multiple files
  # ========================================
  boot.kernelParams = lib.mkAfter [
    # IOMMU Support (from performance.nix and rocm.nix)
    "amd_iommu=on"
    "iommu=pt"
    "clearcpuid=514"

    # Basic AMD GPU Support (from performance.nix)
    "amdgpu.si_support=1"
    "amdgpu.cik_support=1"

    # Advanced GPU Features (from rocm.nix and gaming.nix) - these override defaults
    "amdgpu.ppfeaturemask=0xffffffff" # Enable all AMD GPU features
    "amdgpu.exp_hw_support=1" # Large BAR support
    "amdgpu.gpu_recovery=1" # Enable GPU recovery for stability
  ];

  # ========================================
  # Kernel Modules - Consolidated
  # ========================================
  boot.kernelModules = [ "amdgpu" ];
  boot.initrd.kernelModules = [ "amdgpu" ]; # Early KMS loading

  # ========================================
  # Environment Variables - ROCm and Gaming
  # ========================================
  environment.sessionVariables = {
    # ROCm Variables (CRITICAL for RX 5600/5700 XT compatibility)
    HSA_OVERRIDE_GFX_VERSION = "10.3.0"; # Pretend to be RDNA2 for ROCm compatibility
    ROC_ENABLE_PRE_VEGA = "1"; # Enable ROCm on RDNA1 architecture

    # ROCm Paths
    ROCM_PATH = "${pkgs.rocmPackages.clr}";
    HIP_PATH = "${pkgs.rocmPackages.clr}";

    # HIP Platform Configuration
    HIP_PLATFORM = "amd";
    HIP_COMPILER = "clang";
    HIP_RUNTIME = "rocclr";

    # Device Visibility
    CUDA_VISIBLE_DEVICES = "0";
    HIP_VISIBLE_DEVICES = "0";

    # Performance Optimizations
    HSA_ENABLE_SDMA = "0"; # Disable SDMA for stability
    AMD_DIRECT_DISPATCH = "1"; # Enable direct dispatch

    # Gaming/Vulkan Variables
    AMD_VULKAN_ICD = "RADV"; # Use Mesa RADV driver
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/radeon_icd.i686.json";
    VK_LAYER_PATH = "/run/opengl-driver/share/vulkan/explicit_layer.d:/run/opengl-driver-32/share/vulkan/explicit_layer.d";

    # RADV Driver Optimizations
    RADV_DEBUG = "nongg"; # Disable NGG pipeline, zero VRAM on allocation
    MESA_VK_DEVICE_SELECT_FORCE_DEFAULT_DEVICE = "1";

    # OpenGL Performance
    __GL_THREADED_OPTIMIZATIONS = "1";
  };

  # ========================================
  # Hardware Graphics Configuration
  # ========================================
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for 32-bit games and applications

    extraPackages = with pkgs; [
      # AMD Vulkan drivers
      amdvlk
      vulkan-loader
      vulkan-tools

      # ROCm OpenCL support
      rocmPackages.clr.icd
    ];

    extraPackages32 = with pkgs.driversi686Linux; [
      amdvlk # 32-bit AMD Vulkan driver
    ];
  };

  # ========================================
  # AMD Hardware Optimizations
  # ========================================
  # Enable AMD GPU overdrive support
  hardware.amdgpu.overdrive.enable = true;

  # ========================================
  # udev Rules for AMD GPU
  # ========================================
  services.udev.extraRules = ''
    # ROCm device permissions
    KERNEL=="kfd", GROUP="render", MODE="0664"
    KERNEL=="renderD*", GROUP="render", MODE="0664"

    # AMD GPU specific access
    SUBSYSTEM=="drm", KERNEL=="renderD128", GROUP="render", MODE="0664"
  '';

  # ========================================
  # ROCm System Service
  # ========================================
  systemd.services.rocm-init = {
    description = "Initialize ROCm devices for AMD GPU";
    wantedBy = [ "multi-user.target" ];
    script = ''
      # Set permissions for ROCm devices
      if [ -e /dev/kfd ]; then
        ${pkgs.coreutils}/bin/chmod 666 /dev/kfd
      fi

      # Set render group permissions
      if [ -e /dev/dri/renderD128 ]; then
        ${pkgs.coreutils}/bin/chgrp render /dev/dri/renderD128
        ${pkgs.coreutils}/bin/chmod 664 /dev/dri/renderD128
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # ========================================
  # ROCm Tmpfiles
  # ========================================
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  # ========================================
  # System Limits for GPU Compute
  # ========================================
  security.pam.loginLimits = [
    {
      domain = "*";
      item = "memlock";
      type = "hard";
      value = "unlimited";
    }
    {
      domain = "*";
      item = "memlock";
      type = "soft";
      value = "unlimited";
    }
  ];

  # ========================================
  # User Groups for GPU Access
  # ========================================
  users.users.fabio.extraGroups = [ "render" ];
}
