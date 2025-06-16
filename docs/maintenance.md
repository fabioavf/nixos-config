# Maintenance Guide

## Common Commands

### NixOS Management
```bash
# Rebuild and switch immediately
nrs   # alias for: sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)

# Test configuration without switching
nrt   # alias for: sudo nixos-rebuild test --flake /etc/nixos#$(hostname)

# Rebuild for next boot (current system unchanged)
nrb   # alias for: sudo nixos-rebuild boot --flake /etc/nixos#$(hostname)

# Update flake inputs and rebuild
nru   # alias for: sudo nix flake update /etc/nixos && sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)

# Manual commands
sudo nixos-rebuild switch --flake .#fabio-nixos    # Explicit host
sudo nixos-rebuild dry-build --flake .#fabio-nixos # Test build only
nixos-version                                       # Show NixOS version
```

### Package Management
```bash
# Test package in temporary shell
nix-shell -p package-name

# Search for packages
nix search nixpkgs package-name

# Garbage collection
sudo nix-collect-garbage -d     # Delete old generations
nix-store --gc                  # Garbage collect store
sudo nix-store --optimize       # Optimize store (deduplicate)
```

### Flake Management
```bash
# Update all inputs
nix flake update

# Update specific input
nix flake update nixpkgs

# Show flake info
nix flake show
nix flake metadata

# Add new input
nix flake init  # Create new flake.nix template
```

## System Information

### Hardware & Performance
```bash
# GPU monitoring and control
rocm-smi              # AMD GPU status
rocminfo              # ROCm system info
clinfo                # OpenCL info
nvtop                 # AMD GPU usage (htop-like)
corectrl              # GUI GPU control

# System monitoring
btop                  # Better htop
iotop                 # I/O monitoring
nethogs               # Network per-process
bandwhich             # Network bandwidth by process
ncdu                  # Disk usage analyzer

# Hardware info
lscpu                 # CPU information
lsblk                 # Block devices
lsusb                 # USB devices
lspci                 # PCI devices
```

### Gaming & Media
```bash
# Gaming
gamemode-run command  # Run with performance optimizations
mangohud command      # Run with performance overlay
steam                 # Launch Steam

# Media control
playerctl play-pause  # Media player control
playerctl next        # Next track
playerctl previous    # Previous track
```

### Shell Features
```bash
# Interactive tools (available in user shell)
fcd                   # Interactive directory navigation with fzf
fe                    # Fuzzy file finder and editor
fuck                  # Correct last command with pay-respects
z dirname             # Jump to frequently used directories

# Useful shortcuts
Ctrl+R                # Fuzzy history search with fzf
Ctrl+T                # Fuzzy file finder
Alt+C                 # Fuzzy directory changer
```

## Troubleshooting

### Boot Issues
```bash
# Check boot status
systemctl status
journalctl -b         # Current boot logs
journalctl -b -1      # Previous boot logs

# Boot into safe mode
# Select older generation from systemd-boot menu

# Check Plymouth splash
journalctl -u plymouth-start.service
```

### Graphics & Display
```bash
# Check AMD driver
lsmod | grep amdgpu
dmesg | grep amdgpu

# Verify ROCm
rocminfo              # Should show GPU devices
echo $HSA_OVERRIDE_GFX_VERSION  # Should be 10.3.0

# Check Hyprland
ps aux | grep Hyprland
journalctl --user -u hyprland.service

# Wayland/X11 check
echo $WAYLAND_DISPLAY  # Should be set for Wayland
echo $DISPLAY          # XWayland compatibility
```

### Audio Issues
```bash
# Check PipeWire status
systemctl --user status pipewire
systemctl --user status pipewire-pulse
systemctl --user status wireplumber

# Audio control
wpctl status          # PipeWire control
pavucontrol          # GUI audio control
pactl list sinks     # List audio outputs
```

### Network Issues
```bash
# Network status
ip addr show         # Network interfaces
ping 8.8.8.8         # Test connectivity
systemctl status NetworkManager

# DNS check
nslookup google.com
systemd-resolve --status

# DuckDNS service (desktop only)
systemctl status duckdns.service
journalctl -u duckdns.service
```

### Service Management
```bash
# System services
systemctl status service-name
systemctl restart service-name
journalctl -u service-name

# User services
systemctl --user status service-name
systemctl --user restart service-name
journalctl --user -u service-name

# Fail2ban (security)
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

### Home Manager Issues
```bash
# Home Manager status
systemctl --user status home-manager-fabio.service

# Manual Home Manager commands
home-manager switch
home-manager generations
home-manager packages

# Check configuration
home-manager option-search term
```

## Configuration Management

### Testing Changes
```bash
# Always test before switching
sudo nixos-rebuild dry-build --flake .#fabio-nixos
sudo nixos-rebuild test --flake .#fabio-nixos

# Check configuration syntax
nix flake check
```

### Rollback Procedures
```bash
# List generations
sudo nixos-rebuild list-generations

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Boot into specific generation
# Select from systemd-boot menu at startup
```

### Secrets Management
```bash
# Edit secrets (requires sops and age key)
sops secrets/secrets.yaml

# Check secret status
systemctl status decrypt-fabio-duckdns-token.service

# Regenerate age keys (if needed)
# age-keygen -o /var/lib/sops-nix/key.txt
```

## Regular Maintenance

### Weekly Tasks
- Run `nru` to update flake inputs and rebuild
- Check system logs: `journalctl -xe`
- Monitor disk usage: `ncdu /`
- Clean up downloads: `rm -rf ~/Downloads/old-files`

### Monthly Tasks  
- Update Flatpak apps: `flatpak update`
- Check fail2ban logs: `sudo fail2ban-client status`
- Review security updates in system logs
- Backup important configurations

### As Needed
- Clean old generations: `sudo nix-collect-garbage -d`
- Update BIOS/UEFI firmware
- Check SSD health: `smartctl -a /dev/nvme0n1`
- Review and update documentation

## File Locations

- **System config**: `/etc/nixos/`
- **User data**: `/data/` (separate partition)
- **Logs**: `/var/log/` and `journalctl`
- **Secrets**: `/var/lib/sops-nix/`
- **Flatpak**: `/var/lib/flatpak/` and `~/.local/share/flatpak/`
- **Home Manager**: `~/.local/state/nix/profiles/home-manager`