# /etc/nixos/modules/system/security.nix
{ config, lib, pkgs, ... }:
{
  # Disable default iptables firewall in favor of UFW
  networking.firewall.enable = false;
  
  # Enable UFW (Uncomplicated Firewall)
  networking.ufw = {
    enable = true;
    settings = {
      IPV6 = "yes";
      DEFAULT_INPUT_POLICY = "DROP";
      DEFAULT_OUTPUT_POLICY = "ACCEPT";
      DEFAULT_FORWARD_POLICY = "DROP";
    };
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
  };
  
  # Add UFW GUI for easy management
  environment.systemPackages = with pkgs; [
    ufw
    gufw  # GTK GUI for UFW
  ];
  
  # Fail2ban for SSH protection (compatible with UFW)
  services.fail2ban = {
    enable = true;
    bantime = "24h";
    bantime-increment.enable = true;
    # Configure fail2ban to work with UFW
    jails = {
      DEFAULT = {
        banaction = "ufw";
      };
    };
  };
}
