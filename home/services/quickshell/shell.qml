//@ pragma UseQApplication

import QtQuick
import QtQuick.Controls.Material
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

ShellRoot {
    id: shellRoot

    // Configure Material 3 globally
    Material.theme: Material.Dark
    Material.accent: Material.Blue

    // Load NiriIPC singleton directly
    property var niriIPCInstance: niriIPCLoader.item
    property alias niriIPC: niriService

    Loader {
        id: niriIPCLoader
        source: "./services/NiriIPC.qml"
        
        onLoaded: {
            console.log("Lumin: NiriIPC service loaded successfully")
            console.log(`Lumin: NiriIPC item: ${item}`)
        }
        
        onStatusChanged: {
            console.log(`Lumin: NiriIPC loader status: ${status}`)
            if (status === Loader.Error) {
                console.error("Lumin: Failed to load NiriIPC service")
            }
        }
    }
    
    Item {
        id: niriService
        // Use the proper NiriIPC singleton service
        property var workspaces: niriIPCLoader.item ? niriIPCLoader.item.workspaces : []
        property var windows: niriIPCLoader.item ? niriIPCLoader.item.windows : []
        property bool connected: niriIPCLoader.item ? niriIPCLoader.item.connected : false
        property var currentTime: new Date()
        
        Component.onCompleted: {
            console.log("Lumin: Starting with proper NiriIPC service...")
            console.log(`Lumin: Available screens: ${Quickshell.screens.length}`)
            console.log(`Lumin: NiriIPC loader item: ${niriIPCLoader.item}`)
            console.log(`Lumin: NiriIPC loader status: ${niriIPCLoader.status}`)
            
            for (let i = 0; i < Quickshell.screens.length; i++) {
                const screen = Quickshell.screens[i]
                console.log(`Lumin: Screen ${i}: ${screen.name} ${screen.width}x${screen.height}`)
            }
            
            // Connect to NiriIPC signals for real-time updates when loaded
            if (niriIPCLoader.item) {
                console.log("Lumin: Connecting to NiriIPC signals...")
                niriIPCLoader.item.workspacesUpdated.connect(function(workspaces) {
                    console.log(`Lumin: UI received workspace update - ${workspaces.length} workspaces`)
                })
                
                niriIPCLoader.item.windowsUpdated.connect(function(windows) {
                    console.log(`Lumin: UI received window update - ${windows.length} windows`)
                })
                
                niriIPCLoader.item.connectionStateUpdated.connect(function(connected) {
                    console.log(`Lumin: UI received connection state update - ${connected}`)
                })
            } else {
                console.warn("Lumin: NiriIPC service not available yet")
                // Try to connect when it loads
                connectTimer.start()
            }
        }
        
        Timer {
            id: connectTimer
            interval: 500
            repeat: false
            onTriggered: {
                console.log("Lumin: Retrying NiriIPC connection...")
                if (niriIPCLoader.item) {
                    console.log("Lumin: Connecting to NiriIPC signals (delayed)...")
                    niriIPCLoader.item.workspacesUpdated.connect(function(workspaces) {
                        console.log(`Lumin: UI received workspace update - ${workspaces.length} workspaces`)
                    })
                    
                    niriIPCLoader.item.windowsUpdated.connect(function(windows) {
                        console.log(`Lumin: UI received window update - ${windows.length} windows`)
                    })
                    
                    niriIPCLoader.item.connectionStateUpdated.connect(function(connected) {
                        console.log(`Lumin: UI received connection state update - ${connected}`)
                    })
                } else {
                    console.warn("Lumin: NiriIPC still not available, giving up")
                }
            }
        }
        
        Timer {
            id: clockTimer
            interval: 1000  // Update clock every second
            repeat: true
            running: true
            onTriggered: {
                niriService.currentTime = new Date()
            }
        }
    }

    // Simple bar window
    PanelWindow {
        id: panelWindow
        
        screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
        
        // Layer shell anchoring for proper positioning
        WlrLayershell.anchors.top: true
        WlrLayershell.anchors.left: true
        WlrLayershell.anchors.right: true
        WlrLayershell.exclusiveZone: 44
        
        // Full width at top of screen
        implicitWidth: screen.width
        implicitHeight: 44
        
        color: "transparent"
        
        // Beautiful Material 3 bar using components
        MainBar {
            anchors.fill: parent
            niriIPC: niriService
        }

        // Component definition
        component MainBar: Rectangle {
            property var niriIPC: null
            
            anchors.fill: parent
            color: "#111318" // Material.colors.surface
            
            Row {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 24
                
                // Left section - Workspaces
                Item {
                    width: childrenRect.width
                    height: parent.height
                    
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8
                        
                        Repeater {
                            model: niriIPC?.workspaces?.slice().sort((a, b) => a.idx - b.idx) || []
                            
                            WorkspaceIndicator {
                                workspace: modelData
                                onClicked: {
                                    if (niriIPC && modelData) {
                                        console.log(`Lumin: Switching to workspace ${modelData.id}`)
                                        niriIPC.switchToWorkspace(modelData.id)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Center section - Clock (flexible)
                Item {
                    width: parent.width - (parent.children[0].width + parent.children[2].width + 48) // Dynamic width
                    height: parent.height
                    
                    Text {
                        anchors.centerIn: parent
                        text: Qt.formatDateTime(niriIPC?.currentTime || new Date(), "hh:mm")
                        color: "#e3e2e6" // surfaceText
                        font.pixelSize: 16
                        font.weight: Font.Medium
                        font.family: "Inter"
                    }
                }
                
                // Right section - System info  
                Item {
                    width: childrenRect.width
                    height: parent.height
                    
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12
                        
                        Text {
                            text: `${niriIPC?.windows?.length || 0} windows`
                            color: "#c2c7ce" // surfaceVariantText
                            font.pixelSize: 11
                            font.family: "Inter"
                        }
                        
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            anchors.verticalCenter: parent.verticalCenter
                            color: niriIPC?.connected ? "#4ade80" : "#f87171" // success : error
                            
                            // Subtle glow effect when connected
                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width + 4
                                height: parent.height + 4
                                radius: width / 2
                                color: parent.color
                                opacity: niriIPC?.connected ? 0.3 : 0
                                visible: opacity > 0
                                
                                Behavior on opacity {
                                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                                }
                            }
                            
                            Behavior on color {
                                ColorAnimation { duration: 300; easing.type: Easing.OutCubic }
                            }
                        }
                    }
                }
            }
        }
        
        // Workspace Indicator Component  
        component WorkspaceIndicator: Rectangle {
            property var workspace: null
            property bool isActive: workspace?.is_active || false
            property bool isFocused: workspace?.is_focused || false
            property string workspaceId: workspace?.id || workspace?.idx || "?"
            
            signal clicked()
            
            width: 40
            height: 28
            radius: 12
            
            // Beautiful Material 3 colors
            color: {
                if (isActive) return "#004a9c" // primaryContainer
                if (mouseArea.containsMouse) return "#292d32" // surfaceContainerHigh  
                return "#1e2328" // surfaceContainer
            }
            
            // Focus border
            border.width: isFocused ? 2 : 0
            border.color: "#a6c8ff" // primary
            
            // Drop shadow effect for active workspaces
            Rectangle {
                anchors.centerIn: parent
                width: parent.width + 2
                height: parent.height + 2
                radius: parent.radius + 1
                color: "#000000"
                opacity: isActive ? 0.2 : 0
                z: -1
                visible: opacity > 0
                
                Behavior on opacity {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }
            }
            
            // Smooth transitions
            Behavior on color {
                ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
            
            Behavior on border.width {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }
            
            // Workspace label
            Text {
                anchors.centerIn: parent
                text: parent.workspaceId
                color: {
                    if (parent.isActive) return "#d5e3ff" // primaryContainerText
                    if (mouseArea.containsMouse) return "#e3e2e6" // surfaceText
                    return "#c2c7ce" // surfaceVariantText
                }
                font.pixelSize: 12
                font.weight: Font.Medium
                font.family: "Inter"
                
                Behavior on color {
                    ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
            }
            
            // Interactive area
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: parent.clicked()
                
                // Ripple effect
                Rectangle {
                    id: ripple
                    anchors.centerIn: parent
                    width: 0
                    height: 0
                    radius: width / 2
                    color: "#a6c8ff" // primary
                    opacity: 0
                    
                    NumberAnimation {
                        id: rippleAnimation
                        target: ripple
                        properties: "width,height"
                        from: 0
                        to: parent.width * 1.5
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                    
                    NumberAnimation {
                        id: rippleFade
                        target: ripple
                        property: "opacity"
                        from: 0.3
                        to: 0
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                    
                    onParentChanged: {
                        if (parent && mouseArea.pressed) {
                            rippleAnimation.start()
                            rippleFade.start()
                        }
                    }
                }
            }
        }
    }
}