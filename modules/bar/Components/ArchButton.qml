import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "."
import qs.Services
import qs.Settings

Rectangle {
    id: archButton
    
    width: Settings.settings.barLogoSize || 24
    height: Settings.settings.barLogoSize || 24
    radius: 6
    color: archMouseArea.containsMouse ? "#333333" : "transparent"
    border.color: archMouseArea.containsMouse ? "#555555" : "transparent"
    border.width: archMouseArea.containsMouse ? 1 : 0
    
    // Power panel visibility
    property bool powerPanelVisible: false
    
    // Dynamic logo from LogoService
    Image {
        id: logoImage
        anchors.centerIn: parent
        width: Settings.settings.barLogoSize || 24
        height: Settings.settings.barLogoSize || 24
        source: LogoService.getLogoPath(LogoService.currentBarLogo)
        fillMode: Image.PreserveAspectFit
        smooth: false
        mipmap: true
        cache: true
        sourceSize.width: 64
        sourceSize.height: 64
        
        // Fallback to a generic icon if logo not found
        onStatusChanged: {
            if (status === Image.Error) {
                source = "image://icon/system-linux"
            }
        }
    }
    
    // Dynamic color overlay for the logo
    ColorOverlay {
        anchors.fill: logoImage
        source: logoImage
        color: LogoService.logoColor
    }
    
    // Mouse area for interactions
    MouseArea {
        id: archMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            console.log("ArchButton clicked! powerPanelVisible was:", powerPanelVisible)
            powerPanelVisible = !powerPanelVisible
            console.log("ArchButton clicked! powerPanelVisible is now:", powerPanelVisible)
        }
    }
    
    // Power Profile Panel
    PowerProfilePanel {
        id: powerPanel
        visible: powerPanelVisible
        
        // Close panel when it becomes invisible
        onVisibleChanged: {
            console.log("PowerProfilePanel visibility changed to:", visible)
            if (!visible) {
                powerPanelVisible = false
            }
        }
    }
    
    // Smooth animations like dock buttons
    Behavior on color {
        ColorAnimation {
            duration: 150
            easing.type: Easing.OutQuad
        }
    }
    
    Behavior on border.color {
        ColorAnimation {
            duration: 150
            easing.type: Easing.OutQuad
        }
    }
} 