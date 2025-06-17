        shadowHorizontalOffset: 0
    }

    // State layer for interactive cards
    property bool interactive: false
    property bool hovered: false
    property bool pressed: false
    property bool focused: false

    Rectangle {
        id: stateLayer
        anchors.fill: parent
        radius: parent.radius
        visible: interactive && (hovered || pressed || focused)
        color: {
            if (pressed) return Material.colors.pressed
            if (focused) return Material.colors.focused  
            if (hovered) return Material.colors.hover
            return "transparent"
        }
        opacity: 0.08
    }

    // Accessibility
    Accessible.role: Accessible.Button
    Accessible.description: "Material card"
}