pragma Singleton

import QtQuick
import Quickshell.Io

Singleton {
    id: root

    // State properties
    property var workspaces: []
    property var windows: []
    property var outputs: []
    property var focusedWindow: null
    property bool connected: false
    property string lastError: ""

    // Signals for real-time updates
    signal workspacesChanged(var workspaces)
    signal windowsChanged(var windows)
    signal outputsChanged(var outputs)
    signal focusedWindowChanged(var window)
    signal connectionStateChanged(bool connected)

    // Initial state queries
    Component.onCompleted: {
        console.log("Lumin: Initializing Niri IPC connection...")
        queryWorkspaces()
        queryWindows()
        queryOutputs()
        queryFocusedWindow()
        startEventStream()
    }

    // Query current workspaces
    function queryWorkspaces() {
        console.log("Lumin: Querying Niri workspaces...")
        workspacesQuery.running = true
    }

    Process {
        id: workspacesQuery
        command: ["niri", "msg", "--json", "workspaces"]
        running: false

        stdout: StdioCollector {
            onFinished: {
                try {
                    const data = JSON.parse(text)
                    root.workspaces = data
                    root.workspacesChanged(data)
                    console.log(`Lumin: Loaded ${data.length} workspaces`)
                } catch (e) {
                    console.error("Lumin: Failed to parse workspaces:", e)
                    root.lastError = `Workspaces parse error: ${e}`
                }
            }
        }

        onExited: {
            if (exitCode !== 0) {
                console.error(`Lumin: Workspaces query failed with exit code ${exitCode}`)
                root.lastError = `Workspaces query failed: ${exitCode}`
            }
        }
    }

    // Query current windows
    function queryWindows() {
        console.log("Lumin: Querying Niri windows...")
        windowsQuery.running = true
    }

    Process {
        id: windowsQuery
        command: ["niri", "msg", "--json", "windows"]
        running: false

        stdout: StdioCollector {
            onFinished: {
                try {
                    const data = JSON.parse(text)
                    root.windows = data
                    root.windowsChanged(data)
                    console.log(`Lumin: Loaded ${data.length} windows`)
                } catch (e) {
                    console.error("Lumin: Failed to parse windows:", e)
                    root.lastError = `Windows parse error: ${e}`
                }
            }
        }

        onExited: {
            if (exitCode !== 0) {
                console.error(`Lumin: Windows query failed with exit code ${exitCode}`)
                root.lastError = `Windows query failed: ${exitCode}`
            }
        }
    }

    // Query outputs (monitors)
    function queryOutputs() {
        console.log("Lumin: Querying Niri outputs...")
        outputsQuery.running = true
    }

    Process {
        id: outputsQuery
        command: ["niri", "msg", "--json", "outputs"]
        running: false

        stdout: StdioCollector {
            onFinished: {
                try {
                    const data = JSON.parse(text)
                    root.outputs = data
                    root.outputsChanged(data)
                    console.log(`Lumin: Loaded ${data.length} outputs`)
                } catch (e) {
                    console.error("Lumin: Failed to parse outputs:", e)
                    root.lastError = `Outputs parse error: ${e}`
                }
            }
        }

        onExited: {
            if (exitCode !== 0) {
                console.error(`Lumin: Outputs query failed with exit code ${exitCode}`)
                root.lastError = `Outputs query failed: ${exitCode}`
            }
        }
    }

    // Query focused window
    function queryFocusedWindow() {
        console.log("Lumin: Querying focused window...")
        focusedWindowQuery.running = true
    }

    Process {
        id: focusedWindowQuery
        command: ["niri", "msg", "--json", "focused-window"]
        running: false

        stdout: StdioCollector {
            onFinished: {
                try {
                    const data = text.trim() === "null" ? null : JSON.parse(text)
                    root.focusedWindow = data
                    root.focusedWindowChanged(data)
                    console.log("Lumin: Focused window updated")
                } catch (e) {
                    console.error("Lumin: Failed to parse focused window:", e)
                    root.lastError = `Focused window parse error: ${e}`
                }
            }
        }

        onExited: {
            if (exitCode !== 0) {
                console.error(`Lumin: Focused window query failed with exit code ${exitCode}`)
                root.lastError = `Focused window query failed: ${exitCode}`
            }
        }
    }    // Real-time event stream (CRITICAL for responsive updates)
    function startEventStream() {
        console.log("Lumin: Starting Niri event stream...")
        eventStream.running = true
        root.connected = true
        root.connectionStateChanged(true)
    }

    function stopEventStream() {
        console.log("Lumin: Stopping Niri event stream...")
        eventStream.running = false
        root.connected = false
        root.connectionStateChanged(false)
    }

    Process {
        id: eventStream
        command: ["niri", "msg", "--json", "event-stream"]
        running: false

        stdout: StdioCollector {
            onDataReceived: {
                try {
                    // Event stream sends one JSON object per line
                    const lines = data.split('\n').filter(line => line.trim())
                    for (const line of lines) {
                        handleRealtimeEvent(JSON.parse(line))
                    }
                } catch (e) {
                    console.error("Lumin: Failed to parse event stream data:", e)
                    root.lastError = `Event stream parse error: ${e}`
                }
            }
        }

        onExited: {
            console.warn(`Lumin: Event stream exited with code ${exitCode}`)
            root.connected = false
            root.connectionStateChanged(false)
            
            // Auto-reconnect after 2 seconds
            if (exitCode !== 0) {
                console.log("Lumin: Scheduling event stream reconnection...")
                reconnectTimer.start()
            }
        }
    }

    // Auto-reconnection timer
    Timer {
        id: reconnectTimer
        interval: 2000
        repeat: false
        onTriggered: {
            console.log("Lumin: Attempting to reconnect event stream...")
            startEventStream()
        }
    }

    // Handle real-time events from Niri
    function handleRealtimeEvent(event) {
        console.log(`Lumin: Received event: ${event.type || "unknown"}`)
        
        switch (event.type) {
            case "WorkspacesChanged":
                root.workspaces = event.workspaces || []
                root.workspacesChanged(root.workspaces)
                break
                
            case "WindowsChanged":
                root.windows = event.windows || []
                root.windowsChanged(root.windows)
                break
                
            case "OutputsChanged":
                root.outputs = event.outputs || []
                root.outputsChanged(root.outputs)
                break
                
            case "FocusedWindowChanged":
                root.focusedWindow = event.window || null
                root.focusedWindowChanged(root.focusedWindow)
                break
                
            default:
                console.log(`Lumin: Unhandled event type: ${event.type}`)
        }
    }

    // Action functions for controlling Niri
    function switchToWorkspace(workspaceId) {
        console.log(`Lumin: Switching to workspace ${workspaceId}`)
        const action = actionProcess.createObject(root)
        action.command = ["niri", "msg", "action", "focus-workspace", workspaceId.toString()]
        action.running = true
    }

    function moveToWorkspace(workspaceId) {
        console.log(`Lumin: Moving window to workspace ${workspaceId}`)
        const action = actionProcess.createObject(root)
        action.command = ["niri", "msg", "action", "move-to-workspace", workspaceId.toString()]
        action.running = true
    }

    function closeWindow() {
        console.log("Lumin: Closing focused window")
        const action = actionProcess.createObject(root)
        action.command = ["niri", "msg", "action", "close-window"]
        action.running = true
    }

    function focusWindow(windowId) {
        console.log(`Lumin: Focusing window ${windowId}`)
        const action = actionProcess.createObject(root)
        action.command = ["niri", "msg", "action", "focus-window", "--id", windowId.toString()]
        action.running = true
    }

    // Reusable action process component
    Component {
        id: actionProcess
        
        Process {
            property bool autoDestroy: true
            
            onExited: {
                if (exitCode !== 0) {
                    console.error(`Lumin: Action failed with exit code ${exitCode}`)
                    root.lastError = `Action failed: ${exitCode}`
                }
                
                if (autoDestroy) {
                    destroy()
                }
            }
        }
    }

    // Utility functions
    function getWorkspaceById(id) {
        return workspaces.find(ws => ws.id === id) || null
    }

    function getWindowById(id) {
        return windows.find(win => win.id === id) || null
    }

    function getOutputByName(name) {
        return outputs.find(output => output.name === name) || null
    }

    function getActiveWorkspace() {
        return workspaces.find(ws => ws.is_active) || null
    }

    function getVisibleWorkspaces() {
        return workspaces.filter(ws => ws.is_visible) || []
    }

    // Debug information
    readonly property var debugInfo: ({
        connected: connected,
        lastError: lastError,
        workspaceCount: workspaces.length,
        windowCount: windows.length,
        outputCount: outputs.length,
        hasFocusedWindow: focusedWindow !== null,
        focusedWindowTitle: focusedWindow?.title || "none"
    })
}
