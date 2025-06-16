# Fabio's NixOS Configuration Documentation

## Overview
This is a comprehensive NixOS configuration built with flakes, featuring a modular structure for a high-performance gaming and development workstation with Hyprland desktop environment and AMD GPU support.

## System Information
- **Hostname**: fabio-nixos
- **Platform**: x86_64-linux AMD
- **GPU**: AMD RX 5600/5700 XT (Navi 10 - RDNA1) with ROCm support
- **CPU**: AMD (with KVM support)
- **Storage**: NVMe SSD with ext4 root, separate data partition
- **NixOS Version**: 25.05 (unstable branch)
- **Browser**: Zen Browser (default, installed via Flatpak)

## Architecture

### Main Configuration
- **flake.nix**: Flake configuration with custom overlays and external inputs
- **configuration.nix**: Main imports-only file that ties all modules together
- **hardware-configuration.nix**: Auto-generated hardware detection (do not edit)

### Hybrid Module Structure (2025-06-15 Reorganization)
```
modules/
├── interface/        # NEW: Interface-based organization
│   ├── tui/         # Terminal user interfaces
│   │   ├── default.nix   # Core terminal tools and CLI utilities
│   │   ├── editors.nix   # Text editors and terminal applications
│   │   └── home.nix      # User-level TUI configurations (Home Manager)
│   ├── gui/         # Graphical user interfaces
│   │   ├── default.nix   # Common GUI applications
│   │   ├── desktop-heavy.nix # Desktop-specific heavy applications
│   │   └── home.nix      # User-level GUI configurations (Home Manager)
│   └── wm/          # Window managers
│       └── hyprland/
│           ├── default.nix # System-level WM configuration
│           └── home.nix    # User-level WM settings (Home Manager)
├── environment/     # System-wide concerns
│   ├── audio.nix    # PipeWire audio configuration
│   ├── fonts.nix    # System and programming fonts (Nerd Fonts)
│   ├── gaming.nix   # Steam, Wine, controllers, GameMode
│   └── theming.nix  # GTK/Qt themes (Adwaita Dark)
├── development/     # Development-specific modules
│   ├── shell.nix    # System-wide Zsh configuration
│   └── rocm.nix     # ROCm packages for ML/AI compute workloads
├── hardware/        # Hardware-specific configurations
│   └── amd.nix      # AMD RX 5600/5700 XT hardware configuration
├── system/          # Core system configuration
│   ├── boot.nix     # systemd-boot, Plymouth splash
│   ├── home-manager.nix # Home Manager integration
│   ├── locale.nix   # Timezone and locale settings
│   ├── monitoring.nix # System monitoring, auto-updates
│   ├── networking.nix # NetworkManager configuration
│   ├── nix.nix      # Nix settings, garbage collection
│   ├── performance.nix # SSD optimization, CPU governor
│   ├── secrets.nix  # Secrets management with sops-nix
│   ├── security.nix # Firewall, fail2ban, streaming ports
│   └── users.nix    # System user configuration with auto-login
├── services/        # System services
│   ├── duckdns.nix  # Dynamic DNS service with encrypted secrets
│   ├── filesystems.nix # Data partition mounting
│   └── openssh.nix  # SSH server configuration
├── users/           # User-specific configurations (Home Manager)
│   └── fabio.nix    # Personal user environment and dotfiles
└── packages/        # Custom package definitions
    └── faugus-launcher.nix # Custom game launcher package
├── overlays/        # NEW: Organized overlay system
│   ├── default.nix  # Main overlays combiner
│   └── packages.nix # Custom package overlays (Claude Code)
├── docs/            # NEW: Structured documentation
│   ├── README.md    # Overview and quick start
│   ├── architecture.md # Detailed module organization
│   ├── maintenance.md # Commands and troubleshooting
│   └── modules/     # Module-specific documentation
└── secrets/         # Encrypted secrets management
    ├── keys.txt     # Age encryption key (not in git)
    └── secrets.yaml # Encrypted secrets file
```

## Desktop Environment

### Hyprland Configuration (`modules/desktop/hyprland.nix`)
- **Compositor**: Hyprland with XWayland support
- **Portals**: XDG desktop portal with GTK support
- **Tools**: wofi, wl-clipboard, grim, slurp, swww, hyprpaper
- **System tray**: NetworkManager applet, pavucontrol, brightnessctl
- **Auto-mount**: udiskie for removable media
- **Authentication**: KDE polkit agent
- **Extras**: hypridle (idle management), clipse (clipboard manager)

