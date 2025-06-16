# /etc/nixos/home/services/niri/config.nix
# Basic niri configuration - environment and startup

{ ... }:

let
  makeCommand = command: {
    command = [command];
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
    };

    # Startup programs
    spawn-at-startup = [
      (makeCommand "swww-daemon")
    ];

    # Hotkey overlay
    hotkey-overlay.skip-at-startup = true;
    
    # Cursor configuration
    cursor = {
      size = 20;
    };
  };
}
