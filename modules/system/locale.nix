# /etc/nixos/modules/system/locale.nix
# Time zone and internationalization

{ config, lib, pkgs, ... }:

{
  # Time zone
  time.timeZone = "America/Sao_Paulo";

  # Internationalization
  i18n.defaultLocale = "en_US.UTF-8";
}
