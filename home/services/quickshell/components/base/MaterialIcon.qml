import QtQuick
import Lumin.Config

MaterialText {
    id: root
    
    // Icon properties
    property string name: ""
    property int size: Material.spacing.lg
    property color iconColor: Material.colors.onSurface
    
    // Material Symbols font
    font.family: Material.typography.iconFamily
    font.pixelSize: size
    font.weight: Font.Normal
    
    text: name
    color: iconColor
    
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    
    // Icon accessibility
    Accessible.role: Accessible.Graphic
    Accessible.name: `${name} icon`
}