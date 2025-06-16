# /etc/nixos/modules/system/locale.nix
# Time zone and internationalization

{ config, lib, pkgs, ... }:

{
  # Time zone
  time.timeZone = "America/Sao_Paulo";

  # Internationalization
  i18n.defaultLocale = "en_US.UTF-8";

  # Console font configuration for modern TTY appearance
  console = {
    font = "ter-v32n";  # Terminus font, size 32, normal weight
    packages = with pkgs; [ terminus_font ];
    keyMap = "us";
  };
}
