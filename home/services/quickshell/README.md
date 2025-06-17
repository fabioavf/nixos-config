# 🌟 Lumin Bar - Material 3 Status Bar for Niri

> Beautiful, responsive status bar with smart workspace indicators

## 🚀 Quick Start

```bash
# Enable in NixOS (already configured)
sudo nixos-rebuild switch

# Manual testing in Niri session
quickshell -c lumin
```

## 📚 Documentation

- **[📋 LUMIN_V1_HANDOFF.md](./LUMIN_V1_HANDOFF.md)** - **START HERE** - Complete v1.0 handoff with all current features
- **[📁 docs/](./docs/)** - Historical development documentation

## 🎯 Current Features (v1.0)

✅ **Smart workspace indicators** with window count dots  
✅ **Perfect center-aligned clock** that never moves  
✅ **Material 3 design** with smooth animations  
✅ **Real-time Niri integration** via custom IPC  
✅ **Responsive layout** for MacBook and Desktop  

## 🔧 Key Files

- **`shell.qml`** - Main UI (inline components)
- **`services/NiriIPC.qml`** - Niri communication service  
- **`config/Material.qml`** - Material 3 design system
- **`default.nix`** - NixOS integration

## 🎨 Visual Preview

```
[●●●●] [●●] [○] [●●●●●]        🕐 14:23        12 windows ●
```

---

**Status: ✅ Production Ready** | **Next: Choose features from handoff doc** 🚀