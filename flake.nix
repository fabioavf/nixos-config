# /etc/nixos/flake.nix
# Fabio's NixOS configuration with flake-parts architecture

{
  description = "Fabio's NixOS configuration";

  inputs = {
    # Global, so they can be `.follow`ed
    systems.url = "github:nix-systems/default-linux";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Quickshell flake
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Niri flake
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    # Claude Desktop
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [ ./pkgs ];

      flake =
        let
          # Get desktop and laptop module arrays from system/default.nix
          inherit (import ./system) desktop laptop;

          # Special args to pass to modules
          specialArgs = { inherit inputs; };

          # Home Manager profiles
          homeImports = {
            fabio-nixos = [
              ./home/profiles/fabio.nix
            ];

            fabio-macbook = [
              ./home/profiles/fabio.nix
            ];
          };
        in
        {
          # NixOS configurations
          nixosConfigurations = {
            # Desktop configuration (AMD gaming workstation)
            fabio-nixos = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              inherit specialArgs;
              modules = desktop ++ [
                ./hosts/fabio-nixos/configuration.nix
                inputs.sops-nix.nixosModules.sops
                inputs.home-manager.nixosModules.home-manager
                {
                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    backupFileExtension = "backup";
                    users.fabio.imports = homeImports.fabio-nixos;
                    extraSpecialArgs = specialArgs;
                  };
                }
              ];
            };

            # MacBook configuration (Intel laptop)
            fabio-macbook = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              inherit specialArgs;
              modules = laptop ++ [
                ./hosts/fabio-macbook/configuration.nix
                inputs.sops-nix.nixosModules.sops
                inputs.home-manager.nixosModules.home-manager
                {
                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    backupFileExtension = "backup";
                    users.fabio.imports = homeImports.fabio-macbook;
                    extraSpecialArgs = specialArgs;
                  };
                }
              ];
            };
          };
        };

      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        {
          # Nix Formatter
          formatter = pkgs.alejandra;
        };
    };
}
