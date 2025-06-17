import QtQuick
import QtQuick.Layouts
import "../../config"

// Left section containing workspace indicators
Item {
    id: root
    
    // Properties
    property var niriIPC: null
    
    // Auto-size based on content
    implicitWidth: workspaceRow.implicitWidth
    
    Row {
        id: workspaceRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: Material.spacing.sm
        
        // Workspace indicators
        Repeater {
            model: root.niriIPC?.workspaces?.slice().sort((a, b) => a.idx - b.idx) || []
            
            WorkspaceIndicator {
                workspace: modelData
                
                onClicked: {
                    if (root.niriIPC && modelData) {
                        console.log(`Lumin: Switching to workspace ${modelData.id}`)
                        root.niriIPC.switchToWorkspace(modelData.id)
                    }
                }
            }
        }
    }
}