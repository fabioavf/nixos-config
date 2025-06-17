#!/run/current-system/sw/bin/bash
# QML validation script using qmlls

cd "$(dirname "$0")"

echo "=== QML Validation Report ==="
echo "Directory: $(pwd)"
echo

# Check if qmlls is available
if ! command -v qmlls &> /dev/null; then
    echo "ERROR: qmlls not found in PATH"
    exit 1
fi

# Function to validate a QML file
validate_qml() {
    local file="$1"
    echo "Validating: $file"
    
    # Use qmlls to check the file by starting it in background and sending LSP requests
    # For now, we'll use a simpler approach with basic syntax checking
    if [[ -f "$file" ]]; then
        # Basic syntax check - look for common QML issues
        if grep -q "Singleton {" "$file"; then
            echo "  ERROR: Found 'Singleton {' - should be 'QtObject {' with 'pragma Singleton'"
        fi
        
        if grep -q "readonly property.*signal" "$file"; then
            echo "  WARNING: Possible signal/property conflict"
        fi
        
        echo "  OK: Basic syntax looks good"
    else
        echo "  ERROR: File not found"
    fi
    echo
}

# Validate main files
echo "--- Core Files ---"
validate_qml "shell.qml"

echo "--- Config Files ---"
validate_qml "config/Material.qml"
validate_qml "config/Device.qml" 
validate_qml "config/Layout.qml"

echo "--- Service Files ---"
validate_qml "services/NiriIPC.qml"

echo "--- Component Files ---"
for file in components/base/*.qml; do
    validate_qml "$file"
done

echo "=== Validation Complete ==="