# /etc/nixos/home/services/niri/layout.nix
# Layout configuration and visual settings

{ ... }:

{
  programs.niri.settings = {
    # Enhanced layout configuration
    layout = {
      focus-ring.enable = false;
      border = {
        enable = true;
        width = 1;
        active.color = "#7fb4ca";
        inactive.color = "#090e13";
      };
      shadow = {
        enable = true;
      };

      always-center-single-column = true;

      preset-column-widths = [
        { proportion = 0.25; }
        { proportion = 0.5; }
        { proportion = 0.75; }
        { proportion = 1.0; }
      ];
      default-column-width = {
        proportion = 0.7;
      };

      gaps = 16;
      struts = {
        left = 0;
        right = 0;
        top = 0;
        bottom = 0;
      };

      tab-indicator = {
        hide-when-single-tab = true;
        place-within-column = true;
        position = "left";
        corner-radius = 20.0;
        gap = -12.0;
        gaps-between-tabs = 10.0;
        width = 4.0;
        length.total-proportion = 0.1;
      };

      empty-workspace-above-first = true;
    };
  };
}
