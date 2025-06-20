import QtQuick
import Quickshell.Io

Item {
    id: keyboardService
    
    // State properties
    property string currentLayout: "us"  // Default to US
    property var availableLayouts: ["us", "us-cedilla"]
    property bool connected: false
    property string lastError: ""
    property int errorCount: 0
    property bool hasErrors: false
    
    // Signals
    signal layoutChanged(string newLayout)
    signal errorOccurred(string error)
    
    Component.onCompleted: {
        console.log("Lumin: KeyboardLayoutService starting...")
        // Start monitoring and get initial state
        updateCurrentLayout()
        connected = true
    }
    
    // Timer for periodic layout checking
    Timer {
        id: layoutMonitorTimer
        interval: 5000  // Check every 5 seconds
        repeat: true
        running: connected
        
        onTriggered: {
            updateCurrentLayout()
        }
    }
    
    // Process for getting current layout
    Process {
        id: getCurrentLayoutProcess
        command: ["niri", "msg", "keyboard-layouts"]
        running: false
        
        stdout: StdioCollector {
            id: layoutCollector
        }
        
        onExited: function(exitCode) {
            if (exitCode === 0) {
                try {
                    parseLayoutOutput(layoutCollector.text.trim())
                    errorCount = 0
                    hasErrors = false
                } catch (error) {
                    console.error(`Lumin: Layout parsing error: ${error}`)
                    handleError("Layout parsing failed", error)
                }
            } else {
                console.warn(`Lumin: Get layout process failed with exit code: ${exitCode}`)
                handleError("Get layout process failed", `Exit code: ${exitCode}`)
            }
        }
    }
    
    // Process for switching layouts
    Process {
        id: switchLayoutProcess
        command: []
        running: false
        
        stdout: StdioCollector {
            id: switchCollector
        }
        
        stderr: StdioCollector {
            id: switchErrorCollector
        }
        
        onExited: function(exitCode) {
            if (exitCode === 0) {
                console.log("Lumin: Keyboard layout switched successfully")
                // Update layout after successful switch
                Qt.callLater(updateCurrentLayout)
            } else {
                console.error(`Lumin: Layout switch failed with exit code: ${exitCode}`)
                const errorOutput = switchErrorCollector.text.trim()
                if (errorOutput) {
                    console.error(`Lumin: Switch error: ${errorOutput}`)
                }
                handleError("Layout switch failed", `Exit code: ${exitCode}`)
            }
        }
    }
    
    // Parse the output from "niri msg keyboard-layouts"
    function parseLayoutOutput(output) {
        try {
            const lines = output.split('\n')
            
            // Look for the active layout (marked with *)
            for (const line of lines) {
                const trimmed = line.trim()
                if (trimmed.includes('*')) {
                    // Parse lines like " * 0 English (US)" or " * 1 English (US, international)"
                    let newLayout = "us"  // Default
                    
                    if (trimmed.includes('cedilla') || trimmed.includes('us-cedilla')) {
                        newLayout = "us-cedilla"
                    } else if (trimmed.includes('international') || trimmed.includes('intl')) {
                        newLayout = "us-intl"
                    } else if (trimmed.includes('English (US)') || trimmed.includes('* 0')) {
                        newLayout = "us"
                    }
                    
                    if (newLayout !== currentLayout) {
                        const oldLayout = currentLayout
                        currentLayout = newLayout
                        layoutChanged(newLayout)
                        console.log(`Lumin: Keyboard layout detected: ${oldLayout} → ${newLayout}`)
                    }
                    return
                }
            }
            
            // If no active layout found, default to US
            if (currentLayout !== "us") {
                currentLayout = "us"
                layoutChanged("us")
                console.log("Lumin: No active layout found, defaulting to US")
            }
        } catch (error) {
            console.error(`Lumin: Layout parsing error: ${error}`)
            handleError("Layout parsing failed", error)
        }
    }
    
    // Public function to switch layouts
    function switchToLayout(layoutName) {
        console.log(`Lumin: Switching to layout: ${layoutName}`)
        
        // Map layout names to Niri indices (this may need adjustment based on your Niri config)
        let layoutIndex = "0"  // Default to US
        
        switch (layoutName.toLowerCase()) {
            case "us":
                layoutIndex = "0"
                break
            case "us-cedilla":
                layoutIndex = "1"  
                break
            case "us-intl":
                layoutIndex = "1"  // Keep for backwards compatibility
                break
            default:
                console.warn(`Lumin: Unknown layout: ${layoutName}, defaulting to US`)
                layoutIndex = "0"
        }
        
        const command = ["niri", "msg", "action", "switch-layout", layoutIndex]
        console.log(`Lumin: Executing: ${command.join(" ")}`)
        
        switchLayoutProcess.command = command
        switchLayoutProcess.running = true
    }
    
    // Toggle between US and US-CEDILLA
    function toggleLayout() {
        const nextLayout = (currentLayout === "us") ? "us-cedilla" : "us"
        switchToLayout(nextLayout)
    }
    
    // Update current layout state
    function updateCurrentLayout() {
        if (getCurrentLayoutProcess.running) return
        getCurrentLayoutProcess.running = true
    }
    
    // Error handling
    function handleError(context, error) {
        errorCount++
        lastError = `${context}: ${error}`
        hasErrors = true
        
        console.warn(`Lumin: Keyboard service error [${errorCount}]: ${lastError}`)
        errorOccurred(lastError)
        
        if (errorCount > 10) {
            console.error("Lumin: Too many keyboard service errors, reducing update frequency")
            layoutMonitorTimer.interval = 15000  // Slow down on errors
        }
    }
    
    // Cleanup
    Component.onDestruction: {
        layoutMonitorTimer.stop()
    }
}