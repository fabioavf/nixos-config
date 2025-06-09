# Fabio's NixOS Configuration Documentation

## Overview
This is a comprehensive NixOS configuration built with flakes, featuring a modular structure for a high-performance gaming, AI/ML, and development workstation with Hyprland desktop environment and AMD GPU support.

## System Information
- **Hostname**: fabio-nixos
- **Platform**: x86_64-linux AMD
- **GPU**: AMD RX 5600/5700 XT (Navi 10 - RDNA1) with ROCm support
- **CPU**: AMD (with KVM support)
- **Storage**: NVMe SSD with ext4 root, separate data partition
- **NixOS Version**: 25.05 (unstable branch)
- **Browser**: Zen Browser (default)

## Architecture

### Main Configuration
- **flake.nix**: Flake configuration with custom overlays and external inputs
- **configuration.nix**: Main imports-only file that ties all modules together
- **hardware-configuration.nix**: Auto-generated hardware detection (do not edit)

### Module Structure
```
modules/
├── desktop/          # Desktop environment and applications
│   ├── apps.nix      # Desktop applications, Faugus Launcher, file managers
│   ├── audio.nix     # PipeWire audio configuration
│   ├── fonts.nix     # System and programming fonts (Nerd Fonts)
│   ├── gaming.nix    # Steam, Wine, controllers, AMD GPU optimizations
│   ├── hyprland.nix  # Wayland compositor and tools
│   └── theming.nix   # GTK/Qt themes (Adwaita Dark)
├── development/      # Programming tools and languages
│   ├── ai.nix        # NEW: Ollama, Open WebUI, ML tools with ROCm
│   ├── editors.nix   # Zed Editor, Neovim, VS Code, Alacritty
│   ├── languages.nix # Git, Docker, Node.js, Python, Rust, Claude Code
│   ├── rocm.nix      # AMD GPU compute support with compatibility overrides
│   └── shell.nix     # Zsh, Oh My Zsh, Starship prompt
├── services/         # System services
│   ├── duckdns.nix   # NEW: Dynamic DNS service
│   ├── filesystems.nix # Data partition mounting
│   └── openssh.nix   # SSH server configuration
├── system/          # Core system configuration
│   ├── boot.nix      # systemd-boot, Plymouth splash
│   ├── locale.nix    # Timezone and locale settings
│   ├── monitoring.nix # System monitoring, auto-updates
│   ├── networking.nix # NetworkManager configuration
│   ├── nix.nix       # Nix settings, garbage collection
│   ├── performance.nix # SSD optimization, CPU governor
│   ├── security.nix  # Firewall, fail2ban, streaming ports
│   └── users.nix     # User configuration with auto-login
└── packages/        # Custom package definitions
    └── faugus-launcher.nix # Custom game launcher package
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
- **Browser**: Zen Browser (set as default)
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
- **Hardware**: 32-bit graphics drivers, AMD Vulkan (RADV), ROCm OpenCL
- **Streaming**: Sunshine with proper capabilities and firewall rules
- **Performance**: Custom kernel parameters, sysctl settings, GameMode group
- **Monitoring**: nvtop for AMD GPUs
- **Archives**: Support for game archive formats (unrar, p7zip, cabextract)

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

### Shell (`modules/development/shell.nix`)
- **Shell**: Zsh with Oh My Zsh (robbyrussell theme)
- **Prompt**: Starship
- **Plugins**: git, history, sudo, docker, extract, colored-man-pages
- **Aliases**: NixOS shortcuts (nrs, nrt, nrb, nru), git shortcuts, directory navigation
- **History**: Enhanced with 50k entries, duplicate handling, sharing
- **Tools**: bat (better cat), fzf (fuzzy finder)
- **Auto-start**: Hyprland on TTY1

### ROCm Support (`modules/development/rocm.nix`)
- **Purpose**: AMD GPU compute for ML/AI workloads
- **Compatibility**: RX 5600/5700 XT (Navi 10) support via HSA override to 10.3.0
- **Core**: CLR (Compute Language Runtime), HIP, hipcc compiler
- **Math Libraries**: ROCBlas, HIPBlas, ROCFFT, HIPFFT, ROCSolver, HIPSolver, ROCRand, HIPRand, ROCSparse, HIPSparse, ROCPrim, HIPCUB, ROCThrust
- **ML Libraries**: MIOpen (deep learning), MIGraphX (graph optimization), Tensile
- **Tools**: rocminfo, rocm-smi, roctracer, rocprofiler, hipify (CUDA conversion)
- **OpenCL**: ROCm OpenCL ICD support
- **Environment**: HSA_OVERRIDE_GFX_VERSION="10.3.0", ROC_ENABLE_PRE_VEGA="1"
- **Permissions**: render group access, udev rules, memlock limits
- **Service**: rocm-init systemd service for device setup

### AI and Machine Learning (`modules/development/ai.nix`)
- **Local LLM**: Ollama server with ROCm acceleration
- **Web Interface**: Open WebUI (port 3000) with authentication disabled
- **GPU Target**: HCC_AMDGPU_TARGET="gfx1010" for RX 5600/5700 XT
- **Memory Management**: OLLAMA_MAX_VRAM="7GB" (8GB GPU with 1GB reserved)
- **Python ML Stack**: NumPy, SciPy, Matplotlib, Pandas, Jupyter, IPython
- **AI Libraries**: Hugging Face (hub, transformers, tokenizers, datasets)
- **Computer Vision**: OpenCV4, Pillow
- **Model Tools**: ONNX, git-lfs for large models
- **Development**: Rich terminal output, Typer CLI, Pydantic validation
- **Data Directories**: /data/ai-models, /data/ai-datasets, /data/ai-projects
- **Cache**: Hugging Face cache on data partition
- **Services**: Both Ollama (port 11434) and Open WebUI with proper user/group setup
- **Performance**: Increased shared memory limits, memory map areas
- **Firewall**: TCP ports 11434 (Ollama) and 3000 (Open WebUI) opened

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
- **Options**: defaults, user-accessible, read/write

### DuckDNS (`modules/services/duckdns.nix`)
- **Service**: Dynamic DNS updater for fabioavf.duckdns.org
- **Timer**: Updates every 5 minutes with systemd timer
- **Security**: Runs as nobody user
- **Token**: 49d0657d-81f9-44d9-8995-98b484ab4272

## Flake Dependencies

### External Inputs
- **nixpkgs**: NixOS unstable branch
- **quickshell**: Custom shell/bar (git.outfoxxed.me)
- **claude-desktop**: Claude AI desktop app (github:k3d3/claude-desktop-linux-flake)

### Custom Overlays
- **Claude Code**: Custom package for Anthropic's CLI tool
  - Version: 1.0.17
  - Commands: `claude` and `claude-code` (symlinked)
  - Built from npm registry with Node.js wrapper
  - SHA256: 0xsg7gzwcj8rpfq5qp638s3wslz5d7dyfisz8lbl6fskjyay9lnp

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

### AI/ML
```bash
ollama                 # LLM server CLI
ollama list            # List installed models
ollama pull llama2     # Download model
systemctl status ollama # Check Ollama service
http://localhost:3000  # Open WebUI interface
http://localhost:11434 # Ollama API endpoint
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
- AI/ML: Check Ollama service, verify ROCm with render group access
- Network: Check DuckDNS updates, firewall port status

