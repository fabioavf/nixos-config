# /etc/nixos/pkgs/default.nix
# Custom packages using flake-parts

{
  systems = ["x86_64-linux"];

  perSystem = {pkgs, ...}: {
    packages = {
      # Game launcher for managing Windows games on Linux
      faugus-launcher = pkgs.callPackage ./faugus-launcher.nix {};
      
      # MacBook Pro audio driver for Cirrus Logic CS8409 chip
      snd-hda-macbookpro = pkgs.callPackage ./snd-hda-macbookpro.nix {};
    };
  };
}
