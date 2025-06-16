{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}: let
  # Animation configuration inline for self-contained module
  animations = {
    enabled = true;
    
    # Animation curves
    bezier = [
      "linear, 0, 0, 1, 1"
      "md3_standard, 0.2, 0, 0, 1"
      "md3_decel, 0.05, 0.7, 0.1, 1"
      "md3_accel, 0.3, 0, 0.8, 0.15"
      "overshot, 0.05, 0.9, 0.1, 1.1"
      "crazyshot, 0.1, 1.5, 0.76, 0.92"
      "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
      "menu_decel, 0.1, 1, 0, 1"
      "menu_accel, 0.38, 0.04, 1, 0.07"
      "easeInOutCirc, 0.85, 0, 0.15, 1"
      "easeOutCirc, 0, 0.55, 0.45, 1"
      "easeOutExpo, 0.16, 1, 0.3, 1"
      "softAcDecel, 0.26, 0.26, 0.15, 1"
      "md2, 0.4, 0, 0.2, 1"
    ];
    
    # Animation configurations
    animation = [
      "windows, 1, 3, md3_decel, popin 60%"
      "windowsIn, 1, 3, md3_decel, popin 60%"
      "windowsOut, 1, 3, md3_accel, popin 60%"
      "border, 1, 10, default"
      "fade, 1, 3, md3_decel"
      "layersIn, 1, 3, menu_decel, slide"
      "layersOut, 1, 1.6, menu_accel"
      "fadeLayersIn, 1, 2, menu_decel"
      "fadeLayersOut, 1, 4.5, menu_accel"
      "workspaces, 1, 7, menu_decel, slide"
      "specialWorkspace, 1, 3, md3_decel, slidevert"
    ];
  };
