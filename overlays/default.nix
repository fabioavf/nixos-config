# /overlays/default.nix
# Main overlays file that combines all overlay modules

# Import and merge all overlays
final: prev: 
  # Merge all overlays
  (import ./packages.nix final prev) //
  (import ./macbook-audio.nix final prev)