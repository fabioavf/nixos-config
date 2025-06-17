//@ pragma UseQApplication

import QtQuick
import QtQuick.Controls.Material
import Quickshell
import Quickshell.Wayland
import Lumin.Config
import Lumin.Services

ShellRoot {
    id: shellRoot

    // Configure Material 3 globally
    Material.theme: Material.Dark
    Material.accent: Material.Blue

    // Debug output for initial setup
    Component.onCompleted: {
        console.log("=== Lumin Bar Starting ===")
        console.log("Device Type:", Device.deviceType)
        console.log("Is MacBook:", Device.isMacBook)
        console.log("Is Desktop:", Device.isDesktop)
        console.log("Bar Height:", Device.config.barHeight)
        console.log("System Info Mode:", Device.config.systemInfoDisplayMode)
        console.log("Screen Count:", Quickshell.screens.length)
        
        if (Quickshell.screens.length > 0) {
            const screen = Quickshell.screens[0]
            console.log("Primary Screen:", `${screen.width}x${screen.height} @ ${screen.devicePixelRatio}x`)
            console.log("Logical Size:", `${screen.width/screen.devicePixelRatio}x${screen.height/screen.devicePixelRatio}`)
        }
        
        console.log("Niri IPC Debug:", JSON.stringify(NiriIPC.debugInfo, null, 2))
        console.log("========================")
    }

    // Per-monitor bar instances using Variants
    Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            id: panelWindow
            
            property ShellScreen screen: modelData
            screen: modelData
            
            // Layer shell configuration for Niri
            WlrLayershell.layer: WlrLayershell.LayerTop
            WlrLayershell.anchors: WlrLayershell.AnchorTop | 
                                   WlrLayershell.AnchorLeft | 
                                   WlrLayershell.AnchorRight
            WlrLayershell.exclusionMode: WlrLayershell.ExclusionMode.Exclusive
            WlrLayershell.namespace: "lumin-bar"
            
            // Bar dimensions
            implicitHeight: Device.config.barHeight
            color: "transparent"
            
            // Main bar content
            Rectangle {
                id: barBackground
                anchors.fill: parent
                anchors.margins: Device.config.barMargin
                anchors.bottomMargin: 0
                
                color: Material.colors.surface
                radius: Material.rounding.medium
                border.color: Material.colors.outline
                border.width: 1
                
                // Test content for Phase 1
                Row {
                    anchors.centerIn: parent
                    spacing: Material.spacing.lg
                    
                    MaterialText {
                        text: "Lumin Bar"
                        fontConfig: Material.typography.titleMedium
                        color: Material.colors.primary
                    }
                    
                    MaterialText {
                        text: "•"
                        color: Material.colors.outline
                    }
                    
                    MaterialText {
                        text: Device.deviceType.toUpperCase()
                        fontConfig: Material.typography.bodySmall
                        color: Material.colors.onSurfaceVariant
                    }
                    
                    MaterialText {
                        text: "•"
                        color: Material.colors.outline
                    }
                    
                    MaterialText {
                        text: NiriIPC.connected ? "Connected" : "Disconnected"
                        color: NiriIPC.connected ? Material.colors.success : Material.colors.error
                        fontConfig: Material.typography.bodySmall
                    }
                }
                
                // Debug info in bottom right
                MaterialText {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: Material.spacing.sm
                    
                    text: `${NiriIPC.workspaces.length}ws ${NiriIPC.windows.length}win`
                    fontConfig: Material.typography.labelSmall
                    color: Material.colors.onSurfaceVariant
                }
            }
        }
    }

    // Monitor NiriIPC connection status
    Connections {
        target: NiriIPC
        
        function onConnectionStateChanged(connected) {
            console.log(`Lumin: Niri IPC ${connected ? "connected" : "disconnected"}`)
        }
        
        function onWorkspacesChanged(workspaces) {
            console.log(`Lumin: Workspaces updated: ${workspaces.length} workspaces`)
        }
        
        function onWindowsChanged(windows) {
            console.log(`Lumin: Windows updated: ${windows.length} windows`)
        }
        
        function onFocusedWindowChanged(window) {
            const title = window?.title || "none"
            console.log(`Lumin: Focused window: ${title}`)
        }
    }
}