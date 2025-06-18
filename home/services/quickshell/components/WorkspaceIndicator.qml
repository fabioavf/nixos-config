import QtQuick
import Quickshell
import "../config" as Config

Rectangle {
    id: workspaceIndicator
    property var workspace: null
    property bool isActive: workspace?.is_active || false
    property bool isFocused: workspace?.is_focused || false
    property var workspaceWindows: []
    
    signal clicked()
    
    readonly property int windowCount: workspaceWindows.length
    readonly property int maxVisibleDots: 5
    readonly property int visibleDots: Math.min(windowCount, maxVisibleDots)
    readonly property bool hasOverflow: windowCount > maxVisibleDots
    
    width: windowCount === 0 ? Config.Device.config.workspaceSize : Math.max(Config.Device.config.workspaceSize, Math.min(44, 20 + (visibleDots * 6)))
    height: Config.Device.config.workspaceSize
    radius: Config.Material.rounding.medium
    
    color: {
        if (isActive) return Config.Material.colors.primaryContainer
        if (mouseArea.containsMouse) return Config.Material.colors.surfaceContainerHigh  
        return Config.Material.colors.surfaceContainer
    }
    
    border.width: isFocused ? 2 : 0
    border.color: Config.Material.colors.primary
    
    Rectangle {
        anchors.centerIn: parent
        width: parent.width + 2
        height: parent.height + 2
        radius: parent.radius + 1
        color: Config.Material.elevation.shadowColor
        opacity: isActive ? (Config.Material.elevation.shadowOpacity * 0.7) : 0
        z: -1
        visible: opacity > 0
        
        Behavior on opacity {
            NumberAnimation { 
                duration: Config.Material.animation.durationShort3
                easing.type: Easing.OutCubic 
            }
        }
    }
    
    Behavior on color {
        ColorAnimation { 
            duration: Config.Material.animation.durationShort4
            easing.type: Easing.OutCubic 
        }
    }
    
    Behavior on width {
        NumberAnimation { 
            duration: Config.Material.animation.durationMedium1
            easing.type: Easing.OutCubic 
        }
    }
    
    Behavior on border.width {
        NumberAnimation { 
            duration: Config.Material.animation.durationShort3
            easing.type: Easing.OutCubic 
        }
    }
    
    Item {
        anchors.centerIn: parent
        width: parent.width - 8
        height: parent.height
        
        Rectangle {
            anchors.centerIn: parent
            width: 5
            height: 5
            radius: 2.5
            color: "transparent"
            border.width: 1
            border.color: isActive ? Config.Material.colors.outline : Config.Material.colors.outlineVariant
            visible: windowCount === 0
            opacity: isActive ? 0.9 : 0.6
            
            Behavior on border.color {
                ColorAnimation { 
                    duration: Config.Material.animation.durationShort3
                    easing.type: Easing.OutCubic 
                }
            }
            
            Behavior on opacity {
                NumberAnimation { 
                    duration: Config.Material.animation.durationShort3
                    easing.type: Easing.OutCubic 
                }
            }
        }
        
        Row {
            anchors.centerIn: parent
            spacing: 2
            visible: windowCount > 0
            
            Repeater {
                model: visibleDots + (hasOverflow ? 1 : 0)
                
                Rectangle {
                    width: 4
                    height: 4
                    radius: 2
                    
                    readonly property bool isOverflowDot: hasOverflow && index === visibleDots
                    
                    color: {
                        if (isOverflowDot) return Config.Material.colors.outline
                        if (isActive) return Config.Material.colors.primaryContainerText
                        return Config.Material.colors.outline
                    }
                    
                    opacity: isOverflowDot ? 0.3 : 1.0
                    
                    Behavior on color {
                        ColorAnimation { 
                            duration: Config.Material.animation.durationShort4
                            easing.type: Easing.OutCubic 
                        }
                    }
                    
                    Behavior on opacity {
                        NumberAnimation { 
                            duration: Config.Material.animation.durationShort4
                            easing.type: Easing.OutCubic 
                        }
                    }
                    
                    SequentialAnimation on scale {
                        running: isActive && !isOverflowDot && windowCount > 0
                        loops: Animation.Infinite
                        NumberAnimation { 
                            to: 1.05
                            duration: Config.Material.animation.durationLong4 * 2
                            easing.type: Easing.InOutSine 
                        }
                        NumberAnimation { 
                            to: 1.0
                            duration: Config.Material.animation.durationLong4 * 2
                            easing.type: Easing.InOutSine 
                        }
                    }
                }
            }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: parent.clicked()
    }
}