# /etc/nixos/modules/system/security.nix
{ config, lib, pkgs, ... }:
{
  # Enable firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ]; # SSH only
    allowedUDPPorts = [ ];
    # allowPing = true; # Optional
  };
  
  # Fail2ban for SSH protection
  services.fail2ban = {
    enable = true;
    bantime = "24h";
    bantime-increment.enable = true;
  };
}
