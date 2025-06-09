# /etc/nixos/flake.nix
# Updated flake configuration with Claude Code overlay

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
        
        # Custom packages overlay
        ({ config, lib, pkgs, inputs, ... }: {
          nixpkgs.overlays = [
            # Claude Code overlay
            (final: prev: {
              claude-code = final.stdenv.mkDerivation rec {
                pname = "claude-code";
                version = "1.0.17";

                src = final.fetchurl {
                  url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
                  sha256 = "0xsg7gzwcj8rpfq5qp638s3wslz5d7dyfisz8lbl6fskjyay9lnp";
                };

                nativeBuildInputs = [ final.makeWrapper ];
                buildInputs = [ final.nodejs ];

                unpackPhase = ''
                  tar -xzf $src
                  cd package
                '';

                installPhase = ''
                  runHook preInstall
                  
                  # Create the output directory structure
                  mkdir -p $out/lib/node_modules/@anthropic-ai/claude-code
                  mkdir -p $out/bin
                  
                  # Copy the package contents
                  cp -r . $out/lib/node_modules/@anthropic-ai/claude-code/
                  
                  # Create the executable wrapper (using correct file and binary name)
                  makeWrapper ${final.nodejs}/bin/node $out/bin/claude \
                    --add-flags "$out/lib/node_modules/@anthropic-ai/claude-code/cli.js"
                  
                  # Also create claude-code symlink for consistency
                  ln -s $out/bin/claude $out/bin/claude-code
                  
                  runHook postInstall
                '';

                meta = with final.lib; {
                  description = "Claude Code - AI coding assistant CLI";
                  homepage = "https://claude.ai";
                  license = licenses.mit;
                  maintainers = [ ];
                  platforms = platforms.unix;
                  mainProgram = "claude-code";
                };
              };
            })
          ];
          
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
