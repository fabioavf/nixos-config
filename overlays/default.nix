# /etc/nixos/overlays/default.nix
# Main overlays file that combines all overlay modules

# Import and merge all overlays
(import ./packages.nix)