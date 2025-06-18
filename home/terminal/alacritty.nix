# /etc/nixos/home/terminal/alacritty.nix
# Alacritty terminal emulator configuration

{ config, lib, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;

    settings = {
      # Window configuration
      window = {
        decorations = "none";
        opacity = 0.85;
        title = "Alacritty";
        dynamic_title = true;
        startup_mode = "Windowed";

        dimensions = {
          columns = 80;
          lines = 24;
        };

        padding = {
          x = 12;
          y = 12;
        };

        class = {
          instance = "Alacritty";
          general = "Alacritty";
        };
      };

      # Scrolling configuration
      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      # Font configuration
      font = {
        size = 12;

        normal = {
          family = "Liberation Mono";
          style = "Regular";
        };

        bold = {
          family = "Liberation Mono";
          style = "Bold";
        };

        italic = {
          family = "Liberation Mono";
          style = "Italic";
        };

        bold_italic = {
          family = "Liberation Mono";
          style = "Bold Italic";
        };

        offset = {
          x = 0;
          y = 0;
        };

        glyph_offset = {
          x = 0;
          y = 0;
        };
      };

      # Cursor configuration
      cursor = {
        blink_interval = 750;
        unfocused_hollow = true;

        style = {
          shape = "Block";
          blinking = "On";
        };
      };

      # Mouse configuration
      mouse = {
        hide_when_typing = true;
      };
    };
  };
}
