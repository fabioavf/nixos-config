import QtQuick
import QtQuick.Layouts
import "../base"
import "../../config"

// Main bar container - clean, borderless Material 3 design
Rectangle {
    id: root
    
    // Properties for external configuration
    property var niriIPC: null
    
    anchors.fill: parent
    color: Material.colors.surface
    // No borders for clean look!
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Material.spacing.md
        anchors.rightMargin: Material.spacing.md
        spacing: Material.spacing.lg
        
        // Left section - Workspaces
        LeftSection {
            id: leftSection
            Layout.fillHeight: true
            niriIPC: root.niriIPC
        }
        
        // Center section - Clock (takes up remaining space)
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            CenterSection {
                anchors.centerIn: parent
                niriIPC: root.niriIPC
            }
        }
        
        // Right section - System info
        RightSection {
            id: rightSection
            Layout.fillHeight: true
            niriIPC: root.niriIPC
        }
    }
}