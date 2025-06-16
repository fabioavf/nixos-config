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
        "NIXOS_OZONE_WL" = "1";
        "XDG_SESSION_TYPE" = "wayland";
        "XDG_SESSION_DESKTOP" = "niri";
        "XDG_CURRENT_DESKTOP" = "niri";
        "QT_QPA_PLATFORM" = "wayland";
        "GDK_BACKEND" = "wayland";
      };

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
          tap = isMacBook; # Enable tap on MacBook, disable on desktop
          dwt = true;
          middle-emulation = true;
          accel-speed = if isMacBook then 0.2 else 0.0;
          accel-profile = "adaptive";
          scroll-method = "two-finger";
          click-method = "clickfinger";
        };

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
            position = { x = 0; y = 0; };
          };
        })
        (lib.mkIf isDesktop {
          # Adjust this to match your actual desktop monitor output name
          # You can find it with: niri msg outputs
          "DP-1" = {
            mode = {
              width = 3840;
              height = 2160;
              refresh = 60.0;
            };
            scale = 1.5;
            position = { x = 0; y = 0; };
          };
        })
      ];

      # Enhanced layout configuration
      layout = {
        gaps = 16;
        center-focused-column = "on-overflow";
        preset-column-widths = [
          { proportion = 0.33; }
          { proportion = 0.5; }
          { proportion = 0.67; }
        ];
        default-column-width = { proportion = 0.5; };
        focus-ring = {
          enable = true;
          width = 4;
          active.color = "#7c3aed";
          inactive.color = "#6b7280";
        };
        border = {
          enable = true;
          width = 2;
          active.color = "#a855f7";
          inactive.color = "#4b5563";
        };
      };

      # Window rules
      window-rules = [
        {
          matches = [{ app-id = "firefox"; }];
          default-column-width = { proportion = 0.67; };
        }
        {
          matches = [{ app-id = "nautilus"; }];
          default-column-width = { proportion = 0.33; };
        }
      ];


      # Comprehensive keybindings with arrow key navigation
      binds = with config.lib.niri.actions; {
        # Application shortcuts
        "Mod+Return".action = spawn "alacritty";
        "Mod+Q".action = close-window;
        "Mod+E".action = spawn "nautilus";
        "Mod+Space".action = spawn "fuzzel";
        "Mod+Shift+E".action = quit;
        "Mod+D".action = spawn "discord";
        "Mod+B".action = spawn "firefox";
        
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
        "Mod+F".action = fullscreen-window;

        # Screenshots
        "Print".action = screenshot;
        "Mod+Ctrl+Shift+4".action = screenshot;

        # System shortcuts
        "Mod+L".action = spawn "swaylock";
        "Mod+Shift+Q".action = quit;
        
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
      } // lib.optionalAttrs isMacBook {
        # MacBook-specific function key shortcuts
        "Fn+F1".action = spawn ["brightnessctl" "set" "5%-"];
        "Fn+F2".action = spawn ["brightnessctl" "set" "5%+"];
        "Fn+F10".action = spawn ["pamixer" "--toggle-mute"];
        "Fn+F11".action = spawn ["pamixer" "--decrease" "5"];
        "Fn+F12".action = spawn ["pamixer" "--increase" "5"];
      };
    };
  };
}
