# /etc/nixos/home/services/niri/outputs.nix
# Display and output configuration

{ lib, osConfig, ... }:

let
  # Machine detection
  isMacBook = osConfig.networking.hostName == "fabio-macbook";
  isDesktop = osConfig.networking.hostName == "fabio-nixos";
in
{
  programs.niri.settings.outputs = lib.mkMerge [
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
