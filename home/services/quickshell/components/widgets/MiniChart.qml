import QtQuick
import QtQuick.Shapes

// Beautiful Material 3 Mini Chart for system monitoring
Rectangle {
    id: root
    
    property var dataPoints: []
    property real maxValue: 100
    property color primaryColor: "#a6c8ff"
    property color backgroundColor: "transparent"
    property color gridColor: "#42474e"
    property bool showGrid: false
    property bool showFill: true
    property real lineWidth: 2
    property string label: ""
    
    width: 60
    height: 32
    color: backgroundColor
    radius: 4
    
    // Grid background (optional)
    Canvas {
        id: gridCanvas
        anchors.fill: parent
        visible: showGrid
        
        onPaint: {
            const ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.strokeStyle = gridColor
            ctx.lineWidth = 0.5
            ctx.globalAlpha = 0.3
            
            // Horizontal grid lines
            for (let i = 1; i < 4; i++) {
                const y = (height / 4) * i
                ctx.beginPath()
                ctx.moveTo(0, y)
                ctx.lineTo(width, y)
                ctx.stroke()
            }
            
            // Vertical grid lines
            for (let i = 1; i < 4; i++) {
                const x = (width / 4) * i
                ctx.beginPath()
                ctx.moveTo(x, 0)
                ctx.lineTo(x, height)
                ctx.stroke()
            }
        }
    }
    
    // Chart visualization using Shape
    Shape {
        id: chartShape
        anchors.fill: parent
        visible: dataPoints.length > 1
        
        // Filled area
        ShapePath {
            id: fillPath
            visible: showFill
            strokeColor: "transparent"
            fillColor: Qt.rgba(
                primaryColor.r, 
                primaryColor.g, 
                primaryColor.b, 
                0.2
            )
            
            startX: 0
            startY: parent.height
            
            PathLine { x: 0; y: parent.height - getYForValue(dataPoints[0] || 0) }
            
            Repeater {
                model: dataPoints.length > 1 ? dataPoints.slice(1) : []
                
                PathLine {
                    x: ((index + 1) / Math.max(1, dataPoints.length - 1)) * root.width
                    y: root.height - getYForValue(modelData || 0)
                }
            }
            
            PathLine { x: parent.width; y: parent.height }
            PathLine { x: 0; y: parent.height }
        }
        
        // Stroke line
        ShapePath {
            id: strokePath
            strokeColor: primaryColor
            strokeWidth: lineWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            
            startX: 0
            startY: parent.height - getYForValue(dataPoints[0] || 0)
            
            Repeater {
                model: dataPoints.length > 1 ? dataPoints.slice(1) : []
                
                PathLine {
                    x: ((index + 1) / Math.max(1, dataPoints.length - 1)) * root.width
                    y: root.height - getYForValue(modelData || 0)
                }
            }
        }
    }
    
    // Current value indicator dot
    Rectangle {
        id: currentDot
        width: 4
        height: 4
        radius: 2
        color: primaryColor
        visible: dataPoints.length > 0
        
        x: root.width - width
        y: root.height - getYForValue(dataPoints[dataPoints.length - 1] || 0) - height/2
        
        // Subtle glow effect
        Rectangle {
            anchors.centerIn: parent
            width: parent.width + 2
            height: parent.height + 2
            radius: width / 2
            color: parent.color
            opacity: 0.4
            z: -1
        }
        
        // Gentle pulsing animation
        SequentialAnimation on scale {
            running: true
            loops: Animation.Infinite
            NumberAnimation { to: 1.1; duration: 1000; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.0; duration: 1000; easing.type: Easing.InOutSine }
        }
    }
    
    // Label (optional)
    Text {
        anchors.bottom: parent.top
        anchors.bottomMargin: 2
        anchors.left: parent.left
        
        text: label
        font.pixelSize: 9
        font.family: "Inter"
        color: "#8c9199"
        visible: label.length > 0
    }
    
    // Helper function to convert value to Y coordinate
    function getYForValue(value) {
        const normalizedValue = Math.max(0, Math.min(maxValue, value))
        return (normalizedValue / maxValue) * height
    }
    
    // Smooth transitions when data changes
    Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
    
    // Animation when chart appears
    Component.onCompleted: {
        opacity = 0
        opacityAnimation.start()
    }
    
    NumberAnimation {
        id: opacityAnimation
        target: root
        property: "opacity"
        from: 0
        to: 1
        duration: 400
        easing.type: Easing.OutCubic
    }
}
