# /etc/nixos/home/services/waybar.nix
# Waybar status bar configuration

{ config, lib, pkgs, ... }:

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
        modules-left = [ "niri/workspaces" "niri/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "tray" "pulseaudio" "network" "battery" ];
        
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
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
          on-click-right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
          on-scroll-up = "pactl set-sink-volume @DEFAULT_SINK@ +2%";
          on-scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -2%";
        };
        
        # Network
        "network" = {
          format-wifi = "󰤨 {signalStrength}%";
          format-ethernet = "󰈀 Connected";
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
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          on-click = "gnome-power-statistics";
        };
        
      };
    };
    
    # Material 3 Waybar styling
    style = ''
      * {
        border: none;
        font-family: "Roboto", "JetBrains Mono", sans-serif;
        font-size: 13px;
        font-weight: 500;
        min-height: 0;
        border-radius: 0;
      }
      
      /* Main bar with solid Material 3 background */
      window#waybar {
        background: #1C1B1F;
        color: #E6E0E9;
        padding: 8px 12px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
      }
      
      /* Material 3 elevated surface cards */
      .modules-left,
      .modules-center,
      .modules-right {
        background: transparent;
      }
      
      /* Workspace buttons as Material 3 chips */
      #workspaces {
        background: #2B2930;
        border-radius: 20px;
        padding: 2px 4px;
        margin: 4px 8px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
      }
      
      #workspaces button {
        background: transparent;
        color: #CAC4D0;
        border-radius: 16px;
        padding: 4px 12px;
        margin: 2px;
        min-width: 32px;
        transition: all 0.2s cubic-bezier(0.4, 0.0, 0.2, 1);
      }
      
      #workspaces button:hover {
        background: rgba(208, 188, 255, 0.08);
        color: #E6E0E9;
      }
      
      #workspaces button.active {
        background: #D0BCFF;
        color: #1C1B1F;
        font-weight: 600;
      }
      
      #workspaces button.urgent {
        background: #F2B8B5;
        color: #1C1B1F;
        font-weight: 600;
      }
      
      /* Window title in elevated card */
      #window {
        background: #2B2930;
        color: #E6E0E9;
        border-radius: 12px;
        padding: 6px 16px;
        margin: 4px 8px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
        font-weight: 400;
      }
      
      /* Clock as prominent center card */
      #clock {
        background: #381E72;
        color: #E8DEF8;
        border-radius: 16px;
        padding: 8px 20px;
        margin: 4px 12px;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.3);
        font-weight: 600;
        font-size: 14px;
      }
      
      /* Right side widgets as Material 3 cards */
      #tray,
      #pulseaudio,
      #network,
      #battery {
        background: #2B2930;
        color: #E6E0E9;
        border-radius: 12px;
        padding: 6px 12px;
        margin: 4px 4px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
        transition: all 0.2s cubic-bezier(0.4, 0.0, 0.2, 1);
      }
      
      /* Hover effects for interactive cards */
      #pulseaudio:hover,
      #network:hover,
      #battery:hover {
        background: #36343B;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.3);
      }
      
      /* System tray special styling */
      #tray {
        padding: 4px 8px;
      }
      
      #tray > .passive {
        -gtk-icon-effect: dim;
      }
      
      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background: #F2B8B5;
        color: #1C1B1F;
      }
      
      /* Audio widget states */
      #pulseaudio.muted {
        background: #49454F;
        color: #938F99;
      }
      
      /* Network states */
      #network.disconnected {
        background: #49454F;
        color: #938F99;
      }
      
      /* Battery widget with status colors */
      #battery {
        background: #1E4B3B;
        color: #A8F5C7;
      }
      
      #battery.charging,
      #battery.plugged {
        background: #1E4B3B;
        color: #A8F5C7;
      }
      
      @keyframes battery-critical {
        0% {
          background: #49191C;
          color: #FFB4AB;
        }
        50% {
          background: #F2B8B5;
          color: #1C1B1F;
        }
        100% {
          background: #49191C;
          color: #FFB4AB;
        }
      }
      
      #battery.critical {
        animation: battery-critical 1s ease-in-out infinite;
      }
      
      
      /* Tooltip styling */
      tooltip {
        background: #322F37;
        color: #E6E0E9;
        border-radius: 8px;
        border: none;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
      }
      
      tooltip label {
        padding: 6px 12px;
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
  ];
}