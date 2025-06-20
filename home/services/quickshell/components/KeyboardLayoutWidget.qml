import QtQuick
import "../config" as Config

Rectangle {
    id: layoutWidget
    
    // Properties
    property string currentLayout: "us"  // Default to US
    property bool isConnected: true
    property bool hasError: false
    property bool isActive: false  // Can be used for active state
    
    // Signals
    signal layoutSwitched(string newLayout)
    
    // Styling - match SystemMetric exactly
    width: Config.Device.config.systemCardWidth || 52
    height: Config.Device.config.workspaceSize
    radius: Config.Material.rounding.medium
    color: Config.Material.colors.surfaceContainer
    border.width: hasError ? 1 : 0
    border.color: hasError ? Config.Material.colors.error : "transparent"
    
    // Shadow - match SystemMetric
    Rectangle {
        anchors.centerIn: parent
        width: parent.width + 2
        height: parent.height + 2
        radius: parent.radius + 1
        color: Config.Material.elevation.shadowColor
        opacity: Config.Material.elevation.shadowOpacity * 0.5
        z: -1
    }
    
    Row {
        anchors.centerIn: parent
        spacing: Config.Material.spacing.sm  // Match SystemMetric spacing
        
        // Keyboard icon - match SystemMetric icon styling
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "󰌌"  // Nerd Font keyboard icon
            color: hasError ? Config.Material.colors.error : Config.Material.colors.primary
            font.pixelSize: Config.Device.config.iconSize || 12
            font.family: Config.Material.typography.monoFamily
        }
        
        // Layout text - match SystemMetric text styling
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: hasError ? "!" : layoutWidget.getDisplayText()
            color: hasError ? Config.Material.colors.error : Config.Material.colors.surfaceText
            font.pixelSize: Config.Material.typography.labelSmall.size
            font.family: Config.Material.typography.fontFamily
            font.weight: Config.Material.typography.labelSmall.weight
        }
    }
    
    // MouseArea - match SystemMetric hover behavior exactly
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        onClicked: {
            console.log(`Lumin: Switching keyboard layout from ${currentLayout}`)
            layoutWidget.switchLayout()
        }
        
        onEntered: {
            parent.scale = 1.05
            parent.color = Config.Material.colors.surfaceContainerHigh
        }
        
        onExited: {
            parent.scale = 1.0
            parent.color = Config.Material.colors.surfaceContainer
        }
    }
    
    // Behavior animations - match SystemMetric exactly
    Behavior on scale {
        NumberAnimation { 
            duration: Config.Material.animation.durationShort3
            easing.type: Easing.OutCubic 
        }
    }
    
    Behavior on color {
        ColorAnimation { 
            duration: Config.Material.animation.durationShort4
            easing.type: Easing.OutCubic 
        }
    }
    
    // Get display text for current layout
    function getDisplayText() {
        switch (currentLayout.toLowerCase()) {
            case "us":
            case "0":
                return "US"
            case "us-cedilla":
            case "1":
                return "INTL"
            case "us-intl":
                return "INTL"  // Keep for backwards compatibility
            default:
                return currentLayout.toUpperCase()
        }
    }
    
    // Get icon for current layout (if you want to use icons instead)
    function getLayoutIcon() {
        switch (currentLayout.toLowerCase()) {
            case "us":
            case "0":
                return "󰌌"  // US keyboard icon
            case "us-cedilla":
            case "1":
                return "󰌏"  // Cedilla keyboard icon
            case "us-intl": 
                return "󰌏"  // International keyboard icon (backwards compatibility)
            default:
                return "⌨"
        }
    }
    
    // Switch to next layout
    function switchLayout() {
        const nextLayout = (currentLayout === "us" || currentLayout === "0") ? "us-cedilla" : "us"
        console.log(`Lumin: Switching keyboard layout to: ${nextLayout}`)
        layoutSwitched(nextLayout)
    }
    
    // Update current layout (called from parent)
    function updateLayout(newLayout) {
        const oldLayout = currentLayout
        currentLayout = newLayout
        
        if (oldLayout !== newLayout) {
            console.log(`Lumin: Keyboard layout changed: ${oldLayout} → ${newLayout}`)
        }
    }
    
    // Set error state
    function setError(hasErr) {
        hasError = hasErr
    }
}