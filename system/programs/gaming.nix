# /etc/nixos/system/programs/gaming.nix
# Gaming setup with Steam, optimizations, and Faugus Launcher
# Desktop-only configuration (fabio-nixos)

{ config, lib, pkgs, ... }:

lib.mkIf (config.networking.hostName == "fabio-nixos") {
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
    umu-launcher          # Unified Wine launcher for Proton/Wine
  
    # Game streaming
    sunshine              # NVIDIA GameStream alternative
    
    # Performance and monitoring
    mangohud              # Performance overlay
    gamemode              # Performance optimizations
    gamescope             # Wayland compositor for games
    
    # Wine and compatibility
    wineWowPackages.staging  # 64-bit Wine with 32-bit support
    winetricks           # Wine helper scripts
    dxvk                 # DirectX to Vulkan

    # Controllers and input
    antimicrox           # Controller mapping
    jstest-gtk           # Controller testing GUI
    linuxConsoleTools    # Includes jstest for testing controllers
    evtest               # Event testing tool
    
    # System tools for gaming
    nvtopPackages.amd    # AMD GPU monitoring
    
    # Archive tools for game files
    unrar
    p7zip
    cabextract
  ];

  # Hardware graphics configuration moved to system/hardware/amd.nix

  # AMD GPU kernel parameters moved to system/hardware/amd.nix

  # FIXED: Additional sysctl settings (merged with existing)
  boot.kernel.sysctl = {
    # Gaming-specific memory optimizations
    "vm.max_map_count" = 2147483642;   # Increased for some games
    "fs.file-max" = 2097152;           # Increase file descriptor limit
  };

  # Services for gaming
  services = {
    # udev rules for controllers
    udev.packages = with pkgs; [
      game-devices-udev-rules  # Controller recognition
    ];
    
    # Additional udev rules for 8BitDo controllers
    udev.extraRules = ''
      # 8BitDo Ultimate 2C Controller
      SUBSYSTEM=="input", ATTRS{idVendor}=="2dc8", ATTRS{idProduct}=="310a", MODE="0666", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2dc8", ATTRS{idProduct}=="310a", MODE="0666", TAG+="uaccess"
      
      # 8BitDo controllers (general)
      SUBSYSTEM=="input", ATTRS{idVendor}=="2dc8", MODE="0666", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2dc8", MODE="0666", TAG+="uaccess"
      
      # Ensure joystick devices are accessible
      KERNEL=="js[0-9]*", MODE="0664", GROUP="input"
      SUBSYSTEM=="input", GROUP="input", MODE="0664"
      
      # Additional gamepad permissions for browsers
      SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="*Controller*", MODE="0664", GROUP="input", TAG+="uaccess"
      SUBSYSTEM=="input", KERNEL=="js*", MODE="0664", GROUP="input", TAG+="uaccess"
    '';
  };

  # Note: Firewall ports now handled in security.nix with UFW
  # Gaming ports are configured there along with Sunshine streaming ports

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
    # Wine/Proton optimizations (non-AMD specific)
    WINEPREFIX = "$HOME/.wine-games";
  };
  
  # AMD GPU environment variables moved to system/hardware/amd.nix

  # Add gaming group for permissions
  users.groups.gamemode = {};
  users.users.fabio.extraGroups = [ "gamemode" ];
  
  # Note: render group for AMD GPU access is handled in system/hardware/amd.nix
  
  # FIXED: PipeWire 32-bit support (instead of PulseAudio)
  # Since you use PipeWire, enable 32-bit ALSA support for Steam
  services.pipewire.alsa.support32Bit = true;
}
