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
        
        // Beautiful Material 3 bar using extracted components
        MainBar {
            anchors.fill: parent
            niriIPC: niriService
            systemService: systemService
            systemStatsInstance: systemStatsInstance
            audioService: audioService
        }
        
    }

    // Audio Control Popup Window
    PanelWindow {
        id: audioPopupWindow
        
        screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
        
        WlrLayershell.anchors.top: true
        WlrLayershell.anchors.right: true
        WlrLayershell.exclusiveZone: 0
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        WlrLayershell.margins.top: Config.Device.config.barHeight
        WlrLayershell.margins.right: 20
        
        visible: shellRoot.audioPopupVisible
        
        // Handle escape key to close popup
        Keys.onEscapePressed: {
            console.log("Lumin: Escape pressed - closing popup")
            shellRoot.audioPopupVisible = false
        }
        
        implicitWidth: 300
        implicitHeight: 220
        
        color: "transparent"
        
        // Close popup when clicking outside
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            hoverEnabled: true
            propagateComposedEvents: false
            
            onClicked: function(mouse) {
                console.log("Lumin: Clicked outside popup - closing")
                shellRoot.audioPopupVisible = false
                mouse.accepted = true
            }
            
            onPressed: function(mouse) {
                console.log("Lumin: Pressed outside popup - closing")
                shellRoot.audioPopupVisible = false
                mouse.accepted = true
            }
        }
        
        Rectangle {
            anchors.fill: parent
            anchors.margins: Config.Material.spacing.sm
            
            radius: Config.Material.rounding.large
            color: Config.Material.colors.surfaceContainerHigh
            border.width: 1
            border.color: Config.Material.colors.outline
            
            // Prevent clicks from propagating to close the popup
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: function(mouse) {
                    // Do nothing - prevent propagation
                    mouse.accepted = true
                }
            }
            
            // Drop shadow
            Rectangle {
                anchors.centerIn: parent
                width: parent.width + 4
                height: parent.height + 4
                radius: parent.radius + 2
                color: Config.Material.elevation.shadowColor
                opacity: Config.Material.elevation.shadowOpacity * 0.8
                z: -1
            }
            
            Column {
                anchors.fill: parent
                anchors.margins: Config.Material.spacing.lg
                spacing: Config.Material.spacing.md
                
                // Header
                Row {
                    width: parent.width
                    spacing: Config.Material.spacing.md
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰕾"
                        color: Config.Material.colors.primary
                        font.pixelSize: 24
                        font.family: Config.Material.typography.monoFamily
                    }
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Audio Controls"
                        color: Config.Material.colors.surfaceText
                        font.pixelSize: Config.Material.typography.titleMedium.size
                        font.weight: Config.Material.typography.titleMedium.weight
                        font.family: Config.Material.typography.fontFamily
                    }
                }
                
                // Volume Slider
                Row {
                    width: parent.width
                    spacing: Config.Material.spacing.md
                    
                    Text {
                        text: "󰕿"
                        color: Config.Material.colors.surfaceText
                        font.pixelSize: 16
                        font.family: Config.Material.typography.monoFamily
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Rectangle {
                        width: parent.width - 60
                        height: 6
                        radius: 3
                        color: Config.Material.colors.outline
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Rectangle {
                            width: parent.width * (audioService?.volume || 0)
                            height: parent.height
                            radius: parent.radius
                            color: Config.Material.colors.primary
                            
                            Behavior on width {
                                NumberAnimation {
                                    duration: Config.Material.animation.durationShort3
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: function(mouse) {
                                if (audioService) {
                                    const newVolume = mouse.x / width
                                    audioService.setVolume(Math.max(0, Math.min(1, newVolume)))
                                }
                            }
                        }
                    }
                    
                    Text {
                        text: "󰕾"
                        color: Config.Material.colors.surfaceText
                        font.pixelSize: 16
                        font.family: Config.Material.typography.monoFamily
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                // Device Selection
                Row {
                    width: parent.width
                    spacing: Config.Material.spacing.sm
                    
                    Text {
                        text: "Device:"
                        color: Config.Material.colors.surfaceVariantText
                        font.pixelSize: Config.Material.typography.bodySmall.size
                        font.family: Config.Material.typography.fontFamily
                    }
                    
                    Text {
                        text: {
                            const device = audioService?.currentDevice || "Unknown"
                            console.log("Lumin: Current device in popup:", device)
                            return device
                        }
                        color: Config.Material.colors.surfaceText
                        font.pixelSize: Config.Material.typography.bodySmall.size
                        font.family: Config.Material.typography.fontFamily
                        font.weight: Font.Medium
                    }
                }
                
                // Mute Button
                Rectangle {
                    width: parent.width
                    height: 40
                    radius: Config.Material.rounding.medium
                    color: audioService?.muted ? Config.Material.colors.errorContainer : Config.Material.colors.primaryContainer
                    
                    Text {
                        anchors.centerIn: parent
                        text: audioService?.muted ? "󰸈 Unmute" : "󰕾 Mute"
                        color: audioService?.muted ? Config.Material.colors.errorContainerText : Config.Material.colors.primaryContainerText
                        font.pixelSize: Config.Material.typography.labelLarge.size
                        font.family: Config.Material.typography.fontFamily
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (audioService) {
                                audioService.toggleMute()
                            }
                        }
                    }
                    
                    Behavior on color {
                        ColorAnimation {
                            duration: Config.Material.animation.durationShort3
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}
