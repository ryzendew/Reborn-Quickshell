import QtQuick
import Quickshell
import Quickshell.Hyprland
// import Quickshell.Services.Pipewire  // Temporarily disabled to avoid route device errors
import qs.services
import qs.Widgets
import "."

// Create a proper panel window
PanelWindow {
    id: panel
    
    // Accept volume properties from parent
    property int volume: 0
    property bool volumeMuted: false
    
    // Panel configuration - span full width
    anchors {
        top: true
        left: true
        right: true
    }
    
    implicitHeight: 40
    margins {
        top: 0
        left: 0
        right: 0
    }
    
    // The actual bar content - dark mode
    Rectangle {
        id: bar
        anchors.fill: parent
        color: "#1a1a1a"  // Dark background
        radius: 0  // Full width bar without rounded corners
        border.color: "#333333"
        border.width: 0
        
        // Bottom border only
        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 1
            color: "#5000eeff"
        }

        // Arch Linux button in the top left
        Rectangle {
            id: archButton
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: 4
            }
            width: 32
            height: 32
            radius: 6
            color: archMouseArea.containsMouse ? "#333333" : "transparent"
            border.color: "#00555555"
            border.width: 1
            
            // Arch Linux icon (white version)
            Image {
                anchors.centerIn: parent
                width: 20
                height: 20
                source: Qt.resolvedUrl("../../assets/icons/arch-white-symbolic.svg")
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
            
            // Mouse area for interactions
            MouseArea {
                id: archMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    // TODO: Add functionality for the Arch button
                }
            }
        }

        // Workspaces in the center
        Loader {
            anchors {
                centerIn: parent
            }
            source: "Workspaces.qml"
        }

        // Custom tray menu for system tray
        CustomTrayMenu {
            id: trayMenu
        }
        
        // System tray widget positioned to the left of time
        SystemTray {
            id: systemTrayWidget
            bar: panel  // Pass the panel window reference
            shell: panel  // Pass the panel as shell reference
            trayMenu: trayMenu  // Pass the tray menu reference
            anchors {
                right: timeDisplay.left
                verticalCenter: parent.verticalCenter
                rightMargin: 16
            }
        }

        // Time display
        Text {
            id: timeDisplay
            anchors {
                right: indicatorsModule.left
                verticalCenter: parent.verticalCenter
                rightMargin: 24
            }
            
            property string currentTime: ""
            
            text: currentTime
            color: "#ffffff"
            font.pixelSize: 14
            font.family: "Inter, sans-serif"
            
            // Update time every second
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    var now = new Date()
                    timeDisplay.currentTime = Qt.formatDate(now, "MMM dd") + " " + Qt.formatTime(now, "hh:mm AP")
                }
            }
            
            // Initialize time immediately
            Component.onCompleted: {
                var now = new Date()
                currentTime = Qt.formatDate(now, "MMM dd") + " " + Qt.formatTime(now, "hh:mm AP")
            }
        }
        
        // Indicators module (audio, network, bluetooth status) on the far right
        Loader {
            id: indicatorsModule
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: -9
            
            }
            source: "IndicatorsModule.qml"
            
            // Pass shell properties to the indicators
            property var shell: QtObject {
                property int volume: panel.volume
                property bool volumeMuted: panel.volumeMuted
            }
            
            // Pass shell to the loaded component
            onLoaded: {
                indicatorsModule.item.shell = shell
            }
        }
    }
} 