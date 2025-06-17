#!/run/current-system/sw/bin/bash
# Niri event handler that triggers bar updates

FIFO_PATH="/tmp/lumin-events"

# Create named pipe if it doesn't exist
if [[ ! -p "$FIFO_PATH" ]]; then
    mkfifo "$FIFO_PATH"
fi

# Start event stream and process events
/etc/profiles/per-user/fabio/bin/niri msg --json event-stream | while IFS= read -r line; do
    # Parse event type using simple string matching (no jq dependency)
    if [[ "$line" == *"WorkspacesChanged"* ]]; then
        echo "WorkspacesChanged" > "$FIFO_PATH"
    elif [[ "$line" == *"WorkspaceActivated"* ]]; then
        echo "WorkspaceActivated" > "$FIFO_PATH"
    elif [[ "$line" == *"WindowsChanged"* ]]; then
        echo "WindowsChanged" > "$FIFO_PATH"
    elif [[ "$line" == *"WindowFocusChanged"* ]]; then
        echo "WindowFocusChanged" > "$FIFO_PATH"
    fi
done &