### Applications (`modules/desktop/apps.nix`)
- **File manager**: Nautilus, ranger, gdu
- **Communication**: Discord
- **Media**: Spotify, VLC, OBS Studio, playerctl
- **Productivity**: qbittorrent
- **GPU control**: CoreCtrl for AMD GPU management
- **Launchers**: Faugus Launcher (custom package)
- **System tools**: GNOME Disk Utility, evince (PDF), eog (images)
- **Archives**: zip, unzip, p7zip, rar, unrar, xz, zstd
- **Network**: wget, curl, aria2, rsync, sshfs, ethtool
- **Image editing**: ImageMagick, GIMP
- **Streaming**: Sunshine (game streaming with security wrappers)
- **Browser**: Zen Browser (default, installed via Flatpak)
- **Qt support**: Qt6, Qt5 compatibility layers
- **Flatpak**: Enabled with proper XDG paths

### Audio (`modules/desktop/audio.nix`)
- **Backend**: PipeWire (PulseAudio disabled)
- **Features**: ALSA, 32-bit support, rtkit
- **Tools**: pulseaudio tools, wireplumber, wpctl

### Fonts (`modules/desktop/fonts.nix`)
- **System fonts**: Noto fonts family (including CJK and emoji), Liberation TTF
- **Programming fonts**: Fira Code, JetBrains Mono, Hack, Source Code Pro, Ubuntu Mono, DejaVu Sans Mono, Inconsolata, Roboto Mono (all Nerd Fonts variants)
- **UI fonts**: IBM Plex, Material Symbols

### Gaming (`modules/desktop/gaming.nix`)
- **Steam**: Full setup with Proton-GE, remote play, network transfers
- **GameMode**: Performance optimizations with CPU/GPU tuning
- **Launchers**: Bottles, UMU launcher (unified Wine launcher)
- **Wine**: Full Wine stack with DXVK, winetricks
- **Tools**: MangoHud (performance overlay), Gamescope
- **Controllers**: antimicrox, jstest-gtk, Linux Console Tools, evtest
- **8BitDo support**: Custom udev rules for Ultimate 2C and other models
- **Streaming**: Sunshine with proper capabilities and firewall rules
- **Performance**: GameMode group and PAM limits
- **Monitoring**: nvtop for AMD GPUs
- **Archives**: Support for game archive formats (unrar, p7zip, cabextract)
- **Note**: AMD GPU hardware settings moved to modules/hardware/amd.nix

### Theming (`modules/desktop/theming.nix`)
- **Theme**: Adwaita Dark system-wide
- **GTK**: Versions 2, 3, and 4 configured with detailed settings
- **Qt**: Qt5/Qt6 with Adwaita theme and color schemes
- **Icons**: Adwaita, Papirus, Numix
- **Cursors**: Bibata, Vanilla DMZ
- **Tools**: lxappearance, qt5ct, qt6ct for manual configuration
- **DConf**: System-wide dark theme preferences
- **Environment**: GTK_THEME, QT_QPA_PLATFORMTHEME variables set

## Development Environment

### Editors (`modules/development/editors.nix`)
- **Modern**: Zed Editor, Neovim, VS Code
- **Terminal**: Alacritty

### Languages (`modules/development/languages.nix`)
- **Version control**: GitHub CLI (gh), GitLab CLI (glab), git-lfs
- **Containers**: Docker, docker-compose
- **System**: GCC compiler
- **JavaScript**: Node.js, Bun, node2nix
- **AI Tools**: Claude Code (custom package v1.0.17)
- **Python**: pyenv
- **Rust**: rustc, cargo

### Shell Configuration

#### System Shell (`modules/development/shell.nix`)
- **System-wide**: Zsh enabled with autosuggestions and syntax highlighting
- **Default Shell**: Zsh set as system default
- **Packages**: starship, bat, fzf, pay-respects, zsh-completions

#### User Shell (`modules/users/fabio.nix` - Home Manager)
- **Personal Config**: Oh My Zsh with robbyrussell theme
- **Prompt**: Starship prompt integration
- **Plugins**: git, history, sudo, docker, extract, colored-man-pages, z, fzf
- **Enhanced Features**: 
  - Custom fzf functions: fcd (interactive directory navigation), fe (fuzzy file editor)
  - pay-respects (command correction, alias: fuck)
  - Advanced history management (50k entries, deduplication)
  - Case-insensitive completion with colors
- **Aliases**: NixOS shortcuts (nrs, nrt, nrb, nru), git shortcuts, directory navigation
- **Auto-start**: Hyprland on TTY1
- **Git Integration**: Personal git configuration with user details

### ROCm Support (`modules/development/rocm.nix`)
- **Purpose**: AMD GPU compute for ML/AI workloads (packages only)
- **Core**: CLR (Compute Language Runtime), HIP, hipcc compiler
- **Math Libraries**: ROCBlas, HIPBlas, ROCFFT, HIPFFT, ROCSolver, HIPSolver, ROCRand, HIPRand, ROCSparse, HIPSparse, ROCPrim, HIPCUB, ROCThrust
- **ML Libraries**: MIOpen (deep learning), MIGraphX (graph optimization), Tensile
- **Tools**: rocminfo, rocm-smi, roctracer, rocprofiler, hipify (CUDA conversion)
- **OpenCL**: ROCm OpenCL ICD support
- **Note**: Hardware configuration, environment variables, and services moved to modules/hardware/amd.nix


