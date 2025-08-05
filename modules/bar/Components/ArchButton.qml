import QtQuick
import QtQuick.Layouts
import "."

Rectangle {
    id: archButton
    
    width: 32
    height: 32
    radius: 6
    color: archMouseArea.containsMouse ? "#333333" : "transparent"
    border.color: archMouseArea.containsMouse ? "#555555" : "transparent"
    border.width: archMouseArea.containsMouse ? 1 : 0
    
    // Power panel visibility
    property bool powerPanelVisible: false
    
    // Arch Linux icon (white version)
    Image {
        anchors.centerIn: parent
        width: 20
        height: 20
        source: Qt.resolvedUrl("../../../assets/icons/arch-white-symbolic.svg")
        fillMode: Image.PreserveAspectFit
        smooth: true
        opacity: 1.0  // Ensure icon is fully opaque
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