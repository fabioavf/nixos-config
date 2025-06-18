# /etc/nixos/system/programs/gui.nix
# GUI applications and Flatpak configuration

{
  config,
  lib,
  pkgs,
  ...
}:

{
  # GUI applications
  environment.systemPackages = with pkgs; [
    # ========================================
    # File Management (Common)
    # ========================================
    nautilus # GNOME file manager
    gdu # Disk usage analyzer

    # ========================================
    # GNOME Utilities (Common)
    # ========================================
    evince # PDF viewer
    eog # Image viewer
    gnome-disk-utility # Disk management

    # ========================================
    # Archive and Compression (Common)
    # ========================================
    zip
    unzip
    p7zip
    rar # RAR support
    unrar # RAR extraction
    xz
    zstd

    # ========================================
    # Communication (Common)
    # ========================================
    discord # Development communication

    # ========================================
    # Media (Common)
    # ========================================
    vlc # Media player (efficient)
    playerctl # Media player control

    # ========================================
    # Productivity (Common)
    # ========================================
    obsidian # Note-taking
    qbittorrent # Torrenting

    # ========================================
    # Qt/GTK Support (Common)
    # ========================================
    qt6.qt5compat
    qt6.qtwayland # Qt6 Wayland support
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5.qtwayland # Qt5 Wayland support
    kdePackages.qt5compat
  ];

  # ========================================
  # Flatpak (Common)
  # ========================================
  services.flatpak.enable = true;

  # XDG Desktop Portal for Flatpak
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];

    config = {
      common = {
        default = "gnome"; # Use GNOME portal by default
      };

      gnome = {
        "org.freedesktop.impl.portal.FileChooser" = [ "xdg-desktop-portal-gnome" ];
        "org.freedesktop.impl.portal.Notification" = [ "xdg-desktop-portal-gnome" ];
        "org.freedesktop.impl.portal.DBusMenu" = [ "xdg-desktop-portal-gnome" ];
        "org.freedesktop.impl.portal.Settings" = [ "xdg-desktop-portal-gnome" ];
        "org.freedesktop.impl.portal.Print" = [ "xdg-desktop-portal-gnome" ];
        "org.freedesktop.impl.portal.Secret" = [ "xdg-desktop-portal-gnome" ];
      };
    };
  };

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
