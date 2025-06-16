# /etc/nixos/home/profiles/default.nix
# Home Manager profiles

{
  self,
  inputs,
  ...
}: let
  # get these into the module system
  extraSpecialArgs = {inherit inputs self;};

  homeImports = {
    "fabio@fabio-nixos" = [
      ../profiles/fabio.nix
      # Desktop-specific home config can go here
    ];
    
    "fabio@fabio-macbook" = [
      ../profiles/fabio.nix
      # MacBook-specific home config can go here
    ];
  };

  inherit (inputs.home-manager.lib) homeManagerConfiguration;

  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
in {
  _module.args = {inherit homeImports;};

  flake = {
    homeConfigurations = {
      "fabio_fabio-nixos" = homeManagerConfiguration {
        modules = homeImports."fabio@fabio-nixos";
        inherit pkgs extraSpecialArgs;
      };
      
      "fabio_fabio-macbook" = homeManagerConfiguration {
        modules = homeImports."fabio@fabio-macbook";
        inherit pkgs extraSpecialArgs;
      };
    };
  };
}
