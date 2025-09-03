# /etc/nixos/system/network/default.nix
# Networking configuration

{
  ...
}:

{
  networking = {
    # hostName is set in each host's configuration.nix
    networkmanager.enable = true;
  };

  services.avahi.enable = true;
}
