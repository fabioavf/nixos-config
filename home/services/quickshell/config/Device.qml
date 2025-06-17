pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // Device detection based on screen resolution
    readonly property bool isMacBook: {
        if (!Quickshell.screens.length) return false
        const screen = Quickshell.screens[0]
        const logicalWidth = screen.width / screen.devicePixelRatio
        return logicalWidth <= 1600 // MacBook: 2560x1600 @ 1.6x = 1600x1000 logical
    }

    readonly property bool isDesktop: {
        if (!Quickshell.screens.length) return false
        const screen = Quickshell.screens[0]
        const logicalWidth = screen.width / screen.devicePixelRatio
        return logicalWidth >= 2560 // Desktop: 3840x2160 @ 1.5x = 2560x1440 logical
    }

    readonly property string deviceType: {
        if (isMacBook) return "macbook"
        if (isDesktop) return "desktop"
        return "unknown"
    }

    // Device-specific configuration
    readonly property DeviceConfig config: {
        if (isMacBook) return macbookConfig
        if (isDesktop) return desktopConfig
        return defaultConfig
    }

    // MacBook Configuration
    readonly property DeviceConfig macbookConfig: DeviceConfig {
        // Bar dimensions
        barHeight: 44
        barMargin: 16
        barPadding: 12

        // Widget sizing
        workspaceSize: 32
        iconSize: 20
        systemInfoWidth: 40

        // Features
        showBattery: true
        showWifi: true
        showBluetooth: true
        showExpandedSystemInfo: false
        systemInfoDisplayMode: "popover"

        // Popover sizing
        popoverWidth: 280
        popoverHeight: 200
    }

    // Desktop Configuration  
    readonly property DeviceConfig desktopConfig: DeviceConfig {
        // Bar dimensions
        barHeight: 48
        barMargin: 20
        barPadding: 16

        // Widget sizing
        workspaceSize: 36
        iconSize: 24
        systemCardWidth: 80

        // Features
        showBattery: false       // Desktop has no battery
        showWifi: false          // Desktop uses ethernet
        showBluetooth: false     // Desktop has no bluetooth
        showExpandedSystemInfo: true
        systemInfoDisplayMode: "expanded"

        // No popover needed for desktop
        popoverWidth: 0
        popoverHeight: 0
    }

    // Default fallback configuration
    readonly property DeviceConfig defaultConfig: DeviceConfig {
        barHeight: 46
        barMargin: 18
        barPadding: 14
        workspaceSize: 34
        iconSize: 22
        systemInfoWidth: 60
        systemCardWidth: 70
        showBattery: true
        showWifi: true
        showBluetooth: true
        showExpandedSystemInfo: false
        systemInfoDisplayMode: "popover"
        popoverWidth: 280
        popoverHeight: 200
    }

    component DeviceConfig: QtObject {
        // Bar dimensions
        property int barHeight: 44
        property int barMargin: 16
        property int barPadding: 12

        // Widget sizing
        property int workspaceSize: 32
        property int iconSize: 20
        property int systemInfoWidth: 40
        property int systemCardWidth: 80

        // Feature flags
        property bool showBattery: true
        property bool showWifi: true
        property bool showBluetooth: true
        property bool showExpandedSystemInfo: false
        property string systemInfoDisplayMode: "popover" // "popover" or "expanded"

        // Popover dimensions
        property int popoverWidth: 280
        property int popoverHeight: 200
    }

    // Debug information
    readonly property var debugInfo: ({
        deviceType: deviceType,
        isMacBook: isMacBook,
        isDesktop: isDesktop,
        screenCount: Quickshell.screens.length,
        primaryScreen: Quickshell.screens.length > 0 ? {
            width: Quickshell.screens[0].width,
            height: Quickshell.screens[0].height,
            devicePixelRatio: Quickshell.screens[0].devicePixelRatio,
            logicalWidth: Quickshell.screens[0].width / Quickshell.screens[0].devicePixelRatio,
            logicalHeight: Quickshell.screens[0].height / Quickshell.screens[0].devicePixelRatio
        } : null
    })
}