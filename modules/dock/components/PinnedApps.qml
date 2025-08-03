import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.modules.dock.components

Row {
    id: pinnedAppsContainer
    spacing: 4
    
    // Property to receive the pinned apps from parent
    property var pinnedApps: []
    property var hyprlandManager: null
    property var dockWindow: null
    
    // Application menu
    ApplicationMenu {
        id: applicationMenu
        visible: false
    }
    
    // Arch Linux logo button at the beginning
    Rectangle {
        id: archButton
        width: 48
        height: 48
        radius: 30
        color: archMouseArea.containsMouse ? "#333333" : "transparent"
        border.color: archMouseArea.containsMouse ? "#555555" : "transparent"
        border.width: archMouseArea.containsMouse ? 1 : 0
        
        // Arch Linux icon using root:/ prefix
        Image {
            anchors.centerIn: parent
            width: 32
            height: 32
            source: "root:/assets/icons/arch-white-symbolic.svg"
            fillMode: Image.PreserveAspectFit
            smooth: true
            sourceSize.width: parent.width
            sourceSize.height: parent.height
            
            // Fallback to a generic system icon if arch-linux icon not found
            onStatusChanged: {
                if (status === Image.Error) {
                    source = "image://icon/system-linux"
                }
            }
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
                // Toggle application menu
                applicationMenu.visible = !applicationMenu.visible
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
    
    // Repeater for pinned apps
    Repeater {
        model: pinnedApps
        
        DockIcon {
            appId: modelData
            isPinned: true
            isRunning: hyprlandManager ? hyprlandManager.isAppRunning(modelData) : false
            workspace: hyprlandManager ? hyprlandManager.getAppWorkspace(modelData) : 1
            dockWindow: pinnedAppsContainer.dockWindow
            onAppClicked: {
                if (hyprlandManager) {
                    const isRunning = hyprlandManager.isAppRunning(modelData)
                    hyprlandManager.handleAppClick(modelData, isRunning)
                }
            }
            
            Component.onCompleted: {
            }
        }
    }
    
    // Debug info
    Component.onCompleted: {
        // Component loaded
    }
    
    onPinnedAppsChanged: {
        // Pinned apps changed
    }
} 