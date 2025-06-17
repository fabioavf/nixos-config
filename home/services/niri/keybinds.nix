# /etc/nixos/home/services/niri/keybinds.nix
# Niri keybindings configuration

{ config, ... }:

{
  programs.niri.settings.binds = with config.lib.niri.actions; {
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
    "Mod+Up".action = focus-window-or-workspace-up;
    "Mod+Down".action = focus-window-or-workspace-down;

    # Window movement (arrow keys)
    "Mod+Shift+Left".action = move-column-left;
    "Mod+Shift+Right".action = move-column-right;
    "Mod+Shift+Up".action = move-window-up-or-to-workspace-up;
    "Mod+Shift+Down".action = move-window-down-or-to-workspace-down;

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

    # Move windows to workspaces (1-9)
    "Mod+Shift+1".action.move-column-to-workspace = 1;
    "Mod+Shift+2".action.move-column-to-workspace = 2;
    "Mod+Shift+3".action.move-column-to-workspace = 3;
    "Mod+Shift+4".action.move-column-to-workspace = 4;
    "Mod+Shift+5".action.move-column-to-workspace = 5;
    "Mod+Shift+6".action.move-column-to-workspace = 6;
    "Mod+Shift+7".action.move-column-to-workspace = 7;
    "Mod+Shift+8".action.move-column-to-workspace = 8;
    "Mod+Shift+9".action.move-column-to-workspace = 9;

    # Window management
    "Mod+Shift+F".action = fullscreen-window;
    "Mod+F".action = maximize-column;

    # Screenshots
    "Print".action = screenshot;
    "Mod+Ctrl+Shift+4".action = spawn [
      "grim"
      "-g"
      "\"$(slurp)\""
      "-"
      "|"
      "wl-copy"
    ];

    # System shortcuts
    "Mod+Shift+M".action = quit;

    # Media keys
    "XF86AudioRaiseVolume".action = spawn [
      "pamixer"
      "--increase"
      "5"
    ];
    "XF86AudioLowerVolume".action = spawn [
      "pamixer"
      "--decrease"
      "5"
    ];
    "XF86AudioMute".action = spawn [
      "pamixer"
      "--toggle-mute"
    ];
    "XF86AudioPlay".action = spawn [
      "playerctl"
      "play-pause"
    ];
    "XF86AudioNext".action = spawn [
      "playerctl"
      "next"
    ];
    "XF86AudioPrev".action = spawn [
      "playerctl"
      "previous"
    ];

    # Brightness controls (especially useful for MacBook)
    "XF86MonBrightnessUp".action = spawn [
      "brightnessctl"
      "set"
      "5%+"
    ];
    "XF86MonBrightnessDown".action = spawn [
      "brightnessctl"
      "set"
      "5%-"
    ];

    # Wallpaper controls
    "Mod+Shift+W".action = spawn [
      "set-wallpaper"
      "random"
    ];
    "Mod+Ctrl+W".action = spawn [ "set-wallpaper" ];

    # Scroll wheel bindings
    "Mod+WheelScrollDown".action = focus-workspace-down;
    "Mod+WheelScrollUp".action = focus-workspace-up;
    "Mod+Shift+WheelScrollDown".action = focus-column-right;
    "Mod+Shift+WheelScrollUp".action = focus-column-left;
  };
}
