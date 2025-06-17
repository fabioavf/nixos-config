import QtQuick
import "../base"
import "../../config"

// Center section with elegant clock display
Item {
    id: root
    
    // Properties
    property var niriIPC: null
    
    // Auto-size based on content
    implicitWidth: clockText.implicitWidth
    implicitHeight: clockText.implicitHeight
    
    MaterialText {
        id: clockText
        anchors.centerIn: parent
        
        text: Qt.formatDateTime(root.niriIPC?.currentTime || new Date(), "hh:mm")
        variant: Material.typography.titleMedium
        color: Material.colors.surfaceText
        
        // Smooth text transitions
        Behavior on text {
            enabled: false // Disable to prevent animation on every second
        }
    }
}