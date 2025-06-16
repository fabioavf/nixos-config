# /etc/nixos/system/core/users.nix
# User account configuration

{ config, lib, pkgs, ... }:

{
  # Define user account
  users.users.fabio = {
    isNormalUser = true;
    description = "Fabio";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "corectrl" "input" "render" ];
    packages = with pkgs; [
      # Basic user utilities
      git
      vim
      wget
      curl
      htop
      tree
      unzip
      # Network tools
      ookla-speedtest
    ];
  };

  # Enable automatic login
  services.getty.autologinUser = "fabio";
}
