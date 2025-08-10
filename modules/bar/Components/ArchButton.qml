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
    radius: (Settings.settings.barLogoSize || 24) / 2
    color: archMouseArea.containsMouse ? "#333333" : "transparent"
    border.color: archMouseArea.containsMouse ? "#555555" : "transparent"
    border.width: archMouseArea.containsMouse ? 1 : 0
    
    // Dynamic logo from LogoService
    Image {
        id: dockLogoImage
        anchors.centerIn: parent
        width: (Settings.settings.barLogoSize || 24)
        height: (Settings.settings.barLogoSize || 24)
        source: LogoService.getLogoPath(LogoService.currentBarLogo)
        fillMode: Image.PreserveAspectFit
        smooth: false
        mipmap: true
        cache: true
        sourceSize.width: 64
        sourceSize.height: 64
        
        // Fallback to a generic system icon if logo not found
        onStatusChanged: {
            if (status === Image.Error) {
                source = IconService ? IconService.getIconPath("system-linux") : "image://icon/system-linux"
            }
        }
    }
    
    // Dynamic color overlay for the logo
    ColorOverlay {
        anchors.fill: dockLogoImage
        source: dockLogoImage
        color: LogoService.logoColor
    }
    
    MouseArea {
        id: archMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            archButton.isHovered = true
        }
        onExited: {
            archButton.isHovered = false
        }
        onClicked: {
            // Open power settings tab
            SettingsManager.openSettingsTab(3)  // Power tab index
        }
    }
    
    // Smooth scale animation like other dock icons
    property bool isHovered: false
    
    onIsHoveredChanged: {
        if (isHovered) {
            scale = 1.1
        } else {
            scale = 1.0
        }
    }
    
    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutQuad
        }
    }
    
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