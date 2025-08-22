# /etc/nixos/home/services/niri/outputs.nix
# Display and output configuration

{ lib, osConfig, ... }:

let
  # Machine detection
  isVivobook = osConfig.networking.hostName == "fabio-vivobook";
  isMacBook = osConfig.networking.hostName == "fabio-macbook";
  isDesktop = osConfig.networking.hostName == "fabio-nixos";
in
{
  programs.niri.settings.outputs = lib.mkMerge [
    (lib.mkIf isVivobook {
      "eDP-1" = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 60.0;
        };
        scale = 1.0;
      };
      "HDMI-A-1" = {
        mode = {
          width = 2560;
          height = 1440;
          refresh = 75.0;
        };
        scale = 1.0;
      };
    })
    (lib.mkIf isMacBook {
      "eDP-1" = {
        mode = {
          width = 2560;
          height = 1600;
          refresh = 60.0;
        };
        scale = 1.6;
      };
    })
    (lib.mkIf isDesktop {
      "HDMI-A-3" = {
        mode = {
          width = 3840;
          height = 2160;
          refresh = 60.0;
        };
        scale = 1.5;
      };
    })
  ];
}
