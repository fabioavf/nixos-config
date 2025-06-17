import QtQuick
import Lumin.Config

Text {
    id: root
    
    // Material 3 text properties
    property var fontConfig: Material.typography.bodyMedium
    
    // Apply Material 3 typography
    font.family: fontConfig.family
    font.pixelSize: fontConfig.size
    font.weight: fontConfig.weight
    
    color: Material.colors.onSurface
    
    // Material 3 text rendering
    renderType: Text.NativeRendering
    textFormat: Text.PlainText
    wrapMode: Text.NoWrap
    elide: Text.ElideRight
    
    // Accessibility
    Accessible.role: Accessible.StaticText
    Accessible.name: text
}