import QtQuick
import QtQuick.Controls
import Lumin.Config

Button {
    id: root

    // Material 3 button properties
    property string variant: "filled" // "filled", "outlined", "text"
    property int elevation: variant === "filled" ? Material.elevation.level1 : Material.elevation.level0
    
    implicitWidth: Math.max(64, contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: 40

    // Padding following Material 3 spec
    leftPadding: Material.spacing.md
    rightPadding: Material.spacing.md
    topPadding: Material.spacing.sm + 2
    bottomPadding: Material.spacing.sm + 2

    background: MaterialCard {
        elevation: root.elevation
        backgroundColor: {
            switch (root.variant) {
                case "filled": return root.enabled ? Material.colors.primary : Material.colors.surfaceVariant
                case "outlined": return "transparent"
                case "text": return "transparent" 
                default: return Material.colors.primary
            }
        }
        borderColor: Material.colors.outline
        borderWidth: root.variant === "outlined" ? 1 : 0
        interactive: true
        hovered: root.hovered
        pressed: root.pressed
        focused: root.visualFocus
    }

    contentItem: MaterialText {
        text: root.text
        font: Material.typography.labelLarge
        color: {
            switch (root.variant) {
                case "filled": return root.enabled ? Material.colors.onPrimary : Material.colors.onSurfaceVariant
                case "outlined": return root.enabled ? Material.colors.primary : Material.colors.onSurfaceVariant
                case "text": return root.enabled ? Material.colors.primary : Material.colors.onSurfaceVariant
                default: return Material.colors.onPrimary
            }
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    // Material 3 state transitions
    states: [
        State {
            name: "pressed"
            when: root.pressed
            PropertyChanges {
                target: root.background
                elevation: Math.max(0, root.elevation - 1)
            }
        }
    ]

    transitions: Transition {
        NumberAnimation {
            properties: "elevation"
            duration: Material.animation.durationShort2
            easing.type: Easing.OutCubic
        }
    }
}