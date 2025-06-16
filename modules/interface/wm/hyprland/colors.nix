# Monochrome Ocean Wave Theme - Colors Configuration for NixOS

{
  # Wallpaper path
  image = "/home/fabio/Pictures/Wallpapers/w6.jpg";

  # Pure monochrome palette - blacks, grays, and whites
  background = "rgba(0a0a0aff)";           # Pure black depths
  surface = "rgba(1a1a1aff)";              # Dark charcoal
  surface_container = "rgba(2a2a2aff)";     # Medium gray
  surface_bright = "rgba(4a4a4aff)";        # Light gray
  on_surface = "rgba(f5f5f5ff)";           # Pure white foam

  # Primary monochrome - subtle gray variations
  primary = "rgba(e0e0e0ff)";              # Light gray
  primary_container = "rgba(3a3a3aff)";     # Dark gray container
  on_primary = "rgba(0f0f0fff)";           # Near black
  on_primary_container = "rgba(f0f0f0ff)";  # Off white

  # Secondary monochrome
  secondary = "rgba(c0c0c0ff)";            # Medium light gray
  secondary_container = "rgba(2f2f2fff)";   # Dark container
  on_secondary = "rgba(1f1f1fff)";         # Dark text
  on_secondary_container = "rgba(e5e5e5ff)"; # Light text

  # All accent colors in grayscale
  blue = "rgba(d0d0d0ff)";                 # Light gray (was blue)
  blue_container = "rgba(2d2d2dff)";       # Dark gray container
  green = "rgba(c5c5c5ff)";                # Medium gray (was green)
  green_container = "rgba(252525ff)";      # Dark container
  orange = "rgba(b5b5b5ff)";               # Medium gray (was orange)
  orange_container = "rgba(202020ff)";     # Dark container

  # Functional colors in monochrome
  error = "rgba(a0a0a0ff)";                # Medium gray for errors
  error_container = "rgba(1e1e1eff)";      # Dark container
  warning = "rgba(d5d5d5ff)";              # Light gray for warnings
  success = "rgba(b0b0b0ff)";              # Medium gray for success

  # Monochrome neutrals
  outline = "rgba(505050ff)";              # Medium outline
  outline_variant = "rgba(353535ff)";      # Darker outline
  surface_variant = "rgba(303030ff)";      # Surface variant
  on_surface_variant = "rgba(c8c8c8ff)";   # Light on surface

  # Pure blacks and whites
  shadow = "rgba(000000ff)";               # Pure black shadow
  scrim = "rgba(000000ff)";                # Pure black scrim
  inverse_surface = "rgba(fafafaff)";      # Pure white
  inverse_on_surface = "rgba(151515ff)";   # Dark on white
}