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
├── hardware/         # Hardware-specific configurations (AMD GPU)
├── services/         # System services (SSH, filesystems, DuckDNS)
├── system/          # Core system configuration
├── users/           # User-specific configurations (Home Manager)
└── packages/        # Custom package definitions
```

### Key Features

- **🎮 Gaming Ready**: Steam, Wine, GameMode, MangoHud, controller support
- **💻 Development Environment**: Zed, VS Code, Neovim, Docker, multiple language runtimes
- **🎨 Modern Desktop**: Hyprland with Adwaita Dark theming
- **🔊 Audio**: PipeWire with full audio stack
- **🚀 Performance**: AMD GPU optimization, SSD tuning, ROCm compute support
- **🛡️ Security**: Firewall, fail2ban, encrypted secrets with sops-nix
- **🏠 User Management**: Home Manager for personal environment isolation
- **⚡ Hardware Configuration**: Consolidated AMD GPU settings
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
- **Secrets**: sops-nix encrypted secrets management
- **Home Manager**: User environment integration
- **Monitoring**: System monitoring tools and auto-updates
- **Networking**: NetworkManager with hostname configuration

### Services (`modules/services/`)

- **SSH**: Secure configuration with key-only authentication
- **Filesystems**: Data partition and backup drive mounting
- **DuckDNS**: Dynamic DNS service with encrypted token

### Hardware (`modules/hardware/`)

- **AMD GPU**: Consolidated RX 5600/5700 XT configuration
- **ROCm Support**: Complete compute stack for ML/AI workloads
- **Kernel Parameters**: Optimized AMD GPU settings
- **Environment Variables**: ROCm compatibility overrides

### Users (`modules/users/`)

- **Personal Environment**: Home Manager user configuration
- **Shell Setup**: Enhanced Zsh with advanced features
- **Git Configuration**: Personal development settings
- **Dotfiles Management**: Automatic backup and version control

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

- **Secrets Management**: sops-nix with age encryption for sensitive data
- **Firewall**: Configured for gaming, development, and streaming
- **SSH**: Key-only authentication, fail2ban protection
- **User Permissions**: Proper group membership for hardware access
- **Services**: Minimal attack surface with required services only
- **Encrypted Storage**: All secrets stored encrypted, no plaintext tokens

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
clinfo                 # Check OpenCL support
```

**Secrets Issues**:
```bash
sudo systemctl status duckdns.service    # Check encrypted secret access
sops -d secrets/secrets.yaml            # Decrypt secrets file
```

**Home Manager Problems**:
```bash
systemctl --user status home-manager-fabio    # Check user service
home-manager switch                           # Manual user environment rebuild
```

### Log Checking
```bash
journalctl -xe         # System logs
systemctl status <service>    # Service-specific logs
```

## 📦 Custom Packages

- **Claude Code**: Anthropic's AI CLI tool (v1.0.18)
- **Faugus Launcher**: Game launcher for Windows games on Linux

## 🔄 Recent Updates (2025-06-10)

### Major Improvements Implemented
- **🔒 Secrets Management**: Implemented sops-nix for encrypted secret storage
- **🏠 Home Manager**: Added user environment isolation and dotfiles management
- **⚡ AMD Consolidation**: Unified all AMD GPU settings into single hardware module
- **📁 Module Restructuring**: Improved organization with hardware/, users/, and enhanced system/ modules
- **🛡️ Security Enhancement**: Eliminated hardcoded secrets, proper encryption
- **🧹 Code Cleanup**: Removed duplications, improved maintainability

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

- **CLAUDE.md**: Comprehensive technical documentation
- **IMPROVEMENTS.md**: Implementation status and improvement history
- **README.md**: This overview and quick start guide

## 🤝 Contributing

This is a personal configuration, but feel free to use it as inspiration for your own NixOS setup. The modular structure makes it easy to adapt individual components.

## 📄 License

This configuration is provided as-is for educational and personal use.