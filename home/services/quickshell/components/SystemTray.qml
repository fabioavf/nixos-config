import QtQuick
import Quickshell

Rectangle {
    id: systemTray
    implicitWidth: Math.max(Config.Device.config.systemCardWidth || 60, layout.implicitWidth + Config.Material.spacing.md)
    height: Config.Device.config.workspaceSize
    radius: Config.Material.rounding.medium
    
    color: Config.Material.colors.surfaceContainer
    border.width: 0
    
    visible: layout.children.length > 0
    
    Rectangle {
        anchors.centerIn: parent
        width: parent.width + 2
        height: parent.height + 2
        radius: parent.radius + 1
        color: Config.Material.elevation.shadowColor
        opacity: Config.Material.elevation.shadowOpacity * 0.4
        z: -1
    }
    
    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.margins: Config.Material.spacing.xs
        contentWidth: layout.implicitWidth
        contentHeight: height
        
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalFlick
        
        maximumFlickVelocity: 2000
        flickDeceleration: 1000
        
        Row {
            id: layout
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            
            add: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        properties: "scale"
                        from: 0
                        to: 1
                        duration: Config.Material.animation.durationMedium2
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        properties: "opacity"
                        from: 0
                        to: 1
                        duration: Config.Material.animation.durationMedium2
                        easing.type: Easing.OutCubic
                    }
                }
            }
            
            Repeater {
                model: SystemTray.items
                
                delegate: TrayIcon {
                    required property SystemTrayItem modelData
                    trayItem: modelData
                }
            }
        }
    }
    
    Behavior on implicitWidth {
        NumberAnimation { 
            duration: Config.Material.animation.durationMedium1
            easing.type: Easing.OutCubic
        }
    }
}