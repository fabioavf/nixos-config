# /etc/nixos/modules/development/rocm.nix
# ROCm (Radeon Open Compute) support for AMD RX 5600/5700 XT
# Enables machine learning, compute workloads, and GPU development
# Updated with actual available packages in nixpkgs

{ config, lib, pkgs, ... }:

{
  # Enable ROCm support
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  # ROCm packages and tools (CORRECTED - only existing packages)
  environment.systemPackages = with pkgs; [
    # Core ROCm packages
    rocmPackages.clr               # Compute Language Runtime (replaces rocm-runtime)
    rocmPackages.hip-common        # HIP common files
    rocmPackages.hipcc             # HIP compiler
    
    # ROCm utilities and info tools
    rocmPackages.rocminfo          # ROCm system info tool
    rocmPackages.rocm-smi          # System management interface
    
    # Math libraries
    rocmPackages.rocblas           # Basic Linear Algebra Subprograms
    rocmPackages.hipblas           # HIP BLAS
    rocmPackages.rocfft            # Fast Fourier Transform
    rocmPackages.hipfft            # HIP FFT
    rocmPackages.rocsolver         # Linear algebra solvers
    rocmPackages.hipsolver         # HIP solver
    rocmPackages.rocrand           # Random number generation
    rocmPackages.hiprand           # HIP random
    rocmPackages.rocsparse         # Sparse matrix operations
    rocmPackages.hipsparse         # HIP sparse
    rocmPackages.rocprim           # Primitive operations
    rocmPackages.hipcub            # HIP CUB
    rocmPackages.rocthrust         # ROC Thrust
    
    # Development and profiling tools
    rocmPackages.hipify            # CUDA to HIP conversion
    rocmPackages.roctracer         # ROCm tracer
    rocmPackages.rocprofiler       # ROCm profiler
    
    # Machine Learning libraries
    rocmPackages.miopen            # Deep learning primitives
    rocmPackages.migraphx          # Graph optimization engine
    
    # Additional ROCm tools
    rocmPackages.half              # Half precision library
    rocmPackages.tensile           # Tensor contraction library
    
    # Utilities
    clinfo                         # OpenCL info tool
    opencl-headers                 # OpenCL development headers
  ];

  # Hardware configuration for ROCm
  hardware.graphics = {
    extraPackages = with pkgs; [
      # ROCm OpenCL ICD
      rocmPackages.clr.icd
    ];
  };

  # Environment variables for ROCm on Navi 10 (RX 5600/5700 XT)
  environment.sessionVariables = {
    # CRITICAL: Override GPU version for Navi 10 (gfx1010) compatibility
    # This makes ROCm think you have a supported GPU
    HSA_OVERRIDE_GFX_VERSION = "10.3.0";  # Pretend to be RDNA2 (RX 6000 series)
    
    # ROCm paths
    ROCM_PATH = "${pkgs.rocmPackages.clr}";
    HIP_PATH = "${pkgs.rocmPackages.clr}";
    
    # HIP platform
    HIP_PLATFORM = "amd";
    HIP_COMPILER = "clang";
    HIP_RUNTIME = "rocclr";
    
    # Device visibility
    CUDA_VISIBLE_DEVICES = "0";           # For CUDA-like compatibility
    HIP_VISIBLE_DEVICES = "0";            # HIP device visibility
    
    # Performance optimizations
    HSA_ENABLE_SDMA = "0";                # Disable SDMA for stability
    AMD_DIRECT_DISPATCH = "1";            # Enable direct dispatch
    
    # Pre-Vega support (for RDNA1 cards like yours)
    ROC_ENABLE_PRE_VEGA = "1";            # Enable ROCm on pre-Vega (including RDNA1)
  };

  # System configuration for ROCm
  systemd.services.rocm-init = {
    description = "Initialize ROCm devices";
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

  # Udev rules for ROCm device access
  services.udev.extraRules = ''
    # ROCm device permissions
    KERNEL=="kfd", GROUP="render", MODE="0664"
    KERNEL=="renderD*", GROUP="render", MODE="0664"
    
    # AMD GPU specific
    SUBSYSTEM=="drm", KERNEL=="renderD128", GROUP="render", MODE="0664"
  '';

  # Add user to render group for GPU access
  users.users.fabio.extraGroups = [ "render" ];

  # Kernel modules for ROCm
  boot.kernelModules = [ "amdgpu" ];
  
  # Additional kernel parameters for ROCm optimization
  boot.kernelParams = [
    # Enable all AMD GPU features for ROCm
    "amdgpu.ppfeaturemask=0xffffffff"
    
    # Large BAR support (if your motherboard supports it)
    "amdgpu.exp_hw_support=1"
    
    # Enable GPU recovery for stability
    "amdgpu.gpu_recovery=1"
    
    # IOMMU settings for ROCm
    "iommu=pt"
    "amd_iommu=on"
  ];

  # Additional system limits for compute workloads
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
}
