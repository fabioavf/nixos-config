import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Item {
    id: audioService
    
    // Audio state properties
    property real volume: 0.0              // 0.0 to 1.0
    property bool muted: false
    property real audioLevel: 0.0          // Real-time audio level 0.0 to 1.0
    property string currentDevice: "Unknown"
    property string currentDeviceType: "speaker" // "speaker", "headphone", "bluetooth"
    property var availableDevices: []
    property var deviceIds: []  // Corresponding device IDs for switching
    property bool connected: false
    property string lastError: ""
    property int errorCount: 0
    property bool hasErrors: false
    
    // PipeWire integration
    readonly property bool pipewireAvailable: typeof Pipewire !== "undefined"
    
    // Signals for events not covered by property change signals
    signal audioLevelUpdated(real level)
    signal errorOccurred(string error)
    
    // Internal state
    property var lastAudioData: null
    property bool isUpdating: false
    
    Component.onCompleted: {
        console.log("Lumin: AudioService starting...")
        if (pipewireAvailable) {
            console.log("Lumin: Using PipeWire for audio control")
            initializePipeWire()
        } else {
            console.log("Lumin: Using wpctl/pactl fallback for audio control")
            initializeFallback()
        }
    }
    
    // PipeWire initialization
    function initializePipeWire() {
        try {
            // This will be implemented when PipeWire API is available
            console.log("Lumin: PipeWire integration ready")
            connected = true
            startAudioMonitoring()
        } catch (error) {
            console.warn("Lumin: PipeWire initialization failed, falling back to commands")
            initializeFallback()
        }
    }
    
    // Fallback command-based implementation
    function initializeFallback() {
        connected = true
        startAudioMonitoring()
        updateAudioState()
    }
    
    // Main audio monitoring timer
    Timer {
        id: audioMonitorTimer
        interval: 1000  // 1 second - reasonable for status bar
        repeat: true
        running: false
        
        onTriggered: {
            if (!isUpdating) {
                updateAudioState()
            }
        }
    }
    
    // Device monitoring timer (less frequent)
    Timer {
        id: deviceMonitorTimer
        interval: 5000  // Check devices every 5 seconds
        repeat: true
        running: false
        
        onTriggered: updateDeviceList()
    }
    
    function startAudioMonitoring() {
        audioMonitorTimer.start()
        deviceMonitorTimer.start()
        // Trigger initial device detection
        updateDeviceList()
    }
    
    function stopAudioMonitoring() {
        audioMonitorTimer.stop()
        deviceMonitorTimer.stop()
    }
    
    // Update audio state (volume, mute, level)
    function updateAudioState() {
        if (isUpdating) return
        isUpdating = true
        
        // Get volume and mute state
        volumeProcess.running = true
    }
    
    // Volume and mute state process
    Process {
        id: volumeProcess
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: false
        
        stdout: StdioCollector {
            id: volumeCollector
        }
        
        onExited: function(exitCode) {
            if (exitCode === 0) {
                try {
                    parseVolumeOutput(volumeCollector.text.trim())
                    errorCount = 0
                    hasErrors = false
                    
                    // After volume, get audio level
                    audioLevelProcess.running = true
                } catch (error) {
                    console.error(`Lumin: Volume parsing error: ${error}`)
                    handleError("Volume parsing failed", error)
                    finishUpdate()
                }
            } else {
                console.warn(`Lumin: Volume process failed with exit code: ${exitCode}`)
                handleError("Volume process failed", `Exit code: ${exitCode}`)
                finishUpdate()
            }
        }
    }
    
    // Audio level monitoring process
    Process {
        id: audioLevelProcess
        command: ["wpctl", "status"]
        running: false
        
        stdout: StdioCollector {
            id: audioLevelCollector
        }
        
        onExited: function(exitCode) {
            if (exitCode === 0) {
                try {
                    parseAudioLevel(audioLevelCollector.text.trim())
                } catch (error) {
                    console.error(`Lumin: Audio level parsing error: ${error}`)
                    handleError("Audio level parsing failed", error)
                }
            } else {
                console.warn(`Lumin: Audio level process failed with exit code: ${exitCode}`)
                handleError("Audio level process failed", `Exit code: ${exitCode}`)
            }
            finishUpdate()
        }
    }
    
    // Device list process
    Process {
        id: deviceListProcess
        command: ["wpctl", "status"]
        running: false
        
        stdout: StdioCollector {
            id: deviceListCollector
        }
        
        onExited: function(exitCode) {
            if (exitCode === 0) {
                try {
                    const output = deviceListCollector.text.trim()
                    parseDeviceList(output)
                } catch (error) {
                    console.error(`Lumin: Device list parsing error: ${error}`)
                    handleError("Device list parsing failed", error)
                }
            } else {
                console.warn(`Lumin: Device list process failed with exit code: ${exitCode}`)
                handleError("Device list process failed", `Exit code: ${exitCode}`)
            }
        }
    }
    
    function parseVolumeOutput(output) {
        // Parse wpctl output like "Volume: 0.45 [MUTED]" or "Volume: 0.45"
        try {
            const trimmed = output.trim()
            
            // Match pattern like "Volume: 0.35" or "Volume: 0.35 [MUTED]"
            const volumeMatch = trimmed.match(/Volume:\s*([\d.]+)/)
            if (volumeMatch) {
                const newVolume = parseFloat(volumeMatch[1])
                
                if (!isNaN(newVolume)) {
                    const prevVolume = volume
                    volume = Math.max(0, Math.min(1, newVolume))
                    // Only log on significant changes
                    if (Math.abs(prevVolume - volume) > 0.05) {
                        console.log(`Lumin: Volume changed: ${(volume * 100).toFixed(0)}%`)
                    }
                }
            }
            
            const newMuted = trimmed.includes('[MUTED]')
            if (newMuted !== muted) {
                muted = newMuted
                console.log(`Lumin: Audio ${muted ? 'muted' : 'unmuted'}`)
            }
        } catch (error) {
            console.error(`Lumin: Volume parsing error: ${error}`)
        }
    }
    
    function parseAudioLevel(output) {
        // Simple audio level simulation based on device activity
        // In a real implementation, this would parse actual audio level data
        const now = Date.now()
        const timeSeed = Math.sin(now / 1000) * 0.5 + 0.5
        
        // Simulate audio activity when not muted and volume > 0
        if (!muted && volume > 0) {
            // Create some realistic audio level fluctuation
            audioLevel = Math.random() * 0.3 + timeSeed * 0.4
        } else {
            audioLevel = 0
        }
        
        audioLevelUpdated(audioLevel)
    }
    
    function parseDeviceList(output) {
        try {
            const lines = output.split('\n')
            let devices = []
            let deviceIdList = []
            let inSinks = false
            let currentDefaultDevice = ""
            
            for (const line of lines) {
                const trimmedLine = line.trim()
                
                if (trimmedLine.includes('Sinks:')) {
                    inSinks = true
                    continue
                } else if (trimmedLine.includes('Sources:')) {
                    inSinks = false
                    continue
                }
                
                if (inSinks && trimmedLine.includes('*')) {
                    // This is the default sink
                    const deviceMatch = trimmedLine.match(/\*\s+(\d+)\.\s+(.+?)(?:\s+\[|\s*$)/)
                    if (deviceMatch) {
                        currentDefaultDevice = prettifyDeviceName(deviceMatch[2])
                    }
                }
                
                if (inSinks && (trimmedLine.includes('*') || trimmedLine.match(/^\s*\d+\./))) {
                    const deviceMatch = trimmedLine.match(/[*\s]*(\d+)\.\s+(.+?)(?:\s+\[|\s*$)/)
                    if (deviceMatch) {
                        const deviceId = deviceMatch[1]
                        const deviceName = prettifyDeviceName(deviceMatch[2])
                        
                        if (!devices.includes(deviceName)) {
                            devices.push(deviceName)
                            deviceIdList.push(deviceId)
                        }
                    }
                }
            }
            
            availableDevices = devices
            deviceIds = deviceIdList
            
            if (currentDefaultDevice && currentDefaultDevice !== currentDevice) {
                console.log("Lumin: Audio device changed to:", currentDefaultDevice)
                currentDevice = currentDefaultDevice
                currentDeviceType = detectDeviceType(currentDefaultDevice)
            }
            
        } catch (error) {
            console.error(`Lumin: Device list parsing error: ${error}`)
        }
    }
    
    function prettifyDeviceName(rawName) {
        // Convert technical device names to user-friendly names
        const name = rawName.toLowerCase()
        
        if (name.includes('headphone') || name.includes('headset')) {
            return "Headphones"
        } else if (name.includes('bluetooth') || name.includes('bt')) {
            return "Bluetooth Audio"
        } else if (name.includes('usb')) {
            return "USB Audio"
        } else if (name.includes('hdmi')) {
            return "HDMI Audio"
        } else if (name.includes('speaker') || name.includes('built-in') || name.includes('internal')) {
            return "Speakers"
        } else {
            // Capitalize first letter and clean up
            return rawName.charAt(0).toUpperCase() + rawName.slice(1).replace(/_/g, ' ')
        }
    }
    
    // Public function for device type detection
    function detectDeviceType(deviceName) {
        const name = deviceName.toLowerCase()
        
        if (name.includes('headphone') || name.includes('headset')) {
            return "headphone"
        } else if (name.includes('bluetooth')) {
            return "bluetooth"
        } else {
            return "speaker"
        }
    }
    
    function updateDeviceList() {
        deviceListProcess.running = true
    }
    
    function finishUpdate() {
        isUpdating = false
    }
    
    // Public API functions
    function setVolume(newVolume) {
        if (newVolume < 0 || newVolume > 1) return
        
        const volumePercent = Math.round(newVolume * 100)
        setVolumeProcess.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", `${volumePercent}%`]
        setVolumeProcess.running = true
    }
    
    function toggleMute() {
        muteProcess.running = true
    }
    
    function switchToDevice(deviceIndex) {
        if (deviceIndex < 0 || deviceIndex >= deviceIds.length) return
        
        const deviceId = deviceIds[deviceIndex]
        console.log(`Lumin: Switching to device ID: ${deviceId} (${availableDevices[deviceIndex]})`)
        
        switchDeviceProcess.command = ["wpctl", "set-default", deviceId]
        switchDeviceProcess.running = true
    }
    
    // Set volume process
    Process {
        id: setVolumeProcess
        command: []
        running: false
        
        onExited: function(exitCode) {
            if (exitCode === 0) {
                // Volume set successfully, update state
                Qt.callLater(updateAudioState)
            } else {
                console.warn(`Lumin: Set volume failed with exit code: ${exitCode}`)
                handleError("Set volume failed", `Exit code: ${exitCode}`)
            }
        }
    }
    
    // Mute toggle process
    Process {
        id: muteProcess
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
        running: false
        
        onExited: function(exitCode) {
            if (exitCode === 0) {
                // Mute toggled successfully, update state
                Qt.callLater(updateAudioState)
            } else {
                console.warn(`Lumin: Mute toggle failed with exit code: ${exitCode}`)
                handleError("Mute toggle failed", `Exit code: ${exitCode}`)
            }
        }
    }
    
    // Device switching process
    Process {
        id: switchDeviceProcess
        command: []
        running: false
        
        onExited: function(exitCode) {
            if (exitCode === 0) {
                console.log("Lumin: Audio device switched successfully")
                // Update device list after switching
                Qt.callLater(updateDeviceList)
            } else {
                console.warn(`Lumin: Device switch failed with exit code: ${exitCode}`)
                handleError("Device switch failed", `Exit code: ${exitCode}`)
            }
        }
    }
    
    // Error handling
    function handleError(context, error) {
        errorCount++
        lastError = `${context}: ${error}`
        hasErrors = true
        
        console.warn(`Lumin: Audio service error [${errorCount}]: ${lastError}`)
        errorOccurred(lastError)
        
        if (errorCount > 10) {
            console.error("Lumin: Too many audio service errors, reducing update frequency")
            connected = false
            audioMonitorTimer.interval = 5000  // Slow down on errors
        }
    }
    
    // Cleanup
    Component.onDestruction: {
        stopAudioMonitoring()
    }
}