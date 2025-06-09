# /etc/nixos/modules/services/openssh.nix
# SSH server configuration

{ config, lib, pkgs, ... }:

{
  # Enable SSH daemon
  services.openssh.enable = true;
  
  # Optional: Configure SSH settings
  # services.openssh = {
  #   enable = true;
  #   settings = {
  #     PasswordAuthentication = false;
  #     KbdInteractiveAuthentication = false;
  #     PermitRootLogin = "no";
  #   };
  # };
}
