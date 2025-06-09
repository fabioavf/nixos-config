# Fabio's NixOS Configuration

A comprehensive NixOS configuration built with flakes, featuring a modular structure for a high-performance gaming and development workstation with Hyprland desktop environment and AMD GPU support.

## 🖥️ System Information

- **Hostname**: fabio-nixos
- **Platform**: x86_64-linux AMD
- **GPU**: AMD RX 5600/5700 XT (Navi 10 - RDNA1) with ROCm support
- **CPU**: AMD (with KVM support)
- **Storage**: NVMe SSD with ext4 root, separate data partition
- **NixOS Version**: 25.05 (unstable branch)
- **Desktop Environment**: Hyprland (Wayland)
- **Browser**: Zen Browser (installed via Flatpak)

## 🏗️ Architecture

This configuration follows a modular approach with clear separation of concerns:

```
modules/
├── desktop/          # Desktop environment and applications
├── development/      # Programming tools and languages
├── services/         # System services
├── system/          # Core system configuration
└── packages/        # Custom package definitions
```

### Key Features

- **🎮 Gaming Ready**: Steam, Wine, GameMode, MangoHud, controller support
- **💻 Development Environment**: Zed, VS Code, Neovim, Docker, multiple language runtimes
- **🎨 Modern Desktop**: Hyprland with Adwaita Dark theming
- **🔊 Audio**: PipeWire with full audio stack
- **🚀 Performance**: AMD GPU optimization, SSD tuning, ROCm compute support
- **🛡️ Security**: Firewall, fail2ban, secure SSH configuration
- **📦 Package Management**: Flakes with custom overlays and packages

## 🚀 Quick Start

### Prerequisites

- NixOS installed with flakes enabled
- Git configured

### Installation

1. Clone this repository:
```bash
git clone <repository-url> /etc/nixos
cd /etc/nixos
```

2. Update hardware configuration:
```bash
sudo nixos-generate-config --root /
# Copy the generated hardware-configuration.nix if needed
```

3. Build and switch:
```bash
sudo nixos-rebuild switch --flake .#fabio-nixos
```

## 🛠️ Configuration Modules

### Desktop Environment (`modules/desktop/`)

- **Hyprland**: Wayland compositor with modern tooling
- **Applications**: Discord, Spotify, VLC, OBS, file managers
- **Gaming**: Steam, Wine, Bottles, GameMode, controller support
- **Audio**: PipeWire with full feature set
- **Fonts**: Comprehensive font collection including Nerd Fonts
- **Theming**: Consistent Adwaita Dark across GTK/Qt

### Development Tools (`modules/development/`)

- **Editors**: Zed Editor, Neovim, VS Code, Alacritty terminal
- **Languages**: Node.js, Python, Rust, Docker support
- **Shell**: Enhanced Zsh with Oh My Zsh, Starship, advanced features
- **ROCm**: Full AMD GPU compute stack for ML/AI workloads
- **AI Tools**: Claude Code CLI

### System Configuration (`modules/system/`)

- **Boot**: systemd-boot with Plymouth splash screen
- **Performance**: SSD optimization, CPU governor tuning
- **Security**: Comprehensive firewall, fail2ban protection
- **Monitoring**: System monitoring tools and auto-updates
- **Networking**: NetworkManager with hostname configuration

### Services (`modules/services/`)

- **SSH**: Secure configuration with key-only authentication
- **Filesystems**: Data partition and backup drive mounting
- **DuckDNS**: Dynamic DNS service for remote access

## 🎮 Gaming Features

- **Steam**: Full setup with Proton-GE and remote play
- **Wine Stack**: DXVK, winetricks, UMU launcher
- **Performance**: GameMode optimization, MangoHud overlay
- **Controllers**: Full controller support including 8BitDo devices
- **Streaming**: Sunshine game streaming server
- **Hardware**: AMD Vulkan (RADV), 32-bit graphics support

## 💻 Development Features

### Enhanced Shell Experience
- **Zsh**: Modern shell with intelligent completion
- **Autosuggestions**: Fish-like command suggestions
- **Syntax Highlighting**: Real-time command validation
- **Fuzzy Finding**: Interactive directory navigation (`fcd`) and file editing (`fe`)
- **Command Correction**: `pay-respects` for fixing typos

### Programming Languages
- **JavaScript/TypeScript**: Node.js, Bun runtime
- **Python**: pyenv for version management
- **Rust**: Full toolchain with cargo
- **Containers**: Docker with compose support

## 🔧 Common Commands

### NixOS Management
```bash
nrs    # Rebuild and switch
nrt    # Test configuration  
nrb    # Rebuild for next boot
nru    # Update flake and rebuild
```

### Gaming
```bash
gamemode <game>        # Run with optimizations
mangohud <game>        # Run with performance overlay
steam                  # Launch Steam
```

### ROCm/GPU
```bash
rocminfo              # ROCm system information
rocm-smi              # GPU monitoring
nvtop                 # AMD GPU usage display
corectrl              # GPU control interface
```

### Enhanced Shell
```bash
fcd                   # Interactive directory navigation
fe                    # Fuzzy file finder and editor
fuck                  # Correct last command
z <directory>         # Jump to frequently used directories
```

## 🔒 Security Features

- **Firewall**: Configured for gaming, development, and streaming
- **SSH**: Key-only authentication, fail2ban protection
- **User Permissions**: Proper group membership for hardware access
- **Services**: Minimal attack surface with required services only

## 🚨 Troubleshooting

### Common Issues

**Graphics Problems**:
```bash
lsmod | grep amdgpu    # Check AMD driver loading
```

**Audio Issues**:
```bash
systemctl --user status pipewire    # Check PipeWire status
```

**ROCm Problems**:
```bash
rocminfo               # Verify ROCm installation
echo $HSA_OVERRIDE_GFX_VERSION    # Should show 10.3.0
```

### Log Checking
```bash
journalctl -xe         # System logs
systemctl status <service>    # Service-specific logs
```

## 📦 Custom Packages

- **Claude Code**: Anthropic's AI CLI tool (v1.0.17)
- **Faugus Launcher**: Game launcher for Windows games on Linux

## 🔄 Maintenance

### Regular Tasks
- Monthly flake updates: `nix flake update`
- System cleanup: `sudo nix-collect-garbage -d`
- Monitor disk usage on `/data` partition
- Review system logs for errors

### File Locations
- **Configuration**: `/etc/nixos/`
- **User Data**: `/data/`
- **Backup Drive**: `/mnt/hd/`
- **Logs**: `/var/log/` and `journalctl`

## 📝 Documentation

For detailed information about specific components, see `CLAUDE.md` which contains comprehensive documentation about every aspect of this configuration.

## 🤝 Contributing

This is a personal configuration, but feel free to use it as inspiration for your own NixOS setup. The modular structure makes it easy to adapt individual components.

## 📄 License

This configuration is provided as-is for educational and personal use.