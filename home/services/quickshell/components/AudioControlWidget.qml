import QtQuick
import Quickshell

Item {
    id: audioControlWidget
    property var audioService: null
    property bool showingPopup: false
    
    width: compactWidget.width
    height: Config.Device.config.workspaceSize
    
    // Compact widget (always visible)
    Rectangle {
        id: compactWidget
        width: Config.Device.config.systemCardWidth || 60
        height: Config.Device.config.workspaceSize
        radius: Config.Material.rounding.medium
        
        // Material 3 background with popup state indication
        color: {
            if (showingPopup) return Config.Material.colors.primaryContainer
            if (mouseArea.containsMouse) return Config.Material.colors.surfaceContainerHigh
            return Config.Material.colors.surfaceContainer
        }
        
        // Mute state indication
        border.width: audioService?.muted ? 2 : 0
        border.color: Config.Material.colors.error
    
    // Strikethrough effect when muted
    Rectangle {
        anchors.centerIn: parent
        width: parent.width * 0.8
        height: 2
        color: Config.Material.colors.error
        rotation: -15
        visible: audioService?.muted || false
        opacity: 0.9
        radius: 1
    }
    
    // Subtle elevation shadow
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
        
        // Audio icon with device type indication
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (!audioService) return "󰕿"
                if (audioService.muted) return "󰸈"
                
                switch (audioService.currentDeviceType) {
                    case "headphone": return "󰋋"
                    case "bluetooth": return "󰂯"
                    case "speaker":
                    default: return audioService.volume > 0.6 ? "󰕾" : audioService.volume > 0.3 ? "󰖀" : "󰕿"
                }
            }
            color: {
                if (!audioService) return Config.Material.colors.surfaceVariantText
                if (audioService.muted) return Config.Material.colors.error
                if (popup && popup.showing) return Config.Material.colors.primaryContainerText
                return Config.Material.colors.surfaceText
            }
            font.pixelSize: Config.Device.config.iconSize || 12
            font.family: Config.Material.typography.monoFamily
        }
        
        // Volume percentage
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: audioService ? `${Math.round(audioService.volume * 100)}%` : "-%"
            color: {
                if (!audioService) return Config.Material.colors.surfaceVariantText
                if (audioService.muted) return Config.Material.colors.error
                if (popup && popup.showing) return Config.Material.colors.primaryContainerText
                return Config.Material.colors.surfaceText
            }
            font.pixelSize: Config.Material.typography.labelSmall.size
            font.family: Config.Material.typography.fontFamily
            font.weight: Config.Material.typography.labelSmall.weight
        }
        
        // Mini audio level indicators (3 small bars)
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1
            
            Repeater {
                model: 3
                
                Rectangle {
                    width: 2
                    height: {
                        if (!audioService || audioService.muted) return 2
                        const level = audioService.audioLevel || 0
                        const barHeight = 2 + (level * (8 - 2)) * (index + 1) / 3
                        return Math.max(2, Math.min(8, barHeight))
                    }
                    radius: 1
                    color: {
                        if (!audioService || audioService.muted) return Config.Material.colors.outlineVariant
                        const level = audioService.audioLevel || 0
                        const threshold = (index + 1) / 3
                        if (level > threshold) {
                            return index === 2 ? Config.Material.colors.warning : Config.Material.colors.success
                        }
                        return Config.Material.colors.outlineVariant
                    }
                    
                    // Smooth height animation
                    Behavior on height {
                        NumberAnimation {
                            duration: Config.Material.animation.durationShort2
                            easing.type: Easing.OutCubic
                        }
                    }
                    
                    // Smooth color animation
                    Behavior on color {
                        ColorAnimation {
                            duration: Config.Material.animation.durationShort3
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
        
        // Interactive area
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
        
        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                // Toggle popup
                showingPopup = !showingPopup
            } else if (mouse.button === Qt.RightButton) {
                // Quick mute toggle
                if (audioService) {
                    audioService.toggleMute()
                }
            }
        }
        
        // Scroll to adjust volume
        onWheel: function(wheel) {
            if (!audioService) return
            
            const delta = wheel.angleDelta.y / 120 // Standard scroll step
            const volumeStep = 0.05 // 5% per scroll step
            const newVolume = Math.max(0, Math.min(1, audioService.volume + (delta * volumeStep)))
            
            audioService.setVolume(newVolume)
        }
        
        // Keep popup open when hovering over widget
        onEntered: {
            if (showingPopup) {
                hideTimer.restart()
            }
        }
        }
        
        // Material 3 transitions
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
    }
    }
    
    // Auto-hide timer
    Timer {
        id: hideTimer
        interval: 3000
        repeat: false
        onTriggered: showingPopup = false
    }
    
    // Simple popup (positioned below widget)
    Rectangle {
        anchors.top: compactWidget.bottom
        anchors.topMargin: Config.Material.spacing.xs
        anchors.horizontalCenter: compactWidget.horizontalCenter
        
        width: 280
        height: 120
        radius: Config.Material.rounding.large
        
        visible: showingPopup
        color: Config.Material.colors.surfaceContainerHigh
        border.width: 1
        border.color: Config.Material.colors.outline
        
        Text {
            anchors.centerIn: parent
            text: "Audio controls popup\n(Simplified for now)"
            color: Config.Material.colors.surfaceText
            font.family: Config.Material.typography.fontFamily
            horizontalAlignment: Text.AlignHCenter
        }
        
        // Smooth show/hide animation
        opacity: showingPopup ? 1.0 : 0.0
        scale: showingPopup ? 1.0 : 0.95
        
        Behavior on opacity {
            NumberAnimation {
                duration: Config.Material.animation.durationMedium2
                easing.type: Easing.OutCubic
            }
        }
        
        Behavior on scale {
            NumberAnimation {
                duration: Config.Material.animation.durationMedium2
                easing.type: Easing.OutCubic
            }
        }
    }
}