# /etc/nixos/flake.nix
# Updated flake configuration with proper integration

{
  description = "Fabio's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Quickshell flake
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Claude Desktop
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, quickshell, claude-desktop, ... }@inputs: {
    nixosConfigurations.fabio-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        
        # Flake packages module
        ({ config, lib, pkgs, inputs, ... }: {
          environment.systemPackages = with pkgs; [
            # Flake packages
            inputs.quickshell.packages.x86_64-linux.default
            inputs.claude-desktop.packages.x86_64-linux.default
          ];
        })
      ];
    };
  };
}
