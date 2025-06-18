//@ pragma UseQApplication

import QtQuick
import QtQuick.Controls.Material
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "./config" as Config

ShellRoot {
    id: shellRoot

    // Configure Material 3 globally
    Material.theme: Material.Dark
    Material.accent: Material.Blue

    // Create SystemStats instance directly
    Item {
        id: systemStatsInstance
        
        // System monitoring properties
        property real cpuUsage: 0.0
        property real memoryUsage: 0.0
        property real memoryUsedGB: 0.0
        property real memoryTotalGB: 0.0
        property real diskUsage: 0.0
        property real diskFreeGB: 0.0
        property real diskTotalGB: 0.0
        property real networkDownload: 0.0
        property real networkUpload: 0.0
        property bool connected: true
        property string lastError: ""
        property int errorCount: 0
        property bool hasErrors: false
        
        // Internal state for calculations
        property var lastCpuData: null
        property var lastNetworkData: null
        
        // System monitoring with Timer
        Timer {
            interval: 2000  // Improved responsiveness using optimized timing
            repeat: true
            running: true
            
            property var statsInstance: systemStatsInstance
            
            onTriggered: statsInstance.updateSystemStats()
        }
        
        function updateSystemStats() {
            // Update CPU usage
            cpuProcess.running = true
        }
        
        Process {
            id: cpuProcess
            command: ["cat", "/proc/stat"]
            running: false
            
            property var statsInstance: systemStatsInstance
            
            stdout: StdioCollector {
                id: cpuCollector
            }
            
            onExited: function(exitCode) {
                if (exitCode === 0) {
                    try {
                        const data = cpuCollector.text.trim()
                        statsInstance.parseCpuData(data)
                        statsInstance.errorCount = 0  // Reset error count on success
                        statsInstance.hasErrors = false
                        // After CPU, update memory
                        memoryProcess.running = true
                    } catch (error) {
                        console.error(`Lumin: CPU parsing error: ${error}`)
                        statsInstance.handleError("CPU parsing failed", error)
                        memoryProcess.running = true  // Continue chain despite error
                    }
                } else {
                    console.warn(`Lumin: CPU process failed with exit code: ${exitCode}`)
                    statsInstance.handleError("CPU process failed", `Exit code: ${exitCode}`)
                    memoryProcess.running = true  // Continue chain despite error
                }
            }
        }
        
        Process {
            id: memoryProcess
            command: ["cat", "/proc/meminfo"]
            running: false
            
            property var statsInstance: systemStatsInstance
            
            stdout: StdioCollector {
                id: memoryCollector
            }
            
            onExited: function(exitCode) {
                if (exitCode === 0) {
                    try {
                        const data = memoryCollector.text.trim()
                        statsInstance.parseMemoryData(data)
                        // After memory, update disk
                        diskProcess.running = true
                    } catch (error) {
                        console.error(`Lumin: Memory parsing error: ${error}`)
                        statsInstance.handleError("Memory parsing failed", error)
                        diskProcess.running = true  // Continue chain despite error
                    }
                } else {
                    console.warn(`Lumin: Memory process failed with exit code: ${exitCode}`)
                    statsInstance.handleError("Memory process failed", `Exit code: ${exitCode}`)
                    diskProcess.running = true  // Continue chain despite error
                }
            }
        }
        
        Process {
            id: diskProcess
            command: ["df", "-BG", "/"]
            running: false
            
            property var statsInstance: systemStatsInstance
            
            stdout: StdioCollector {
                id: diskCollector
            }
            
            onExited: function(exitCode) {
                if (exitCode === 0) {
                    try {
                        const data = diskCollector.text.trim()
                        statsInstance.parseDiskData(data)
                        // After disk, update network
                        networkProcess.running = true
                    } catch (error) {
                        console.error(`Lumin: Disk parsing error: ${error}`)
                        statsInstance.handleError("Disk parsing failed", error)
                        networkProcess.running = true  // Continue chain despite error
                    }
                } else {
                    console.warn(`Lumin: Disk process failed with exit code: ${exitCode}`)
                    statsInstance.handleError("Disk process failed", `Exit code: ${exitCode}`)
                    networkProcess.running = true  // Continue chain despite error
                }
            }
        }
        
        Process {
            id: networkProcess
            command: ["cat", "/proc/net/dev"]
            running: false
            
            property var statsInstance: systemStatsInstance
            
            stdout: StdioCollector {
                id: networkCollector
            }
            
            onExited: function(exitCode) {
                if (exitCode === 0) {
                    try {
                        const data = networkCollector.text.trim()
                        statsInstance.parseNetworkData(data)
                    } catch (error) {
                        console.error(`Lumin: Network parsing error: ${error}`)
                        statsInstance.handleError("Network parsing failed", error)
                    }
                } else {
                    console.warn(`Lumin: Network process failed with exit code: ${exitCode}`)
                    statsInstance.handleError("Network process failed", `Exit code: ${exitCode}`)
                }
            }
        }
        
        function parseCpuData(data) {
            const lines = data.split('\n')
            const cpuLine = lines[0] // First line is overall CPU
            
            if (cpuLine.startsWith('cpu ')) {
                const values = cpuLine.split(/\s+/).slice(1).map(Number)
                const currentData = {
                    user: values[0] || 0,
                    nice: values[1] || 0,
                    system: values[2] || 0,
                    idle: values[3] || 0,
                    iowait: values[4] || 0,
                    irq: values[5] || 0,
                    softirq: values[6] || 0,
                    steal: values[7] || 0
                }

                if (lastCpuData) {
                    // Calculate differences
                    const totalDiff = Object.values(currentData).reduce((a, b) => a + b, 0) - 
                                    Object.values(lastCpuData).reduce((a, b) => a + b, 0)
                    const idleDiff = currentData.idle - lastCpuData.idle
                    
                    if (totalDiff > 0) {
                        const usage = Math.max(0, Math.min(100, ((totalDiff - idleDiff) / totalDiff) * 100))
                        cpuUsage = usage
                    }
                }

                lastCpuData = currentData
            }
        }
        
        function parseMemoryData(data) {
            const lines = data.split('\n')
            let memTotal = 0, memFree = 0, memAvailable = 0, buffers = 0, cached = 0

            lines.forEach(line => {
                const match = line.match(/^(\w+):\s+(\d+)\s+kB$/)
                if (match) {
                    const key = match[1]
                    const value = parseInt(match[2]) * 1024 // Convert KB to bytes
                    
                    switch (key) {
                        case 'MemTotal': memTotal = value; break
                        case 'MemFree': memFree = value; break
                        case 'MemAvailable': memAvailable = value; break
                        case 'Buffers': buffers = value; break
                        case 'Cached': cached = value; break
                    }
                }
            })

            if (memTotal > 0) {
                // Use MemAvailable if available, otherwise calculate
                const available = memAvailable > 0 ? memAvailable : (memFree + buffers + cached)
                const used = memTotal - available
                
                memoryUsage = (used / memTotal) * 100
                memoryUsedGB = used / (1024 * 1024 * 1024) // Convert to GB
                memoryTotalGB = memTotal / (1024 * 1024 * 1024) // Convert to GB
            }
        }
        
        function parseDiskData(data) {
            const lines = data.split('\n')
            if (lines.length > 1) {
                // Skip header line, get filesystem data
                const fsLine = lines[1].trim().split(/\s+/)
                if (fsLine.length >= 4) {
                    const totalGB = parseInt(fsLine[1].replace('G', '')) || 0
                    const usedGB = parseInt(fsLine[2].replace('G', '')) || 0
                    const availableGB = parseInt(fsLine[3].replace('G', '')) || 0
                    
                    diskTotalGB = totalGB
                    diskFreeGB = availableGB
                    diskUsage = totalGB > 0 ? ((totalGB - availableGB) / totalGB) * 100 : 0
                }
            }
        }
        
        function parseNetworkData(data) {
            const lines = data.split('\n').slice(2) // Skip header lines
            let totalRx = 0, totalTx = 0

            lines.forEach(line => {
                const parts = line.trim().split(/\s+/)
                if (parts.length >= 10) {
                    const iface = parts[0].replace(':', '')
                    // Skip loopback and virtual interfaces
                    if (!iface.startsWith('lo') && !iface.startsWith('veth') && !iface.startsWith('docker')) {
                        totalRx += parseInt(parts[1]) || 0  // Received bytes
                        totalTx += parseInt(parts[9]) || 0  // Transmitted bytes
                    }
                }
            })

            const currentData = { rx: totalRx, tx: totalTx, timestamp: Date.now() }

            if (lastNetworkData) {
                const timeDiff = (currentData.timestamp - lastNetworkData.timestamp) / 1000 // seconds
                if (timeDiff > 0) {
                    const rxDiff = currentData.rx - lastNetworkData.rx
                    const txDiff = currentData.tx - lastNetworkData.tx
                    
                    // Convert to KB/s
                    networkDownload = Math.max(0, rxDiff / timeDiff / 1024)
                    networkUpload = Math.max(0, txDiff / timeDiff / 1024)
                }
            }

            lastNetworkData = currentData
        }
        
        function formatBytes(bytes) {
            if (bytes === 0) return "0 B"
            const k = 1024
            const sizes = ["B", "KB", "MB", "GB"]
            const i = Math.floor(Math.log(bytes) / Math.log(k))
            return (bytes / Math.pow(k, i)).toFixed(1) + " " + sizes[i]
        }
        
        function formatSpeed(kbps) {
            if (kbps < 1024) {
                return kbps.toFixed(1) + " KB/s"
            } else {
                return (kbps / 1024).toFixed(1) + " MB/s"
            }
        }
        
        // Error handling with exponential backoff
        Timer {
            id: retryTimer
            repeat: false
            running: false
            onTriggered: {
                console.log("Lumin: Retrying system monitoring after backoff")
                connected = true
                hasErrors = false
                errorCount = Math.max(0, errorCount - 2)  // Reduce error count on retry
            }
        }
        
        function handleError(context, error) {
            errorCount++
            lastError = `${context}: ${error}`
            hasErrors = true
            
            console.warn(`Lumin: System monitoring error [${errorCount}]: ${lastError}`)
            
            // Implement exponential backoff for repeated errors
            if (errorCount > 5) {
                console.error("Lumin: Too many system monitoring errors, reducing update frequency")
                connected = false
                
                // Start retry timer with exponential backoff
                retryTimer.interval = Math.min(10000, 1000 * Math.pow(2, Math.min(errorCount - 5, 4)))
                retryTimer.start()
            }
        }
        
        Component.onCompleted: updateSystemStats()
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
        // Use the embedded SystemStats service
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
        
        // Beautiful Material 3 bar using components
        MainBar {
            anchors.fill: parent
            niriIPC: niriService
        }

        // Component definition
        component MainBar: Rectangle {
            property var niriIPC: null
            
            anchors.fill: parent
            color: Config.Material.colors.surface // Use Material 3 surface color
            
            // Left section - Workspaces (absolute positioning)
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
                color: Config.Material.colors.surfaceText
                font.pixelSize: Config.Material.typography.titleMedium.size
                font.weight: Config.Material.typography.titleMedium.weight
                font.family: Config.Material.typography.fontFamily
            }
            
            // Right section - System monitoring (absolute positioning)
            Row {
                id: systemMonitor
                anchors.right: parent.right
                anchors.rightMargin: Config.Device.config.barMargin
                anchors.verticalCenter: parent.verticalCenter
                spacing: Config.Material.spacing.sm
                
                // Helper functions for dynamic colors
                function getColorForUsage(usage) {
                    if (usage > 80) return Config.Material.colors.error
                    if (usage > 60) return Config.Material.colors.warning
                    return Config.Material.colors.success
                }
                
                function getColorForDiskUsage(usage) {
                    // For disk, we want to show free space, so invert the logic
                    if (usage > 90) return Config.Material.colors.error
                    if (usage > 75) return Config.Material.colors.warning
                    return Config.Material.colors.success
                }
                
                function getNetworkColor() {
                    return Config.Material.colors.info
                }
                
                // CPU Indicator
                SystemMetric {
                    label: "󰻠" // Nerd Font CPU icon
                    value: systemService?.cpuUsage || 0
                    maxValue: 100
                    unit: "%"
                    metricColor: systemStatsInstance.hasErrors ? Config.Material.colors.error : parent.getColorForUsage(value)
                    isActive: value > 70
                    hasError: systemStatsInstance.hasErrors
                }
                
                // Memory Indicator  
                SystemMetric {
                    label: "󰍛" // Nerd Font Memory icon
                    value: systemService?.memoryUsedGB || 0
                    maxValue: systemService?.memoryTotalGB || 16
                    unit: "GB"
                    metricColor: systemStatsInstance.hasErrors ? Config.Material.colors.error : parent.getColorForUsage((value / maxValue) * 100)
                    isActive: (value / maxValue) > 0.8
                    hasError: systemStatsInstance.hasErrors
                }
                
                // Disk Indicator
                SystemMetric {
                    label: "󰋊" // Nerd Font Disk icon
                    value: systemService?.diskFreeGB || 0
                    maxValue: systemService?.diskTotalGB || 100
                    unit: "GB"
                    metricColor: systemStatsInstance.hasErrors ? Config.Material.colors.error : parent.getColorForDiskUsage(systemService?.diskUsage || 0)
                    isActive: (systemService?.diskUsage || 0) > 80
                    isDiskIndicator: true
                    hasError: systemStatsInstance.hasErrors
                }
                
                // Network Indicator
                SystemMetric {
                    label: "󰛳" // Nerd Font Network icon
                    value: (systemService?.networkDownload || 0) + (systemService?.networkUpload || 0)
                    maxValue: 10240 // 10 MB/s max for scaling
                    unit: "KB/s"
                    metricColor: systemStatsInstance.hasErrors ? Config.Material.colors.error : parent.getNetworkColor()
                    isActive: value > 1024 // Active when > 1MB/s
                    hasError: systemStatsInstance.hasErrors
                }
                
                // System Tray
                SystemTray {
                    id: systemTray
                    anchors.verticalCenter: parent.verticalCenter
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
            
            width: windowCount === 0 ? Config.Device.config.workspaceSize : Math.max(Config.Device.config.workspaceSize, Math.min(44, 20 + (visibleDots * 6)))
            height: Config.Device.config.workspaceSize
            radius: Config.Material.rounding.medium
            
            // Beautiful Material 3 colors
            color: {
                if (isActive) return Config.Material.colors.primaryContainer
                if (mouseArea.containsMouse) return Config.Material.colors.surfaceContainerHigh  
                return Config.Material.colors.surfaceContainer
            }
            
            // Focus border
            border.width: isFocused ? 2 : 0
            border.color: Config.Material.colors.primary
            
            // Material 3 elevation shadow for active workspaces
            Rectangle {
                anchors.centerIn: parent
                width: parent.width + 2
                height: parent.height + 2
                radius: parent.radius + 1
                color: Config.Material.elevation.shadowColor
                opacity: isActive ? (Config.Material.elevation.shadowOpacity * 0.7) : 0
                z: -1
                visible: opacity > 0
                
                Behavior on opacity {
                    NumberAnimation { 
                        duration: Config.Material.animation.durationShort3
                        easing.type: Easing.OutCubic 
                    }
                }
            }
            
            // Material 3 motion system transitions for container
            Behavior on color {
                ColorAnimation { 
                    duration: Config.Material.animation.durationShort4
                    easing.type: Easing.OutCubic 
                }
            }
            
            Behavior on width {
                NumberAnimation { 
                    duration: Config.Material.animation.durationMedium1
                    easing.type: Easing.OutCubic 
                }
            }
            
            Behavior on border.width {
                NumberAnimation { 
                    duration: Config.Material.animation.durationShort3
                    easing.type: Easing.OutCubic 
                }
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
                    border.color: isActive ? Config.Material.colors.outline : Config.Material.colors.outlineVariant
                    visible: windowCount === 0
                    opacity: isActive ? 0.9 : 0.6
                    
                    Behavior on border.color {
                        ColorAnimation { 
                            duration: Config.Material.animation.durationShort3
                            easing.type: Easing.OutCubic 
                        }
                    }
                    
                    Behavior on opacity {
                        NumberAnimation { 
                            duration: Config.Material.animation.durationShort3
                            easing.type: Easing.OutCubic 
                        }
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
                                if (isOverflowDot) return Config.Material.colors.outline
                                if (isActive) return Config.Material.colors.primaryContainerText
                                return Config.Material.colors.outline
                            }
                            
                            // Gradient effect for overflow dot
                            opacity: isOverflowDot ? 0.3 : 1.0
                            
                            // Material 3 motion system transitions
                            Behavior on color {
                                ColorAnimation { 
                                    duration: Config.Material.animation.durationShort4
                                    easing.type: Easing.OutCubic 
                                }
                            }
                            
                            Behavior on opacity {
                                NumberAnimation { 
                                    duration: Config.Material.animation.durationShort4
                                    easing.type: Easing.OutCubic 
                                }
                            }
                            
                            // Material 3 breathing animation for active workspace only
                            SequentialAnimation on scale {
                                running: isActive && !isOverflowDot && windowCount > 0
                                loops: Animation.Infinite
                                NumberAnimation { 
                                    to: 1.05
                                    duration: Config.Material.animation.durationLong4 * 2  // 1200ms breathing rhythm
                                    easing.type: Easing.InOutSine 
                                }
                                NumberAnimation { 
                                    to: 1.0
                                    duration: Config.Material.animation.durationLong4 * 2  // 1200ms breathing rhythm
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
                    duration: Config.Material.animation.durationShort3
                    easing.type: Easing.OutCubic
                }
                
                // Click ripple effect
                Rectangle {
                    id: ripple
                    anchors.centerIn: parent
                    width: 0
                    height: 0
                    radius: width / 2
                    color: Config.Material.colors.primary
                    opacity: 0
                    
                    ParallelAnimation {
                        id: rippleAnimation
                        NumberAnimation {
                            target: ripple
                            properties: "width,height"
                            from: 0
                            to: mouseArea.width * 1.5
                            duration: Config.Material.animation.durationShort4
                            easing.type: Easing.OutCubic
                        }
                        SequentialAnimation {
                            NumberAnimation {
                                target: ripple
                                property: "opacity"
                                from: 0
                                to: 0.3
                                duration: Config.Material.animation.durationShort1
                            }
                            NumberAnimation {
                                target: ripple
                                property: "opacity"
                                from: 0.3
                                to: 0
                                duration: Config.Material.animation.durationShort3
                            }
                        }
                    }
                }
                
                onPressed: rippleAnimation.start()
            }
        }
        
        // Component for individual system metrics
        component SystemMetric: Rectangle {
            property string label: ""
            property real value: 0
            property real maxValue: 100
            property string unit: ""
            property color metricColor: Config.Material.colors.primary
            property bool isActive: false
            property bool isDiskIndicator: false
            property bool hasError: false
            
            width: Config.Device.config.systemCardWidth || 52
            height: Config.Device.config.workspaceSize  // Match workspace indicator height
            radius: Config.Material.rounding.medium
            
            // Proper Material 3 background with contrast
            color: Config.Material.colors.surfaceContainer
            border.width: (isActive || hasError) ? 1 : 0
            border.color: hasError ? Config.Material.colors.error : (isActive ? metricColor : "transparent")
            
            // Subtle elevation shadow for depth
            Rectangle {
                anchors.centerIn: parent
                width: parent.width + 2
                height: parent.height + 2
                radius: parent.radius + 1
                color: Config.Material.elevation.shadowColor
                opacity: Config.Material.elevation.shadowOpacity * 0.5
                z: -1
            }
            
            Row {
                anchors.centerIn: parent
                spacing: Config.Material.spacing.sm  // Better spacing between icon and text
                
                // Icon text (Nerd Font)
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: label
                    color: metricColor
                    font.pixelSize: Config.Device.config.iconSize || 12
                    font.family: Config.Material.typography.monoFamily
                }
                
                // Value text  
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: hasError ? "!" : (isDiskIndicator ? 
                        value.toFixed(0) + unit : 
                        value.toFixed(0) + unit)
                    color: hasError ? Config.Material.colors.error : Config.Material.colors.surfaceText
                    font.pixelSize: Config.Material.typography.labelSmall.size
                    font.family: Config.Material.typography.fontFamily
                    font.weight: Config.Material.typography.labelSmall.weight
                }
            }
            
            // Interactive hover effects
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                
                onEntered: {
                    parent.scale = 1.05
                    parent.color = Config.Material.colors.surfaceContainerHigh
                }
                
                onExited: {
                    parent.scale = 1.0
                    parent.color = Config.Material.colors.surfaceContainer
                }
            }
            
            // Material 3 motion system transitions
            Behavior on scale {
                NumberAnimation { 
                    duration: Config.Material.animation.durationShort3
                    easing.type: Easing.OutCubic 
                }
            }
            
            Behavior on color {
                ColorAnimation { 
                    duration: Config.Material.animation.durationShort4
                    easing.type: Easing.OutCubic 
                }
            }
            
            Behavior on border.color {
                ColorAnimation { 
                    duration: Config.Material.animation.durationShort4
                    easing.type: Easing.OutCubic 
                }
            }
            
            // Material 3 breathing animation when active or error pulsing
            SequentialAnimation on opacity {
                running: isActive || hasError
                loops: Animation.Infinite
                NumberAnimation { 
                    to: hasError ? 0.6 : 0.8  // More pronounced pulse for errors
                    duration: hasError ? Config.Material.animation.durationMedium2 : Config.Material.animation.durationLong4 * 2.5
                    easing.type: Easing.InOutSine 
                }
                NumberAnimation { 
                    to: 1.0
                    duration: hasError ? Config.Material.animation.durationMedium2 : Config.Material.animation.durationLong4 * 2.5
                    easing.type: Easing.InOutSine 
                }
            }
        }
        
        // Material 3 System Tray Component
        component SystemTray: Rectangle {
            implicitWidth: Math.max(Config.Device.config.systemCardWidth || 60, layout.implicitWidth + Config.Material.spacing.md)
            height: Config.Device.config.workspaceSize  // Match workspace and system monitor height
            radius: Config.Material.rounding.medium
            
            // Material 3 surface container background
            color: Config.Material.colors.surfaceContainer
            border.width: 0
            
            // Only show when tray items are present
            visible: layout.children.length > 0
            
            // Subtle elevation shadow for depth
            Rectangle {
                anchors.centerIn: parent
                width: parent.width + 2
                height: parent.height + 2
                radius: parent.radius + 1
                color: Config.Material.elevation.shadowColor
                opacity: Config.Material.elevation.shadowOpacity * 0.4
                z: -1
            }
            
            // Scrollable content area for overflow handling
            Flickable {
                id: flickable
                anchors.fill: parent
                anchors.margins: Config.Material.spacing.xs
                contentWidth: layout.implicitWidth
                contentHeight: height
                
                // Horizontal scrolling only
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.HorizontalFlick
                
                // Smooth scrolling behavior
                maximumFlickVelocity: 2000
                flickDeceleration: 1000
                
                Row {
                    id: layout
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    
                    // Smooth addition animation using Material 3 timing
                    add: Transition {
                        ParallelAnimation {
                            NumberAnimation {
                                properties: "scale"
                                from: 0
                                to: 1
                                duration: Config.Material.animation.durationMedium2
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                properties: "opacity"
                                from: 0
                                to: 1
                                duration: Config.Material.animation.durationMedium2
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                    
                    Repeater {
                        model: SystemTray.items
                        
                        delegate: TrayIcon {
                            required property SystemTrayItem modelData
                            trayItem: modelData
                        }
                    }
                }
            }
            
            // Smooth width animation using Material 3 timing
            Behavior on implicitWidth {
                NumberAnimation { 
                    duration: Config.Material.animation.durationMedium1
                    easing.type: Easing.OutCubic
                }
            }
            
            // Container hover effect
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                z: -1
                
                onEntered: {
                    parent.color = Config.Material.colors.surfaceContainerHigh
                }
                
                onExited: {
                    parent.color = Config.Material.colors.surfaceContainer
                }
            }
            
            // Smooth container color transitions
            Behavior on color {
                ColorAnimation { 
                    duration: Config.Material.animation.durationShort3
                    easing.type: Easing.OutCubic
                }
            }
        }
        
        // Individual System Tray Icon Component
        component TrayIcon: Rectangle {
            property SystemTrayItem trayItem: null
            
            width: Config.Device.config.iconSize + Config.Material.spacing.xs
            height: Config.Device.config.iconSize + Config.Material.spacing.xs
            radius: Config.Material.rounding.small
            
            // Material 3 state layer background
            color: {
                if (mouseArea.pressed) return Config.Material.colors.pressed
                if (mouseArea.containsMouse) return Config.Material.colors.hover
                return "transparent"
            }
            
            // Tray icon image
            Image {
                id: trayIconImage
                anchors.centerIn: parent
                width: Config.Device.config.iconSize
                height: Config.Device.config.iconSize
                
                // Critical icon path processing (required for QuickShell SystemTray)
                source: {
                    if (!trayItem) return ""
                    let icon = trayItem.icon || ""
                    if (icon.includes("?path=")) {
                        const parts = icon.split("?path=")
                        const name = parts[0]
                        const path = parts[1]
                        icon = `file://${path}/${name.slice(name.lastIndexOf("/") + 1)}`
                    }
                    return icon
                }
                
                fillMode: Image.PreserveAspectFit
                smooth: true
                asynchronous: true
                
                // Material 3 interaction feedback
                opacity: mouseArea.pressed ? 0.8 : 1.0
                scale: mouseArea.pressed ? 0.95 : 1.0
                
                Behavior on opacity {
                    NumberAnimation { 
                        duration: Config.Material.animation.durationShort3
                        easing.type: Easing.OutCubic
                    }
                }
                
                Behavior on scale {
                    NumberAnimation { 
                        duration: Config.Material.animation.durationShort3
                        easing.type: Easing.OutCubic
                    }
                }
            }
            
            // Mouse interaction handling
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                hoverEnabled: true
                
                onClicked: function(mouse) {
                    if (!trayItem) return
                    
                    if (mouse.button === Qt.LeftButton) {
                        // Primary activation (left click)
                        trayItem.activate()
                    } else if (mouse.button === Qt.RightButton) {
                        // Context menu (right click)
                        if (trayItem.hasMenu) {
                            contextMenu.open()
                        }
                    }
                }
                
                // Material 3 ripple effect on click
                onPressed: {
                    rippleAnimation.start()
                }
            }
            
            // Material 3 styled context menu
            QsMenuAnchor {
                id: contextMenu
                menu: trayItem?.menu
                anchor.window: this.QsWindow.window
                anchor.rect {
                    x: parent.mapToItem(null, 0, 0).x + parent.width / 2
                    y: parent.mapToItem(null, 0, 0).y + parent.height + Config.Material.spacing.xs
                    width: 0
                    height: 0
                }
            }
            
            // Click ripple effect
            Rectangle {
                id: ripple
                anchors.centerIn: parent
                width: 0
                height: 0
                radius: width / 2
                color: Config.Material.colors.primary
                opacity: 0
                z: -1
                
                ParallelAnimation {
                    id: rippleAnimation
                    NumberAnimation {
                        target: ripple
                        properties: "width,height"
                        from: 0
                        to: parent.width * 1.5
                        duration: Config.Material.animation.durationShort4
                        easing.type: Easing.OutCubic
                    }
                    SequentialAnimation {
                        NumberAnimation {
                            target: ripple
                            property: "opacity"
                            from: 0
                            to: 0.2
                            duration: Config.Material.animation.durationShort2
                        }
                        NumberAnimation {
                            target: ripple
                            property: "opacity"
                            from: 0.2
                            to: 0
                            duration: Config.Material.animation.durationShort3
                        }
                    }
                }
            }
            
            // Smooth state layer transitions
            Behavior on color {
                ColorAnimation { 
                    duration: Config.Material.animation.durationShort3
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}