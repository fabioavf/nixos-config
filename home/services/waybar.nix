# /etc/nixos/home/services/waybar.nix
# Waybar status bar configuration

{
  pkgs,
  ...
}:

{
  # Enable waybar
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;

    # Waybar configuration
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 48;
        spacing = 0;

        # Module layout
        modules-left = [
          "niri/workspaces"
          "niri/window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "custom/keyboard-layout"
          "cpu"
          "memory"
          "disk"
          "network"
          "pulseaudio"
          "tray"
          "battery"
        ];

        # Workspaces module
        "niri/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "󰲠";
            "2" = "󰲢";
            "3" = "󰲤";
            "4" = "󰲦";
            "5" = "󰲨";
            "6" = "󰲪";
            "7" = "󰲬";
            "8" = "󰲮";
            "9" = "󰲰";
            "default" = "󰊠";
          };
          on-click = "activate";
          sort-by-number = true;
        };

        # Window title
        "niri/window" = {
          format = "{title}";
          max-length = 50;
          separate-outputs = true;
        };

        # Clock
        "clock" = {
          format = "{:%H:%M}";
          format-alt = "{:%Y-%m-%d %H:%M:%S}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          on-click = "gnome-calendar";
        };

        # System tray
        "tray" = {
          icon-size = 21;
          spacing = 10;
        };

        # Audio
        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-bluetooth = "{icon} {volume}%";
          format-bluetooth-muted = "󰸈 {icon}";
          format-muted = "󰸈";
          format-source = " {volume}%";
          format-source-muted = "";
          format-icons = {
            headphone = "󰋋";
            hands-free = "󱡏";
            headset = "󰋎";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "pavucontrol";
          on-click-right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
          on-scroll-up = "pactl set-sink-volume @DEFAULT_SINK@ +2%";
          on-scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -2%";
        };

        # CPU usage
        "cpu" = {
          format = "󰍛  {usage}%";
          tooltip = false;
          interval = 1;
        };

        # Memory usage
        "memory" = {
          format = "󰾆  {used:.1f} GB";
          tooltip-format = "Used: {used:.1f}GB\nAvailable: {avail:.1f}GB\nTotal: {total:.1f}GB";
          interval = 1;
        };

        # Disk usage
        "disk" = {
          format = "󰋊  {free}";
          path = "/";
          tooltip-format = "Used: {used}GB\nFree: {free}GB\nTotal: {total}GB";
          interval = 30;
        };

        # Network
        "network" = {
          format-wifi = "󰤨  {signalStrength}%";
          format-ethernet = "󰈀  Connected";
          format-linked = "󰈂 {ifname}";
          format-disconnected = "󰤭 Disconnected";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
          tooltip-format = "{ifname} via {gwaddr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%) 󰤨";
          on-click = "nm-connection-editor";
        };

        # Battery (for laptop)
        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰂄 {capacity}%";
          format-alt = "{icon} {time}";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          on-click = "gnome-power-statistics";
        };

        # Custom keyboard layout module
        "custom/keyboard-layout" = {
          exec = "swaymsg -t get_inputs | jq -r '.[] | select(.type==\"keyboard\") | .xkb_active_layout_name' | head -1";
          interval = 1;
          format = " {}";
          tooltip = false;
        };
      };
    };

    # Metallic gradient Waybar styling
    style = ''
      * {
        border: none;
        font-family: "Inter", "SF Pro Display", "Roboto", sans-serif;
        font-size: 13px;
        font-weight: 500;
        min-height: 0;
        border-radius: 0;
        /* Smooth all transitions */
        transition-property: background-color, background-image, color, box-shadow, opacity;
        transition-duration: 0.3s;
        transition-timing-function: cubic-bezier(0.4, 0.0, 0.2, 1);
      }

      /* Main bar with metallic gradient */
      window#waybar {
        background-image: linear-gradient(
          to bottom,
          #0A0A0C 0%,
          #141416 50%,
          #0A0A0C 100%
        );
        color: #E8EAED;
        padding: 6px 8px;
        box-shadow:
          0 2px 10px rgba(0, 0, 0, 0.8),
          inset 0 1px 0 rgba(148, 152, 161, 0.1),
          inset 0 -1px 0 rgba(0, 0, 0, 0.5);
      }

      /* Module sections */
      .modules-left,
      .modules-center,
      .modules-right {
        background: transparent;
      }

      /* Workspace container with fluid shape */
      #workspaces {
        background-image: linear-gradient(
          135deg,
          #1C1E22 0%,
          #2A2D33 50%,
          #1C1E22 100%
        );
        border-radius: 24px;
        padding: 3px 6px;
        margin: 2px 12px 2px 4px;
        box-shadow:
          0 4px 8px rgba(0, 0, 0, 0.4),
          inset 0 1px 0 rgba(148, 152, 161, 0.08),
          inset 0 -1px 2px rgba(0, 0, 0, 0.3);
      }

      #workspaces button {
        background: transparent;
        color: #9AA0A6;
        border-radius: 18px;
        padding: 5px 14px;
        margin: 1px 2px;
        min-width: 36px;
        transition: all 0.3s cubic-bezier(0.4, 0.0, 0.2, 1);
      }

      #workspaces button:hover {
        background-image: linear-gradient(
          135deg,
          rgba(148, 152, 161, 0.15),
          rgba(148, 152, 161, 0.05)
        );
        color: #E8EAED;
        box-shadow:
          0 2px 4px rgba(0, 0, 0, 0.2),
          inset 0 1px 0 rgba(148, 152, 161, 0.1);
      }

      #workspaces button.active {
        background-image: linear-gradient(
          135deg,
          #44474F 0%,
          #5A5E67 50%,
          #44474F 100%
        );
        color: #FFFFFF;
        font-weight: 600;
        box-shadow:
          0 2px 6px rgba(0, 0, 0, 0.3),
          inset 0 1px 0 rgba(148, 152, 161, 0.2),
          inset 0 -1px 0 rgba(0, 0, 0, 0.2);
      }

      #workspaces button.urgent {
        background-image: linear-gradient(
          135deg,
          #6B4445 0%,
          #8A5556 100%
        );
        color: #FFFFFF;
        font-weight: 600;
      }

      /* Window title with metallic surface */
      #window {
        background-image: linear-gradient(
          135deg,
          #1C1E22 0%,
          #26282D 100%
        );
        color: #9AA0A6;
        border-radius: 20px;
        padding: 6px 18px;
        margin: 2px 8px;
        box-shadow:
          0 3px 6px rgba(0, 0, 0, 0.3),
          inset 0 1px 0 rgba(148, 152, 161, 0.05);
        font-weight: 400;
      }

      /* Clock with metallic shine */
      #clock {
        background-image: linear-gradient(
          135deg,
          #2A2D33 0%,
          #383C44 50%,
          #2A2D33 100%
        );
        color: #FFFFFF;
        border-radius: 20px;
        padding: 7px 22px;
        margin: 2px 12px;
        box-shadow:
          0 4px 10px rgba(0, 0, 0, 0.4),
          inset 0 1px 0 rgba(148, 152, 161, 0.15),
          inset 0 -1px 2px rgba(0, 0, 0, 0.3);
        font-weight: 600;
        font-size: 14px;
        letter-spacing: 0.5px;
      }

      /* System modules with liquid metal appearance */
      #tray,
      #pulseaudio,
      #network,
      #battery,
      #cpu,
      #memory,
      #disk,
      #custom-keyboard-layout {
        background-image: linear-gradient(
          135deg,
          #1C1E22 0%,
          #26282D 100%
        );
        color: #E8EAED;
        border-radius: 18px;
        padding: 6px 14px;
        margin: 2px 3px;
        box-shadow:
          0 3px 6px rgba(0, 0, 0, 0.3),
          inset 0 1px 0 rgba(148, 152, 161, 0.06);
        transition: all 0.3s cubic-bezier(0.4, 0.0, 0.2, 1);
      }

      /* Hover effects with metallic glow */
      #pulseaudio:hover,
      #network:hover,
      #battery:hover,
      #cpu:hover,
      #memory:hover,
      #disk:hover,
      #custom-keyboard-layout:hover {
        background-image: linear-gradient(
          135deg,
          #2A2D33 0%,
          #34373E 100%
        );
        box-shadow:
          0 4px 10px rgba(0, 0, 0, 0.4),
          0 0 20px rgba(148, 152, 161, 0.1),
          inset 0 1px 0 rgba(148, 152, 161, 0.1);
      }

      /* System tray with subtle styling */
      #tray {
        padding: 4px 10px;
        background-image: linear-gradient(
          135deg,
          rgba(28, 30, 34, 0.8),
          rgba(38, 40, 45, 0.8)
        );
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
        opacity: 0.6;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-image: linear-gradient(
          135deg,
          #6B4445 0%,
          #8A5556 100%
        );
      }

      /* Audio widget muted state */
      #pulseaudio.muted {
        background-image: linear-gradient(
          135deg,
          #1A1A1C 0%,
          #202022 100%
        );
        color: #5A5E67;
        opacity: 0.7;
      }

      /* Network disconnected state */
      #network.disconnected {
        background-image: linear-gradient(
          135deg,
          #1A1A1C 0%,
          #202022 100%
        );
        color: #5A5E67;
        opacity: 0.7;
      }

      /* Battery with metallic green */
      #battery {
        background-image: linear-gradient(
          135deg,
          #1C2622 0%,
          #263330 100%
        );
        color: #A8F5C7;
      }

      #battery.charging,
      #battery.plugged {
        background-image: linear-gradient(
          135deg,
          #1E3A2F 0%,
          #2A4A3E 100%
        );
        color: #A8F5C7;
        box-shadow:
          0 3px 8px rgba(0, 0, 0, 0.3),
          0 0 15px rgba(168, 245, 199, 0.15),
          inset 0 1px 0 rgba(168, 245, 199, 0.1);
      }

      @keyframes battery-critical {
        0% {
          background-image: linear-gradient(
            135deg,
            #3A1A1C 0%,
            #4A2022 100%
          );
          color: #FFB4AB;
        }
        50% {
          background-image: linear-gradient(
            135deg,
            #6B4445 0%,
            #8A5556 100%
          );
          color: #FFFFFF;
          box-shadow:
            0 3px 10px rgba(255, 180, 171, 0.3),
            0 0 20px rgba(255, 180, 171, 0.2);
        }
        100% {
          background-image: linear-gradient(
            135deg,
            #3A1A1C 0%,
            #4A2022 100%
          );
          color: #FFB4AB;
        }
      }

      #battery.critical {
        animation: battery-critical 1.5s ease-in-out infinite;
      }

      #battery.warning {
        background-image: linear-gradient(
          135deg,
          #3A3A1C 0%,
          #4A4A22 100%
        );
        color: #FFE082;
      }

      /* CPU with subtle animation potential */
      #cpu {
        background-image: linear-gradient(
          135deg,
          #1C1E22 0%,
          #26282D 100%
        );
      }

      /* Memory with blue tint */
      #memory {
        background-image: linear-gradient(
          135deg,
          #1C1E26 0%,
          #262833 100%
        );
      }

      /* Disk with purple tint */
      #disk {
        background-image: linear-gradient(
          135deg,
          #201C26 0%,
          #2A2633 100%
        );
      }

      /* Tooltip with metallic styling */
      tooltip {
        background-image: linear-gradient(
          135deg,
          #2A2D33 0%,
          #34373E 100%
        );
        color: #E8EAED;
        border-radius: 12px;
        border: 1px solid rgba(148, 152, 161, 0.1);
        box-shadow:
          0 8px 20px rgba(0, 0, 0, 0.6),
          inset 0 1px 0 rgba(148, 152, 161, 0.1);
      }

      tooltip label {
        padding: 8px 14px;
        font-size: 12px;
      }
    '';
  };

  # Additional packages for waybar functionality
  home.packages = with pkgs; [
    waybar
    # For network module
    networkmanagerapplet
    # For audio control
    pavucontrol
    # For power statistics (if on laptop)
    gnome-power-manager
    # For keyboard layout detection
    xorg.setxkbmap
    jq
  ];
}
