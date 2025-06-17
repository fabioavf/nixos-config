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

      # Color scheme configuration
      colors = {
        primary = {
          background = "#16191e";
          foreground = "#e6e8eb";
        };

        cursor = {
          text = "#16191e";
          cursor = "#7d8287";
        };

        selection = {
          text = "#e6e8eb";
          background = "#2d3237";
        };

        normal = {
          black = "#16191e";
          red = "#696e75";
          green = "#4a4e52";
          yellow = "#7d8287";
          blue = "#60656b";    # Modified from original dark blue
          magenta = "#5a5f66";
          cyan = "#696e75";    # Modified from original dark cyan
          white = "#e6e8eb";
        };

        bright = {
          black = "#5a5f66";   # Modified from original dark black
          red = "#7f8388";
          green = "#60656b";
          yellow = "#a5a8ad";
          blue = "#4a4e52";
          magenta = "#5a5f66";
          cyan = "#60656b";
          white = "#f0f1f2";
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
