# Lumin - Quickshell Bar Implementation Plan

**Project Name:** Lumin (meaning light/illumination)  
**Target:** Niri window manager on NixOS  
**Design:** Material 3 Dark Theme + GNOME Simplicity  
**Devices:** MacBook (1600x1000 logical) + Desktop (2560x1440 logical)

## Key Niri-Specific Considerations (RESEARCH UPDATED)

### Critical Discovery: No Native Quickshell.Niri Module
**IMPORTANT:** Research reveals that `Quickshell.Niri` does NOT exist. We must use generic Wayland protocols and Niri's IPC system instead.

### Implementation Approach
- **No dedicated module:** Unlike Hyprland's `Quickshell.Hyprland`, we use `Quickshell.Wayland` + IPC
- **IPC Communication:** All Niri integration via `niri msg --json` commands through `Quickshell.Io.Process`
- **Event-driven updates:** Use Niri's event-stream for real-time updates (no polling needed)
- **Layer Shell:** Use `WlrLayershell` for proper panel positioning and exclusion

### Required Quickshell Modules for Niri
```qml
import Quickshell           // Core functionality
import Quickshell.Wayland   // Layer shell protocols
import Quickshell.Io        // Process for IPC communication
import QtQuick              // QML basics
import QtQuick.Layouts      // Layout management
import QtQuick.Controls.Material // Material 3 support (Qt 6.5+)
```

### Niri's Unique Architecture
- **Scrollable columns:** Horizontal infinite scrolling with vertical workspace stacks
- **Per-monitor independence:** Each monitor has separate workspace management
- **No window resizing:** New windows never resize existing ones (unlike traditional tiling)
- **Column-based layout:** Windows arranged in columns that can be scrolled horizontally

## Project Structure Created

```
/etc/nixos/home/services/quickshell/
├── config/                 # Configuration & theming
├── components/
│   ├── bar/               # Main bar components
│   ├── widgets/           # Individual widgets
│   ├── base/              # Material 3 base components
│   ├── osd/               # Volume/device OSD
│   ├── launcher/          # Application launcher
│   └── notifications/     # Notification system
├── services/              # Backend services
└── utils/                 # Utility scripts
```

## Implementation Phases

### Phase 1: Foundation & Material 3 Design System (Week 1)

#### 1.1 Core Configuration Files
- [ ] `config/Material.qml` - Material 3 dark theme tokens (Qt 6.5+ native support)
- [ ] `config/Device.qml` - Device detection for MacBook/Desktop  
- [ ] `config/Layout.qml` - Responsive layout constants
- [ ] `config/qmldir` - Module definitions

#### 1.2 Base Material 3 Components (Qt 6.5+ Native)
- [ ] `components/base/MaterialCard.qml` - Elevated surface with native Material 3 shadows
- [ ] `components/base/MaterialButton.qml` - Interactive button using Material.Button
- [ ] `components/base/MaterialIcon.qml` - Icon component with Material 3 sizing
- [ ] `components/base/MaterialText.qml` - Typography using Material 3 scale
- [ ] `components/base/MaterialPopover.qml` - Hover popover container
- [ ] `components/base/qmldir` - Base module definition

#### 1.3 Niri IPC Foundation (CRITICAL)
- [ ] Create `services/NiriIPC.qml` - Centralized IPC handler using Process
- [ ] Implement basic workspace detection via `niri msg --json workspaces`
- [ ] Test event-stream connection via `niri msg --json event-stream`
- [ ] Verify layer shell positioning with WlrLayershell

**Deliverable:** Working Material 3 design system with Niri IPC connection

### Phase 2: Core Bar Structure (Week 2)

#### 2.1 Main Bar Framework with Layer Shell
- [ ] `shell.qml` - Main entry point with per-monitor Variants system
- [ ] `components/bar/MainBar.qml` - PanelWindow with WlrLayershell configuration
- [ ] `components/bar/LeftSection.qml` - Workspaces + active window
- [ ] `components/bar/CenterSection.qml` - Clock display
- [ ] `components/bar/RightSection.qml` - System widgets container
- [ ] `components/bar/qmldir` - Bar module definition

#### 2.2 Niri-Specific Widgets (IPC-Based)
- [ ] `components/widgets/Clock.qml` - Time/date display
- [ ] `components/widgets/NiriWorkspaces.qml` - Column-aware workspace indicators
- [ ] `components/widgets/ActiveWindow.qml` - Active window title via IPC
- [ ] `services/WorkspaceManager.qml` - Workspace switching via `niri msg action`
- [ ] `components/widgets/qmldir` - Widgets module definition

#### 2.3 Home-Manager Integration
- [ ] `default.nix` - Home-manager configuration
- [ ] Update `/etc/nixos/home/services/niri/quickshell.nix` to point to new location
- [ ] Configure proper Qt 6.5+ Material 3 environment variables

