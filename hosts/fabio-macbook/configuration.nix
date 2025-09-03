# /etc/nixos/hosts/fabio-macbook/configuration.nix
# MacBook configuration - Intel laptop

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
  networking.hostName = "fabio-macbook";

  # Install git globally for root user and custom packages
  environment.systemPackages = with pkgs; [
    git
    # Flake packages (MacBook)
    inputs.claude-desktop.packages.x86_64-linux.default
    # MacBook audio driver
    inputs.self.packages.x86_64-linux.snd-hda-macbookpro
  ];

  # System state version
  system.stateVersion = "25.05";
}
