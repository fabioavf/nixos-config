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
        console.log("Lumin: Initializing Niri IPC connection...");

        // Get socket path from environment
        getSocketPath.running = true;
    }

    // Process objects as properties
    property var getSocketPath: Process {
        command: ["sh", "-c", "echo $NIRI_SOCKET"]
        running: false

        stdout: StdioCollector {
            id: socketPathCollector
        }

        onExited: function (exitCode) {
            if (exitCode === 0) {
                const path = socketPathCollector.text.trim();
                if (path) {
                    root.socketPath = path;
                    console.log(`Lumin: Found Niri socket: ${path}`);
                    connectToSocket();
                } else {
                    console.error("Lumin: NIRI_SOCKET environment variable not set");
                    root.lastError = "NIRI_SOCKET not found";
                    // Try to find socket automatically
                    findSocketFallback.running = true;
                }
            } else {
                console.error(`Lumin: Failed to get NIRI_SOCKET, exit code: ${exitCode}`);
                findSocketFallback.running = true;
            }
        }
    }

    property var findSocketFallback: Process {
        command: ["sh", "-c", "find /run/user/$(id -u) -name '*niri*.sock' 2>/dev/null | head -1"]
        running: false

        stdout: StdioCollector {
            id: socketFallbackCollector
        }

        onExited: function (exitCode) {
            if (exitCode === 0) {
                const path = socketFallbackCollector.text.trim();
                if (path) {
                    root.socketPath = path;
                    console.log(`Lumin: Using fallback socket: ${path}`);
                    connectToSocket();
                } else {
                    console.error("Lumin: No niri socket found");
                    root.lastError = "No niri socket found";
                }
            } else {
                console.error("Lumin: Failed to find niri socket");
                root.lastError = "Socket search failed";
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
            root.socketConnected = connected;
            root.connected = connected;
            root.connectionStateUpdated(connected);

            if (connected) {
                if (pendingRequest === "EventStream") {
                    sendRequest("EventStream");
                    eventStreamActive = true;
                } else if (pendingRequest) {
                    sendRequest(pendingRequest);
                    pendingRequest = "";
                } else {
                    // Initial connection - start with workspace query
                    sendRequest("Workspaces");
                }
            } else {
                if (eventStreamActive) {
                    eventStreamActive = false;
                    reconnectTimer.start();
                } else {
                    // Query completed normally, continue with next queries
                    if (!initialQueriesDone) {
                        initialStateTimer.start();
                    }
                }
            }
        }

        onError: function (error) {
            console.error(`Lumin: Socket error: ${error}`);
            root.lastError = `Socket error: ${error}`;
        }

        parser: SplitParser {
            splitMarker: "\n"

            onRead: function (data) {
                const line = data.trim();
                if (line) {
                    try {
                        const response = JSON.parse(line);
                        root.handleResponse(response);
                    } catch (e) {
                        console.error(`Lumin: Failed to parse response: ${line}`);
                        console.error(`Lumin: Parse error: ${e}`);
                        root.lastError = `Parse error: ${e}`;
                    }
                }
            }
        }

        function sendRequest(request) {
            if (!connected) {
                return;
            }

            let jsonRequest;

            // Handle different request types properly
            if (typeof request === "string") {
                // Simple string requests like "Workspaces", "Windows", etc.
                // Send as JSON string (quoted string)
                jsonRequest = JSON.stringify(request);
            } else {
                // Complex requests (actions) - send as JSON object
                jsonRequest = JSON.stringify(request);
            }

            try {
                write(jsonRequest + "\n");
                flush();
            } catch (e) {
                console.error(`Lumin: Failed to send request: ${e}`);
                root.lastError = `Send error: ${e}`;
            }
        }
    }

    function executeRefreshQuery(query, command) {
        refreshProcess.targetQuery = query;
        refreshProcess.command = command;
        refreshProcess.running = true;
    }

    // Response handler (moved outside Socket for proper scoping)
    function handleResponse(response) {
        // Check if this is an event or a query response
        if (response.hasOwnProperty("WorkspacesChanged")) {
            // WorkspacesChanged event - refresh workspace data
            refreshTimer.addQuery("Workspaces");
        } else if (response.hasOwnProperty("WorkspaceActivated")) {
            // WorkspaceActivated event
            refreshTimer.addQuery("Workspaces");
        } else if (response.hasOwnProperty("WindowsChanged")) {
            // WindowsChanged event
            refreshTimer.addQuery("Windows");
        } else if (response.hasOwnProperty("WindowFocusChanged")) {
            // WindowFocusChanged event
            refreshTimer.addQuery("FocusedWindow");
        } else if (response.hasOwnProperty("WindowOpenedOrChanged")) {
            // WindowOpenedOrChanged event
            refreshTimer.addQuery("Windows");
        } else if (response.hasOwnProperty("WindowClosed")) {
            // WindowClosed event
            refreshTimer.addQuery("Windows");
        } else if (response.hasOwnProperty("WorkspaceActiveWindowChanged")) {
            // WorkspaceActiveWindowChanged event
            refreshTimer.addQuery("Workspaces");
        } else if (response.hasOwnProperty("Ok")) {
            // Handle successful query responses
            const data = response.Ok;

            // Check if this is a nested response (e.g., {"Ok": {"Workspaces": [...]}})
            if (data.hasOwnProperty("Workspaces")) {
                root.workspaces = data.Workspaces;
                root.workspacesUpdated(data.Workspaces);
            } else if (data.hasOwnProperty("Windows")) {
                root.windows = data.Windows;
                root.windowsUpdated(data.Windows);
            } else if (data.hasOwnProperty("Outputs")) {
                root.outputs = data.Outputs;
                root.outputsUpdated(data.Outputs);
            } else if (data.hasOwnProperty("FocusedWindow")) {
                if (data.FocusedWindow) {
                    // Received focused window
                    root.focusedWindow = data.FocusedWindow;
                    root.focusedWindowUpdated(data.FocusedWindow);
                } else {
                    // No focused window
                    root.focusedWindow = null;
                    root.focusedWindowUpdated(null);
                }
            } else if (data === null) {
                // Null response (e.g., no focused window)
                // Received null response
                root.focusedWindow = null;
                root.focusedWindowUpdated(null);
            } else if (Array.isArray(data)) {
                if (data.length === 0) {
                    console.log("Lumin: Received empty array response");
                } else {
                    // Determine data type by examining first item
                    const firstItem = data[0];
                    if (firstItem.hasOwnProperty("id") && firstItem.hasOwnProperty("is_active")) {
                        // Workspace data
                        // Received workspaces data
                        root.workspaces = data;
                        root.workspacesUpdated(data);
                    } else if (firstItem.hasOwnProperty("id") && firstItem.hasOwnProperty("title")) {
                        // Window data
                        // Received windows data
                        root.windows = data;
                        root.windowsUpdated(data);
                    } else if (firstItem.hasOwnProperty("name") && (firstItem.hasOwnProperty("make") || firstItem.hasOwnProperty("logical"))) {
                        // Output data
                        // Received outputs data
                        root.outputs = data;
                        root.outputsUpdated(data);
                    } else {
                        console.log(`Lumin: Unknown array data type: ${JSON.stringify(firstItem)}`);
                    }
                }
            } else if (typeof data === "object" && data.hasOwnProperty("title")) {
                // Single window (focused window)
                // Received focused window
                root.focusedWindow = data;
                root.focusedWindowUpdated(data);
            } else
            // Unknown response data
            {}
        } else if (response.hasOwnProperty("Err")) {
            console.error(`Lumin: Niri error response: ${JSON.stringify(response.Err)}`);
            root.lastError = `Niri error: ${JSON.stringify(response.Err)}`;
        } else
        // Unknown response type
        {}
    }

    // Timers for connection management
    property var initialStateTimer: Timer {
        id: initialStateTimer

        property int step: 0

        interval: 500  // Give time between queries
        repeat: false

        onTriggered: {
            // Initial state step progression
            switch (step) {
            case 0:
                // Query windows
                queryNiri("Windows");
                step++;
                interval = 500;
                start();
                break;
            case 1:
                // Query focused window
                queryNiri("FocusedWindow");
                step++;
                interval = 500;
                start();
                break;
            case 2:
                // Start event stream for real-time updates
                // Starting event stream
                startEventStream();
                niriSocket.initialQueriesDone = true;
                step = 0;  // Reset for next time
                break;
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
                // Attempting reconnection
                connectToSocket();
            }
        }
    }

    function connectToSocket() {
        if (root.socketPath) {
            // Connecting to socket
            // Reset state before connecting
            niriSocket.eventStreamActive = false;
            // Set connected to true to initiate connection
            niriSocket.connected = true;
        } else {
            console.error("Lumin: No socket path available for connection");
            root.lastError = "No socket path available";
        }
    }

    function queryNiri(requestType) {
        // Querying niri
        if (root.socketPath) {
            // Create a new connection for each query (niri closes after each response)
            niriSocket.pendingRequest = requestType;
            niriSocket.connected = false;  // Disconnect first

            // Use timer to reconnect and send request
            queryTimer.targetRequest = requestType;
            queryTimer.start();
        }
    }

    function startEventStream() {
        // Starting event stream
        if (root.socketPath) {
            niriSocket.pendingRequest = "EventStream";
            niriSocket.connected = false;  // Disconnect first

            // Use timer to reconnect for event stream
            eventStreamTimer.start();
        }
    }

    property var queryTimer: Timer {
        interval: 100
        repeat: false
        property string targetRequest: ""

        onTriggered: {
            if (targetRequest && root.socketPath) {
                // Reconnecting for query
                niriSocket.pendingRequest = targetRequest;
                niriSocket.connected = true;
            }
        }
    }

    property var eventStreamTimer: Timer {
        id: eventStreamTimer
        interval: 100
        repeat: false

        onTriggered: {
            if (root.socketPath) {
                // Reconnecting for event stream
                niriSocket.pendingRequest = "EventStream";
                niriSocket.connected = true;
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
                const query = pendingQueries.shift();  // Remove first item
                // Processing queued refresh

                let command;
                if (query === "FocusedWindow") {
                    command = ["niri", "msg", "--json", "focused-window"];
                } else {
                    command = ["niri", "msg", "--json", query.toLowerCase()];
                }

                executeRefreshQuery(query, command);
            }
        }

        function addQuery(query) {
            // Add to pending queries if not already present
            if (pendingQueries.indexOf(query) === -1) {
                pendingQueries.push(query);
                // Added query to batch
            }

            // Start/restart timer
            targetQuery = query;  // Keep last query for compatibility
            restart();
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

        onExited: function (exitCode) {
            // Refresh process completed
            if (exitCode === 0 && targetQuery) {
                try {
                    const rawText = refreshCollector.text.trim();
                    // Raw refresh response received
                    const rawResponse = JSON.parse(rawText);
                    // Refresh query completed

                    // Convert raw response to socket format for consistent handling
                    let response;
                    if (targetQuery === "Workspaces") {
                        response = {
                            "Ok": {
                                "Workspaces": rawResponse
                            }
                        };
                    } else if (targetQuery === "Windows") {
                        response = {
                            "Ok": {
                                "Windows": rawResponse
                            }
                        };
                    } else if (targetQuery === "FocusedWindow") {
                        response = {
                            "Ok": {
                                "FocusedWindow": rawResponse
                            }
                        };
                    } else {
                        response = {
                            "Ok": rawResponse
                        };
                    }

                    handleResponse(response);
                } catch (e) {
                    console.error(`Lumin: Failed to parse refresh response: ${e}`);
                    console.error(`Lumin: Raw text was: "${refreshCollector.text}"`);
                }
            }
            targetQuery = "";

            // Process next query in queue if any
            if (refreshTimer.pendingQueries.length > 0) {
                // Processing next query
                refreshTimer.start();
            }
        }
    }

    // Process for executing niri actions
    property var actionProcess: Process {
        command: ["echo", ""]  // Default empty command
        running: false

        stdout: StdioCollector {
            id: actionCollector
        }

        stderr: StdioCollector {
            id: actionErrorCollector
        }

        onExited: function (exitCode) {
            if (exitCode === 0) {
                console.log("Lumin: Action executed successfully");
                // Trigger a workspace refresh to update UI
                refreshTimer.addQuery("Workspaces");
            } else {
                console.error(`Lumin: Action failed with exit code: ${exitCode}`);
                const errorOutput = actionErrorCollector.text.trim();
                if (errorOutput) {
                    console.error(`Lumin: Action error: ${errorOutput}`);
                }
            }
        }
    }

    // Action functions for controlling Niri
    function switchToWorkspace(workspaceId) {
        console.log(`Lumin: switchToWorkspace called with ID: ${workspaceId}`);
        
        // Find the workspace object to get its idx (Niri expects idx, not id)
        const workspace = workspaces.find(ws => ws.id === workspaceId);
        if (workspace) {
            console.log(`Lumin: Switching to workspace idx: ${workspace.idx} (id: ${workspace.id})`);
            
            // Use niri msg command with idx instead of id
            const action = ["niri", "msg", "action", "focus-workspace", workspace.idx.toString()];
            actionProcess.command = action;
            actionProcess.running = true;
            
            console.log(`Lumin: Executing command: ${action.join(" ")}`);
        } else {
            console.error(`Lumin: Workspace with ID ${workspaceId} not found`);
        }
    }

    function moveToWorkspace(workspaceId) {
        console.log(`Lumin: moveToWorkspace called with ID: ${workspaceId}`);
        
        // Find the workspace object to get its idx (Niri expects idx, not id)
        const workspace = workspaces.find(ws => ws.id === workspaceId);
        if (workspace) {
            console.log(`Lumin: Moving window to workspace idx: ${workspace.idx} (id: ${workspace.id})`);
            const action = ["niri", "msg", "action", "move-window-to-workspace", workspace.idx.toString()];
            actionProcess.command = action;
            actionProcess.running = true;
        } else {
            console.error(`Lumin: Workspace with ID ${workspaceId} not found`);
        }
    }

    function closeWindow() {
        console.log("Lumin: closeWindow called");
        const action = ["niri", "msg", "action", "close-window"];
        actionProcess.command = action;
        actionProcess.running = true;
    }

    function focusWindow(windowId) {
        console.log(`Lumin: focusWindow called with ID: ${windowId}`);
        const action = ["niri", "msg", "action", "focus-window", "--id", windowId.toString()];
        actionProcess.command = action;
        actionProcess.running = true;
    }

    // Utility functions
    function getWorkspaceById(id) {
        return workspaces.find(ws => ws.id === id) || null;
    }

    function getWindowById(id) {
        return windows.find(win => win.id === id) || null;
    }

    function getOutputByName(name) {
        return outputs.find(output => output.name === name) || null;
    }

    function getActiveWorkspace() {
        return workspaces.find(ws => ws.is_active) || null;
    }

    function getVisibleWorkspaces() {
        return workspaces.filter(ws => ws.is_visible) || [];
    }

    // Refresh functions for manual state updates
    function refreshWorkspaces() {
        if (niriSocket.connected) {
            niriSocket.sendRequest("Workspaces");
        }
    }

    function refreshWindows() {
        if (niriSocket.connected) {
            niriSocket.sendRequest("Windows");
        }
    }

    function refreshAll() {
        if (niriSocket.connected) {
            niriSocket.sendRequest("Workspaces");
            niriSocket.sendRequest("Windows");
            niriSocket.sendRequest("FocusedWindow");
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
