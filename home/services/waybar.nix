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
        height = 34;
        spacing = 4;
        
        # Module layout
        modules-left = [ "niri/workspaces" "niri/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "tray" "pulseaudio" "network" "battery" "custom/power" ];
        
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
        
        # Power menu
        "custom/power" = {
          format = "󰐥";
          tooltip = "Power Menu";
          on-click = "niri msg action power-off-screen";
          on-click-right = "systemctl suspend";
        };
      };
    };
    
    # Waybar styling
    style = ''
      * {
        border: none;
        font-family: "JetBrains Mono", sans-serif;
        font-size: 13px;
        min-height: 0;
      }
      
      window#waybar {
        background-color: rgba(30, 30, 46, 0.9);
        color: #cdd6f4;
        transition-property: background-color;
        transition-duration: 0.5s;
        border-bottom: 2px solid rgba(137, 180, 250, 0.3);
      }
      
      button {
        box-shadow: inset 0 -3px transparent;
        border: none;
        border-radius: 0;
      }
      
      button:hover {
        background: inherit;
        box-shadow: inset 0 -3px #89b4fa;
      }
      
      #workspaces button {
        padding: 0 8px;
        background-color: transparent;
        color: #6c7086;
      }
      
      #workspaces button:hover {
        background: rgba(137, 180, 250, 0.2);
        color: #cdd6f4;
      }
      
      #workspaces button.active {
        background-color: #89b4fa;
        color: #1e1e2e;
      }
      
      #workspaces button.urgent {
        background-color: #f38ba8;
        color: #1e1e2e;
      }
      
      #mode {
        background-color: #64727d;
        border-bottom: 3px solid #cdd6f4;
      }
      
      #clock,
      #battery,
      #cpu,
      #memory,
      #disk,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #custom-media,
      #tray,
      #mode,
      #idle_inhibitor,
      #custom-power {
        padding: 0 10px;
        color: #cdd6f4;
      }
      
      #window,
      #workspaces {
        margin: 0 4px;
      }
      
      .modules-left > widget:first-child > #workspaces {
        margin-left: 0;
      }
      
      .modules-right > widget:last-child > #workspaces {
        margin-right: 0;
      }
      
      #clock {
        background-color: rgba(137, 180, 250, 0.2);
      }
      
      #battery {
        background-color: rgba(166, 227, 161, 0.2);
      }
      
      #battery.charging, #battery.plugged {
        color: #a6e3a1;
        background-color: rgba(166, 227, 161, 0.2);
      }
      
      @keyframes blink {
        to {
          background-color: rgba(243, 139, 168, 0.8);
          color: #1e1e2e;
        }
      }
      
      #battery.critical:not(.charging) {
        background-color: #f38ba8;
        color: #1e1e2e;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }
      
      label:focus {
        background-color: #1e1e2e;
      }
      
      #network {
        background-color: rgba(250, 179, 135, 0.2);
      }
      
      #network.disconnected {
        background-color: rgba(243, 139, 168, 0.2);
      }
      
      #pulseaudio {
        background-color: rgba(245, 194, 231, 0.2);
      }
      
      #pulseaudio.muted {
        background-color: rgba(108, 112, 134, 0.2);
        color: #6c7086;
      }
      
      #tray {
        background-color: rgba(166, 227, 161, 0.2);
      }
      
      #tray > .passive {
        -gtk-icon-effect: dim;
      }
      
      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: #f38ba8;
      }
      
      #custom-power {
        background-color: rgba(243, 139, 168, 0.2);
        color: #f38ba8;
      }
      
      #custom-power:hover {
        background-color: rgba(243, 139, 168, 0.4);
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