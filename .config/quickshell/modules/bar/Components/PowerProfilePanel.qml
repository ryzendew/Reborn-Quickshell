import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Wayland
import qs.Settings

PanelWindow {
    id: powerPanel

    WlrLayershell.namespace: "quickshell:powerPanel:blur"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    
    // Floating behavior - don't push other windows out of the way
    exclusiveZone: 0
    
    // Position the window at the top left of the screen
    anchors {
        top: parent.top
        left: parent.left
    }
    
    implicitWidth: 200
    implicitHeight: 100
    
    // Make the panel window transparent
    color: "transparent"
    
    Component.onCompleted: {
        console.log("PowerProfilePanel created!")
    }
    
    // Power profile states - use Quickshell's PowerProfiles service
    property int currentProfile: PowerProfiles.profile
    
    // Background rectangle with blur support
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: "#1a1a1a"
        opacity: 0.8
        radius: 12
        border.color: "#333333"
        border.width: 1
        
        // Hover effects - simple magnification
        property bool isHovered: false
        scale: isHovered ? 1.1 : 1.0
        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
        
        // Ensure this rectangle is detected for blur
        layer.enabled: true
        layer.smooth: true
        
        // Close panel when clicking outside
        MouseArea {
            anchors.fill: parent
            onClicked: {
                powerPanel.visible = false
            }
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        

        
        // Spacer to push buttons to bottom
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
        
        // Bottom power profile buttons row
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "transparent"
            
            RowLayout {
                anchors.centerIn: parent
                spacing: 16
                
                // Power profile buttons using Material Symbols
                Repeater {
                    model: [
                        {icon: "battery_saver", profile: PowerProfile.PowerSaver, name: "Power Saver"},
                        {icon: "balance", profile: PowerProfile.Balanced, name: "Balanced"},
                        {icon: "speed", profile: PowerProfile.Performance, name: "Performance"}
                    ]
                    
                    Rectangle {
                        width: 48
                        height: 48
                        radius: 24
                        color: profileButtonArea.containsMouse ? "#444444" : (currentProfile === modelData.profile ? "#2196F3" : "transparent")
                        border.color: currentProfile === modelData.profile ? "#4CAF50" : "#666666"
                        border.width: currentProfile === modelData.profile ? 2 : 1
                        
                        // Material Design icons
                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: 24
                            color: currentProfile === modelData.profile ? "#ffffff" : "#888888"
                        }
                        
                        MouseArea {
                            id: profileButtonArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                // Use Quickshell's PowerProfiles service like the reference code
                                PowerProfiles.profile = modelData.profile
                                console.log(modelData.name + " mode selected")
                            }
                        }
                        
                        // Tooltip
                        Rectangle {
                            anchors.bottom: parent.top
                            anchors.bottomMargin: 8
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: tooltipText.width + 12
                            height: tooltipText.height + 8
                            color: "#000000"
                            opacity: 0.8
                            radius: 4
                            visible: profileButtonArea.containsMouse
                            
                            Text {
                                id: tooltipText
                                anchors.centerIn: parent
                                text: modelData.name
                                color: "#ffffff"
                                font.pixelSize: 10
                            }
                        }
                        
                        Behavior on color {
                            ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
                        }
                        
                        Behavior on border.color {
                            ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
                        }
                    }
                }
            }
        }
    }
} 