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
            
            // Left section - Workspaces (absolute positioning)
            Row {
                id: leftSection
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                
                Repeater {
                    model: niriIPC?.workspaces?.slice().sort((a, b) => a.idx - b.idx) || []
                    
                    WorkspaceIndicator {
                        workspace: modelData
                        workspaceWindows: {
                            // Filter windows that belong to this workspace
                            if (!niriIPC?.windows || !modelData) return []
                            return niriIPC.windows.filter(window => 
                                window.workspace_id === modelData.id
                            )
                        }
                        
                        onClicked: {
                            if (niriIPC && modelData) {
                                console.log(`Lumin: Switching to workspace ${modelData.id}`)
                                niriIPC.switchToWorkspace(modelData.id)
                            }
                        }
                    }
                }
            }
            
            // Center section - Clock (absolutely centered, ignores side content)
            Text {
                anchors.centerIn: parent
                text: Qt.formatDateTime(niriIPC?.currentTime || new Date(), "hh:mm")
                color: "#e3e2e6" // surfaceText
                font.pixelSize: 16
                font.weight: Font.Medium
                font.family: "Inter"
            }
            
            // Right section - System info (absolute positioning)
            Row {
                id: rightSection
                anchors.right: parent.right
                anchors.rightMargin: 16
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
        
        // Clean Dot Matrix Workspace Indicator - Window Count Only
        component WorkspaceIndicator: Rectangle {
            property var workspace: null
            property bool isActive: workspace?.is_active || false
            property bool isFocused: workspace?.is_focused || false
            property var workspaceWindows: []
            
            signal clicked()
            
            // Dynamic sizing based on window count
            readonly property int windowCount: workspaceWindows.length
            readonly property int maxVisibleDots: 5
            readonly property int visibleDots: Math.min(windowCount, maxVisibleDots)
            readonly property bool hasOverflow: windowCount > maxVisibleDots
            
            width: windowCount === 0 ? 28 : Math.max(28, Math.min(44, 20 + (visibleDots * 6)))
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
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }
            }
            
            // Smooth transitions for container
            Behavior on color {
                ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
            
            Behavior on width {
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
            }
            
            Behavior on border.width {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }
            
            // Window dots container
            Item {
                anchors.centerIn: parent
                width: parent.width - 8
                height: parent.height
                
                // Empty state - hollow circle
                Rectangle {
                    anchors.centerIn: parent
                    width: 5
                    height: 5
                    radius: 2.5
                    color: "transparent"
                    border.width: 1
                    border.color: isActive ? "#8c9199" : "#42474e" // More visible when active
                    visible: windowCount === 0
                    opacity: isActive ? 0.9 : 0.6
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }
                }
                
                // Window dots
                Row {
                    anchors.centerIn: parent
                    spacing: 2
                    visible: windowCount > 0
                    
                    Repeater {
                        model: visibleDots + (hasOverflow ? 1 : 0)
                        
                        Rectangle {
                            width: 4
                            height: 4
                            radius: 2
                            
                            readonly property bool isOverflowDot: hasOverflow && index === visibleDots
                            
                            color: {
                                if (isOverflowDot) return "#8c9199" // More visible for unfocused
                                if (isActive) return "#d5e3ff" // primaryContainerText
                                return "#8c9199" // outline - more visible than surfaceVariantText
                            }
                            
                            // Gradient effect for overflow dot
                            opacity: isOverflowDot ? 0.3 : 1.0
                            
                            // Smooth transitions
                            Behavior on color {
                                ColorAnimation { 
                                    duration: 200; 
                                    easing.type: Easing.OutCubic 
                                }
                            }
                            
                            Behavior on opacity {
                                NumberAnimation { 
                                    duration: 200; 
                                    easing.type: Easing.OutCubic 
                                }
                            }
                            
                            // Gentle breathing animation for active workspace only
                            SequentialAnimation on scale {
                                running: isActive && !isOverflowDot && windowCount > 0
                                loops: Animation.Infinite
                                NumberAnimation { 
                                    to: 1.05; 
                                    duration: 1200; 
                                    easing.type: Easing.InOutSine 
                                }
                                NumberAnimation { 
                                    to: 1.0; 
                                    duration: 1200; 
                                    easing.type: Easing.InOutSine 
                                }
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
                onClicked: parent.clicked()
                
                // Hover elevation effect
                onEntered: {
                    elevationAnimation.to = 4
                    elevationAnimation.start()
                }
                onExited: {
                    elevationAnimation.to = isActive ? 2 : 1
                    elevationAnimation.start()
                }
                
                NumberAnimation {
                    id: elevationAnimation
                    target: parent.parent // target the shadow rectangle
                    property: "opacity"
                    duration: 150
                    easing.type: Easing.OutCubic
                }
                
                // Click ripple effect
                Rectangle {
                    id: ripple
                    anchors.centerIn: parent
                    width: 0
                    height: 0
                    radius: width / 2
                    color: "#a6c8ff" // primary
                    opacity: 0
                    
                    ParallelAnimation {
                        id: rippleAnimation
                        NumberAnimation {
                            target: ripple
                            properties: "width,height"
                            from: 0
                            to: mouseArea.width * 1.5
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                        SequentialAnimation {
                            NumberAnimation {
                                target: ripple
                                property: "opacity"
                                from: 0
                                to: 0.3
                                duration: 50
                            }
                            NumberAnimation {
                                target: ripple
                                property: "opacity"
                                from: 0.3
                                to: 0
                                duration: 150
                            }
                        }
                    }
                }
                
                onPressed: rippleAnimation.start()
            }
        }
    }
}