in {
  # Hyprland-specific tools only
  home.packages = with pkgs; [
    # Wayland/Hyprland tools
    grim # screenshot tool
    slurp # area selection for screenshots  
    wl-clipboard # clipboard utilities
    swww # wallpaper daemon
    hyprpaper # wallpaper manager
    hyprpolkitagent # polkit agent
    hypridle # idle manager
    hyprlock # screen locker
  ];

  # Hyprland home configuration
  wayland.windowManager.hyprland = {
    enable = true;

    xwayland.enable = true;

    # Import environment variables for systemd services
    systemd.variables = ["--all"];

    settings = {

      # Monitor configuration
      monitor = [
        "eDP-1, 3840x2160@60, 0x0, 1.5"
      ];

      # Environment variables
      env = [
        "MANPAGER,sh -c 'col -bx | bat -l man -p'"
        "MANROFFOPT,-c"
        "LANG,en_US.UTF-8"
        "LANGUAGE,en_US"
        "LC_CTYPE,en_US.UTF-8"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "SDL_VIDEODRIVER,wayland"
        "HYPRCURSOR_THEME,Adwaita"
        "XCURSOR_THEME,Adwaita"
        "HYPRCURSOR_SIZE,24"
        "XCURSOR_SIZE,24"
        "HYPRSHOT_DIR,/home/fabio/Pictures/ScreenShot"
        "PATH,$HOME/.bun/bin:$PATH"
        "PATH,$HOME/fvm/default/bin:$PATH"
        "MOZ_DISABLE_RDD_SANDBOX,1"
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
        "BROWSER,zen"
      ];

      # Variables
      "$terminal" = "alacritty";
      "$fileManager" = "nautilus";
      "$browser" = "zen-browser";
      "$editor" = "zeditor";
      "$musicPlayer" = "spotify";
      "$emoji" = "wofi-emoji";
      "$mainMod" = "SUPER";

      # General settings
      general = {
        layout = "dwindle";
        resize_on_border = true;
        allow_tearing = true;
        gaps_in = 5;
        gaps_out = "14,14,14,14";
        border_size = 2;
        "col.active_border" = "rgba(e0e0e0ff)";  # primary color from your colors.conf
        "col.inactive_border" = "rgba(1a1a1aff)";  # surface color from your colors.conf
      };

      # Decoration settings
      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        
        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = false;
          xray = false;
          brightness = 1.0;
          contrast = 1.1;
          vibrancy = 0.2;
          noise = 0.02;
          popups = true;
          special = true;
        };
        
        shadow = {
          enabled = true;
          range = 20;
          render_power = 3;
          color = "0xee1a1a1a";
        };
        
        dim_inactive = false;
        dim_strength = 0.1;
        dim_special = 0.0;
      };

      # Animations
      animations = animations;

      # Dwindle layout
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Master layout
      master = {
        new_status = "master";
      };

      # Input settings
      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";
        numlock_by_default = true;
        follow_mouse = 1;
        sensitivity = 0;
        
        touchpad = {
          natural_scroll = false;
        };
      };

      # Gestures
      gestures = {
        workspace_swipe = false;
      };

      # XWayland settings
      xwayland = {
        force_zero_scaling = true;
      };

      # Misc settings
      misc = {
        vrr = 0;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
      };

      # Keybindings
      bind = [
        # Application controls
        "$mainMod, Return, exec, $terminal"
        "$mainMod, Q, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, Space, exec, /home/fabio/.config/quickshell/fabios-qs/utils/toggle-launcher.sh"
        "$mainMod, N, exec, $editor"
        "$mainMod, F, exec, $musicPlayer"
        "$mainMod, H, exec, $editor ~/.config/hypr"
        "$mainMod SHIFT, H, exec, $editor /etc/nixos"
        "$mainMod SHIFT, L, exec, hyprlock"
        "$mainMod, period, exec, $emoji"
        "$mainMod SHIFT, R, exec, hyprctl reload"

        # Window management
        "$mainMod, V, togglefloating,"
        "$mainMod, P, pseudo,"
        "$mainMod, J, togglesplit,"
        "$mainMod, F11, fullscreen,"
        "$mainMod SHIFT, F, fullscreen,"

        # Focus navigation
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # Move active window
        "$mainMod SHIFT, left, movewindow, l"
        "$mainMod SHIFT, right, movewindow, r"
        "$mainMod SHIFT, up, movewindow, u"
        "$mainMod SHIFT, down, movewindow, d"

        # Workspace navigation
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move windows to workspaces
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Special workspace
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"

        # Clipboard manager
        "$mainMod, comma, exec, alacritty --class clipse -e clipse"

        # Screenshots
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mainMod, Print, exec, grim -g \"$(slurp)\" ~/Pictures/Screenshots/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

        # Mouse workspace navigation
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        # Window resizing
        "$mainMod CTRL, left, resizeactive, -30 0"
        "$mainMod CTRL, right, resizeactive, 30 0"
        "$mainMod CTRL, up, resizeactive, 0 -30"
        "$mainMod CTRL, down, resizeactive, 0 30"

        # Media controls
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      # Mouse bindings
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # Repeating bindings
      bindle = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      # Window rules
      windowrulev2 = [
        # Floating windows
        "float, class:^(clipse)$"
        "float, class:^(com.clipse)$"
        "float, class:^(yad)$"
        "float, class:^(org.kde.polkit-kde-authentication-agent-1)$"
        "float, class:^(org.pulseaudio.pavucontrol)$"
        "float, class:^(xdg-desktop-portal-gtk)$"

        # Window sizes
        "size 622 652, class:^(clipse)$"
        "size 700 700, class:^(com.clipse)$"
        "size 800 600, class:^(org.pulseaudio.pavucontrol)$"
        "size 800 600, class:^(xdg-desktop-portal-gtk)$"

        # Opacity settings (0.90 transparency)
        "opacity 0.90 0.90, class:^(kitty)$"
        "opacity 0.90 0.90, class:^(org.gnome.Nautilus)$"
        "opacity 0.90 0.90, class:^(vesktop)$"
        "opacity 0.90 0.90, class:^(org.qbittorrent.qBittorrent)$"
        "opacity 0.90 0.90, class:^(spotify)$"
        "opacity 0.90 0.90, class:^(dev.zed.Zed)$"
        "opacity 0.90 0.90, class:^(clipse)$"
        "opacity 0.90 0.90, class:^(com.clipse)$"
        "opacity 0.90 0.90, class:^(yad)$"
        "opacity 0.90 0.90, class:^(hyprpolkitagent)$"
        "opacity 0.90 0.90, class:^(org.pulseaudio.pavucontrol)$"
        "opacity 0.90 0.90, class:^(xdg-desktop-portal-gtk)$"
        "opacity 0.90 0.90, class:^(nm-connection-editor)$"
      ];

      # Layer rules
      layerrule = [
        "ignorealpha 0.70,gtk-layer-shell"
        "ignorealpha 0.70,rofi"
        "ignorealpha 0.70,wallpaperpicker"
        "ignorealpha 0.70,control-center"
        "ignorealpha 0.70,quicksettings"
        "ignorealpha 0.70,app-launcher"
        "ignorealpha 0.70,osd"
        "ignorealpha 0.70,notifications*"
        "ignorealpha 0.70,notifications-popup"
        "ignorealpha 0.70,dashboard"
        "ignorealpha 0.70,popup-window"
        "ignorealpha 0.70,powermenu"
        "ignorealpha 0.70,verification"
        "ignorealpha 0.70,corner-t-r"
        "ignorealpha 0.70,corner-t-l"

        "blur,corner-t-l"
        "blur,corner-t-r"
        "blur,bar"
        "blur,osd"
        "blur,wallpaperpicker"
        "blur,notifications"
        "blur,notifications-popup"
        "blur,dashboard"
        "blur,app-launcher"
        "blur,control-center"
        "blur,quicksettings"
        "blur,popup-window"
        "blur,powermenu"
        "blur,verification"

        "animation popin 30%, popup-window"
        "animation popin 30%, powermenu"
        "animation popin 30%, verification"
        "animation slide top, dashboard"
        "animation slide top, wallpaperpicker"
        "animation slide right, control-center"
        "animation slide left, app-launcher"
        "animation slide top, bar"
        "animation slide top, notifications"
        "animation slide right,quicksettings"
        "animation slide top, weather"
        "animation fade, opaque-scrim"
        "animation fade, transparent-scrim"
        "animation fade, lockscreen"
        "noanim, selection"
        "noanim, hyprpicker"
        "noanim, foamshot-selection"
        "noanim, notifications-popup*"
        "animation slide bottom, osd"
        "noanim, swww"
        "ignorezero, waybar"
        "xray 1,gtk-layer-shell"
        "xray 1,bar"
        "xray 1,osd"
        "xray 1,calendar"
        "xray 1,notifications"
        "xray 1,dashboard"
        "xray 1,app-launcher"
        "xray 1,control-center"
        "xray 1,wallpaperpicker"
        "xray 1,popup-window"
        "xray 1,powermenu"
        "xray 1,verification"
        "xray 1,quicksettings"
      ];

      # Blur layer shell
      blurls = ["simple-bar"];

      # Startup applications
      exec-once = [
        "systemctl --user start hyprpolkitagent"
        "nm-applet &"
        "udiskie &"
        "clipse -listen"
        "hypridle"
        "polkit-kde-agent-1"
        "hyprpaper"
        "sunshine"
        "swww-daemon"
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        
        # Auto-start applications on specific workspaces
        "[workspace 1 silent] spotify --force-device-scale-factor=1.5"
        "[workspace 2 silent] app.zen_browser.zen"
        "[workspace 4 silent] discord"
        "[workspace 5 silent] corectrl"
        "[workspace 5 silent] qbittorrent"
      ];
    };
  };
}