## System Configuration

### Boot (`modules/system/boot.nix`)
- **Bootloader**: systemd-boot with EFI variable support
- **Splash**: Plymouth with breeze theme
- **Graphics**: Early KMS for smooth transitions (amdgpu module)
- **Quiet boot**: Minimal boot messages with rd.systemd.show_status=false

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
- **SSD**: fstrim enabled for NVMe optimization
- **CPU**: Performance governor (or ondemand)
- **Memory**: vm.swappiness=10, vm.vfs_cache_pressure=50
- **AMD**: IOMMU enabled, GPU support parameters (amdgpu.si_support, amdgpu.cik_support)

### Security (`modules/system/security.nix`)
- **Firewall**: Comprehensive port configuration
  - SSH: port 22
  - Steam: TCP 27015-27030, 27036-27037; UDP 27000-27100, 3478-4380
  - Epic Games: TCP 5795-5847
  - Sunshine streaming: TCP/UDP 47984-48010, 47998-48010
- **Fail2ban**: SSH protection with 24h bans and increment escalation
- **udev Rules**: DRM device access for video capture, input device permissions
- **Tools**: iptables for direct firewall management

### Monitoring (`modules/system/monitoring.nix`)
- **Logging**: Systemd journal with 1GB max size, 7-day retention
- **Updates**: Weekly automatic security updates (no reboot)
- **Tools**: btop (better htop), iotop, nethogs, ncdu (disk usage), bandwhich (network per-process)

### Users (`modules/system/users.nix`)
- **User**: fabio (normal user with description)
- **Groups**: networkmanager, wheel, audio, video, corectrl, input, render
- **Auto-login**: Enabled on TTY
- **Packages**: git, vim, wget, curl, htop, tree, unzip, ookla-speedtest

## Services

### OpenSSH (`modules/services/openssh.nix`)
- **Security**: Password auth disabled, no interactive keyboard auth, no root login
- **Settings**: Protocol 2, max 3 auth tries, X11 forwarding disabled
- **Keep-alive**: 300s intervals, max 2 missed counts
- **Firewall**: Automatically opened

### Filesystems (`modules/services/filesystems.nix`)
- **Data partition**: /dev/nvme0n1p3 mounted at /data
- **Backup drive**: /dev/disk/by-uuid/c997d32a-3a0d-43c7-b0b5-1a7ed6fcaa29 mounted at /mnt/hd
- **Options**: defaults, user-accessible, read/write

### Secrets Management

#### Secrets Configuration (`modules/system/secrets.nix`)
- **Framework**: sops-nix with age encryption
- **Key Management**: Age key stored in `/var/lib/sops-nix/key.txt`
- **Secrets File**: `secrets/secrets.yaml` (encrypted)
- **Access Control**: Proper ownership and permissions for secrets

#### DuckDNS Service (`modules/services/duckdns.nix`)
- **Service**: Dynamic DNS updater for fabioavf.duckdns.org
- **Timer**: Updates every 5 minutes with systemd timer
- **Security**: Runs as nobody user with encrypted token
- **Token**: Securely stored in encrypted secrets file

#### Home Manager Integration (`modules/system/home-manager.nix`)
- **User Management**: Home Manager integration for user fabio
- **Backup**: Automatic backup of existing dotfiles with `.backup` extension
- **Global Packages**: Access to system packages in user environment
- **User Packages**: User-specific package management

## Flake Dependencies

### External Inputs
- **nixpkgs**: NixOS unstable branch
- **sops-nix**: Secrets management with age encryption
- **home-manager**: User environment and dotfiles management
- **quickshell**: Custom shell/bar (git.outfoxxed.me)
- **claude-desktop**: Claude AI desktop app (github:k3d3/claude-desktop-linux-flake)

### Custom Overlays
- **Claude Code**: Custom package for Anthropic's CLI tool
  - Version: 1.0.18
  - Commands: `claude` and `claude-code` (symlinked)
  - Built from npm registry with Node.js wrapper
  - SHA256: bY+lkBeGYGy3xLcoo6Hlf5223z1raWuatR0VMQPfxKc=

