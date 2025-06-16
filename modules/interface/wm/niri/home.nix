{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}: let
  # Machine detection
  isMacBook = osConfig.networking.hostName == "fabio-macbook";
  isDesktop = osConfig.networking.hostName == "fabio-nixos";

  makeCommand = command: {
    command = [command];
  };
in {
  # Niri-specific tools
  home.packages = with pkgs; [
    # Wayland/Niri tools
    grim # screenshot tool
    slurp # area selection for screenshots
    wl-clipboard # clipboard utilities
    swww # wallpaper daemon
    swaylock # screen locker
    alacritty # terminal (niri default)
    fuzzel # app launcher (niri default)

    # Additional tools for enhanced experience
    playerctl # media control
    brightnessctl # brightness control
    pamixer # audio control
  ];

  # Enable niri with comprehensive configuration
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;

    settings = {
      # Environment variables
      environment = {
        "CLUTTER_BACKEND" = "wayland";
        "NIXOS_OZONE_WL" = "1";
        "XDG_SESSION_TYPE" = "wayland";
        "XDG_SESSION_DESKTOP" = "niri";
        "XDG_CURRENT_DESKTOP" = "niri";
        "QT_QPA_PLATFORM" = "wayland";
        "GDK_BACKEND" = "wayland";
        "MOZ_ENABLE_WAYLAND" = "1";
        "SDL_VIDEODRIVER" = "wayland";

      };

      spawn-at-startup = [
        (makeCommand "swww-daemon")
      ];

      # Enhanced input configuration
      input = {
        keyboard = {
          xkb = {
            layout = "us";
          };
          repeat-delay = 600;
          repeat-rate = 25;
        };

        touchpad = {
          natural-scroll = true;
	        tap = false;
          dwt = true;
          middle-emulation = true;
          accel-speed = if isMacBook then 0.2 else 0.0;
          accel-profile = "adaptive";
          scroll-method = "two-finger";
          click-method = "clickfinger";
        };

        focus-follows-mouse.enable = true;
        warp-mouse-to-focus = true;
        workspace-auto-back-and-forth = true;

        mouse = {
          natural-scroll = false;
          accel-speed = 0.0;
          accel-profile = "flat";
        };
      };

      # Conditional output configuration
      outputs = lib.mkMerge [
        (lib.mkIf isMacBook {
          "eDP-1" = {
            mode = {
              width = 2560;
              height = 1600;
              refresh = 60.0;
            };
            scale = 1.6;
          };
        })
        (lib.mkIf isDesktop {
          "HDMI-A-3" = {
            mode = {
              width = 3840;
              height = 2160;
              refresh = 60.0;
            };
            scale = 1.5;
          };
        })
      ];

      cursor = {
        size = 20;
      };

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
        preset-column-widths = [
          {proportion = 0.25;}
          {proportion = 0.5;}
          {proportion = 0.75;}
          {proportion = 1.0;}
        ];
        default-column-width = {proportion = 0.5;};

        gaps = 6;
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
      };

      animations.shaders.window-resize = ''
        vec4 resize_color(vec3 coords_curr_geo, vec3 size_curr_geo) {
          vec3 coords_next_geo = niri_curr_geo_to_next_geo * coords_curr_geo;

          vec3 coords_stretch = niri_geo_to_tex_next * coords_curr_geo;
          vec3 coords_crop = niri_geo_to_tex_next * coords_next_geo;

          // We can crop if the current window size is smaller than the next window
          // size. One way to tell is by comparing to 1.0 the X and Y scaling
          // coefficients in the current-to-next transformation matrix.
          bool can_crop_by_x = niri_curr_geo_to_next_geo[0][0] <= 1.0;
          bool can_crop_by_y = niri_curr_geo_to_next_geo[1][1] <= 1.0;

          vec3 coords = coords_stretch;
          if (can_crop_by_x)
              coords.x = coords_crop.x;
          if (can_crop_by_y)
              coords.y = coords_crop.y;

          vec4 color = texture2D(niri_tex_next, coords.st);

          // However, when we crop, we also want to crop out anything outside the
          // current geometry. This is because the area of the shader is unspecified
          // and usually bigger than the current geometry, so if we don't fill pixels
          // outside with transparency, the texture will leak out.
          //
          // When stretching, this is not an issue because the area outside will
          // correspond to client-side decoration shadows, which are already supposed
          // to be outside.
          if (can_crop_by_x && (coords_curr_geo.x < 0.0 || 1.0 < coords_curr_geo.x))
            color = vec4(0.0);
          if (can_crop_by_y && (coords_curr_geo.y < 0.0 || 1.0 < coords_curr_geo.y))
            color = vec4(0.0);

          return color;
        }
      '';

      hotkey-overlay.skip-at-startup = true;

      # Comprehensive keybindings with arrow key navigation
      binds = with config.lib.niri.actions; {
        # Application shortcuts
        "Mod+Return".action = spawn "alacritty";
        "Mod+Q".action = close-window;
        "Mod+E".action = spawn "nautilus";
        "Mod+Space".action = spawn "fuzzel";
        "Mod+Shift+E".action = quit;
        "Mod+B".action = spawn "app.zen_browser.zen";

        # Focus navigation (arrow keys)
        "Mod+Left".action = focus-column-left;
        "Mod+Right".action = focus-column-right;
        "Mod+Up".action = focus-window-up;
        "Mod+Down".action = focus-window-down;

        # Window movement (arrow keys)
        "Mod+Shift+Left".action = move-column-left;
        "Mod+Shift+Right".action = move-column-right;
        "Mod+Shift+Up".action = move-window-up;
        "Mod+Shift+Down".action = move-window-down;

        # Window resizing
        "Mod+Equal".action = set-column-width "+10%";
        "Mod+Minus".action = set-column-width "-10%";
        "Mod+Shift+Equal".action = set-window-height "+10%";
        "Mod+Shift+Minus".action = set-window-height "-10%";

        # Workspace navigation (1-9)
        "Mod+1".action = focus-workspace 1;
        "Mod+2".action = focus-workspace 2;
        "Mod+3".action = focus-workspace 3;
        "Mod+4".action = focus-workspace 4;
        "Mod+5".action = focus-workspace 5;
        "Mod+6".action = focus-workspace 6;
        "Mod+7".action = focus-workspace 7;
        "Mod+8".action = focus-workspace 8;
        "Mod+9".action = focus-workspace 9;

        # Window management (using basic actions that work)
        "Mod+Shift+F".action = fullscreen-window;

        # Screenshots
        "Print".action = spawn ["grim" "-g" "\"$(slurp)\"" "-" "|" "wl-copy"];
        "Mod+Ctrl+Shift+4".action = screenshot;

        # System shortcuts
        "Mod+Shift+M".action = quit;

        # Media keys
        "XF86AudioRaiseVolume".action = spawn ["pamixer" "--increase" "5"];
        "XF86AudioLowerVolume".action = spawn ["pamixer" "--decrease" "5"];
        "XF86AudioMute".action = spawn ["pamixer" "--toggle-mute"];
        "XF86AudioPlay".action = spawn ["playerctl" "play-pause"];
        "XF86AudioNext".action = spawn ["playerctl" "next"];
        "XF86AudioPrev".action = spawn ["playerctl" "previous"];

        # Brightness controls (especially useful for MacBook)
        "XF86MonBrightnessUp".action = spawn ["brightnessctl" "set" "5%+"];
        "XF86MonBrightnessDown".action = spawn ["brightnessctl" "set" "5%-"];

        # Scroll wheel bindings
        "Mod+WheelScrollDown".action = focus-workspace-down;
        "Mod+WheelScrollUp".action = focus-workspace-up;
        "Mod+Shift+WheelScrollDown".action = focus-column-right;
        "Mod+Shift+WheelScrollUp".action = focus-column-left;
      };
    };
  };
}
