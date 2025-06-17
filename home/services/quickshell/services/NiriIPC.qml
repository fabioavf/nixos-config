pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    // State properties
    property var workspaces: []
    property var windows: []
    property var outputs: []
    property var focusedWindow: null
    property bool connected: false
    property string lastError: ""

    // Socket properties
    property string socketPath: ""
    property bool socketConnected: false

    // Signals for real-time updates
    signal workspacesUpdated(var workspaces)
    signal windowsUpdated(var windows) 
    signal outputsUpdated(var outputs)
    signal focusedWindowUpdated(var window)
    signal connectionStateUpdated(bool connected)

    // Component.onCompleted handler
    Component.onCompleted: {
        console.log("Lumin: Initializing Niri socket IPC connection...")
        console.log("Lumin: Current environment check...")
        
        // Get socket path from environment
        getSocketPath.running = true
    }

    // Process objects as properties
    property var getSocketPath: Process {
        command: ["sh", "-c", "echo $NIRI_SOCKET"]
        running: false

        stdout: StdioCollector {
            id: socketPathCollector
        }

        onExited: function(exitCode) {
            console.log(`Lumin: getSocketPath exited with code: ${exitCode}`)
            console.log(`Lumin: Raw output: "${socketPathCollector.text}"`)
            
            if (exitCode === 0) {
                const path = socketPathCollector.text.trim()
                console.log(`Lumin: Trimmed path: "${path}"`)
                if (path) {
                    root.socketPath = path
                    console.log(`Lumin: Found Niri socket: ${path}`)
                    connectToSocket()
                } else {
                    console.error("Lumin: NIRI_SOCKET environment variable not set")
                    root.lastError = "NIRI_SOCKET not found"
                    // Try to find socket automatically
                    findSocketFallback.running = true
                }
            } else {
                console.error(`Lumin: Failed to get NIRI_SOCKET, exit code: ${exitCode}`)
                findSocketFallback.running = true
            }
        }
    }

    property var findSocketFallback: Process {
        command: ["sh", "-c", "find /run/user/$(id -u) -name '*niri*.sock' 2>/dev/null | head -1"]
        running: false

        stdout: StdioCollector {
            id: socketFallbackCollector
        }

        onExited: function(exitCode) {
            console.log(`Lumin: Socket fallback search exited with code: ${exitCode}`)
            if (exitCode === 0) {
                const path = socketFallbackCollector.text.trim()
                console.log(`Lumin: Fallback found socket: "${path}"`)
                if (path) {
                    root.socketPath = path
                    console.log(`Lumin: Using fallback socket: ${path}`)
                    connectToSocket()
                } else {
                    console.error("Lumin: No niri socket found in /run/user/$(id -u)")
                    root.lastError = "No niri socket found"
                }
            } else {
                console.error("Lumin: Failed to find niri socket")
                root.lastError = "Socket search failed"
            }
        }
    }

    // Main Niri socket connection
    property var niriSocket: Socket {
        id: niriSocket
        path: root.socketPath
        connected: false

        property bool eventStreamActive: false
        property bool initializing: false
        property string pendingRequest: ""
        property bool initialQueriesDone: false

        onConnectedChanged: {
            root.socketConnected = connected
            root.connected = connected
            root.connectionStateUpdated(connected)
            
            if (connected) {
                console.log("Lumin: Connected to Niri socket")
                
                if (pendingRequest === "EventStream") {
                    console.log("Lumin: Starting event stream (persistent connection)...")
                    sendRequest("EventStream")
                    eventStreamActive = true
                } else if (pendingRequest) {
                    console.log(`Lumin: Sending single query: ${pendingRequest}`)
                    sendRequest(pendingRequest)
                    pendingRequest = ""
                } else {
                    // Initial connection - start with workspace query
                    console.log("Lumin: Initial connection - querying workspaces")
                    sendRequest("Workspaces")
                }
            } else {
                console.log("Lumin: Disconnected from Niri socket")
                
                if (eventStreamActive) {
                    console.log("Lumin: Event stream disconnected, will reconnect...")
                    eventStreamActive = false
                    reconnectTimer.start()
                } else {
                    console.log("Lumin: Query completed, will start additional queries")
                    // Query completed normally, continue with next queries
                    if (!initialQueriesDone) {
                        initialStateTimer.start()
                    }
                }
            }
        }

        onError: function(error) {
            console.error(`Lumin: Socket error: ${error}`)
            root.lastError = `Socket error: ${error}`
        }

        parser: SplitParser {
            splitMarker: "\n"
            
            onRead: function(data) {
                const line = data.trim()
                if (line) {
                    try {
                        const response = JSON.parse(line)
                        root.handleResponse(response)
                    } catch (e) {
                        console.error(`Lumin: Failed to parse response: ${line}`)
                        console.error(`Lumin: Parse error: ${e}`)
                        root.lastError = `Parse error: ${e}`
                    }
                }
            }
        }

        function sendRequest(request) {
            if (!connected) {
                console.warn(`Lumin: Cannot send request - socket not connected`)
                return
            }

            let jsonRequest
            
            // Handle different request types properly
            if (typeof request === "string") {
                // Simple string requests like "Workspaces", "Windows", etc.
                // Send as JSON string (quoted string)
                jsonRequest = JSON.stringify(request)
            } else {
                // Complex requests (actions) - send as JSON object
                jsonRequest = JSON.stringify(request)
            }

            console.log(`Lumin: Sending request: ${jsonRequest}`)
            
            try {
                write(jsonRequest + "\n")
                flush()
            } catch (e) {
                console.error(`Lumin: Failed to send request: ${e}`)
                root.lastError = `Send error: ${e}`
            }
        }
    }

    function executeRefreshQuery(query, command) {
        refreshProcess.targetQuery = query
        refreshProcess.command = command
        refreshProcess.running = true
    }

    // Response handler (moved outside Socket for proper scoping)
    function handleResponse(response) {
        // Check if this is an event or a query response
        if (response.hasOwnProperty("WorkspacesChanged")) {
            console.log("Lumin: WorkspacesChanged event received - refreshing workspace data")
            refreshTimer.addQuery("Workspaces")
        } else if (response.hasOwnProperty("WorkspaceActivated")) {
            console.log(`Lumin: WorkspaceActivated event: ${JSON.stringify(response.WorkspaceActivated)}`)
            refreshTimer.addQuery("Workspaces")
        } else if (response.hasOwnProperty("WindowsChanged")) {
            console.log("Lumin: WindowsChanged event received - refreshing window data")
            refreshTimer.addQuery("Windows")
        } else if (response.hasOwnProperty("WindowFocusChanged")) {
            console.log("Lumin: WindowFocusChanged event received - refreshing focus data")
            refreshTimer.addQuery("FocusedWindow")
        } else if (response.hasOwnProperty("WindowOpenedOrChanged")) {
            console.log("Lumin: WindowOpenedOrChanged event received - refreshing window data")
            refreshTimer.addQuery("Windows")
        } else if (response.hasOwnProperty("WindowClosed")) {
            console.log("Lumin: WindowClosed event received - refreshing window data")
            refreshTimer.addQuery("Windows")
        } else if (response.hasOwnProperty("WorkspaceActiveWindowChanged")) {
            console.log("Lumin: WorkspaceActiveWindowChanged event received - refreshing workspace data")
            refreshTimer.addQuery("Workspaces")
        } else if (response.hasOwnProperty("Ok")) {
            // Handle successful query responses
            const data = response.Ok
            
            // Check if this is a nested response (e.g., {"Ok": {"Workspaces": [...]}})
            if (data.hasOwnProperty("Workspaces")) {
                console.log(`Lumin: Received ${data.Workspaces.length} workspaces`)
                root.workspaces = data.Workspaces
                root.workspacesUpdated(data.Workspaces)
            } else if (data.hasOwnProperty("Windows")) {
                console.log(`Lumin: Received ${data.Windows.length} windows`)
                root.windows = data.Windows
                root.windowsUpdated(data.Windows)
            } else if (data.hasOwnProperty("Outputs")) {
                console.log(`Lumin: Received ${data.Outputs.length} outputs`)
                root.outputs = data.Outputs
                root.outputsUpdated(data.Outputs)
            } else if (data.hasOwnProperty("FocusedWindow")) {
                if (data.FocusedWindow) {
                    console.log(`Lumin: Received focused window: ${data.FocusedWindow.title}`)
                    root.focusedWindow = data.FocusedWindow
                    root.focusedWindowUpdated(data.FocusedWindow)
                } else {
                    console.log("Lumin: No focused window")
                    root.focusedWindow = null
                    root.focusedWindowUpdated(null)
                }
            } else if (data === null) {
                // Null response (e.g., no focused window)
                console.log("Lumin: Received null response (probably no focused window)")
                root.focusedWindow = null
                root.focusedWindowUpdated(null)
            } else if (Array.isArray(data)) {
                if (data.length === 0) {
                    console.log("Lumin: Received empty array response")
                } else {
                    // Determine data type by examining first item
                    const firstItem = data[0]
                    if (firstItem.hasOwnProperty("id") && firstItem.hasOwnProperty("is_active")) {
                        // Workspace data
                        console.log(`Lumin: Received ${data.length} workspaces`)
                        root.workspaces = data
                        root.workspacesUpdated(data)
                    } else if (firstItem.hasOwnProperty("id") && firstItem.hasOwnProperty("title")) {
                        // Window data
                        console.log(`Lumin: Received ${data.length} windows`)
                        root.windows = data
                        root.windowsUpdated(data)
                    } else if (firstItem.hasOwnProperty("name") && (firstItem.hasOwnProperty("make") || firstItem.hasOwnProperty("logical"))) {
                        // Output data
                        console.log(`Lumin: Received ${data.length} outputs`)
                        root.outputs = data
                        root.outputsUpdated(data)
                    } else {
                        console.log(`Lumin: Unknown array data type: ${JSON.stringify(firstItem)}`)
                    }
                }
            } else if (typeof data === "object" && data.hasOwnProperty("title")) {
                // Single window (focused window)
                console.log(`Lumin: Received focused window: ${data.title}`)
                root.focusedWindow = data
                root.focusedWindowUpdated(data)
            } else {
                console.log(`Lumin: Unknown response data: ${JSON.stringify(data)}`)
            }
        } else if (response.hasOwnProperty("Err")) {
            console.error(`Lumin: Niri error response: ${JSON.stringify(response.Err)}`)
            root.lastError = `Niri error: ${JSON.stringify(response.Err)}`
        } else {
            console.log(`Lumin: Unknown response type: ${JSON.stringify(response)}`)
        }
    }

    // Timers for connection management
    property var initialStateTimer: Timer {
        id: initialStateTimer
        
        property int step: 0
        
        interval: 500  // Give time between queries
        repeat: false
        
        onTriggered: {
            console.log(`Lumin: Initial state step ${step}`)
            switch(step) {
                case 0:
                    // Query windows
                    queryNiri("Windows")
                    step++
                    interval = 500
                    start()
                    break
                case 1:
                    // Query focused window
                    queryNiri("FocusedWindow")
                    step++
                    interval = 500
                    start()
                    break
                case 2:
                    // Start event stream for real-time updates
                    console.log("Lumin: Starting event stream for real-time updates...")
                    startEventStream()
                    niriSocket.initialQueriesDone = true
                    step = 0  // Reset for next time
                    break
            }
        }
    }

    // Auto-reconnection timer
    property var reconnectTimer: Timer {
        id: reconnectTimer
        interval: 5000  // Longer interval to reduce spam
        repeat: false
        onTriggered: {
            if (root.socketPath && !root.socketConnected) {
                console.log("Lumin: Attempting to reconnect to Niri socket...")
                connectToSocket()
            }
        }
    }

    function connectToSocket() {
        if (root.socketPath) {
            console.log(`Lumin: Connecting to socket: ${root.socketPath}`)
            // Reset state before connecting
            niriSocket.eventStreamActive = false
            // Set connected to true to initiate connection
            niriSocket.connected = true
        } else {
            console.error("Lumin: No socket path available for connection")
            root.lastError = "No socket path available"
        }
    }

    function queryNiri(requestType) {
        console.log(`Lumin: Querying niri for: ${requestType}`)
        if (root.socketPath) {
            // Create a new connection for each query (niri closes after each response)
            niriSocket.pendingRequest = requestType
            niriSocket.connected = false  // Disconnect first
            
            // Use timer to reconnect and send request
            queryTimer.targetRequest = requestType
            queryTimer.start()
        }
    }

    function startEventStream() {
        console.log("Lumin: Starting persistent event stream connection...")
        if (root.socketPath) {
            niriSocket.pendingRequest = "EventStream"
            niriSocket.connected = false  // Disconnect first
            
            // Use timer to reconnect for event stream
            eventStreamTimer.start()
        }
    }

    property var queryTimer: Timer {
        interval: 100
        repeat: false
        property string targetRequest: ""
        
        onTriggered: {
            if (targetRequest && root.socketPath) {
                console.log(`Lumin: Reconnecting for query: ${targetRequest}`)
                niriSocket.pendingRequest = targetRequest
                niriSocket.connected = true
            }
        }
    }

    property var eventStreamTimer: Timer {
        id: eventStreamTimer
        interval: 100
        repeat: false
        
        onTriggered: {
            if (root.socketPath) {
                console.log("Lumin: Reconnecting for event stream...")
                niriSocket.pendingRequest = "EventStream"
                niriSocket.connected = true
            }
        }
    }

    // Separate timer for refreshing data without disrupting event stream
    property var refreshTimer: Timer {
        interval: 300  // Slightly longer delay to batch multiple events
        repeat: false
        property string targetQuery: ""
        property var pendingQueries: []
        
        onTriggered: {
            // Process first pending query
            if (pendingQueries.length > 0) {
                const query = pendingQueries.shift()  // Remove first item
                console.log(`Lumin: Processing queued refresh: ${query} (${pendingQueries.length} remaining)`)
                
                let command
                if (query === "FocusedWindow") {
                    command = ["niri", "msg", "--json", "focused-window"]
                } else {
                    command = ["niri", "msg", "--json", query.toLowerCase()]
                }
                
                executeRefreshQuery(query, command)
            }
        }
        
        function addQuery(query) {
            // Add to pending queries if not already present
            if (pendingQueries.indexOf(query) === -1) {
                pendingQueries.push(query)
                console.log(`Lumin: Added ${query} to refresh batch`)
            }
            
            // Start/restart timer
            targetQuery = query  // Keep last query for compatibility
            restart()
        }
    }

    // Separate process for refresh queries to avoid disrupting event stream
    property var refreshProcess: Process {
        property string targetQuery: ""
        command: ["echo", ""]  // Default empty command
        running: false

        stdout: StdioCollector {
            id: refreshCollector
        }

        onExited: function(exitCode) {
            console.log(`Lumin: Refresh process exited with code ${exitCode} for query: ${targetQuery}`)
            if (exitCode === 0 && targetQuery) {
                try {
                    const rawText = refreshCollector.text.trim()
                    console.log(`Lumin: Raw refresh response: ${rawText}`)
                    const rawResponse = JSON.parse(rawText)
                    console.log(`Lumin: Refresh query ${targetQuery} completed`)
                    
                    // Convert raw response to socket format for consistent handling
                    let response
                    if (targetQuery === "Workspaces") {
                        response = {"Ok": {"Workspaces": rawResponse}}
                    } else if (targetQuery === "Windows") {
                        response = {"Ok": {"Windows": rawResponse}}
                    } else if (targetQuery === "FocusedWindow") {
                        response = {"Ok": {"FocusedWindow": rawResponse}}
                    } else {
                        response = {"Ok": rawResponse}
                    }
                    
                    handleResponse(response)
                } catch (e) {
                    console.error(`Lumin: Failed to parse refresh response: ${e}`)
                    console.error(`Lumin: Raw text was: "${refreshCollector.text}"`)
                }
            }
            targetQuery = ""
            
            // Process next query in queue if any
            if (refreshTimer.pendingQueries.length > 0) {
                console.log(`Lumin: Processing next query in queue (${refreshTimer.pendingQueries.length} remaining)`)
                refreshTimer.start()
            }
        }
    }

    // Action functions for controlling Niri
    function switchToWorkspace(workspaceId) {
        console.log(`Lumin: Switching to workspace ${workspaceId}`)
        const action = {
            "Action": {
                "FocusWorkspace": {
                    "reference": {
                        "Id": workspaceId
                    }
                }
            }
        }
        niriSocket.sendRequest(action)
    }

    function moveToWorkspace(workspaceId) {
        console.log(`Lumin: Moving window to workspace ${workspaceId}`)
        const action = {
            "Action": {
                "MoveWindowToWorkspace": {
                    "reference": {
                        "Id": workspaceId
                    }
                }
            }
        }
        niriSocket.sendRequest(action)
    }

    function closeWindow() {
        console.log("Lumin: Closing focused window")
        const action = {
            "Action": "CloseWindow"
        }
        niriSocket.sendRequest(action)
    }

    function focusWindow(windowId) {
        console.log(`Lumin: Focusing window ${windowId}`)
        const action = {
            "Action": {
                "FocusWindow": {
                    "id": windowId
                }
            }
        }
        niriSocket.sendRequest(action)
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

    // Refresh functions for manual state updates
    function refreshWorkspaces() {
        if (niriSocket.connected) {
            niriSocket.sendRequest("Workspaces")
        }
    }

    function refreshWindows() {
        if (niriSocket.connected) {
            niriSocket.sendRequest("Windows")
        }
    }

    function refreshAll() {
        if (niriSocket.connected) {
            niriSocket.sendRequest("Workspaces")
            niriSocket.sendRequest("Windows")
            niriSocket.sendRequest("FocusedWindow")
        }
    }

    // Debug information
    readonly property var debugInfo: ({
        connected: connected,
        socketConnected: socketConnected,
        socketPath: socketPath,
        lastError: lastError,
        workspaceCount: workspaces.length,
        windowCount: windows.length,
        outputCount: outputs.length,
        hasFocusedWindow: focusedWindow !== null,
        focusedWindowTitle: focusedWindow?.title || "none",
        eventStreamActive: niriSocket.eventStreamActive,
        initializing: niriSocket.initializing
    })
}