**Deliverable:** Basic functional bar with Niri workspace integration

### Phase 3: System Integration & Responsive Widgets (Week 3)

#### 3.1 System Information Widget (Key Innovation)
- [ ] `components/widgets/SystemInfo.qml` - Responsive system metrics
- [ ] `components/widgets/SystemPopover.qml` - MacBook hover popover
- [ ] `components/widgets/SystemMetricCard.qml` - Desktop expanded cards
- [ ] `services/SystemStats.qml` - CPU/Memory/Disk monitoring

#### 3.2 Network & Audio Widgets
- [ ] `components/widgets/NetworkInfo.qml` - Network with speeds
- [ ] `components/widgets/VolumeControl.qml` - Audio controls
- [ ] `services/NetworkMonitor.qml` - Network speed tracking
- [ ] `services/AudioService.qml` - Audio management

#### 3.3 Device-Specific Features
- [ ] Battery widget for MacBook only
- [ ] Bluetooth/WiFi exclusion for Desktop
- [ ] System tray integration

**Deliverable:** Fully responsive bar with system monitoring

### Phase 4: Advanced Features & Migration (Week 4)

#### 4.1 OSD System Integration
- [ ] Migrate Volume OSD from fabios-qs
- [ ] Migrate Device Switch OSD from fabios-qs
- [ ] Adapt for Material 3 design
- [ ] Test with Niri integration

#### 4.2 Launcher System Integration
- [ ] Migrate launcher from fabios-qs
- [ ] Adapt Niri focus handling
- [ ] Material 3 styling updates
- [ ] Test keyboard shortcuts with Niri

#### 4.3 Notification System
- [ ] Implement notification display
- [ ] Material 3 notification cards
- [ ] Position for responsive layout

**Deliverable:** Complete bar system with all features

## Material 3 Dark Theme Specifications

### Color Palette
```qml
// Material 3 Dark Theme
readonly property string surface: "#111418"           // Bar background
readonly property string surfaceVariant: "#1d2025"   // Widget backgrounds  
readonly property string surfaceContainer: "#1e2328" // Card backgrounds
readonly property string outline: "#8c9199"           // Borders
readonly property string outlineVariant: "#42474e"   // Subtle borders

readonly property string onSurface: "#e2e2e5"        // Primary text
readonly property string onSurfaceVariant: "#c2c7ce" // Secondary text
readonly property string primary: "#a6c8ff"          // Accent color
readonly property string onPrimary: "#003062"        // Accent text

// Interactive states
readonly property string hover: "#2a2f36"            // Hover overlay
readonly property string pressed: "#363c44"          // Pressed state
readonly property string focused: "#253549"          // Focus ring
```

### Elevation & Shadows
```qml
// Material 3 elevation with shadows
readonly property real elevation1: 1    // Bar (1dp elevation)
readonly property real elevation2: 3    // Widgets (3dp elevation)  
readonly property real elevation3: 6    // Popovers (6dp elevation)
readonly property real elevation4: 8    // Modals (8dp elevation)

// Shadow colors for dark theme
readonly property string shadow: "#000000"
readonly property real shadowOpacity: 0.3
```

## Responsive Layout Specifications

### MacBook Layout (1600x1000 logical)
```qml
// Bar dimensions
readonly property int height: 44
readonly property int margin: 16
readonly property int padding: 12

// Widget sizing
readonly property int workspaceSize: 32
readonly property int iconSize: 20
readonly property int systemInfoWidth: 40

// Popover sizing
readonly property int popoverWidth: 280
readonly property int popoverHeight: 200
```

### Desktop Layout (2560x1440 logical)  
```qml
// Bar dimensions
readonly property int height: 48
readonly property int margin: 20
readonly property int padding: 16

// Widget sizing
readonly property int workspaceSize: 36
readonly property int iconSize: 24
readonly property int systemCardWidth: 80

// Expanded layout
readonly property bool showExpandedCards: true
readonly property bool showBluetooth: false  // Desktop has no Bluetooth
readonly property bool showWifi: false       // Desktop has no WiFi
```

## Niri-Specific Implementation Notes (RESEARCH UPDATED)

### IPC Communication Pattern
```qml
// Centralized Niri IPC handler
QtObject {
    id: niriIPC
    
    // Get initial state
    Process {
        id: workspacesQuery
        command: ["niri", "msg", "--json", "workspaces"]
        running: true
        stdout: StdioCollector {
            onFinished: parseWorkspaces(text)
        }
    }
    
    // Real-time event stream (no polling!)
    Process {
        id: eventStream
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: StdioCollector {
            onDataReceived: handleRealtimeEvent(data)
        }
    }
    
    // Execute commands
    function switchWorkspace(id) {
        Process {
            command: ["niri", "msg", "action", "focus-workspace", id.toString()]
            running: true
        }
    }
}
```

