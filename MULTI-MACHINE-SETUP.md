# Multi-Machine NixOS Configuration

This repository now supports multiple machines with shared and machine-specific configurations.

## Supported Machines

### 🖥️ fabio-nixos (Desktop)
- **Hardware**: AMD RX 5600/5700 XT, AMD CPU
- **Purpose**: Gaming and development workstation
- **Features**: Full gaming stack, ROCm compute, heavy desktop applications

### 💻 fabio-macbook (MacBook Pro 13" 2017)
- **Hardware**: Intel i5-7267U, Intel Iris Plus Graphics 640
- **Purpose**: Portable development machine
- **Features**: Battery-optimized, lightweight apps, game streaming client

## Installation Instructions

### For MacBook (New Installation)

1. **Boot from NixOS live USB** on the MacBook

2. **Clone this repository**:
   ```bash
   git clone <your-repo-url> /mnt/etc/nixos
   cd /mnt/etc/nixos
   ```

3. **Generate hardware configuration**:
   ```bash
   sudo nixos-generate-config --root /mnt
   # Copy the generated hardware-configuration.nix
   cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/hosts/fabio-macbook/
   ```

4. **Install NixOS**:
   ```bash
   sudo nixos-install --flake /mnt/etc/nixos#fabio-macbook
   ```

5. **Reboot and enjoy**! Your MacBook will have:
   - Minimal Hyprland desktop environment
   - Full development tools (same as desktop)
   - Battery optimizations with TLP
   - WiFi management with impala
   - Moonlight game streaming
   - quickshell and claude-desktop

### For Desktop (Existing Installation)

Your desktop configuration remains the same, just use the new flake structure:

```bash
sudo nixos-rebuild switch --flake /etc/nixos#fabio-nixos
```

## Configuration Structure

```
/etc/nixos/
├── flake.nix                 # Multi-machine flake configuration
├── hosts/                    # Machine-specific configurations
│   ├── fabio-nixos/         # Desktop configuration
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   └── fabio-macbook/       # MacBook configuration
│       ├── configuration.nix
│       └── hardware-configuration.nix
├── modules/                  # Shared modules with conditional loading
│   ├── hardware/
│   │   ├── amd.nix          # Desktop only
│   │   └── intel-mac.nix    # MacBook only
│   ├── environment/         # Applications and desktop environment
│   │   ├── apps.nix         # Common apps (both machines)
│   │   ├── desktop.nix      # Desktop-specific heavy apps
│   │   ├── laptop.nix       # MacBook-specific apps
│   │   ├── gaming.nix       # Desktop gaming (Steam, Wine, etc.)
│   │   └── [shared environment modules]
│   └── [other shared modules]
```

## Machine-Specific Features

### Desktop (fabio-nixos)
- ✅ Gaming: Steam, Wine, controllers, GameMode
- ✅ AMD GPU: ROCm, CoreCtrl, advanced optimizations
- ✅ Heavy Apps: OBS, GIMP, full desktop suite
- ✅ Services: DuckDNS, filesystem mounts
- ✅ Streaming: Sunshine game streaming server

### MacBook (fabio-macbook)
- ✅ Development: Same tools as desktop (editors, languages)
- ✅ Lightweight: Minimal app selection, battery optimized
- ✅ Intel Graphics: Proper drivers and optimizations
- ✅ Power Management: TLP, clight, aggressive power saving
- ✅ Networking: impala for WiFi, NetworkManager
- ✅ Gaming: moonlight-qt for streaming from desktop
- ✅ Desktop: Minimal Hyprland with quickshell
- ❌ No Gaming: No Steam, Wine, heavy games
- ❌ No ROCm: Intel graphics only
- ❌ No Heavy Apps: Optimized for battery life

## Usage Commands

Both machines use the same commands (machine-aware):

```bash
nrs    # Rebuild and switch (auto-detects hostname)
nrt    # Test configuration
nrb    # Rebuild for next boot
nru    # Update flake and rebuild
```

### MacBook-Specific Commands
```bash
battery      # Check battery status
powersave    # Switch to battery mode
performance  # Switch to AC power mode
wifi         # Launch impala WiFi manager
```

## Development Workflow

1. **Shared Development Environment**: Both machines have identical development tools
2. **Consistent Shell**: Same zsh configuration, aliases, and features
3. **Synchronized Configs**: Git settings, editor configurations shared
4. **Game Streaming**: Use moonlight-qt on MacBook to stream games from desktop

## Maintenance

- **Desktop**: Full gaming and development workstation
- **MacBook**: Lightweight, battery-optimized development machine
- **Shared**: Common development tools, shell, and user environment
- **Updates**: Single repository maintains both configurations

This setup gives you the best of both worlds: a powerful desktop for gaming and intensive work, and an efficient laptop for portable development with game streaming capabilities.