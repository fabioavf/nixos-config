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
    
    # Claude Desktop
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, sops-nix, home-manager, quickshell, claude-desktop, ... }@inputs: {
    # Desktop configuration (AMD gaming workstation)
    nixosConfigurations.fabio-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/fabio-nixos/configuration.nix
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        
        # Custom packages overlay
        ({ config, lib, pkgs, inputs, ... }: {
          nixpkgs.overlays = [
            # Claude Code overlay
            (final: prev: {
              claude-code = final.stdenv.mkDerivation rec {
                pname = "claude-code";
                version = "1.0.18";

                src = final.fetchurl {
                  url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
                  sha256 = "bY+lkBeGYGy3xLcoo6Hlf5223z1raWuatR0VMQPfxKc=";
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
            # Flake packages (desktop only)
            inputs.quickshell.packages.x86_64-linux.default
            inputs.claude-desktop.packages.x86_64-linux.default
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
        
        # MacBook-specific overlay (minimal packages)
        ({ config, lib, pkgs, inputs, ... }: {
          nixpkgs.overlays = [
            # Claude Code overlay (shared)
            (final: prev: {
              claude-code = final.stdenv.mkDerivation rec {
                pname = "claude-code";
                version = "1.0.18";

                src = final.fetchurl {
                  url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
                  sha256 = "bY+lkBeGYGy3xLcoo6Hlf5223z1raWuatR0VMQPfxKc=";
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
          
          # MacBook packages (lightweight but complete development setup)
          environment.systemPackages = with pkgs; [
            # Flake packages (shared with desktop)
            inputs.quickshell.packages.x86_64-linux.default
            inputs.claude-desktop.packages.x86_64-linux.default
            
            # Essential laptop tools
            impala            # WiFi management via terminal
            moonlight-qt      # Game streaming client
          ];
        })
      ];
    };
  };
}
