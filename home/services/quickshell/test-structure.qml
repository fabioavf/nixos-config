pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root
    // Test if Process works in QtObject
    property var testProcess: Process {
        command: ["echo", "test"]
        running: false
    }
}
