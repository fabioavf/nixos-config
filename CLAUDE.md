# Fabio's NixOS Configuration Documentation

## Overview
This is a comprehensive NixOS configuration built with flakes, featuring a modular structure for a high-performance gaming and development workstation with Hyprland desktop environment and AMD GPU support.

## System Information
- **Hostname**: fabio-nixos
- **Platform**: x86_64-linux AMD
- **GPU**: AMD RX 5600/5700 XT (Navi 10 - RDNA1)
- **CPU**: AMD (with KVM support)
- **Storage**: NVMe SSD with ext4 root, separate data partition
- **NixOS Version**: 25.05 (unstable branch)

## Architecture

### Main Configuration
- **flake.nix**: Flake configuration with custom overlays and external inputs
- **configuration.nix**: Main imports-only file that ties all modules together
- **hardware-configuration.nix**: Auto-generated hardware detection (do not edit)

### Module Structure
```
modules/
├── desktop/          # Desktop environment and applications
├── development/      # Programming tools and languages  
├── services/         # System services
└── system/          # Core system configuration
```

## Desktop Environment

### Hyprland Configuration (`modules/desktop/hyprland.nix`)
- **Compositor**: Hyprland with XWayland support
- **Portals**: XDG desktop portal with GTK support
- **Tools**: wofi, wl-clipboard, grim, slurp, hyprpaper
- **System tray**: NetworkManager applet, pavucontrol
- **Auto-mount**: udiskie for removable media
- **Authentication**: KDE polkit agent

### Applications (`modules/desktop/apps.nix`)
- **File manager**: Nautilus, ranger
- **Communication**: Discord
- **Media**: Spotify, VLC, OBS Studio
- **Productivity**: qbittorrent
- **GPU control**: CoreCtrl for AMD GPU management
- **Flatpak**: Enabled with proper XDG paths

### Audio (`modules/desktop/audio.nix`)
- **Backend**: PipeWire (PulseAudio disabled)
- **Features**: ALSA, 32-bit support, rtkit
- **Tools**: pulseaudio tools, wireplumber, wpctl

### Fonts (`modules/desktop/fonts.nix`)
- **System fonts**: Noto fonts family, Liberation TTF
- **Programming fonts**: Multiple Nerd Fonts variants
- **UI fonts**: IBM Plex, Material Symbols

### Gaming (`modules/desktop/gaming.nix`)
- **Steam**: Full setup with Proton-GE
- **GameMode**: Performance optimizations enabled
- **Tools**: MangoHud, Gamescope, Bottles
- **Wine**: Full Wine stack with DXVK
- **Hardware**: 32-bit graphics drivers, AMD Vulkan
- **Optimizations**: kernel parameters, firewall ports

### Theming (`modules/desktop/theming.nix`)
- **Theme**: Adwaita Dark system-wide
- **GTK**: Versions 2, 3, and 4 configured
- **Qt**: Qt5/Qt6 with Adwaita theme
- **Icons**: Adwaita, Papirus, Numix
- **Cursors**: Bibata, Vanilla DMZ

## Development Environment

### Editors (`modules/development/editors.nix`)
- **Modern**: Zed Editor, Neovim
- **Terminal**: Alacritty

### Languages (`modules/development/languages.nix`)
- **Version control**: Git, GitHub CLI, GitLab CLI, git-lfs
- **Containers**: Docker, docker-compose
- **System**: GCC compiler
- **JavaScript**: Node.js, Bun, node2nix
- **AI Tools**: Claude Code (custom package)
- **Python**: pyenv
- **Rust**: rustc, cargo

### Shell (`modules/development/shell.nix`)
- **Shell**: Zsh with Oh My Zsh
- **Prompt**: Starship
- **Plugins**: git, history, sudo, docker, extract
- **Aliases**: NixOS shortcuts, git shortcuts, directory navigation
- **Auto-start**: Hyprland on TTY1

### ROCm Support (`modules/development/rocm.nix`)
- **Purpose**: AMD GPU compute for ML/AI workloads
- **Compatibility**: RX 5600/5700 XT (Navi 10) support via HSA override
- **Libraries**: Full ROCm stack including MIOpen, ROCBlas, HIP
- **Environment**: HSA_OVERRIDE_GFX_VERSION="10.3.0" for compatibility
- **Permissions**: render group access, udev rules

