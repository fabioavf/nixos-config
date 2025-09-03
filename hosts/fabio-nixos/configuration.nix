# /etc/nixos/hosts/fabio-nixos/configuration.nix
# Desktop configuration - AMD gaming workstation

{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Hardware
    ./hardware-configuration.nix
  ];

  # Machine identification
  networking.hostName = "fabio-nixos";

  # Install git globally for root user and custom packages
  environment.systemPackages = with pkgs; [
    git
    # Flake packages (desktop only)
    inputs.claude-desktop.packages.x86_64-linux.default
    # Custom packages
    inputs.self.packages.x86_64-linux.faugus-launcher
  ];

  # System state version
  system.stateVersion = "25.05";
}
