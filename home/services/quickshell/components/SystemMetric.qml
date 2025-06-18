import QtQuick
import Quickshell
import "../config" as Config

Rectangle {
    id: systemMetric
    property string label: ""
    property real value: 0
    property real maxValue: 100
    property string unit: ""
    property color metricColor: Config.Material.colors.primary
    property bool isActive: false
    property bool isDiskIndicator: false
    property bool hasError: false
    
    width: Config.Device.config.systemCardWidth || 52
    height: Config.Device.config.workspaceSize
    radius: Config.Material.rounding.medium
    
    color: Config.Material.colors.surfaceContainer
    border.width: (isActive || hasError) ? 1 : 0
    border.color: hasError ? Config.Material.colors.error : (isActive ? metricColor : "transparent")
    
    Rectangle {
        anchors.centerIn: parent
        width: parent.width + 2
        height: parent.height + 2
        radius: parent.radius + 1
        color: Config.Material.elevation.shadowColor
        opacity: Config.Material.elevation.shadowOpacity * 0.5
        z: -1
    }
    
    Row {
        anchors.centerIn: parent
        spacing: Config.Material.spacing.sm
        
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: label
            color: metricColor
            font.pixelSize: Config.Device.config.iconSize || 12
            font.family: Config.Material.typography.monoFamily
        }
        
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: hasError ? "!" : (isDiskIndicator ? 
                value.toFixed(0) + unit : 
                value.toFixed(0) + unit)
            color: hasError ? Config.Material.colors.error : Config.Material.colors.surfaceText
            font.pixelSize: Config.Material.typography.labelSmall.size
            font.family: Config.Material.typography.fontFamily
            font.weight: Config.Material.typography.labelSmall.weight
        }
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: {
            parent.scale = 1.05
            parent.color = Config.Material.colors.surfaceContainerHigh
        }
        
        onExited: {
            parent.scale = 1.0
            parent.color = Config.Material.colors.surfaceContainer
        }
    }
    
    Behavior on scale {
        NumberAnimation { 
            duration: Config.Material.animation.durationShort3
            easing.type: Easing.OutCubic 
        }
    }
    
    Behavior on color {
        ColorAnimation { 
            duration: Config.Material.animation.durationShort4
            easing.type: Easing.OutCubic 
        }
    }
}