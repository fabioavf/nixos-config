# Fabio's NixOS Configuration

A comprehensive, modular NixOS configuration built with flakes, featuring a hybrid architecture optimized for gaming and development on AMD hardware.

## 🚀 Quick Start

```bash
# Rebuild system
sudo nixos-rebuild switch --flake .#fabio-nixos

# Useful aliases (available after rebuild)
nrs    # Rebuild and switch
nrt    # Test configuration  
nrb    # Rebuild for next boot
nru    # Update flake and rebuild
```

## 🏗️ Architecture

This configuration uses a **hybrid module architecture** that combines:

- **Interface-based organization** (TUI/GUI/WM) for user interaction patterns
- **Domain-based separation** (hardware, services, system) for logical concerns
- **Host-specific configurations** for multi-machine support
- **Dual-level modules** with system and user configurations

```
├── flake.nix                 # Main flake configuration
├── hosts/                    # Host-specific configurations
│   └── fabio-nixos/         # AMD gaming workstation
├── modules/                  # Modular system components
│   ├── interface/           # Interface-based (TUI/GUI/WM)
│   ├── environment/         # System-wide settings
│   ├── hardware/           # Hardware-specific
│   ├── development/        # Development tools
│   ├── system/            # Core OS functionality
│   ├── services/          # System services
│   └── users/             # User configurations
├── docs/                   # Comprehensive documentation
├── overlays/              # Custom package overlays
├── packages/              # Custom package definitions
└── secrets/               # Encrypted secrets (sops-nix)
```

## 🖥️ System Information

- **Platform**: x86_64-linux AMD desktop workstation
- **GPU**: AMD RX 5600/5700 XT with ROCm support for ML/AI
- **Desktop**: Hyprland (Wayland) with modern tooling
- **Shell**: Zsh with Oh My Zsh, Starship, and advanced fzf integration
- **Development**: Comprehensive setup with Zed, Neovim, Claude Code
- **Gaming**: Steam, Wine, GameMode, custom launchers
- **Security**: sops-nix encrypted secrets, comprehensive firewall

## 📚 Documentation

Detailed documentation is available in the [`docs/`](./docs/) directory:

- **[Overview & Quick Start](./docs/README.md)** - Getting started guide
- **[Architecture](./docs/architecture.md)** - Module organization and design principles  
- **[Maintenance](./docs/maintenance.md)** - Commands, troubleshooting, updates
- **[Module Documentation](./docs/modules/)** - Individual module details
- **[Complete Reference](./docs/CLAUDE.md)** - Comprehensive configuration documentation

## ✨ Key Features

### 🎮 **Gaming & Performance**
- AMD GPU optimization with ROCm for ML/AI workloads
- GameMode integration with performance tuning
- Multiple game launchers including custom Faugus Launcher
- 8BitDo controller support with proper udev rules

### 🛠️ **Development Environment**
- Modern editors: Zed, Neovim, VS Code with terminal integration
- Complete language support: Node.js, Python, Rust, with package managers
- Claude Code AI assistant for enhanced development workflow
- Sophisticated shell with fuzzy finding and interactive navigation

### 🔒 **Security & Secrets**
- sops-nix integration for encrypted secrets management
- Proper service isolation with dedicated users and capabilities
- Comprehensive firewall with application-specific rules
- Secure DuckDNS dynamic DNS with encrypted tokens

### 🖼️ **Desktop Experience**
- Hyprland Wayland compositor with XWayland compatibility
- PipeWire audio system with 32-bit support and low latency
- Modern theming with Adwaita Dark across GTK/Qt applications
- Comprehensive font stack including programming fonts

### 🏠 **Home Management**
- Home Manager integration for user-specific configurations
- Host-conditional loading for different machine types
- Advanced shell configuration with custom functions and aliases
- Automated Hyprland launch on login

## 🔄 Recent Updates

### Major Reorganization (2025-06-15)
- **🏗️ Hybrid Architecture**: Combined interface-based and domain-based organization
- **📱 Interface Modules**: New TUI/GUI/WM structure for better context grouping  
- **🔄 Dual-Level Modules**: System and user configurations properly separated
- **📚 Structured Documentation**: Comprehensive docs with architecture guides
- **📦 Clean Overlays**: Organized custom package management
- **🎯 Host-Specific**: Better multi-machine configuration targeting

## 🚀 Getting Started

1. **Clone and explore**:
   ```bash
   cd /etc/nixos
   ls -la                    # Explore directory structure
   cat docs/README.md        # Read detailed documentation
   ```

2. **Test changes safely**:
   ```bash
   sudo nixos-rebuild dry-build --flake .#fabio-nixos  # Test build
   sudo nixos-rebuild test --flake .#fabio-nixos       # Test without persistence
   ```

3. **Apply configuration**:
   ```bash
   sudo nixos-rebuild switch --flake .#fabio-nixos     # Apply changes
   ```

4. **Maintenance**:
   ```bash
   nru                       # Update and rebuild (alias)
   sudo nix-collect-garbage -d  # Clean old generations
   ```

## 🎯 Philosophy

This configuration embodies several key principles:

- **Modularity**: Each component has a single, clear responsibility
- **Maintainability**: Clean abstractions and explicit dependencies
- **Scalability**: Easy to add new machines, features, and configurations
- **Security**: Secrets management and proper service isolation
- **Performance**: Optimizations for gaming, development, and daily use
- **Documentation**: Comprehensive guides for understanding and maintenance

## 📄 License

This configuration is provided as-is for educational and reference purposes. Feel free to use, modify, and adapt for your own NixOS setups.

---

**Built with ❤️ using NixOS, flakes, and modern tooling**