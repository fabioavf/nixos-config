# /etc/nixos/modules/desktop/apps.nix
# Desktop applications

{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Custom packages
    (callPackage ../../packages/faugus-launcher.nix {})
    # File manager
    nautilus
    
    # Communication
    discord
    
    # Media
    spotify
    playerctl
    
    # Productivity
    qbittorrent
    
    # System monitoring and control
    corectrl              # AMD GPU control
    gnome-disk-utility    # GNOME Disks for disk management
    
    # GNOME document and media viewers
    evince                # GNOME Document Viewer (PDF, etc.)
    eog                   # GNOME Image Viewer (Eye of GNOME)

    # Archive and compression
    zip
    unzip
    p7zip
    rar
    unrar
    xz
    zstd

    # File management
    ranger        # Terminal file manager
    fd            # Better find
    ripgrep       # Better grep (already have this?)
    gdu

    # Network tools
    wget
    curl
    aria2         # Multi-connection downloader
    rsync         # File synchronization
    sshfs         # Mount remote filesystems
    ethtool       # Ethernet configuration tool

    # Image manipulation
    imagemagick
    gimp          # If you need advanced image editing

    # Video tools
    vlc           # Media player
    ffmpeg        # Video processing
    obs-studio    # Screen recording/streaming

    # Qt support for applications
    qt6.qt5compat
    libsForQt5.qt5.qtgraphicaleffects
    kdePackages.qt5compat
  ];
  
  # Enable Flatpak
  services.flatpak.enable = true;
  
  # Add Flatpak desktop files to XDG paths so launchers can find them
  environment.sessionVariables = {
    XDG_DATA_DIRS = [
      "/var/lib/flatpak/exports/share"
      "/home/fabio/.local/share/flatpak/exports/share"
    ];
    # Set Zen browser as default
    BROWSER = "zen-browser";
    # Force VS Code and other apps to use Zen Browser
    DEFAULT_BROWSER = "zen-browser";
  };
  
  # Set default applications
  xdg.mime.defaultApplications = {
    "text/html" = "zen.desktop";
    "text/xml" = "zen.desktop";
    "application/xhtml+xml" = "zen.desktop";
    "x-scheme-handler/http" = "zen.desktop";
    "x-scheme-handler/https" = "zen.desktop";
    "x-scheme-handler/about" = "zen.desktop";
    "x-scheme-handler/unknown" = "zen.desktop";
  };
  
  # CoreCtrl configuration for AMD GPU control
  programs.corectrl.enable = true;
  hardware.amdgpu.overdrive.enable = true;  # Updated option name
  
  # Add user to corectrl group
  users.users.fabio.extraGroups = [ "corectrl" ];
  
  # Sunshine configuration for game streaming
  security.wrappers.sunshine = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+p";
    source = "${pkgs.sunshine}/bin/sunshine";
  };
}