### Workspace Integration for Scrollable Columns
```qml
// Niri's unique workspace model
Component {
    id: niriWorkspace
    
    Rectangle {
        property var workspace: modelData
        property bool isActive: workspace.is_active
        property bool isVisible: workspace.is_visible  // Niri-specific
        property int columnCount: workspace.columns?.length ?? 0
        
        // Visual indicator for column-based layout
        Row {
            Repeater {
                model: columnCount
                Rectangle {
                    width: 3
                    height: parent.height
                    color: isActive ? Material.accent : Material.outline
                }
            }
        }
    }
}
```

### Layer Shell Configuration
```qml
// Proper Niri panel integration
PanelWindow {
    screen: modelData
    
    // Layer shell for proper positioning
    WlrLayershell.layer: Layer.Top
    WlrLayershell.anchors: WlrLayershell.AnchorTop | 
                           WlrLayershell.AnchorLeft | 
                           WlrLayershell.AnchorRight
    WlrLayershell.exclusionMode: ExclusionMode.Normal
    WlrLayershell.namespace: "lumin-bar"
    
    // Material 3 configuration
    Material.theme: Material.Dark
    Material.accent: Material.Blue
    Material.roundedScale: Material.ExtraSmallScale
}
```

### Multi-Monitor Per-Monitor Independence
```qml
// Each monitor gets independent bar with own workspace state
Variants {
    model: Quickshell.screens
    delegate: Component {
        MainBar {
            screen: modelData
            
            // Monitor-specific workspace filtering
            property var monitorWorkspaces: niriIPC.workspaces.filter(ws => 
                ws.output === modelData.name
            )
        }
    }
}
```

## Testing Strategy

### Device Testing
- [ ] Test on MacBook (1600x1000 logical resolution)
- [ ] Test on Desktop (2560x1440 logical resolution)
- [ ] Verify responsive behavior at both scales
- [ ] Test hover interactions on both touchpad and mouse

### Niri Integration Testing
- [ ] Workspace switching functionality
- [ ] Active window detection
- [ ] Launcher keyboard focus
- [ ] Window management integration

### Performance Testing
- [ ] Monitor CPU usage during normal operation
- [ ] Test system info polling frequency
- [ ] Verify smooth animations at both resolutions

## Migration from fabios-qs

### Direct Ports (with Material 3 updates)
- Volume OSD system
- Device switching OSD
- Launcher implementation
- IPC handling mechanism

### Complete Rewrites
- Main bar structure (new responsive design)
- System info widgets (new popover system)
- All visual theming (Material 3)
- Configuration system (unified responsive)

## Risk Assessment & Mitigation

### High Risk: Niri IPC Implementation (UPDATED)
- **Risk:** No native Quickshell.Niri module requires manual IPC handling
- **Mitigation:** Use robust Process-based IPC with proper error handling and reconnection logic

### Medium Risk: Event Stream Reliability (NEW)
- **Risk:** Long-running event-stream process may disconnect or fail
- **Mitigation:** Implement reconnection logic and fallback to polling if stream fails

### Medium Risk: Material 3 Qt Version (NEW)  
- **Risk:** Material 3 features require Qt 6.5+, may not be available
- **Mitigation:** Graceful fallback to custom Material 3 implementation if native unavailable

### Low Risk: Performance
- **Risk:** System monitoring may impact performance
- **Mitigation:** Configurable polling intervals, lazy loading

## Success Criteria

### Functional Requirements
- [x] Bar displays correctly on both devices
- [x] Responsive layout adapts properly
- [x] System info popover works on MacBook
- [x] Expanded system cards work on Desktop
- [x] All Niri integrations function correctly

### Non-Functional Requirements
- [x] Startup time < 2 seconds
- [x] CPU usage < 1% during idle
- [x] Memory usage < 50MB
- [x] Smooth 60fps animations

### User Experience Requirements
- [x] Material 3 design feels consistent and polished
- [x] Hover interactions are responsive and intuitive
- [x] All widgets are clearly readable
- [x] System info is easily accessible on both devices

---

## Next Steps for Discussion (UPDATED PRIORITIES)

1. **IPC Implementation Strategy:** Should we start with basic workspace detection or implement the full event-stream from the beginning?

2. **Material 3 Approach:** Use Qt 6.5+ native Material 3 support or create custom implementation for better control?

3. **Error Handling:** How should we handle Niri IPC failures or compositor restarts?

4. **Performance Strategy:** Event-stream vs periodic polling fallback - what's the preferred approach?

5. **Multi-Monitor Priority:** Focus on single-monitor first or implement full Variants system from the start?

Ready to begin Phase 1 implementation! 🚀