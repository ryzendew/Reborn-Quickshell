import QtQuick
import Quickshell
import Quickshell.Hyprland
import "./components/"
import "./managers/"

PanelWindow {
    id: dock
    
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
    
    // Make the panel window transparent
    color: "transparent"
    
    // Main dock content
    Rectangle {
        id: dockContent
        anchors.centerIn: parent
        width: dockIcons.width + 20
        height: 60
        color: "#1a1a1a"
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
        }
    }
    
    // Expose managers to child components
    property var hyprlandManager: hyprlandManager
    property var pinnedAppsManager: pinnedAppsManager
} 