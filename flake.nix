# /etc/nixos/flake.nix
# Updated flake configuration with Claude Code overlay

{
  description = "Fabio's NixOS configuration";

  inputs = {
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
    
  };

  outputs = { self, nixpkgs, sops-nix, home-manager, quickshell, ... }@inputs: {
    # Desktop configuration (AMD gaming workstation)
    nixosConfigurations.fabio-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/fabio-nixos/configuration.nix
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        
        # Custom overlays
        ({ config, lib, pkgs, inputs, ... }: {
          nixpkgs.overlays = [
            (import ./overlays/default.nix)
          ];
          
          environment.systemPackages = with pkgs; [
            # Flake packages (desktop only)
            inputs.quickshell.packages.x86_64-linux.default
          ];
        })
      ];
    };
  };
}
