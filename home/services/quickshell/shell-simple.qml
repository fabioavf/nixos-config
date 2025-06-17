//@ pragma UseQApplication

import QtQuick
import QtQuick.Controls.Material
import Quickshell
import Quickshell.Wayland

ShellRoot {
    id: shellRoot

    // Configure Material 3 globally
    Material.theme: Material.Dark
    Material.accent: Material.Blue

    // Per-monitor bar instances using Variants
    Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            id: panelWindow
            
            screen: modelData
            
            // Layer shell configuration for Niri
            WlrLayershell.layer: WlrLayershell.Layer.Top
            WlrLayershell.anchors: WlrLayershell.Anchor.Top | 
                                   WlrLayershell.Anchor.Left | 
                                   WlrLayershell.Anchor.Right
            WlrLayershell.exclusiveZone: 44
            
            // Bar dimensions
            implicitHeight: 44
            color: "transparent"
            
            // Simple test bar
            Rectangle {
                anchors.fill: parent
                anchors.margins: 16
                anchors.bottomMargin: 0
                
                color: "#111418"
                radius: 8
                border.color: "#8c9199"
                border.width: 1
                
                Text {
                    anchors.centerIn: parent
                    text: "Lumin Bar - WORKING!"
                    color: "#a6c8ff"
                    font.pixelSize: 16
                }
            }
        }
    }
}