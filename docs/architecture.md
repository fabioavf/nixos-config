# Architecture Documentation

## Hybrid Module Organization

This configuration uses a **hybrid architecture** that combines domain-based and interface-based organization for maximum maintainability and scalability.

### Directory Structure

```
/etc/nixos/
├── flake.nix                   # Flake configuration with custom overlays
├── configuration.nix           # Main entry point (imports host config)
├── hardware-configuration.nix  # Auto-generated hardware detection
├── hosts/
│   └── fabio-nixos/           # Host-specific configuration
│       ├── configuration.nix   # All imports for this machine
│       └── hardware-configuration.nix
├── modules/
│   ├── interface/             # NEW: Interface-based organization
│   │   ├── tui/              # Terminal user interfaces
│   │   │   ├── default.nix   # System-level TUI tools
│   │   │   ├── editors.nix   # Text editors and terminals
│   │   │   └── home.nix      # User-level TUI configurations
│   │   ├── gui/              # Graphical user interfaces  
│   │   │   ├── default.nix   # System-level GUI apps
│   │   │   ├── desktop-heavy.nix # Desktop-specific heavy apps
│   │   │   └── home.nix      # User-level GUI configurations
│   │   └── wm/               # Window managers
│   │       └── hyprland/
│   │           ├── default.nix # System-level WM configuration
│   │           └── home.nix    # User-level WM settings
│   ├── environment/          # System-wide concerns
│   │   ├── audio.nix         # PipeWire audio configuration
│   │   ├── fonts.nix         # System and programming fonts
│   │   ├── gaming.nix        # Steam, Wine, controllers
│   │   ├── theming.nix       # GTK/Qt themes
│   │   └── laptop.nix        # Laptop-specific optimizations
│   ├── hardware/             # Hardware-specific configurations
│   │   ├── amd.nix          # AMD GPU configuration
│   │   └── intel-mac.nix    # Intel MacBook configuration
│   ├── development/          # Development-specific modules
│   │   ├── shell.nix        # System-wide shell configuration
│   │   └── rocm.nix         # ROCm for ML/AI workloads
│   ├── system/              # Core system configuration
│   │   ├── boot.nix         # Boot configuration
│   │   ├── networking.nix   # Network configuration
│   │   ├── users.nix        # System user management
│   │   ├── security.nix     # Firewall and security
│   │   ├── secrets.nix      # Secrets management
│   │   └── ...             # Other system modules
│   ├── services/           # System services
│   │   ├── openssh.nix     # SSH server
│   │   ├── duckdns.nix     # Dynamic DNS
│   │   └── filesystems.nix # Additional filesystems
│   └── users/              # User-specific configurations
│       └── fabio.nix       # Home Manager user config
├── packages/               # Custom package definitions
│   └── faugus-launcher.nix # Custom game launcher
└── secrets/               # Encrypted secrets
    └── secrets.yaml       # sops-encrypted secrets
```

## Architectural Principles

### 1. Interface-Based Organization

**Innovation from external repo**: Modules are organized by interface type rather than just application type:

- **`interface/tui/`**: Terminal-based tools and applications
- **`interface/gui/`**: Graphical applications and desktop tools  
- **`interface/wm/`**: Window managers and desktop environments

**Benefits**:
- Groups tools by usage context
- Easier to find modules when working in specific environments
- Better separation between heavy desktop apps and lightweight alternatives

### 2. Dual-Level Module Structure

**Innovation from external repo**: Each interface module has both system and user configurations:

```nix
modules/interface/wm/hyprland/
├── default.nix    # System-level (enables Hyprland service)
└── home.nix       # User-level (personal Hyprland config)
```

**Benefits**:
- Clear separation between system and user concerns
- Easier Home Manager integration
- Consistent structure across all interface modules

### 3. Host-Specific Configuration

**Your original strength enhanced**: Host-specific configurations handle machine differences:

```nix
# hosts/fabio-nixos/configuration.nix imports:
../../modules/interface/gui/desktop-heavy.nix  # Heavy desktop apps
../../modules/hardware/amd.nix                # AMD GPU configuration
../../modules/development/rocm.nix             # ROCm for ML/AI

# Future hosts/laptop/ would import:
../../modules/interface/tui/default.nix       # Lightweight TUI tools only
../../modules/hardware/intel.nix              # Intel-specific configuration
# (No heavy desktop apps or ROCm)
```

### 4. Conditional Loading Patterns

**Enhanced from both approaches**: Smart loading based on machine capabilities:

```nix
# In host configurations
lib.mkIf (config.networking.hostName == "fabio-nixos") {
  # Desktop-only features
}

# In user configurations (future enhancement)
imports = [
  # Core modules
] ++ lib.optionals (hostname == "fabio-nixos") [
  # Desktop-specific user modules
] ++ lib.optionals (hostname == "laptop") [
  # Laptop-specific user modules
];
```

## Design Philosophy

### Separation of Concerns

1. **Interface modules**: How users interact (TUI vs GUI vs WM)
2. **Environment modules**: System-wide settings that affect all interfaces
3. **Hardware modules**: Machine-specific optimizations and drivers
4. **Development modules**: Programming tools and environments
5. **System modules**: Core OS functionality
6. **Services modules**: Background services and daemons

### Maintainability Features

- **Single source of truth** for each concern
- **Explicit dependencies** through imports
- **Machine-specific optimizations** without code duplication
- **Easy testing** with `nixos-rebuild dry-build`
- **Rollback capability** with NixOS generations

### Scalability Benefits

- **Easy machine addition**: Create new host directory, reuse existing modules
- **Feature modularity**: Mix and match capabilities as needed
- **Clean abstractions**: Hardware-specific code isolated from generic logic
- **Future-proof**: Structure supports new interface types and hardware

## Migration Benefits

### What We Kept (Your Strengths)
- ✅ Excellent domain separation (hardware, services, system)
- ✅ Sophisticated multi-machine support with conditional loading  
- ✅ Modern secrets management with sops-nix
- ✅ Consolidated hardware configurations (AMD module)
- ✅ Advanced Home Manager integration

### What We Added (External Innovations)
- ✅ Interface-based organization (TUI/GUI/WM)
- ✅ Dual-level modules (system + user configs)
- ✅ Host-conditional user configurations
- ✅ Structured documentation approach
- ✅ Better overlay organization (planned)

### Result: Best of Both Worlds
A hybrid architecture that maintains all existing functionality while improving organization, maintainability, and scalability for future expansion.