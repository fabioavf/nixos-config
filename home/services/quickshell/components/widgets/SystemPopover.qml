import QtQuick
import QtQuick.Controls.Material
import "../base"

// Beautiful Material 3 system information popover for MacBook
Rectangle {
    id: root
    
    property var systemStats: null
    property bool visible: false
    
    width: 320
    height: 240
    radius: 12
    color: "#1e2328" // surfaceContainer
    border.width: 1
    border.color: "#42474e" // outlineVariant
    
    // Material 3 elevation shadow
    Rectangle {
        anchors.centerIn: parent
        width: parent.width + 4
        height: parent.height + 4
        radius: parent.radius + 2
        color: "#000000"
        opacity: 0.2
        z: -1
    }
    
    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        
        // Header
        Text {
            text: "System Monitor"
            color: "#e3e2e6" // surfaceText
            font.pixelSize: 16
            font.weight: Font.Medium
            font.family: "Inter"
        }
        
        // CPU Section
        DetailSection {
            title: "CPU Usage"
            value: `${(systemStats?.cpuUsage || 0).toFixed(1)}%`
            subtitle: `${systemStats?.cpuCores || 1} cores`
            chartData: systemStats?.cpuHistory || []
            maxValue: 100
            color: getColorForUsage(systemStats?.cpuUsage || 0)
        }
        
        // Memory Section
        DetailSection {
            title: "Memory"
            value: `${(systemStats?.memoryUsage || 0).toFixed(1)}%`
            subtitle: systemStats ? 
                `${systemStats.formatBytes(systemStats.memoryUsed)} / ${systemStats.formatBytes(systemStats.memoryTotal)}` : 
                ""
            chartData: [] // Memory doesn't need history chart
            color: getColorForUsage(systemStats?.memoryUsage || 0)
        }
        
        // Network Section
        DetailSection {
            title: "Network"
            value: systemStats ? 
                `${systemStats.formatSpeed((systemStats.networkDownload || 0) + (systemStats.networkUpload || 0))}` : 
                "0 KB/s"
            subtitle: systemStats ? 
                `↓${systemStats.formatSpeed(systemStats.networkDownload)} ↑${systemStats.formatSpeed(systemStats.networkUpload)}` : 
                ""
            chartData: systemStats?.networkHistory?.map(h => h.download + h.upload) || []
            maxValue: 10240 // 10 MB/s
            color: "#60a5fa" // info blue
        }
        
        // Battery Section (if available)
        DetailSection {
            visible: systemStats?.batteryAvailable || false
            title: "Battery"
            value: `${systemStats?.batteryLevel || 0}%`
            subtitle: systemStats?.batteryTimeRemaining || ""
            chartData: []
            color: getBatteryColor(systemStats?.batteryLevel || 0, systemStats?.batteryCharging || false)
            
            // Battery icon
            Text {
                anchors.right: parent.right
                anchors.top: parent.top
                text: systemStats?.batteryCharging ? "🔌" : "🔋"
                font.pixelSize: 16
            }
        }
        
        // Temperature Section (if available)
        DetailSection {
            visible: systemStats?.temperatureAvailable || false
            title: "Temperature"
            value: `${(systemStats?.cpuTemperature || 0).toFixed(1)}°C`
            subtitle: getTempStatus(systemStats?.cpuTemperature || 0)
            chartData: []
            color: getTempColor(systemStats?.cpuTemperature || 0)
        }
    }
    
    // Detail section component
    component DetailSection: Rectangle {
        property string title: ""
        property string value: ""
        property string subtitle: ""
        property var chartData: []
        property real maxValue: 100
        property color color: "#a6c8ff"
        
        width: parent.width
        height: 40
        radius: 8
        color: "#111318" // surface
        border.width: 1
        border.color: "#2a2f36" // hover
        
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12
            
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                
                Text {
                    text: title
                    color: "#c2c7ce" // surfaceVariantText
                    font.pixelSize: 11
                    font.family: "Inter"
                }
                
                Text {
                    text: value
                    color: parent.parent.parent.color
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    font.family: "Inter"
                }
                
                Text {
                    text: subtitle
                    color: "#8c9199" // outline
                    font.pixelSize: 10
                    font.family: "Inter"
                    visible: subtitle.length > 0
                }
            }
            
            // Chart (if data available)
            MiniChart {
                visible: chartData.length > 1
                anchors.verticalCenter: parent.verticalCenter
                width: 60
                height: 24
                dataPoints: chartData
                maxValue: parent.maxValue
                primaryColor: parent.color
                showFill: true
                lineWidth: 1.5
            }
        }
    }
    
    // Smooth appearance animation
    opacity: visible ? 1 : 0
    scale: visible ? 1 : 0.9
    
    Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
    
    Behavior on scale {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
    
    // Helper functions
    function getColorForUsage(usage) {
        if (usage > 80) return "#f87171" // error red
        if (usage > 60) return "#fbbf24" // warning amber
        return "#4ade80" // success green
    }
    
    function getTempColor(temp) {
        if (temp > 80) return "#f87171" // Hot - red
        if (temp > 65) return "#fbbf24" // Warm - amber
        if (temp > 50) return "#60a5fa" // Normal - blue
        return "#4ade80" // Cool - green
    }
    
    function getBatteryColor(level, charging) {
        if (charging) return "#60a5fa" // Charging - blue
        if (level > 50) return "#4ade80" // Good - green
        if (level > 20) return "#fbbf24" // Warning - amber
        return "#f87171" // Critical - red
    }
    
    function getTempStatus(temp) {
        if (temp > 80) return "Hot"
        if (temp > 65) return "Warm"
        if (temp > 50) return "Normal"
        return "Cool"
    }
}
