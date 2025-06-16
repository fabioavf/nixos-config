# /etc/nixos/system/programs/desktop-heavy.nix
# Desktop-specific heavy applications (fabio-nixos only)

{ config, lib, pkgs, inputs, ... }:

lib.mkIf (config.networking.hostName == "fabio-nixos") {
  environment.systemPackages = with pkgs; [
    # ========================================
    # Custom Desktop Packages
    # ========================================
    inputs.self.packages.x86_64-linux.faugus-launcher
    
    # ========================================
    # Media Production (Heavy)
    # ========================================
    (spotify.overrideAttrs (oldAttrs: {
      postFixup = (oldAttrs.postFixup or "") + ''
        wrapProgram $out/bin/spotify \
          --add-flags "--force-device-scale-factor=1.5"
      '';
    }))
    obs-studio              # Screen recording/streaming
    droidcam               # Android camera as webcam
    ffmpeg                 # Video processing
    
    # ========================================
    # Image and Graphics (Heavy)
    # ========================================
    imagemagick
    gimp                   # Advanced image editing
    
    # ========================================
    # System Control (Desktop-specific)
    # ========================================
    corectrl               # AMD GPU control
    neofetch               # System info
    openrgb-with-all-plugins
    
    # ========================================
    # Network Tools (Desktop-specific)
    # ========================================
    ethtool                # Ethernet configuration tool
  ];
  
  # ========================================
  # Desktop-only Configurations
  # ========================================
  
  # CoreCtrl for AMD GPU control
  programs.corectrl.enable = true;
  
  # Add user to corectrl group
  users.users.fabio.extraGroups = [ "corectrl" ];
  
  # Sunshine configuration for game streaming
  security.wrappers.sunshine = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+p";
    source = "${pkgs.sunshine}/bin/sunshine";
  };
  
  # v4l2loopback support for droidcam (virtual camera)
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
}
