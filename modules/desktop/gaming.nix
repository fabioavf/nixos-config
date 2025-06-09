# /etc/nixos/modules/desktop/gaming.nix
# Gaming setup with Steam, optimizations, and Faugus Launcher
# Designed to work with existing audio.nix, security.nix, and performance.nix

{ config, lib, pkgs, ... }:

{
  # Enable Steam and gaming features
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    
    # Compatibility layers
    extraCompatPackages = with pkgs; [
      proton-ge-bin  # Enhanced Proton
    ];
  };

  # Enable GameMode for performance optimizations
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
        ioprio = 0;
        inhibit_screensaver = 1;
        softrealtime = "auto";
      };
      
      # GPU optimizations for AMD
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
      
      # CPU optimizations
      cpu = {
        park_cores = "no";
        pin_cores = "yes";
      };
    };
  };

  # Gaming-related packages
  environment.systemPackages = with pkgs; [
    # Game launchers and stores
    bottles                # Wine prefix manager
    
    # Performance and monitoring
    mangohud              # Performance overlay
    gamemode              # Performance optimizations
    gamescope             # Wayland compositor for games
    
    # Wine and compatibility
    wine                  # Windows compatibility layer
    winetricks           # Wine helper scripts
    dxvk                 # DirectX to Vulkan
    
    # Controllers and input
    antimicrox           # Controller mapping
    
    # System tools for gaming
    nvtopPackages.amd    # AMD GPU monitoring
    
    # Archive tools for game files
    unrar
    p7zip
    cabextract
  ];

  # Hardware optimizations for gaming
  hardware = {
    # Enable graphics drivers
    graphics = {
      enable = true;
      enable32Bit = true;  # Required for 32-bit games
      extraPackages = with pkgs; [
        # AMD GPU packages
        amdvlk          # AMD Vulkan driver
        rocmPackages.clr # AMD OpenCL
      ];
      extraPackages32 = with pkgs.driversi686Linux; [
        amdvlk          # 32-bit AMD Vulkan
      ];
    };
  };

  # FIXED: Additional kernel parameters (merged with existing)
  boot.kernelParams = [
    # Gaming-specific AMD GPU optimizations
    "amdgpu.ppfeaturemask=0xffffffff"  # Enable all AMD GPU features
    "amdgpu.gpu_recovery=1"            # Enable GPU recovery
    
    # Performance optimizations (optional - enable if you want less security for more performance)
    # "mitigations=off"                # Disable CPU mitigations for performance
  ];

  # FIXED: Additional sysctl settings (merged with existing)
  boot.kernel.sysctl = {
    # Gaming-specific memory optimizations
    "vm.max_map_count" = 2147483642;   # Increased for some games
    "fs.file-max" = 2097152;           # Increase file descriptor limit
  };

  # Services for gaming
  services = {
    # Optional: Enable Game Bar equivalent
    # udev rules for controllers
    udev.packages = with pkgs; [
      game-devices-udev-rules  # Controller recognition
    ];
  };

  # FIXED: Extend existing firewall config instead of overriding
  networking.firewall = {
    allowedTCPPortRanges = [
      # Steam
      { from = 27015; to = 27030; }
      { from = 27036; to = 27037; }
      # Epic Games
      { from = 5795; to = 5847; }
    ];
    allowedUDPPortRanges = [
      # Steam
      { from = 27000; to = 27100; }
      { from = 3478; to = 4380; }
    ];
  };

  # Security exceptions for anti-cheat (if needed)
  security.pam.loginLimits = [
    {
      domain = "@gamemode";
      item = "nice";
      type = "soft";
      value = "-10";
    }
  ];

  # Environment variables for gaming
  environment.sessionVariables = {
    # AMD GPU optimizations
    AMD_VULKAN_ICD = "RADV";  # Use Mesa RADV driver
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
    
    # Wine/Proton optimizations
    WINEPREFIX = "$HOME/.wine-games";
    
    # Performance
    __GL_THREADED_OPTIMIZATIONS = "1";
    
    # MangoHud config (use 'mangohud command' to enable per-app)
    MANGOHUD_CONFIG = "cpu_temp,gpu_temp,cpu_load_change,gpu_load_change,cpu_mhz,gpu_core_clock,ram,vram,fps,frametime,frame_timing";
  };

  # Add gaming group for permissions
  users.groups.gamemode = {};
  users.users.fabio.extraGroups = [ "gamemode" ];
  
  # FIXED: PipeWire 32-bit support (instead of PulseAudio)
  # Since you use PipeWire, enable 32-bit ALSA support for Steam
  services.pipewire.alsa.support32Bit = true;
}
