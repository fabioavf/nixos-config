# Fabio's NixOS Configuration

## Overview
This is a comprehensive NixOS configuration built with flakes, featuring a modular hybrid architecture for a high-performance gaming and development workstation with Hyprland desktop environment and AMD GPU support.

## System Information
- **Hostname**: fabio-nixos  
- **Platform**: x86_64-linux AMD
- **GPU**: AMD RX 5600/5700 XT (Navi 10 - RDNA1) with ROCm support
- **CPU**: AMD (with KVM support)
- **Storage**: NVMe SSD with ext4 root, separate data partition
- **NixOS Version**: 25.05 (unstable branch)
- **Browser**: Zen Browser (default, installed via Flatpak)

## Quick Start

### Rebuilding the System
```bash
sudo nixos-rebuild switch --flake .#fabio-nixos
```

### Common Aliases
```bash
nrs    # Rebuild and switch
nrt    # Test configuration  
nrb    # Rebuild for next boot
nru    # Update flake and rebuild
```

## Documentation Structure

- **[Architecture](./architecture.md)** - Module organization and design principles
- **[Modules](./modules/)** - Individual module documentation
- **[Maintenance](./maintenance.md)** - Commands, troubleshooting, and updates

## Key Features

### Hybrid Architecture
Combines the best of both domain-based and interface-based organization:
- **Interface modules** (TUI/GUI/WM) for user interaction patterns
- **Environment modules** for system-wide concerns (audio, fonts, theming)
- **Hardware modules** for machine-specific configurations
- **Dual-level modules** with system and user configurations

### Enhanced User Configuration
- **Host-conditional loading** for different machine types
- **Sophisticated shell** with Oh My Zsh, Starship, and fzf integration
- **Modern development environment** with Zed, Neovim, and Claude Code

### Security & Secrets
- **sops-nix integration** for encrypted secrets management
- **Proper service isolation** with dedicated users
- **Comprehensive firewall** with application-specific rules

### Gaming & Performance
- **AMD GPU optimization** with ROCm support for ML/AI workloads
- **GameMode integration** with performance tuning
- **Multiple game launchers** including custom Faugus Launcher

## Recent Reorganization (2025-06-15)

This configuration was recently reorganized using a hybrid approach that combines:
- **Your original strengths**: Excellent domain separation, multi-machine support, modern secrets management
- **External innovations**: Interface-based organization (TUI/GUI/WM), dual-level modules, conditional user loading

The result is a more maintainable and scalable configuration that preserves all existing functionality while improving organization and modularity.