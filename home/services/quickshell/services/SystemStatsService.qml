import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: systemStatsService
    
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
        
        onTriggered: systemStatsService.updateSystemStats()
    }
    
    function updateSystemStats() {
        // Update CPU usage
        cpuProcess.running = true
    }
    
    Process {
        id: cpuProcess
        command: ["cat", "/proc/stat"]
        running: false
        
        stdout: StdioCollector {
            id: cpuCollector
        }
        
        onExited: function(exitCode) {
            if (exitCode === 0) {
                try {
                    const data = cpuCollector.text.trim()
                    systemStatsService.parseCpuData(data)
                    systemStatsService.errorCount = 0  // Reset error count on success
                    systemStatsService.hasErrors = false
                    // After CPU, update memory
                    memoryProcess.running = true
                } catch (error) {
                    console.error(`Lumin: CPU parsing error: ${error}`)
                    systemStatsService.handleError("CPU parsing failed", error)
                    memoryProcess.running = true  // Continue chain despite error
                }
            } else {
                console.warn(`Lumin: CPU process failed with exit code: ${exitCode}`)
                systemStatsService.handleError("CPU process failed", `Exit code: ${exitCode}`)
                memoryProcess.running = true  // Continue chain despite error
            }
        }
    }
    
    Process {
        id: memoryProcess
        command: ["cat", "/proc/meminfo"]
        running: false
        
        stdout: StdioCollector {
            id: memoryCollector
        }
        
        onExited: function(exitCode) {
            if (exitCode === 0) {
                try {
                    const data = memoryCollector.text.trim()
                    systemStatsService.parseMemoryData(data)
                    // After memory, update disk
                    diskProcess.running = true
                } catch (error) {
                    console.error(`Lumin: Memory parsing error: ${error}`)
                    systemStatsService.handleError("Memory parsing failed", error)
                    diskProcess.running = true  // Continue chain despite error
                }
            } else {
                console.warn(`Lumin: Memory process failed with exit code: ${exitCode}`)
                systemStatsService.handleError("Memory process failed", `Exit code: ${exitCode}`)
                diskProcess.running = true  // Continue chain despite error
            }
        }
    }
    
    Process {
        id: diskProcess
        command: ["df", "-BG", "/"]
        running: false
        
        stdout: StdioCollector {
            id: diskCollector
        }
        
        onExited: function(exitCode) {
            if (exitCode === 0) {
                try {
                    const data = diskCollector.text.trim()
                    systemStatsService.parseDiskData(data)
                    // After disk, update network
                    networkProcess.running = true
                } catch (error) {
                    console.error(`Lumin: Disk parsing error: ${error}`)
                    systemStatsService.handleError("Disk parsing failed", error)
                    networkProcess.running = true  // Continue chain despite error
                }
            } else {
                console.warn(`Lumin: Disk process failed with exit code: ${exitCode}`)
                systemStatsService.handleError("Disk process failed", `Exit code: ${exitCode}`)
                networkProcess.running = true  // Continue chain despite error
            }
        }
    }
    
    Process {
        id: networkProcess
        command: ["cat", "/proc/net/dev"]
        running: false
        
        stdout: StdioCollector {
            id: networkCollector
        }
        
        onExited: function(exitCode) {
            if (exitCode === 0) {
                try {
                    const data = networkCollector.text.trim()
                    systemStatsService.parseNetworkData(data)
                } catch (error) {
                    console.error(`Lumin: Network parsing error: ${error}`)
                    systemStatsService.handleError("Network parsing failed", error)
                }
            } else {
                console.warn(`Lumin: Network process failed with exit code: ${exitCode}`)
                systemStatsService.handleError("Network process failed", `Exit code: ${exitCode}`)
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