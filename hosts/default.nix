# /etc/nixos/hosts/default.nix
# Host configurations using flake-parts

{
  self,
  inputs,
  homeImports,
  ...
}: {
  flake.nixosConfigurations = let
    # shorten paths
    inherit (inputs.nixpkgs.lib) nixosSystem;
    mod = "${self}/system";

    # get the basic config to build on top of
    inherit (import "${self}/system") desktop laptop;

    # get these into the module system
    specialArgs = {inherit inputs self;};
  in {
    # Desktop configuration (AMD gaming workstation)
    fabio-nixos = nixosSystem {
      inherit specialArgs;
      modules =
        desktop
        ++ [
          ./fabio-nixos
          {
            home-manager = {
              users.fabio.imports = homeImports."fabio@fabio-nixos";
              extraSpecialArgs = specialArgs;
            };
          }

          inputs.sops-nix.nixosModules.sops
          inputs.home-manager.nixosModules.home-manager
        ];
    };

    # MacBook configuration (Intel laptop)
    fabio-macbook = nixosSystem {
      inherit specialArgs;
      modules =
        laptop
        ++ [
          ./fabio-macbook
          {
            home-manager = {
              users.fabio.imports = homeImports."fabio@fabio-macbook";
              extraSpecialArgs = specialArgs;
            };
          }

          inputs.sops-nix.nixosModules.sops
          inputs.home-manager.nixosModules.home-manager
        ];
    };
  };
}
