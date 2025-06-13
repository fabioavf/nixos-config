# /etc/nixos/modules/hardware/intel-mac.nix
# Intel hardware configuration for 2017 MacBook Pro 13"
# Intel i5-7267U (Kaby Lake) with Iris Plus Graphics 640

{ config, lib, pkgs, ... }:

{
  # ========================================
  # Intel Graphics Configuration
  # ========================================
  boot.kernelModules = [ "i915" ];
  boot.initrd.kernelModules = [ "i915" ];  # Early KMS loading

  # Kernel parameters for Intel graphics
  boot.kernelParams = [
    # Intel graphics optimizations
    "i915.enable_guc=2"           # Enable GuC and HuC firmware
    "i915.enable_fbc=1"           # Enable framebuffer compression
    "i915.enable_psr=1"           # Enable panel self refresh (power saving)
    "i915.fastboot=1"             # Fast boot for Intel graphics
  ];

  # ========================================
  # Hardware Graphics Configuration
  # ========================================
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # For any 32-bit applications
    
    extraPackages = with pkgs; [
      # Intel graphics drivers and media support
      intel-media-driver   # VAAPI driver for Intel Gen 8+ (Broadwell+)
      intel-vaapi-driver   # Legacy VAAPI driver (fallback)
      vaapiVdpau          # VAAPI -> VDPAU translation
      libvdpau-va-gl      # VDPAU -> VA-GL translation
      intel-compute-runtime # OpenCL support for Intel graphics
    ];
    
    extraPackages32 = with pkgs.driversi686Linux; [
      intel-vaapi-driver  # 32-bit Intel VAAPI driver
    ];
  };

  # ========================================
  # Intel Graphics Environment Variables
  # ========================================
  environment.sessionVariables = {
    # Intel graphics driver selection
    VDPAU_DRIVER = "va_gl";
    LIBVA_DRIVER_NAME = "iHD";    # Use modern iHD driver (intel-media-driver)
    
    # Intel graphics optimizations
    INTEL_DEBUG = "";             # Can add debug flags if needed
    
    # Vulkan configuration for Intel
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";
  };

  # ========================================
  # Power Management (Laptop-specific)
  # ========================================
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkForce "powersave";  # Override desktop setting for battery optimization
  };

  # Intel CPU microcode updates
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # ========================================
  # Laptop Hardware Support
  # ========================================
  
  # Enable firmware for Intel wireless (likely needed for MacBook WiFi)
  hardware.enableRedistributableFirmware = true;
  
  # Bluetooth support (MacBook has Bluetooth)
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # ========================================
  # TLP Power Management
  # ========================================
  services.tlp = {
    enable = true;
    settings = {
      # CPU scaling
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      
      # CPU energy performance policy
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      
      # Intel CPU boost
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      
      # Intel graphics power management
      INTEL_GPU_MIN_FREQ_ON_AC = 100;
      INTEL_GPU_MIN_FREQ_ON_BAT = 100;
      INTEL_GPU_MAX_FREQ_ON_AC = 1050;  # Max for Iris Plus 640
      INTEL_GPU_MAX_FREQ_ON_BAT = 300;  # Conservative for battery
      INTEL_GPU_BOOST_FREQ_ON_AC = 1050;
      INTEL_GPU_BOOST_FREQ_ON_BAT = 300;
      
      # Battery charge thresholds (helps preserve battery life)
      START_CHARGE_THRESH_BAT0 = 20;
      STOP_CHARGE_THRESH_BAT0 = 80;
      
      # WiFi power management
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
      
      # USB autosuspend
      USB_AUTOSUSPEND = 1;
      
      # Audio power saving
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
    };
  };

  # ========================================
  # System Limits and Optimizations
  # ========================================
  
  # Laptop-specific kernel optimizations (override desktop settings)
  boot.kernel.sysctl = {
    # Memory management for limited RAM (8GB) - override desktop values
    "vm.swappiness" = lib.mkForce 5;                    # Very conservative swapping
    "vm.vfs_cache_pressure" = lib.mkForce 50;          # Keep balanced cache pressure
    "vm.dirty_ratio" = 3;                  # Lower dirty page ratio for SSD
    "vm.dirty_background_ratio" = 1;       # Lower background write ratio
    
    # Network optimizations for laptop
    "net.core.rmem_max" = 134217728;       # Receive buffer size
    "net.core.wmem_max" = 134217728;       # Send buffer size
  };

  # ========================================
  # MacBook-specific Services
  # ========================================
  
  # Location for automatic brightness (São Paulo, Brazil)
  location = {
    latitude = -23.5505;
    longitude = -46.6333;
  };
  
  # Automatic brightness adjustment
  services.clight = {
    enable = true;
    settings = {
      verbose = true;
      backlight = {
        disabled = false;
        restore_on_exit = true;
        no_smooth_transition = false;
        trans_step = 0.05;
        trans_timeout = 30;
      };
      sensor = {
        captures = 5;
        ac_regression_points = [ 0.0 0.15 0.29 0.45 0.61 0.74 0.81 0.88 0.93 0.97 1.0 ];
        batt_regression_points = [ 0.0 0.1 0.18 0.25 0.35 0.45 0.55 0.65 0.75 0.85 1.0 ];
      };
    };
  };

  # Laptop lid management
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchExternalPower = "suspend";
    extraConfig = ''
      IdleAction=suspend
      IdleActionSec=20min
      HandlePowerKey=suspend
    '';
  };

  # ========================================
  # User Groups for Hardware Access
  # ========================================
  users.users.fabio.extraGroups = [ 
    "video"        # Video hardware access
    "input"        # Input device access
    "audio"        # Audio device access
  ];
}