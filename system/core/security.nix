# /etc/nixos/system/core/security.nix
{
  pkgs,
  ...
}:
{
  # Enable firewall with comprehensive port configuration
  networking.firewall = {
    enable = true;
    # Allow SSH and common ports
    allowedTCPPorts = [
      22 # SSH
      55443 # Common service port
    ];
    # Common port ranges (if any needed for all systems)
    allowedTCPPortRanges = [ ];
    allowedUDPPortRanges = [ ];
    # Allow ping
    allowPing = true;
  };

  # Additional firewall management tools
  environment.systemPackages = with pkgs; [
    iptables # Direct iptables management
  ];

  # Fail2ban for SSH protection
  services.fail2ban = {
    enable = true;
    bantime = "24h";
    bantime-increment.enable = true;
  };
}
