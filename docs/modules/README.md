# Module Documentation

This directory contains detailed documentation for each module category in the NixOS configuration.

## Interface Modules

### Terminal User Interface (TUI)
- **[tui/default.nix](../../../modules/interface/tui/default.nix)** - Core terminal tools and CLI utilities
- **[tui/editors.nix](../../../modules/interface/tui/editors.nix)** - Text editors and terminal applications

### Graphical User Interface (GUI)  
- **[gui/default.nix](../../../modules/interface/gui/default.nix)** - Common GUI applications
- **[gui/desktop-heavy.nix](../../../modules/interface/gui/desktop-heavy.nix)** - Desktop-specific heavy applications

### Window Manager (WM)
- **[wm/hyprland/](../../../modules/interface/wm/hyprland/)** - Hyprland Wayland compositor configuration

## Environment Modules

System-wide configuration modules that affect all interfaces:

- **[audio.nix](../../../modules/environment/audio.nix)** - PipeWire audio system
- **[fonts.nix](../../../modules/environment/fonts.nix)** - System and programming fonts
- **[gaming.nix](../../../modules/environment/gaming.nix)** - Gaming platform and tools
- **[theming.nix](../../../modules/environment/theming.nix)** - GTK/Qt themes and appearance
- **[laptop.nix](../../../modules/environment/laptop.nix)** - Laptop-specific optimizations

## Hardware Modules

Machine-specific hardware configurations:

- **[amd.nix](../../../modules/hardware/amd.nix)** - AMD RX 5600/5700 XT GPU configuration
- **[intel-mac.nix](../../../modules/hardware/intel-mac.nix)** - Intel MacBook configuration

## Development Modules

Development environment and tools:

- **[shell.nix](../../../modules/development/shell.nix)** - System-wide shell configuration
- **[rocm.nix](../../../modules/development/rocm.nix)** - ROCm packages for ML/AI workloads

## System Modules

Core operating system functionality:

- **[boot.nix](../../../modules/system/boot.nix)** - Boot configuration and Plymouth
- **[networking.nix](../../../modules/system/networking.nix)** - Network configuration
- **[users.nix](../../../modules/system/users.nix)** - System user management
- **[security.nix](../../../modules/system/security.nix)** - Firewall and security settings
- **[secrets.nix](../../../modules/system/secrets.nix)** - Secrets management with sops-nix
- **[monitoring.nix](../../../modules/system/monitoring.nix)** - System monitoring and logging
- **[performance.nix](../../../modules/system/performance.nix)** - Performance optimizations

## Service Modules

System services and daemons:

- **[openssh.nix](../../../modules/services/openssh.nix)** - SSH server configuration
- **[duckdns.nix](../../../modules/services/duckdns.nix)** - Dynamic DNS service
- **[filesystems.nix](../../../modules/services/filesystems.nix)** - Additional filesystem mounts

## User Modules

User-specific configurations via Home Manager:

- **[fabio.nix](../../../modules/users/fabio.nix)** - Personal user environment and dotfiles

## Creating New Modules

### Interface Modules

When creating new interface modules, follow the dual-level pattern:

```
modules/interface/new-interface/
├── default.nix    # System-level configuration
└── home.nix       # User-level configuration (Home Manager)
```

### Module Template

```nix
# modules/category/module-name.nix
# Brief description of what this module does

{ config, lib, pkgs, ... }:

{
  # Conditional loading if needed
  # lib.mkIf (condition) {
  
  # System packages
  environment.systemPackages = with pkgs; [
    # packages here
  ];
  
  # Service configuration
  services.example = {
    enable = true;
    # configuration options
  };
  
  # Additional configuration
  # ...
  
  # }
}
```

### Best Practices

1. **Single Responsibility**: Each module should have one clear purpose
2. **Conditional Loading**: Use `lib.mkIf` for machine-specific features
3. **Documentation**: Include comments explaining non-obvious configuration
4. **Dependencies**: Make dependencies explicit through imports
5. **Testing**: Ensure the module works with `nixos-rebuild dry-build`