import QtQuick
import Quickshell
import "../config" as Config

Item {
    property var audioSvc: null
    property bool showingPopup: false
    
    width: compactWidget.width
    height: Config.Device.config.workspaceSize
    
    Rectangle {
        id: compactWidget
        width: Config.Device.config.systemCardWidth || 60
        height: Config.Device.config.workspaceSize
        radius: Config.Material.rounding.medium
        
        color: {
            if (showingPopup) return Config.Material.colors.primaryContainer
            if (mouseArea.containsMouse) return Config.Material.colors.surfaceContainerHigh
            return Config.Material.colors.surfaceContainer
        }
        
        border.width: audioSvc?.muted ? 2 : 0
        border.color: Config.Material.colors.error
        
        Behavior on color {
            ColorAnimation {
                duration: Config.Material.animation.durationShort4
                easing.type: Easing.OutCubic
            }
        }
        
        Behavior on border.width {
            NumberAnimation {
                duration: Config.Material.animation.durationShort3
                easing.type: Easing.OutCubic
            }
        }
    
    Rectangle {
        anchors.centerIn: parent
        width: parent.width * 0.8
        height: 2
        color: Config.Material.colors.error
        rotation: -15
        visible: audioSvc?.muted || false
        opacity: 0.9
        radius: 1
    }
    
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
        spacing: Config.Material.spacing.xs
        
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (!audioSvc) return "󰕿"
                if (audioSvc.muted) return "󰸈"
                
                switch (audioSvc.currentDeviceType) {
                    case "headphone": return "󰋋"
                    case "bluetooth": return "󰂯"
                    case "speaker":
                    default: return audioSvc.volume > 0.6 ? "󰕾" : audioSvc.volume > 0.3 ? "󰖀" : "󰕿"
                }
            }
            color: {
                if (!audioSvc) return Config.Material.colors.surfaceVariantText
                if (audioSvc.muted) return Config.Material.colors.error
                return Config.Material.colors.surfaceText
            }
            font.pixelSize: Config.Device.config.iconSize || 12
            font.family: Config.Material.typography.monoFamily
        }
        
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: audioSvc ? `${Math.round(audioSvc.volume * 100)}%` : "-%"
            color: {
                if (!audioSvc) return Config.Material.colors.surfaceVariantText
                if (audioSvc.muted) return Config.Material.colors.error
                return Config.Material.colors.surfaceText
            }
            font.pixelSize: Config.Material.typography.labelSmall.size
            font.family: Config.Material.typography.fontFamily
            font.weight: Config.Material.typography.labelSmall.weight
        }
        
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1
            
            Repeater {
                model: 3
                
                Rectangle {
                    width: 2
                    height: {
                        if (!audioSvc || audioSvc.muted) return 2
                        const level = audioSvc.audioLevel || 0
                        const barHeight = 2 + (level * (8 - 2)) * (index + 1) / 3
                        return Math.max(2, Math.min(8, barHeight))
                    }
                    radius: 1
                    color: {
                        if (!audioSvc || audioSvc.muted) return Config.Material.colors.outlineVariant
                        const level = audioSvc.audioLevel || 0
                        const threshold = (index + 1) / 3
                        if (level > threshold) {
                            return index === 2 ? Config.Material.colors.warning : Config.Material.colors.success
                        }
                        return Config.Material.colors.outlineVariant
                    }
                    
                    Behavior on height {
                        NumberAnimation {
                            duration: Config.Material.animation.durationShort2
                            easing.type: Easing.OutCubic
                        }
                    }
                    
                    Behavior on color {
                        ColorAnimation {
                            duration: Config.Material.animation.durationShort3
                            easing.type: Easing.OutCubic
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
        acceptedButtons: Qt.LeftButton | Qt.RightButton
    
    onClicked: function(mouse) {
        if (mouse.button === Qt.LeftButton) {
            showingPopup = !showingPopup
            // Find the shell root to set popup visibility
            let root = parent
            while (root && !root.hasOwnProperty('audioPopupVisible')) {
                root = root.parent
            }
            if (root) {
                root.audioPopupVisible = showingPopup
            }
        } else if (mouse.button === Qt.RightButton) {
            if (audioSvc) {
                audioSvc.toggleMute()
            }
        }
    }
    
    onWheel: function(wheel) {
        if (!audioSvc) return
        
        const delta = wheel.angleDelta.y / 120
        const volumeStep = 0.05
        const newVolume = Math.max(0, Math.min(1, audioSvc.volume + (delta * volumeStep)))
        
        audioSvc.setVolume(newVolume)
    }
    
    onEntered: {
        if (showingPopup) {
            hideTimer.restart()
        }
    }
    }
    }
    
    Timer {
        id: hideTimer
        interval: 3000
        repeat: false
        onTriggered: {
            showingPopup = false
            // Find the shell root to set popup visibility
            let root = parent
            while (root && !root.hasOwnProperty('audioPopupVisible')) {
                root = root.parent
            }
            if (root) {
                root.audioPopupVisible = false
            }
        }
    }
}