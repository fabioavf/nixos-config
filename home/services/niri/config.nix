# /etc/nixos/home/services/niri/config.nix
# Basic niri configuration - environment and startup

{ ... }:

let
  makeCommand = command: {
    command = [ command ];
  };
in
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
    };

    # Startup programs
    spawn-at-startup = [
      # Removed swww-daemon - will be handled by wallpaper service
      # Lumin Bar - Material 3 Quickshell Bar
      {
        command = [
          "quickshell"
          "-c"
          "lumin"
        ];
      }
      {
        command = [
          "xwayland-satellite"
        ];
      }
    ];

    # Hotkey overlay
    hotkey-overlay.skip-at-startup = true;

    # Cursor configuration
    cursor = {
      size = 20;
    };
  };
}
