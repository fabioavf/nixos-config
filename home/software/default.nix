# /etc/nixos/home/software/default.nix
# Media applications and tools

{ pkgs, ... }:

{
  # Media packages for all devices
  home.packages = with pkgs; [
    firefox
    chromium
    vesktop
    moonlight-qt
    telegram-desktop
    fusee-nano
    yt-dlp
    marktext
  ];
}
