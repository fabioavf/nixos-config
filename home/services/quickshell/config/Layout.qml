pragma Singleton

import QtQuick
import "./Material.qml" as M
import "./Device.qml" as D

Singleton {
    id: root

    // Responsive layout constants based on device
    readonly property LayoutConfig layout: Device.config.systemInfoDisplayMode === "expanded" 
        ? expandedLayout 
        : compactLayout

    // Compact layout (MacBook)
    readonly property LayoutConfig compactLayout: LayoutConfig {
        // Main sections
        leftSectionMinWidth: 200
        centerSectionWidth: 160
        rightSectionMinWidth: 180

        // Workspace configuration
        workspaceSpacing: Material.spacing.sm
        workspaceIndicatorSize: Device.config.workspaceSize
        maxVisibleWorkspaces: 8

        // System info configuration
        systemInfoMode: "compact"
        systemInfoSpacing: Material.spacing.xs
        showSystemCards: false

        // Widget spacing
        widgetSpacing: Material.spacing.md
        sectionSpacing: Material.spacing.lg
        innerPadding: Device.config.barPadding
    }

    // Expanded layout (Desktop)
    readonly property LayoutConfig expandedLayout: LayoutConfig {
        // Main sections
        leftSectionMinWidth: 300
        centerSectionWidth: 180
        rightSectionMinWidth: 400

        // Workspace configuration
        workspaceSpacing: Material.spacing.md
        workspaceIndicatorSize: Device.config.workspaceSize
        maxVisibleWorkspaces: 12

        // System info configuration
        systemInfoMode: "expanded"
        systemInfoSpacing: Material.spacing.sm
        showSystemCards: true

        // Widget spacing
        widgetSpacing: Material.spacing.lg
        sectionSpacing: Material.spacing.xl
        innerPadding: Device.config.barPadding
    }

    component LayoutConfig: QtObject {
        // Section widths
        property int leftSectionMinWidth: 200
        property int centerSectionWidth: 160
        property int rightSectionMinWidth: 180

        // Workspace layout
        property int workspaceSpacing: Material.spacing.sm
        property int workspaceIndicatorSize: 32
        property int maxVisibleWorkspaces: 8

        // System info layout
        property string systemInfoMode: "compact" // "compact" or "expanded"
        property int systemInfoSpacing: Material.spacing.xs
        property bool showSystemCards: false

        // General spacing
        property int widgetSpacing: Material.spacing.md
        property int sectionSpacing: Material.spacing.lg
        property int innerPadding: 12
    }

    // Animation configurations for responsive transitions
    readonly property AnimationConfig animations: AnimationConfig {
        // Layout transition animations
        resizeAnimation: Transition {
            NumberAnimation {
                properties: "width,height,x,y"
                duration: Material.animation.durationMedium2
                easing.type: Easing.OutCubic
            }
        }

        // Workspace transition animations
        workspaceAnimation: Transition {
            NumberAnimation {
                properties: "opacity,scale"
                duration: Material.animation.durationShort4
                easing.type: Easing.OutCubic
            }
        }

        // System info transition animations
        systemInfoAnimation: Transition {
            NumberAnimation {
                properties: "opacity,width"
                duration: Material.animation.durationMedium1
                easing.type: Easing.OutCubic
            }
        }
    }

    component AnimationConfig: QtObject {
        property Transition resizeAnimation
        property Transition workspaceAnimation
        property Transition systemInfoAnimation
    }

    // Responsive breakpoints
    readonly property BreakpointConfig breakpoints: BreakpointConfig {
        // Width breakpoints (logical pixels)
        compactMax: 1700      // MacBook and smaller
        mediumMax: 2400       // Intermediate screens
        expandedMin: 2400     // Desktop and larger

        // Height breakpoints
        shortMax: 800         // Very short screens
        tallMin: 1200         // Tall screens
    }

    component BreakpointConfig: QtObject {
        property int compactMax: 1700
        property int mediumMax: 2400
        property int expandedMin: 2400
        property int shortMax: 800
        property int tallMin: 1200
    }

    // Layout state information
    readonly property var layoutState: ({
        isCompact: Device.isMacBook,
        isExpanded: Device.isDesktop,
        currentMode: layout.systemInfoMode,
        deviceType: Device.deviceType,
        barHeight: Device.config.barHeight,
        showSystemCards: layout.showSystemCards
    })
}