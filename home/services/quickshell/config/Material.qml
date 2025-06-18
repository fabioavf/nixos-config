pragma Singleton

import QtQuick
import QtQuick.Controls.Material

QtObject {
    id: root

    readonly property Colors colors: Colors {}
    readonly property Typography typography: Typography {}
    readonly property Elevation elevation: Elevation {}
    readonly property Spacing spacing: Spacing {}
    readonly property Rounding rounding: Rounding {}
    readonly property Animation animation: Animation {}

    // Material 3 Dark Theme Colors
    component Colors: QtObject {
        // Surface colors
        readonly property string surface: "#111318"           // Bar background
        readonly property string surfaceContainer: "#1e2328"  // Widget backgrounds
        readonly property string surfaceContainerHigh: "#292d32" // Elevated widgets
        readonly property string surfaceVariant: "#42474e"    // Alternative surfaces
        
        // Text colors
        readonly property string surfaceText: "#e3e2e6"        // Primary text
        readonly property string surfaceVariantText: "#c2c7ce" // Secondary text
        readonly property string outline: "#8c9199"           // Borders
        readonly property string outlineVariant: "#42474e"   // Subtle borders
        
        // Primary accent colors
        readonly property string primary: "#a6c8ff"          // Accent
        readonly property string primaryText: "#003062"        // Accent text
        readonly property string primaryContainer: "#004a9c" // Accent container
        readonly property string primaryContainerText: "#d5e3ff" // Accent container text
        
        // Interactive states
        readonly property string hover: "#2a2f36"            // Hover overlay
        readonly property string pressed: "#363c44"          // Pressed state
        readonly property string focused: "#253549"          // Focus ring
        readonly property string selected: "#1f2937"        // Selection
        
        // Status colors (monochrome approach)
        readonly property string success: "#4ade80"         // Success green
        readonly property string warning: "#fbbf24"         // Warning amber
        readonly property string error: "#f87171"           // Error red
        readonly property string errorContainer: "#5f1a13"  // Error container
        readonly property string errorContainerText: "#fecdc8" // Error container text
        readonly property string info: "#60a5fa"            // Info blue
        
        // Transparent overlays
        readonly property string scrim: "#000000"           // Modal backdrop
        readonly property real scrimOpacity: 0.4
    }

    // Material 3 Typography Scale
    component Typography: QtObject {
        readonly property FontConfig displayLarge: FontConfig { size: 57; weight: Font.Normal; family: fontFamily }
        readonly property FontConfig displayMedium: FontConfig { size: 45; weight: Font.Normal; family: fontFamily }
        readonly property FontConfig displaySmall: FontConfig { size: 36; weight: Font.Normal; family: fontFamily }
        
        readonly property FontConfig headlineLarge: FontConfig { size: 32; weight: Font.Normal; family: fontFamily }
        readonly property FontConfig headlineMedium: FontConfig { size: 28; weight: Font.Normal; family: fontFamily }
        readonly property FontConfig headlineSmall: FontConfig { size: 24; weight: Font.Normal; family: fontFamily }
        
        readonly property FontConfig titleLarge: FontConfig { size: 22; weight: Font.Medium; family: fontFamily }
        readonly property FontConfig titleMedium: FontConfig { size: 16; weight: Font.Medium; family: fontFamily }
        readonly property FontConfig titleSmall: FontConfig { size: 14; weight: Font.Medium; family: fontFamily }
        
        readonly property FontConfig bodyLarge: FontConfig { size: 16; weight: Font.Normal; family: fontFamily }
        readonly property FontConfig bodyMedium: FontConfig { size: 14; weight: Font.Normal; family: fontFamily }
        readonly property FontConfig bodySmall: FontConfig { size: 12; weight: Font.Normal; family: fontFamily }
        
        readonly property FontConfig labelLarge: FontConfig { size: 14; weight: Font.Medium; family: fontFamily }
        readonly property FontConfig labelMedium: FontConfig { size: 12; weight: Font.Medium; family: fontFamily }
        readonly property FontConfig labelSmall: FontConfig { size: 11; weight: Font.Medium; family: fontFamily }
        
        readonly property string fontFamily: "Inter" // System default fallback
        readonly property string monoFamily: "JetBrains Mono NF"
        readonly property string iconFamily: "Material Symbols Rounded"
    }

    component FontConfig: QtObject {
        property int size: 14
        property int weight: Font.Normal
        property string family: "Inter"
    }

    // Material 3 Elevation System
    component Elevation: QtObject {
        readonly property int level0: 0   // Surface
        readonly property int level1: 1   // Bar background
        readonly property int level2: 3   // Widget cards
        readonly property int level3: 6   // Popovers
        readonly property int level4: 8   // Modals
        readonly property int level5: 12  // Navigation drawer
        
        readonly property string shadowColor: "#000000"
        readonly property real shadowOpacity: 0.3
    }

    // Material 3 Spacing (4dp base grid)
    component Spacing: QtObject {
        readonly property int xs: 4      // Extra small
        readonly property int sm: 8      // Small
        readonly property int md: 16     // Medium
        readonly property int lg: 24     // Large
        readonly property int xl: 32     // Extra large
        readonly property int xxl: 40    // Extra extra large
    }

    // Material 3 Corner Radius System
    component Rounding: QtObject {
        readonly property int none: 0
        readonly property int extraSmall: 4
        readonly property int small: 8
        readonly property int medium: 12
        readonly property int large: 16
        readonly property int extraLarge: 28
        readonly property int full: 1000
    }

    // Material 3 Motion System
    component Animation: QtObject {
        readonly property int durationShort1: 50    // 50ms
        readonly property int durationShort2: 100   // 100ms
        readonly property int durationShort3: 150   // 150ms
        readonly property int durationShort4: 200   // 200ms
        readonly property int durationMedium1: 250  // 250ms
        readonly property int durationMedium2: 300  // 300ms
        readonly property int durationMedium3: 350  // 350ms
        readonly property int durationMedium4: 400  // 400ms
        readonly property int durationLong1: 450    // 450ms
        readonly property int durationLong2: 500    // 500ms
        readonly property int durationLong3: 550    // 550ms
        readonly property int durationLong4: 600    // 600ms
        
        // Easing curves
        readonly property var emphasized: [0.2, 0.0, 0, 1.0]
        readonly property var emphasizedDecelerate: [0.05, 0.7, 0.1, 1.0]
        readonly property var emphasizedAccelerate: [0.3, 0.0, 0.8, 0.15]
        readonly property var standard: [0.2, 0.0, 0, 1.0]
        readonly property var standardDecelerate: [0, 0.0, 0, 1.0]
        readonly property var standardAccelerate: [0.3, 0.0, 1.0, 1.0]
    }
}