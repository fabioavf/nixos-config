import QtQuick
import QtQuick.Layouts
import "../base"
import "../../config"

// Right section with system information
Item {
    id: root
    
    // Properties
    property var niriIPC: null
    
    // Auto-size based on content
    implicitWidth: systemRow.implicitWidth
    
    Row {
        id: systemRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: Material.spacing.md
        
        // Window count
        MaterialText {
            text: `${root.niriIPC?.windows?.length || 0} windows`
            variant: Material.typography.bodySmall
            color: Material.colors.surfaceVariantText
        }
        
        // Connection status indicator
        Rectangle {
            width: 8
            height: 8
            radius: 4
            anchors.verticalCenter: parent.verticalCenter
            
            color: root.niriIPC?.connected ? Material.colors.success : Material.colors.error
            
            // Subtle glow effect when connected
            Rectangle {
                anchors.centerIn: parent
                width: parent.width + 4
                height: parent.height + 4
                radius: width / 2
                color: parent.color
                opacity: root.niriIPC?.connected ? 0.3 : 0
                visible: opacity > 0
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: Material.animation.durationMedium1
                        easing.type: Easing.OutCubic
                    }
                }
            }
            
            // Smooth color transitions
            Behavior on color {
                ColorAnimation {
                    duration: Material.animation.durationMedium1
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}