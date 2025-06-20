//@ pragma UseQApplication

import QtQuick
import QtQuick.Controls.Material
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "./config" as Config
import "./services" as Services
import "./components"

ShellRoot {
    id: shellRoot
    
    // Global audio popup state
    property bool audioPopupVisible: false

    // Configure Material 3 globally
    Material.theme: Material.Dark
    Material.accent: Material.Blue

    // Create AudioService instance directly
    Services.AudioService {
        id: audioService
        
        Component.onCompleted: {
            console.log("Lumin: AudioService loaded directly")
        }
    }
    
    // Create SystemStatsService instance
    Services.SystemStatsService {
        id: systemStatsInstance
        
        Component.onCompleted: {
            console.log("Lumin: SystemStatsService loaded")
        }
    }
    
    // Create KeyboardLayoutService instance
    Services.KeyboardLayoutService {
        id: keyboardLayoutService
        
        Component.onCompleted: {
            console.log("Lumin: KeyboardLayoutService loaded")
        }
    }

    property var niriIPCInstance: niriIPCLoader.item
    property alias niriIPC: niriService

    Loader {
        id: niriIPCLoader
        source: "./services/NiriIPC.qml"
        
        onLoaded: {
            console.log("Lumin: NiriIPC service loaded")
        }
        
        onStatusChanged: {
            if (status === Loader.Error) {
                console.error("Lumin: Failed to load NiriIPC service")
            }
        }
    }
    
    Item {
        id: systemService
        // Use the SystemStatsService
        property var cpuUsage: systemStatsInstance.cpuUsage
        property var memoryUsage: systemStatsInstance.memoryUsage
        property var memoryUsedGB: systemStatsInstance.memoryUsedGB
        property var memoryTotalGB: systemStatsInstance.memoryTotalGB
        property var diskUsage: systemStatsInstance.diskUsage
        property var diskFreeGB: systemStatsInstance.diskFreeGB
        property var diskTotalGB: systemStatsInstance.diskTotalGB
        property var networkDownload: systemStatsInstance.networkDownload
        property var networkUpload: systemStatsInstance.networkUpload
        property bool statsConnected: systemStatsInstance.connected
        
        // Helper functions
        function formatBytes(bytes) {
            return systemStatsInstance.formatBytes(bytes)
        }
        
        function formatSpeed(kbps) {
            return systemStatsInstance.formatSpeed(kbps)
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
            console.log("Lumin: Starting Niri integration...")
            
            // Connect to NiriIPC signals for real-time updates when loaded
            if (niriIPCLoader.item) {
                connectToNiriSignals()
            } else {
                // Try to connect when it loads
                connectTimer.start()
            }
        }
        
        function connectToNiriSignals() {
            if (niriIPCLoader.item) {
                niriIPCLoader.item.workspacesUpdated.connect(function(workspaces) {
                    // Workspace data updated
                })
                
                niriIPCLoader.item.windowsUpdated.connect(function(windows) {
                    // Window data updated  
                })
                
                niriIPCLoader.item.connectionStateUpdated.connect(function(connected) {
                    // Connection state updated
                })
            }
        }
        
        Timer {
            id: connectTimer
            interval: 500
            repeat: false
            onTriggered: {
                connectToNiriSignals()
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
        
        // Expose NiriIPC functions through the service wrapper
        function switchToWorkspace(workspaceId) {
            if (niriIPCLoader.item && niriIPCLoader.item.switchToWorkspace) {
                niriIPCLoader.item.switchToWorkspace(workspaceId)
            } else {
                console.warn("Lumin: NiriIPC not loaded or switchToWorkspace not available")
            }
        }
        
        function moveToWorkspace(workspaceId) {
            if (niriIPCLoader.item && niriIPCLoader.item.moveToWorkspace) {
                niriIPCLoader.item.moveToWorkspace(workspaceId)
            }
        }
        
        function closeWindow() {
            if (niriIPCLoader.item && niriIPCLoader.item.closeWindow) {
                niriIPCLoader.item.closeWindow()
            }
        }
        
        function focusWindow(windowId) {
            if (niriIPCLoader.item && niriIPCLoader.item.focusWindow) {
                niriIPCLoader.item.focusWindow(windowId)
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
        implicitHeight: Config.Device.config.barHeight
        
        color: "transparent"
        
        // Beautiful Material 3 bar using extracted components
        MainBar {
            anchors.fill: parent
            niriIPC: niriService
            systemService: systemService
            systemStatsInstance: systemStatsInstance
            audioService: audioService
            keyboardLayoutService: keyboardLayoutService
            
            // Connect audio popup signal
            onAudioPopupRequested: function(visible) {
                shellRoot.audioPopupVisible = visible
            }
        }
    }

    // Audio Control Popup Window using AudioPopup component
    AudioPopup {
        id: audioPopup
        audioService: audioService
        popupVisible: shellRoot.audioPopupVisible
        
        // Bind the popup visibility to the shell root state
        onPopupVisibleChanged: {
            shellRoot.audioPopupVisible = popupVisible
        }
    }
}