### Custom Packages (`packages/`)
- **Faugus Launcher**: Game launcher for Windows games on Linux
  - Version: 1.6.2
  - Dependencies: Python3, GTK3, imagemagick, icoextract
  - Features: Wine integration, UMU support, icon extraction

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
corectrl               # AMD GPU control interface
```

### Shell Features
```bash
fcd                    # Interactive directory navigation with fzf
fe                     # Fuzzy file finder and editor
fuck                   # Correct last command with pay-respects
Ctrl+R                 # Fuzzy history search with fzf
z dirname              # Jump to frequently used directories
```

## Maintenance

### Regular Tasks
- Check `sudo nixos-rebuild switch` output for warnings
- Monitor `/data` partition usage
- Review systemd journal: `journalctl -xe`
- Update flake inputs monthly: `nix flake update`

### Troubleshooting
- Boot issues: Check systemd-boot entries, Plymouth theme loading
- Graphics: Check AMD driver loading with `lsmod | grep amdgpu`
- ROCm: Verify with `rocminfo` and check HSA_OVERRIDE_GFX_VERSION=10.3.0
- Audio: Check PipeWire status: `systemctl --user status pipewire`
- Gaming: Check Steam in gamemode, verify controller with `jstest`
- Shell: Test autosuggestions, syntax highlighting, and fzf functions
- **Network**: Check DuckDNS updates, firewall port status
- **Secrets**: Verify sops decryption with encrypted secrets access
- **Home Manager**: Check user service status: `systemctl --user status home-manager-fabio`
- **AMD Hardware**: Verify kernel parameters: `cat /proc/cmdline | grep amdgpu`

### File Locations
- **Configuration**: /etc/nixos/
- **User data**: /data/
- **Backup**: /mnt/hd/ (additional storage drive)
- **Logs**: /var/log/ and `journalctl`
- **Flatpak**: /var/lib/flatpak/ and ~/.local/share/flatpak/

## Hardware Configuration (`modules/hardware/amd.nix`)

### Consolidated AMD RX 5600/5700 XT Settings
- **Kernel Parameters**: Complete AMD GPU optimization (ppfeaturemask, IOMMU, recovery)
- **Environment Variables**: ROCm compatibility (HSA_OVERRIDE_GFX_VERSION=10.3.0, ROC_ENABLE_PRE_VEGA=1)
- **Graphics Hardware**: Vulkan (RADV), OpenCL, 32-bit support
- **Device Permissions**: render group access, udev rules for /dev/kfd and /dev/dri
- **Services**: rocm-init service for device initialization
- **System Limits**: Unlimited memlock for compute workloads
- **Overdrive**: AMD GPU overdrive support for advanced tuning

### Other Hardware
- **Storage**: NVMe with ext4, separate data partition for user files, additional backup drive
- **Audio**: PipeWire handles all audio routing with 32-bit support
- **Controllers**: Game controller support via udev rules, including 8BitDo Ultimate 2C
- **Streaming**: Sunshine configured for low-latency game streaming

## Recent Updates

### Major Reorganization (2025-06-15)
- **🏗️ RESTRUCTURED**: Hybrid architecture combining domain-based and interface-based organization
- **📱 NEW**: Interface modules (TUI/GUI/WM) for better usage context grouping
- **🔄 NEW**: Dual-level modules with system and user configurations
- **📚 NEW**: Comprehensive documentation structure (docs/README.md, architecture.md, maintenance.md)
- **📦 NEW**: Organized overlay system for custom packages
- **🎯 IMPROVED**: Host-specific configurations for better machine targeting
- **🔧 ENHANCED**: User configuration with conditional loading patterns
- **📋 ADDED**: Module templates and best practices documentation

### Previous Updates (2025-06-10)
- **🔒 NEW**: Secrets management with sops-nix for encrypted DuckDNS token
- **🏠 NEW**: Home Manager integration for user-specific configurations
- **⚡ NEW**: AMD hardware consolidation - single source of truth for all GPU settings
- **📁 NEW**: Modular user configuration structure (modules/users/fabio.nix)
- **🔧 IMPROVED**: Enhanced shell with zsh-autosuggestions, syntax-highlighting, and advanced fzf integration
- **🎮 IMPROVED**: pay-respects command correction tool replacing thefuck
- **💻 IMPROVED**: Custom interactive functions for directory navigation (fcd) and file editing (fe)
- **🌐 IMPROVED**: DuckDNS dynamic DNS service with encrypted secrets
- **🎯 IMPROVED**: Comprehensive gaming optimizations with 8BitDo controller support
- **📦 IMPROVED**: Faugus Launcher custom package for game management
- **💾 IMPROVED**: Additional backup drive mount at /mnt/hd
- **🛡️ UPDATED**: Enhanced security with comprehensive firewall rules
- **🎨 UPDATED**: Improved theming with detailed GTK/Qt configuration
- **♻️ REFACTORED**: AMD settings consolidated from 4 files into dedicated hardware module

This configuration provides a complete desktop environment optimized for gaming and development workloads on AMD hardware with comprehensive ROCm support, secure secrets management, and personalized user environments through Home Manager integration. The recent reorganization improves maintainability and scalability while preserving all existing functionality.