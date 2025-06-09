# /etc/nixos/modules/system/security.nix
{ config, lib, pkgs, ... }:
{
  # Enable firewall with comprehensive port configuration
  networking.firewall = {
    enable = true;
    # Allow SSH
    allowedTCPPorts = [ 22 ];
    # Gaming and streaming ports
    allowedTCPPortRanges = [
      # Steam
      { from = 27015; to = 27030; }
      { from = 27036; to = 27037; }
      # Epic Games
      { from = 5795; to = 5847; }
      # Sunshine streaming
      { from = 47984; to = 47990; }  # Sunshine HTTPS and Web UI
    ];
    allowedUDPPortRanges = [
      # Steam
      { from = 27000; to = 27100; }
      { from = 3478; to = 4380; }
      # Sunshine streaming
      { from = 47998; to = 48000; }  # Sunshine video/audio streaming
    ];
    # Allow ping
    allowPing = true;
  };
  
  # Add UFW for additional management (as standalone tool)
  environment.systemPackages = with pkgs; [
    ufw    # UFW command line tool
    gufw   # GTK GUI for UFW (can be used alongside iptables)
  ];
  
  # Fail2ban for SSH protection
  services.fail2ban = {
    enable = true;
    bantime = "24h";
    bantime-increment.enable = true;
  };
}
