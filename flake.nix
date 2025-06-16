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
    
    # Niri flake
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    
  };

  outputs = { self, nixpkgs, sops-nix, home-manager, quickshell, niri, ... }@inputs: {
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
            niri.overlays.niri
          ];
          
          environment.systemPackages = with pkgs; [
            # Flake packages (desktop only)
            inputs.quickshell.packages.x86_64-linux.default
          ];
        })
      ];
    };

    # MacBook configuration (Intel laptop)
    nixosConfigurations.fabio-macbook = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/fabio-macbook/configuration.nix
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        
        # Custom overlays (including MacBook audio driver)
        ({ config, lib, pkgs, inputs, ... }: {
          nixpkgs.overlays = [
            (import ./overlays/default.nix)
            niri.overlays.niri
          ];
          
          environment.systemPackages = with pkgs; [
            # Flake packages (MacBook)
            inputs.quickshell.packages.x86_64-linux.default
          ];
        })
      ];
    };
  };
}
