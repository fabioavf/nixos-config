# /etc/nixos/system/hardware/intel-graphics.nix
# Intel graphics configuration for MacBook

{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf (config.networking.hostName == "fabio-macbook") {
  # Intel graphics drivers
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      intel-media-driver # Intel VAAPI driver
      vaapiIntel # VAAPI driver for Intel GPUs
      vaapiVdpau # VDPAU/VAAPI backend
      libvdpau-va-gl # VDPAU driver with OpenGL/VAAPI backend
      intel-ocl # Intel OpenCL runtime
    ];
  };

  # Intel graphics kernel parameters
  boot.kernelParams = [
    "i915.enable_guc=2" # Enable GuC and HuC firmware loading
    "i915.enable_psr=1" # Enable Panel Self Refresh
    "pcie_aspm=off"
    "acpi_osi=Darwin"
    "brcmfmac.feature_disable=0x82000" # Disable some problematic features
    "processor.max_cstate=1" # Reduce CPU sleep states for lower latency
    "intel_idle.max_cstate=0" # Disable Intel idle states
  ];

  # Early KMS loading for Intel
  boot.initrd.kernelModules = [ "i915" ];

  # Intel graphics environment variables
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Use Intel Media Driver for VAAPI
    VDPAU_DRIVER = "va_gl"; # Use VAAPI-OpenGL bridge for VDPAU
  };

  # Additional packages for Intel graphics
  environment.systemPackages = with pkgs; [
    intel-gpu-tools # Intel GPU debugging tools
    libva-utils # VAAPI info tool (replaces vainfo)
    vdpauinfo # VDPAU info tool
  ];
}
