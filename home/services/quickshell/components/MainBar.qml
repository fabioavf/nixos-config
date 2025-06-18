import QtQuick
import Quickshell
import "../config" as Config
import "."

Rectangle {
    id: mainBar
    property var niriIPC: null
    property var systemService: null
    property var systemStatsInstance: null
    property var audioService: null
    
    // Signal for audio popup control
    signal audioPopupRequested(bool visible)
    
    anchors.fill: parent
    color: Config.Material.colors.surface
    
    Row {
        id: leftSection
        anchors.left: parent.left
        anchors.leftMargin: Config.Device.config.barMargin
        anchors.verticalCenter: parent.verticalCenter
        spacing: Config.Material.spacing.sm
        
        Repeater {
            model: niriIPC?.workspaces?.slice().sort((a, b) => a.idx - b.idx) || []
            
            WorkspaceIndicator {
                workspace: modelData
                workspaceWindows: {
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
    
    Text {
        anchors.centerIn: parent
        text: Qt.formatDateTime(niriIPC?.currentTime || new Date(), "hh:mm")
        color: Config.Material.colors.surfaceText
        font.pixelSize: Config.Material.typography.titleMedium.size
        font.weight: Config.Material.typography.titleMedium.weight
        font.family: Config.Material.typography.fontFamily
    }
    
    Row {
        id: systemMonitor
        anchors.right: parent.right
        anchors.rightMargin: Config.Device.config.barMargin
        anchors.verticalCenter: parent.verticalCenter
        spacing: Config.Material.spacing.sm
        
        function getColorForUsage(usage) {
            if (usage > 80) return Config.Material.colors.error
            if (usage > 60) return Config.Material.colors.warning
            return Config.Material.colors.success
        }
        
        function getColorForDiskUsage(usage) {
            if (usage > 90) return Config.Material.colors.error
            if (usage > 75) return Config.Material.colors.warning
            return Config.Material.colors.success
        }
        
        function getNetworkColor() {
            return Config.Material.colors.info
        }
        
        SystemMetric {
            label: "󰻠"
            value: systemService?.cpuUsage || 0
            maxValue: 100
            unit: "%"
            metricColor: systemStatsInstance.hasErrors ? Config.Material.colors.error : parent.getColorForUsage(value)
            isActive: value > 70
            hasError: systemStatsInstance.hasErrors
        }
        
        SystemMetric {
            label: "󰍛"
            value: systemService?.memoryUsedGB || 0
            maxValue: systemService?.memoryTotalGB || 16
            unit: "GB"
            metricColor: systemStatsInstance.hasErrors ? Config.Material.colors.error : parent.getColorForUsage((value / maxValue) * 100)
            isActive: (value / maxValue) > 0.8
            hasError: systemStatsInstance.hasErrors
        }
        
        SystemMetric {
            label: "󰋊"
            value: systemService?.diskFreeGB || 0
            maxValue: systemService?.diskTotalGB || 100
            unit: "GB"
            metricColor: systemStatsInstance.hasErrors ? Config.Material.colors.error : parent.getColorForDiskUsage(systemService?.diskUsage || 0)
            isActive: (systemService?.diskUsage || 0) > 80
            isDiskIndicator: true
            hasError: systemStatsInstance.hasErrors
        }
        
        SystemMetric {
            label: "󰛳"
            value: (systemService?.networkDownload || 0) + (systemService?.networkUpload || 0)
            maxValue: 10240
            unit: "KB/s"
            metricColor: systemStatsInstance.hasErrors ? Config.Material.colors.error : parent.getNetworkColor()
            isActive: value > 1024
            hasError: systemStatsInstance.hasErrors
        }
        
        AudioControlWidget {
            audioSvc: audioService
            onPopupToggled: function(visible) {
                mainBar.audioPopupRequested(visible)
            }
        }
        
        SystemTray {
            id: systemTray
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}