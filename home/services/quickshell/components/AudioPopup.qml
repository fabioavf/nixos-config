import QtQuick
import Quickshell
import Quickshell.Wayland
import "../config" as Config

PanelWindow {
    id: audioPopupWindow
    property var audioService: null
    property bool popupVisible: false

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null

    WlrLayershell.anchors.top: true
    WlrLayershell.anchors.right: true
    WlrLayershell.exclusiveZone: 0
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.margins.top: Config.Device.config.barHeight
    WlrLayershell.margins.right: 20

    visible: popupVisible

    // Handle escape key to close popup
    Keys.onEscapePressed: {
        console.log("Lumin: Escape pressed - closing popup");
        popupVisible = false;
    }

    implicitWidth: 300
    implicitHeight: 220

    color: "transparent"

    // Close popup when clicking outside
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        hoverEnabled: true
        propagateComposedEvents: false

        onClicked: function (mouse) {
            console.log("Lumin: Clicked outside popup - closing");
            popupVisible = false;
            mouse.accepted = true;
        }

        onPressed: function (mouse) {
            console.log("Lumin: Pressed outside popup - closing");
            popupVisible = false;
            mouse.accepted = true;
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: Config.Material.spacing.sm

        radius: Config.Material.rounding.large
        color: Config.Material.colors.surfaceContainerHigh
        border.width: 1
        border.color: Config.Material.colors.outline

        // Prevent clicks from propagating to close the popup
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: function (mouse) {
                // Do nothing - prevent propagation
                mouse.accepted = true;
            }
        }

        // Drop shadow
        Rectangle {
            anchors.centerIn: parent
            width: parent.width + 4
            height: parent.height + 4
            radius: parent.radius + 2
            color: Config.Material.elevation.shadowColor
            opacity: Config.Material.elevation.shadowOpacity * 0.8
            z: -1
        }

        Column {
            anchors.fill: parent
            anchors.margins: Config.Material.spacing.lg
            spacing: Config.Material.spacing.md

            // Header
            Row {
                width: parent.width
                spacing: Config.Material.spacing.md

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰕾"
                    color: Config.Material.colors.primary
                    font.pixelSize: 24
                    font.family: Config.Material.typography.monoFamily
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Audio Controls"
                    color: Config.Material.colors.surfaceText
                    font.pixelSize: Config.Material.typography.titleMedium.size
                    font.weight: Config.Material.typography.titleMedium.weight
                    font.family: Config.Material.typography.fontFamily
                }
            }

            // Volume Slider
            Row {
                width: parent.width
                spacing: Config.Material.spacing.md

                Text {
                    text: "󰕿"
                    color: Config.Material.colors.surfaceText
                    font.pixelSize: 16
                    font.family: Config.Material.typography.monoFamily
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: parent.width - 60
                    height: 6
                    radius: 3
                    color: Config.Material.colors.outline
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        width: parent.width * (audioService?.volume || 0)
                        height: parent.height
                        radius: parent.radius
                        color: Config.Material.colors.primary

                        Behavior on width {
                            NumberAnimation {
                                duration: Config.Material.animation.durationShort3
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: function (mouse) {
                            if (audioService) {
                                const newVolume = mouse.x / width;
                                audioService.setVolume(Math.max(0, Math.min(1, newVolume)));
                            }
                        }
                    }
                }

                Text {
                    text: "󰕾"
                    color: Config.Material.colors.surfaceText
                    font.pixelSize: 16
                    font.family: Config.Material.typography.monoFamily
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Device Selection
            Row {
                width: parent.width
                spacing: Config.Material.spacing.sm

                Text {
                    text: "Device:"
                    color: Config.Material.colors.surfaceVariantText
                    font.pixelSize: Config.Material.typography.bodySmall.size
                    font.family: Config.Material.typography.fontFamily
                }

                Text {
                    text: {
                        const device = audioService?.currentDevice || "Unknown";
                        console.log("Lumin: Current device in popup:", device);
                        return device;
                    }
                    color: Config.Material.colors.surfaceText
                    font.pixelSize: Config.Material.typography.bodySmall.size
                    font.family: Config.Material.typography.fontFamily
                    font.weight: Font.Medium
                }
            }

            // Mute Button
            Rectangle {
                width: parent.width
                height: 40
                radius: Config.Material.rounding.medium
                color: audioService?.muted ? Config.Material.colors.errorContainer : Config.Material.colors.primaryContainer

                Text {
                    anchors.centerIn: parent
                    text: audioService?.muted ? "󰸈 Unmute" : "󰕾 Mute"
                    color: audioService?.muted ? Config.Material.colors.errorContainerText : Config.Material.colors.primaryContainerText
                    font.pixelSize: Config.Material.typography.labelLarge.size
                    font.family: Config.Material.typography.fontFamily
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (audioService) {
                            audioService.toggleMute();
                        }
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
