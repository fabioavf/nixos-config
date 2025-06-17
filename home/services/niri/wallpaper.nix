# /etc/nixos/home/services/niri/wallpaper.nix
# Simple wallpaper configuration using swaybg

{ config, lib, pkgs, ... }:

{
  # Simple wallpaper script using swaybg
  home.file.".local/bin/set-wallpaper" = {
    text = ''
      #!${pkgs.bash}/bin/bash
      
      WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
      
      # Function to set wallpaper
      set_wallpaper() {
        local wallpaper="$1"
        
        # If no wallpaper specified, find the first available one
        if [[ -z "$wallpaper" ]]; then
          wallpaper=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.jpeg" \) | head -n 1)
        elif [[ ! -f "$wallpaper" && -f "$WALLPAPER_DIR/$wallpaper" ]]; then
          # If it's just a filename, prepend the wallpaper directory
          wallpaper="$WALLPAPER_DIR/$wallpaper"
        fi
        
        if [[ ! -f "$wallpaper" ]]; then
          echo "No wallpaper files found in $WALLPAPER_DIR"
          echo "Add some images to ~/Pictures/Wallpapers/"
          exit 1
        fi
        
        # Kill any existing swaybg instances
        ${pkgs.procps}/bin/pkill swaybg 2>/dev/null || true
        
        # Set wallpaper with swaybg
        ${pkgs.swaybg}/bin/swaybg -i "$wallpaper" -m fill &
        
        echo "Wallpaper set to: $(basename "$wallpaper")"
      }
      
      # Function to set random wallpaper from directory
      random_wallpaper() {
        local random_file
        random_file=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.jpeg" \) | shuf -n 1)
        
        if [[ -n "$random_file" ]]; then
          set_wallpaper "$random_file"
        else
          echo "No wallpaper files found in $WALLPAPER_DIR"
          exit 1
        fi
      }
      
      # Main script logic
      case "''${1:-}" in
        random|rand|-r)
          random_wallpaper
          ;;
        list|-l)
          echo "Available wallpapers:"
          find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.jpeg" \) -printf "%f\n" 2>/dev/null | sort || \
          find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.jpeg" \) | xargs -I {} basename {} | sort
          ;;
        help|-h|--help)
          echo "Usage: set-wallpaper [wallpaper_file|random|list|help]"
          echo ""
          echo "Commands:"
          echo "  <file>     Set specific wallpaper file"
          echo "  random     Set random wallpaper from ~/Pictures/Wallpapers"
          echo "  list       List available wallpapers"
          echo "  help       Show this help message"
          echo ""
          echo "If no arguments provided, sets first available wallpaper"
          ;;
        "")
          set_wallpaper
          ;;
        *)
          set_wallpaper "$1"
          ;;
      esac
    '';
    executable = true;
  };

  # Systemd user service to set wallpaper on login
  systemd.user.services.wallpaper = {
    Unit = {
      Description = "Set wallpaper using swaybg";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash ${config.home.homeDirectory}/.local/bin/set-wallpaper";
      Environment = [
        "PATH=${lib.makeBinPath (with pkgs; [ swaybg coreutils findutils bash util-linux procps ])}"
        "HOME=${config.home.homeDirectory}"
        "WAYLAND_DISPLAY=wayland-1"
      ];
      # Shorter delay since swaybg works instantly
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
    };
    
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
