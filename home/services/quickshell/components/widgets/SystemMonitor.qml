import QtQuick
import QtQuick.Controls.Material
import "../base"
import "."

// Beautiful Material 3 System Monitor widget for the status bar
Row {
    id: root
    
    property var systemStats: null
    property var niriIPC: null
    property var deviceConfig: null
    property bool showDetailed: false
    
    spacing: 8
    
    // CPU Indicator
    SystemMetric {
        id: cpuMetric
        label: "CPU"
        value: systemStats?.cpuUsage || 0
        maxValue: 100
        unit: "%"
        color: getColorForUsage(value)
        chartData: systemStats?.cpuHistory || []
        
        icon: "⚡" // CPU icon
        isActive: value > 70
    }
    
    // Memory Indicator  
    SystemMetric {
        id: memoryMetric
        label: "RAM"
        value: systemStats?.memoryUsage || 0
        maxValue: 100
        unit: "%"
        color: getColorForUsage(value)
        
        icon: "🧠" // Memory icon
        isActive: value > 80
        
        // Additional info for hover
        property string detailText: systemStats ? 
            `${systemStats.formatBytes(systemStats.memoryUsed)} / ${systemStats.formatBytes(systemStats.memoryTotal)}` : 
            ""
    }
    
    // Network Indicator
    SystemMetric {
        id: networkMetric
        label: "NET"
        value: (systemStats?.networkDownload || 0) + (systemStats?.networkUpload || 0)
        maxValue: 10240 // 10 MB/s max for scaling
        unit: "KB/s"
        color: "#60a5fa" // Info blue for network
        chartData: systemStats?.networkHistory?.map(h => h.download + h.upload) || []
        
        icon: "🌐" // Network icon
        isActive: value > 1024 // Active when > 1MB/s
        
        property string detailText: systemStats ? 
            `↓${systemStats.formatSpeed(systemStats.networkDownload)} ↑${systemStats.formatSpeed(systemStats.networkUpload)}` : 
            ""
    }
    
    // Temperature Indicator (if available)
    SystemMetric {
        id: tempMetric
        visible: systemStats?.temperatureAvailable || false
        label: "TEMP"
        value: systemStats?.cpuTemperature || 0
        maxValue: 100
        unit: "°C"
        color: getTempColor(value)
        
        icon: "🌡️" // Temperature icon
        isActive: value > 70
    }
    
    // Battery Indicator (MacBook only)
    SystemMetric {
        id: batteryMetric
        visible: (deviceConfig?.showBattery) && (systemStats?.batteryAvailable || false)
        label: "BAT"
        value: systemStats?.batteryLevel || 0
        maxValue: 100
        unit: "%"
        color: getBatteryColor(value, systemStats?.batteryCharging || false)
        
        icon: systemStats?.batteryCharging ? "🔌" : "🔋"
        isActive: systemStats?.batteryCharging || false
        
        property string detailText: systemStats?.batteryTimeRemaining || ""
    }
    
    // Connection status indicator
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 8
        height: 8
        radius: 4
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
    
    // Window count (preserving original functionality)
    Text {
        id: windowCount
        anchors.verticalCenter: parent.verticalCenter
        text: `${niriIPC?.windows?.length || 0} windows`
        color: "#c2c7ce" // surfaceVariantText
        font.pixelSize: 11
        font.family: "Inter"
    }
    
    // Component for individual metrics
    component SystemMetric: Rectangle {
        property string label: ""
        property real value: 0
        property real maxValue: 100
        property string unit: ""
        property color color: "#a6c8ff"
        property var chartData: []
        property string icon: ""
        property bool isActive: false
        property string detailText: ""
        
        width: (deviceConfig?.systemInfoDisplayMode === "expanded") ? 56 : 40
        height: 24
        radius: 6
        
        color: isActive ? Qt.rgba(parent.color.r, parent.color.g, parent.color.b, 0.1) : "transparent"
        border.width: 1
        border.color: isActive ? parent.color : "transparent"
        
        // Background with subtle gradient
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "#1e2328" // surfaceContainer
            opacity: 0.6
            z: -1
        }
        
        Row {
            anchors.centerIn: parent
            spacing: 4
            
            // Value text
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: value.toFixed(0) + unit
                color: parent.color
                font.pixelSize: 10
                font.family: "Inter"
                font.weight: Font.Medium
            }
            
            // Mini chart (for expanded view)
            MiniChart {
                id: miniChart
                visible: (deviceConfig?.systemInfoDisplayMode === "expanded") && chartData.length > 0
                width: 20
                height: 12
                dataPoints: chartData
                maxValue: parent.maxValue
                primaryColor: parent.color
                showFill: true
                lineWidth: 1
            }
        }
        
        // Hover effects
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            
            onEntered: {
                parent.scale = 1.05
                // Show detailed popover on MacBook
                if ((deviceConfig?.systemInfoDisplayMode === "popover") && detailText) {
                    // TODO: Show detailed popover
                }
            }
            
            onExited: {
                parent.scale = 1.0
            }
        }
        
        // Smooth transitions
        Behavior on scale {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
        
        Behavior on color {
            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
        
        Behavior on border.color {
            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
        
        // Subtle breathing animation when active
        SequentialAnimation on opacity {
            running: isActive
            loops: Animation.Infinite
            NumberAnimation { to: 0.8; duration: 1500; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.0; duration: 1500; easing.type: Easing.InOutSine }
        }
    }
    
    // Helper functions for dynamic colors
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
}