### File Locations
- **Configuration**: /etc/nixos/
- **User data**: /data/
- **AI Models**: /data/ai-models/ (Ollama and Hugging Face cache)
- **AI Projects**: /data/ai-datasets/, /data/ai-projects/
- **Logs**: /var/log/ and `journalctl`
- **Flatpak**: /var/lib/flatpak/ and ~/.local/share/flatpak/
- **Services**: /var/lib/ollama/, /var/lib/open-webui/

## Hardware Notes
- **GPU**: RX 5600/5700 XT (Navi 10/RDNA1) requires HSA override for ROCm compatibility
- **Storage**: NVMe with ext4, separate data partition for user files and AI models
- **Audio**: PipeWire handles all audio routing with 32-bit support
- **Controllers**: Game controller support via udev rules, including 8BitDo Ultimate 2C
- **ROCm**: Full compute stack with compatibility overrides for RDNA1 architecture
- **Streaming**: Sunshine configured for low-latency game streaming

## Recent Updates
- **NEW**: AI/ML module with Ollama and Open WebUI
- **NEW**: DuckDNS dynamic DNS service
- **NEW**: Comprehensive gaming optimizations with 8BitDo controller support
- **NEW**: Faugus Launcher custom package for game management
- **UPDATED**: Enhanced security with comprehensive firewall rules
- **UPDATED**: Improved theming with detailed GTK/Qt configuration

This configuration provides a complete desktop environment optimized for gaming, AI/ML development, and GPU compute workloads on AMD hardware with comprehensive ROCm support.