## System Configuration

### Boot (`modules/system/boot.nix`)
- **Bootloader**: systemd-boot with EFI
- **Splash**: Plymouth with breeze theme
- **Graphics**: Early KMS for smooth transitions
- **Quiet boot**: Minimal boot messages

### Networking (`modules/system/networking.nix`)
- **Manager**: NetworkManager
- **Hostname**: fabio-nixos

### Locale (`modules/system/locale.nix`)
- **Timezone**: America/Sao_Paulo
- **Locale**: en_US.UTF-8

### Nix (`modules/system/nix.nix`)
- **Features**: Flakes, new nix command
- **Unfree**: Allowed
- **Garbage collection**: Weekly cleanup

### Performance (`modules/system/performance.nix`)
- **SSD**: fstrim enabled
- **CPU**: Performance governor
- **Memory**: Optimized swappiness and cache pressure
- **AMD**: IOMMU and GPU-specific parameters

### Security (`modules/system/security.nix`)
- **Firewall**: Enabled with SSH (port 22) only
- **Fail2ban**: SSH protection with 24h bans

### Monitoring (`modules/system/monitoring.nix`)
- **Logging**: Systemd journal with size/retention limits
- **Updates**: Weekly automatic security updates
- **Tools**: btop, iotop, nethogs, ncdu, bandwhich

### Users (`modules/system/users.nix`)
- **User**: fabio (normal user)
- **Groups**: networkmanager, wheel, audio, video, corectrl
- **Auto-login**: Enabled on TTY
- **Packages**: Basic utilities and applications

## Services

### OpenSSH (`modules/services/openssh.nix`)
- **Security**: Key-based auth only, no root login
- **Settings**: Protocol 2, limited auth tries
- **Firewall**: Automatically opened

### Filesystems (`modules/services/filesystems.nix`)
- **Data partition**: /dev/nvme0n1p3 mounted at /data
- **Options**: User-accessible with read/write

## Flake Dependencies

### External Inputs
- **nixpkgs**: NixOS unstable branch
- **quickshell**: Custom shell/bar (git.outfoxxed.me)
- **claude-desktop**: Claude AI desktop app

### Custom Overlays
- **Claude Code**: Custom package for Anthropic's CLI tool
  - Version: 1.0.17
  - Command: `claude` and `claude-code`
  - Built from npm registry

## Common Commands

### NixOS Management
```bash
nrs    # Rebuild and switch
nrt    # Test configuration  
nrb    # Rebuild for next boot
nru    # Update flake and rebuild
```

### System Info
```bash
nixos-version           # Show NixOS version
nix-shell -p hello      # Test package in shell
sudo nix-collect-garbage -d  # Manual cleanup
```

### Gaming
```bash
gamemode gamecmd        # Run with optimizations
mangohud gamecmd        # Run with overlay
steam                   # Launch Steam
```

### ROCm/GPU
```bash
rocminfo               # ROCm system info
clinfo                 # OpenCL info
rocm-smi               # GPU monitoring
nvtop                  # AMD GPU usage
```

## Maintenance

### Regular Tasks
- Check `sudo nixos-rebuild switch` output for warnings
- Monitor `/data` partition usage
- Review systemd journal: `journalctl -xe`
- Update flake inputs monthly: `nix flake update`

### Troubleshooting
- Boot issues: Check systemd-boot entries
- Graphics: Check AMD driver loading with `lsmod | grep amdgpu`
- ROCm: Verify with `rocminfo` and check HSA_OVERRIDE_GFX_VERSION
- Audio: Check PipeWire status: `systemctl --user status pipewire`

### File Locations
- **Configuration**: /etc/nixos/
- **User data**: /data/
- **Logs**: /var/log/ and `journalctl`
- **Flatpak**: /var/lib/flatpak/ and ~/.local/share/flatpak/

## Hardware Notes
- **GPU**: RX 5600/5700 XT requires HSA override for ROCm compatibility
- **Storage**: NVMe with ext4, separate data partition for user files
- **Audio**: PipeWire handles all audio routing
- **Controllers**: Game controller support via udev rules

This configuration provides a complete desktop environment optimized for gaming, development, and GPU compute workloads on AMD hardware.