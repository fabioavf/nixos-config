# /etc/nixos/home/services/niri/config.nix
# Basic niri configuration - environment and startup

{ ... }:

{
  programs.niri.settings = {
    # Environment variables
    environment = {
      "CLUTTER_BACKEND" = "wayland";
      "NIXOS_OZONE_WL" = "1";
      "XDG_SESSION_TYPE" = "wayland";
      "XDG_SESSION_DESKTOP" = "niri";
      "XDG_CURRENT_DESKTOP" = "niri";
      "QT_QPA_PLATFORM" = "wayland";
      "GDK_BACKEND" = "wayland";
      "MOZ_ENABLE_WAYLAND" = "1";
      "SDL_VIDEODRIVER" = "wayland";
      "DISPLAY" = ":0";
      "BROWSER" = "app.zen_browser.zen";
    };

    # Startup programs
    spawn-at-startup = [
      # Notification daemon
      {
        command = [
          "mako"
        ];
      }
      # Lumin Bar - Material 3 Quickshell Bar
      # {
      #   command = [
      #     "quickshell"
      #     "-c"
      #     "lumin"
      #   ];
      # }
      {
        command = [
          "swaybg"
          "-i"
          "/home/fabio/Pictures/Wallpapers/wallpaper.jpg"
          "-m"
          "fill"
        ];
      }
      {
        command = [
          "waybar"
        ];
      }
      {
        command = [
          "xwayland-satellite"
        ];
      }
      {
        command = [
          "qbittorrent"
        ];
      }
      {
        command = [
          "sunshine"
        ];
      }
      {
        command = [
          "corectrl"
        ];
      }
    ];

    prefer-no-csd = true;

    # Hotkey overlay
    hotkey-overlay.skip-at-startup = true;

    # Cursor configuration
    cursor = {
      size = 20;
      theme = "adwaita";
    };

    clipboard = {
      disable-primary = true;
    };
  };
}
