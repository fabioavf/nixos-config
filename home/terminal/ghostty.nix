# /etc/nixos/home/terminal/ghostty.nix

{ ... }:

{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      title = "Ghostty";
      class = "Ghostty";

      window-padding-x = 12;
      window-padding-y = 6;

      theme = "GitHub-Dark-Default";

      font-family = "Liberation Mono";
      font-family-bold = "Liberation Mono Bold";
      font-family-italic = "Liberation Mono Italic";
      font-family-bold-italic = "Liberation Mono Bold Italic";

      font-size = 12;

      background-opacity = 0.85;

      cursor-style = "underline";
      shell-integration-features = "no-cursor";

      confirm-close-surface = false;
    };
  };
}
