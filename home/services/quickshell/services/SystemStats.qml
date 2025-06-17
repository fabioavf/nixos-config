pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    // CPU Statistics
    property real cpuUsage: 0.0
    property var cpuHistory: []
    property int cpuCores: 1

    // Memory Statistics  
    property real memoryUsage: 0.0
    property real memoryTotal: 0.0
    property real memoryUsed: 0.0
    property real swapUsage: 0.0
    property real swapTotal: 0.0

    // Network Statistics
    property real networkDownload: 0.0  // KB/s
    property real networkUpload: 0.0    // KB/s
    property real networkDownloadTotal: 0.0  // Total MB
    property real networkUploadTotal: 0.0    // Total MB
    property var networkHistory: []

    // Temperature (if available)
    property real cpuTemperature: 0.0
    property bool temperatureAvailable: false

    // Battery (MacBook only)
    property real batteryLevel: 0.0
    property bool batteryCharging: false
    property string batteryTimeRemaining: ""
    property bool batteryAvailable: false

    // Connection state
    property bool connected: false
    property string lastError: ""

    // Signals for reactive updates
    signal cpuUpdated(real usage, var history)
    signal memoryUpdated(real usage, real total, real used)
    signal networkUpdated(real download, real upload)
    signal temperatureUpdated(real temperature)
    signal batteryUpdated(real level, bool charging, string timeRemaining)
    signal statsUpdated()

    // Internal state for calculations
    property var lastCpuData: null
    property var lastNetworkData: null
    property int maxHistoryLength: 30  // Keep 30 data points for charts

    Component.onCompleted: {
        console.log("Lumin: Initializing SystemStats service...")
        connected = true
        
        // Start monitoring
        updateTimer.start()
        
        // Initial data collection
        updateTimer.triggered()
    }

    // Main update timer - every 2 seconds for good responsiveness
    Timer {
        id: updateTimer
        interval: 2000
        repeat: true
        running: false

        onTriggered: {
            // Update all stats in sequence to prevent overlapping
            updateCPU()
            updateMemory()
            updateNetwork()
            updateTemperature()
            updateBattery()
        }
    }

    // CPU Usage Monitoring
    function updateCPU() {
        readCpuProcess.running = true
    }

    Process {
        id: readCpuProcess
        command: ["cat", "/proc/stat"]
        running: false

        stdout: StdioCollector {
            id: cpuCollector
        }

        onExited: function(exitCode) {
            if (exitCode === 0) {
                const data = cpuCollector.text.trim()
                parseCpuData(data)
            } else {
                console.warn("Lumin: Failed to read CPU stats")
                root.lastError = "CPU read failed"
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

            // Calculate CPU cores count from /proc/stat
            const coreLines = lines.filter(line => line.match(/^cpu\d+/))
            root.cpuCores = coreLines.length

            if (root.lastCpuData) {
                // Calculate differences
                const totalDiff = Object.values(currentData).reduce((a, b) => a + b, 0) - 
                                Object.values(root.lastCpuData).reduce((a, b) => a + b, 0)
                const idleDiff = currentData.idle - root.lastCpuData.idle
                
                if (totalDiff > 0) {
                    const usage = Math.max(0, Math.min(100, ((totalDiff - idleDiff) / totalDiff) * 100))
                    root.cpuUsage = usage
                    
                    // Update history
                    root.cpuHistory.push(usage)
                    if (root.cpuHistory.length > root.maxHistoryLength) {
                        root.cpuHistory.shift()
                    }
                    
                    root.cpuUpdated(usage, root.cpuHistory)
                }
            }

            root.lastCpuData = currentData
        }
    }

    // Memory Usage Monitoring
    function updateMemory() {
        readMemoryProcess.running = true
    }

    Process {
        id: readMemoryProcess
        command: ["cat", "/proc/meminfo"]
        running: false

        stdout: StdioCollector {
            id: memoryCollector
        }

        onExited: function(exitCode) {
            if (exitCode === 0) {
                const data = memoryCollector.text.trim()
                parseMemoryData(data)
            } else {
                console.warn("Lumin: Failed to read memory stats")
                root.lastError = "Memory read failed"
            }
        }
    }

    function parseMemoryData(data) {
        const lines = data.split('\n')
        let memTotal = 0, memFree = 0, memAvailable = 0, buffers = 0, cached = 0
        let swapTotal = 0, swapFree = 0

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
                    case 'SwapTotal': swapTotal = value; break
                    case 'SwapFree': swapFree = value; break
                }
            }
        })

        if (memTotal > 0) {
            // Use MemAvailable if available, otherwise calculate
            const available = memAvailable > 0 ? memAvailable : (memFree + buffers + cached)
            const used = memTotal - available
            
            root.memoryTotal = memTotal
            root.memoryUsed = used
            root.memoryUsage = (used / memTotal) * 100
            
            if (swapTotal > 0) {
                root.swapTotal = swapTotal
                root.swapUsage = ((swapTotal - swapFree) / swapTotal) * 100
            }
            
            root.memoryUpdated(root.memoryUsage, root.memoryTotal, root.memoryUsed)
        }
    }

    // Network Monitoring
    function updateNetwork() {
        readNetworkProcess.running = true
    }

    Process {
        id: readNetworkProcess
        command: ["cat", "/proc/net/dev"]
        running: false

        stdout: StdioCollector {
            id: networkCollector
        }

        onExited: function(exitCode) {
            if (exitCode === 0) {
                const data = networkCollector.text.trim()
                parseNetworkData(data)
            } else {
                console.warn("Lumin: Failed to read network stats")
                root.lastError = "Network read failed"
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

        if (root.lastNetworkData) {
            const timeDiff = (currentData.timestamp - root.lastNetworkData.timestamp) / 1000 // seconds
            if (timeDiff > 0) {
                const rxDiff = currentData.rx - root.lastNetworkData.rx
                const txDiff = currentData.tx - root.lastNetworkData.tx
                
                // Convert to KB/s
                root.networkDownload = Math.max(0, rxDiff / timeDiff / 1024)
                root.networkUpload = Math.max(0, txDiff / timeDiff / 1024)
                
                // Update totals (in MB)
                root.networkDownloadTotal = currentData.rx / (1024 * 1024)
                root.networkUploadTotal = currentData.tx / (1024 * 1024)

                // Update history
                const networkPoint = {
                    download: root.networkDownload,
                    upload: root.networkUpload,
                    timestamp: currentData.timestamp
                }
                root.networkHistory.push(networkPoint)
                if (root.networkHistory.length > root.maxHistoryLength) {
                    root.networkHistory.shift()
                }
                
                root.networkUpdated(root.networkDownload, root.networkUpload)
            }
        }

        root.lastNetworkData = currentData
    }

    // Temperature Monitoring
    function updateTemperature() {
        readTemperatureProcess.running = true
    }

    Process {
        id: readTemperatureProcess
        command: ["sh", "-c", "find /sys/class/thermal -name 'temp' -exec cat {} \\; 2>/dev/null | head -1"]
        running: false

        stdout: StdioCollector {
            id: temperatureCollector
        }

        onExited: function(exitCode) {
            if (exitCode === 0) {
                const data = temperatureCollector.text.trim()
                if (data) {
                    const tempMilliC = parseInt(data)
                    if (!isNaN(tempMilliC)) {
                        root.cpuTemperature = tempMilliC / 1000 // Convert to Celsius
                        root.temperatureAvailable = true
                        root.temperatureUpdated(root.cpuTemperature)
                    }
                }
            } else {
                root.temperatureAvailable = false
            }
        }
    }

    // Battery Monitoring (MacBook only)
    function updateBattery() {
        readBatteryProcess.running = true
    }

    Process {
        id: readBatteryProcess
        command: ["sh", "-c", "ls /sys/class/power_supply/BAT* 2>/dev/null | head -1"]
        running: false

        stdout: StdioCollector {
            id: batteryPathCollector
        }

        onExited: function(exitCode) {
            if (exitCode === 0) {
                const batteryPath = batteryPathCollector.text.trim()
                if (batteryPath) {
                    readBatteryDetails.batteryPath = batteryPath
                    readBatteryDetails.running = true
                } else {
                    root.batteryAvailable = false
                }
            } else {
                root.batteryAvailable = false
            }
        }
    }

    Process {
        id: readBatteryDetails
        property string batteryPath: ""
        command: ["sh", "-c", `cat "${batteryPath}/capacity" "${batteryPath}/status" 2>/dev/null`]
        running: false

        stdout: StdioCollector {
            id: batteryDetailsCollector
        }

        onExited: function(exitCode) {
            if (exitCode === 0) {
                const lines = batteryDetailsCollector.text.trim().split('\n')
                if (lines.length >= 2) {
                    const capacity = parseInt(lines[0])
                    const status = lines[1].trim()
                    
                    if (!isNaN(capacity)) {
                        root.batteryLevel = capacity
                        root.batteryCharging = status === "Charging"
                        root.batteryAvailable = true
                        
                        // Calculate time remaining (rough estimate)
                        if (root.batteryCharging) {
                            root.batteryTimeRemaining = "Charging"
                        } else {
                            const hoursRemaining = Math.floor((capacity / 100) * 8) // Rough estimate
                            root.batteryTimeRemaining = `${hoursRemaining}h remaining`
                        }
                        
                        root.batteryUpdated(root.batteryLevel, root.batteryCharging, root.batteryTimeRemaining)
                    }
                }
            }
        }
    }

    // Utility functions
    function formatBytes(bytes) {
        if (bytes === 0) return "0 B"
        const k = 1024
        const sizes = ["B", "KB", "MB", "GB", "TB"]
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
}
