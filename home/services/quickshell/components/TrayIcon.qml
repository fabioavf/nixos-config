import QtQuick
import Quickshell

Rectangle {
    id: trayIcon
    property SystemTrayItem trayItem: null
    
    width: Config.Device.config.iconSize + Config.Material.spacing.xs
    height: Config.Device.config.iconSize + Config.Material.spacing.xs
    radius: Config.Material.rounding.small
    
    color: {
        if (mouseArea.pressed) return Config.Material.colors.pressed
        if (mouseArea.containsMouse) return Config.Material.colors.hover
        return "transparent"
    }
    
    Image {
        id: trayIconImage
        anchors.centerIn: parent
        width: Config.Device.config.iconSize
        height: Config.Device.config.iconSize
        
        source: {
            if (!trayItem) return ""
            let icon = trayItem.icon || ""
            if (icon.includes("?path=")) {
                const parts = icon.split("?path=")
                const name = parts[0]
                const path = parts[1]
                icon = `file://${path}/${name.slice(name.lastIndexOf("/") + 1)}`
            }
            return icon
        }
        
        fillMode: Image.PreserveAspectFit
        smooth: true
        asynchronous: true
        
        opacity: mouseArea.pressed ? 0.8 : 1.0
        scale: mouseArea.pressed ? 0.95 : 1.0
        
        Behavior on opacity {
            NumberAnimation { 
                duration: Config.Material.animation.durationShort3
                easing.type: Easing.OutCubic
            }
        }
        
        Behavior on scale {
            NumberAnimation { 
                duration: Config.Material.animation.durationShort3
                easing.type: Easing.OutCubic
            }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        
        onClicked: function(mouse) {
            if (!trayItem) return
            
            if (mouse.button === Qt.LeftButton) {
                trayItem.activate()
            } else if (mouse.button === Qt.RightButton) {
                if (trayItem.hasMenu) {
                    contextMenu.open()
                }
            }
        }
    }
    
    QsMenuAnchor {
        id: contextMenu
        menu: trayItem?.menu
        anchor.window: this.QsWindow.window
        anchor.rect {
            x: parent.mapToItem(null, 0, 0).x + parent.width / 2
            y: parent.mapToItem(null, 0, 0).y + parent.height + Config.Material.spacing.xs
            width: 0
            height: 0
        }
    }
    
    Behavior on color {
        ColorAnimation { 
            duration: Config.Material.animation.durationShort3
            easing.type: Easing.OutCubic
        }
    }
}