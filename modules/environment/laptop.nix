# /etc/nixos/modules/environment/laptop.nix
# MacBook-specific applications and configurations
# Optimized for battery life and portability

{ config, lib, pkgs, ... }:

lib.mkIf (config.networking.hostName == "fabio-macbook") {
  environment.systemPackages = with pkgs; [
    # ========================================
    # Laptop-Specific Power Tools
    # ========================================
    acpi                  # Battery status and ACPI info
    powertop             # Power consumption analysis
    brightnessctl        # Backlight control
    light                # Alternative backlight control
    
    # ========================================
    # Network Management (Laptop-specific)
    # ========================================
    impala               # WiFi management via terminal (as requested)
    networkmanagerapplet # GUI network management
    bluez-tools          # Bluetooth command line tools
    
    # ========================================
    # System Monitoring (Lightweight)
    # ========================================
    btop                 # Modern system monitor (lightweight alternative)
    iotop                # I/O monitoring
    
    # ========================================
    # Gaming (Minimal - Only Moonlight)
    # ========================================
    moonlight-qt         # Game streaming client (as requested)
  ];
  
  # ========================================
  # Laptop-Specific Services
  # ========================================
  
  # udev rules for laptop hardware
  services.udev.extraRules = ''
    # Allow brightness control for users in video group
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"
    
    # Power button handling
    ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="Power Button", TAG+="power-switch"
    
    # Lid switch handling
    ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="Lid Switch", TAG+="power-switch"
  '';
  
  # ========================================
  # Laptop Hardware Groups
  # ========================================
  users.users.fabio.extraGroups = [ 
    "video"             # Brightness control
    "input"             # Input devices
    "audio"             # Audio devices
    "networkmanager"    # Network management
  ];
  
  # ========================================
  # Laptop-Specific Environment Variables
  # ========================================
  environment.sessionVariables = {
    # Qt optimizations for laptop
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    
    # GTK optimizations
    GDK_BACKEND = "wayland";
    
    # Electron apps optimization (Discord, VS Code, etc.)
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };
  
  # ========================================
  # Bluetooth Configuration (Laptop)
  # ========================================
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };
  
  # Bluetooth service
  services.blueman.enable = true;
}