import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "./components"
import "./managers"

PanelWindow {
    id: dock
    
    // Set the specific screen (DP-1)
    screen: Quickshell.screens.find(screen => screen.name === "DP-1")
    
    // Set layer name for Hyprland blur effects
    WlrLayershell.namespace: "quickshell:dock:blur"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    
    // Accept context menu from parent
    property var contextMenu: null
    
    // Dock configuration - bottom center
    anchors {
        bottom: true
    }
    
    implicitWidth: dockContent.width
    implicitHeight: dockContent.height
    
    // Managers for different functionalities (instantiate first)
    PinnedAppsManager {
        id: pinnedAppsManager
    }
    
    HyprlandManager {
        id: hyprlandManager
    }
    
    // Settings window
    SettingsWindow {
        id: settingsWindow
        visible: false
    }
    
    // Make the panel window transparent
    color: "transparent"
    
    // Main dock content
    Rectangle {
        id: dockContent
        anchors.centerIn: parent
        width: dockIcons.width + 20
        height: 60
        color: "#1a1a1a"
        opacity: 0.8
        radius: 30
        border.color: "#5700eeff"
        border.width: 1
        
        // Dock icons container with pinned apps on left, running apps on right
        Row {
            id: dockIcons
            anchors.centerIn: parent
            spacing: 8
            height: 48  // Match the height of DockIcon
            
            // Pinned apps on the left
            PinnedApps {
                pinnedApps: pinnedAppsManager.pinnedApps
                hyprlandManager: hyprlandManager
                dockWindow: dock
            }
            
            // Separator between pinned and running apps
            Rectangle {
                visible: true
                width: 1
                height: 40
                color: "#33ffffff"
                radius: 1
                anchors.verticalCenter: parent.verticalCenter
                x: 8  // Move separator 8px to the right
            }
            
            // Running apps on the right
            RunningApps {
                runningApps: hyprlandManager.runningApps
                pinnedApps: pinnedAppsManager.pinnedApps
                hyprlandManager: hyprlandManager
                dockWindow: dock
            }
            
            // Separator between running apps and settings
            Rectangle {
                visible: true
                width: 1
                height: 40
                color: "#33ffffff"
                radius: 1
                anchors.verticalCenter: parent.verticalCenter
                x: 8  // Move separator 8px to the right
            }
            
            // Settings button
            Rectangle {
                id: settingsButton
                width: 48
                height: 48
                radius: 30
                color: settingsMouseArea.containsMouse ? "#333333" : "transparent"
                border.color: settingsMouseArea.containsMouse ? "#555555" : "transparent"
                border.width: settingsMouseArea.containsMouse ? 1 : 0
                
                // Settings icon using Material Symbols
                Text {
                    id: settingsIcon
                    anchors.centerIn: parent
                    text: "settings"
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 24
                    color: "#ffffff"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    
                    // Rotation animation
                    property real rotationAngle: 0
                    
                    transform: Rotation {
                        origin.x: settingsIcon.width / 2
                        origin.y: settingsIcon.height / 2
                        angle: settingsIcon.rotationAngle
                    }
                    
                    // Continuous rotation animation when hovering
                    SequentialAnimation {
                        id: rotationAnimation
                        loops: Animation.Infinite
                        running: settingsButton.isHovered
                        
                        NumberAnimation {
                            target: settingsIcon
                            property: "rotationAngle"
                            from: 0
                            to: 360
                            duration: 2000
                            easing.type: Easing.Linear
                        }
                    }
                }
                
                MouseArea {
                    id: settingsMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        settingsButton.isHovered = true
                    }
                    onExited: {
                        settingsButton.isHovered = false
                    }
                    onClicked: {
                        // Open settings window
                        settingsWindow.visible = true
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
        }
    }
    
    // Expose managers to child components
    property var hyprlandManager: hyprlandManager
    property var pinnedAppsManager: pinnedAppsManager
} 