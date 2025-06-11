# /etc/nixos/modules/development/rocm.nix
# ROCm (Radeon Open Compute) support for AMD RX 5600/5700 XT
# Enables machine learning, compute workloads, and GPU development
# Updated with actual available packages in nixpkgs

{ config, lib, pkgs, ... }:

{
  # ROCm tmpfiles moved to modules/hardware/amd.nix

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

  # Hardware configuration moved to modules/hardware/amd.nix

  # Environment variables moved to modules/hardware/amd.nix

  # ROCm system services, udev rules, kernel modules, and limits moved to modules/hardware/amd.nix
}
