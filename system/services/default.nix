# /etc/nixos/system/services/default.nix
# System services configuration

{
  ...
}:

{
  imports = [
    ./openssh.nix
    ./filesystems.nix
    ./duckdns.nix
    ./media.nix
  ];
}
