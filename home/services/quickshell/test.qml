import QtQuick; import Quickshell.Io; Item { Process { id: test; command: ["echo"]; running: false; stdout: StdioCollector {} } }
