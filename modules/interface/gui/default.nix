# /etc/nixos/modules/interface/gui/default.nix
# Common GUI applications for both machines (system-level)

{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # ========================================
    # File Management (Common)
    # ========================================
    nautilus            # GNOME file manager
    gdu                 # Disk usage analyzer
    
    # ========================================
    # GNOME Utilities (Common)
    # ========================================
    evince              # PDF viewer
    eog                 # Image viewer
    gnome-disk-utility  # Disk management
    
    # ========================================
    # Archive and Compression (Common)
    # ========================================
    zip
    unzip
    p7zip
    rar                 # RAR support
    unrar               # RAR extraction
    xz
    zstd
    
    # ========================================
    # Communication (Common)
    # ========================================
    discord             # Development communication
    
    # ========================================
    # Media (Common)
    # ========================================
    vlc                 # Media player (efficient)
    playerctl           # Media player control
    
    # ========================================
    # Productivity (Common)
    # ========================================
    obsidian            # Note-taking
    qbittorrent         # Torrenting
    
    # ========================================
    # Qt/GTK Support (Common)
    # ========================================
    qt6.qt5compat
    qt6.qtwayland       # Qt6 Wayland support
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5.qtwayland  # Qt5 Wayland support
    kdePackages.qt5compat
  ];
  
  # ========================================
  # Flatpak (Common)
  # ========================================
  services.flatpak.enable = true;
  
  # Add Flatpak desktop files to XDG paths
  environment.sessionVariables = {
    XDG_DATA_DIRS = [
      "/var/lib/flatpak/exports/share"
      "/home/fabio/.local/share/flatpak/exports/share"
    ];
    # Set Zen browser as default (installed via Flatpak)
    BROWSER = "zen-browser";
    DEFAULT_BROWSER = "zen-browser";
  };
  
  # ========================================
  # Default Applications (Common)
  # ========================================
  xdg.mime.defaultApplications = {
    "text/html" = "zen.desktop";
    "text/xml" = "zen.desktop";
    "application/xhtml+xml" = "zen.desktop";
    "x-scheme-handler/http" = "zen.desktop";
    "x-scheme-handler/https" = "zen.desktop";
    "x-scheme-handler/about" = "zen.desktop";
    "x-scheme-handler/unknown" = "zen.desktop";
  };
  
  # ========================================
  # Auto-mount Removable Media (Common)
  # ========================================
  services.udisks2.enable = true;
}