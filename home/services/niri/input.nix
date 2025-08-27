# /etc/nixos/home/services/niri/input.nix
# Input configuration - keyboard, mouse, touchpad

{ lib, osConfig, ... }:

let
  # Machine detection
  isMacBook = osConfig.networking.hostName == "fabio-macbook";
in
{
  programs.niri.settings.input = {
    keyboard = {
      xkb = {
        layout = "us,us";
        variant = ",intl";
        options = "grp:alt_shift_toggle";
      };
      repeat-delay = 600;
      repeat-rate = 25;
    };

    touchpad = {
      natural-scroll = true;
      tap = false;
      dwt = true;
      middle-emulation = true;
      accel-speed = 0.2;
      accel-profile = "adaptive";
      scroll-method = "two-finger";
      click-method = "clickfinger";
    };

    focus-follows-mouse.enable = true;
    warp-mouse-to-focus.enable = true;
    workspace-auto-back-and-forth = true;

    mouse = {
      natural-scroll = false;
      scroll-factor = 1.0;
      accel-speed = 0.0;
      accel-profile = "flat";
    };
  };
}
