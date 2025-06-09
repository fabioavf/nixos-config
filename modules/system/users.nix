# /etc/nixos/modules/system/users.nix
# User account configuration

{ config, lib, pkgs, ... }:

{
  # Define user account
  users.users.fabio = {
    isNormalUser = true;
    description = "Fabio";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "corectrl" ];
    packages = with pkgs; [
      # Basic user utilities
      firefox
      git
      vim
      wget
      curl
      htop
      tree
      unzip
    ];
  };

  # Enable automatic login
  services.getty.autologinUser = "fabio";
}
