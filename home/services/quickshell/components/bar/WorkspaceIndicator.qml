import QtQuick
import QtQuick.Controls.Material
import "../base"
import "../../config"

// Beautiful Material 3 workspace indicator
MaterialCard {
    id: root
    
    // Workspace data
    property var workspace: null
    property bool isActive: workspace?.is_active || false
    property bool isFocused: workspace?.is_focused || false
    property string workspaceId: workspace?.id || workspace?.idx || "?"
    
    // Signals
    signal clicked()
    
    // Dimensions
    width: 40
    height: 28
    
    // Material 3 styling
    elevation: isActive ? Material.elevation.level2 : Material.elevation.level1
    
    // Dynamic colors based on state
    color: {
        if (isActive) return Material.colors.primaryContainer
        if (hovered) return Material.colors.surfaceContainerHigh
        return Material.colors.surfaceContainer
    }
    
    // Interactive states
    interactive: true
    hovered: workspaceArea.containsMouse
    pressed: workspaceArea.pressed
    focused: workspaceArea.activeFocus
    
    // Border for focused state
    border.width: isFocused ? 2 : 0
    border.color: Material.colors.primary
    
    // Smooth transitions
    Behavior on color {
        ColorAnimation {
            duration: Material.animation.durationShort4
            easing.type: Easing.OutCubic
        }
    }
    
    Behavior on elevation {
        NumberAnimation {
            duration: Material.animation.durationShort3
            easing.type: Easing.OutCubic
        }
    }
    
    Behavior on border.width {
        NumberAnimation {
            duration: Material.animation.durationShort2
            easing.type: Easing.OutCubic
        }
    }
    
    // Workspace label
    MaterialText {
        anchors.centerIn: parent
        text: root.workspaceId
        variant: Material.typography.labelMedium
        
        color: {
            if (root.isActive) return Material.colors.primaryContainerText
            if (root.hovered) return Material.colors.surfaceText
            return Material.colors.surfaceVariantText
        }
        
        Behavior on color {
            ColorAnimation {
                duration: Material.animation.durationShort4
                easing.type: Easing.OutCubic
            }
        }
    }
    
    // Click area
    MouseArea {
        id: workspaceArea
        anchors.fill: parent
        hoverEnabled: true
        
        // Accessibility
        Accessible.role: Accessible.Button
        Accessible.name: `Workspace ${root.workspaceId}`
        Accessible.description: root.isActive ? "Current workspace" : "Switch to workspace"
        
        onClicked: {
            console.log(`Lumin: Workspace ${root.workspaceId} clicked`)
            root.clicked()
        }
    }
    
    // Ripple effect for Material 3 feedback
    Rectangle {
        id: ripple
        anchors.centerIn: parent
        width: 0
        height: 0
        radius: width / 2
        color: Material.colors.primary
        opacity: 0
        
        // Ripple animation
        ParallelAnimation {
            id: rippleAnimation
            
            NumberAnimation {
                target: ripple
                property: "width"
                from: 0
                to: root.width * 1.5
                duration: Material.animation.durationMedium2
                easing.type: Easing.OutCubic
            }
            
            NumberAnimation {
                target: ripple
                property: "height"
                from: 0
                to: root.height * 1.5
                duration: Material.animation.durationMedium2
                easing.type: Easing.OutCubic
            }
            
            SequentialAnimation {
                NumberAnimation {
                    target: ripple
                    property: "opacity"
                    from: 0
                    to: 0.12
                    duration: Material.animation.durationShort4
                    easing.type: Easing.OutCubic
                }
                
                NumberAnimation {
                    target: ripple
                    property: "opacity"
                    from: 0.12
                    to: 0
                    duration: Material.animation.durationMedium2 - Material.animation.durationShort4
                    easing.type: Easing.OutCubic
                }
            }
        }
        
        // Trigger ripple on click
        Connections {
            target: workspaceArea
            function onPressed() {
                rippleAnimation.start()
            }
        }
    }
}