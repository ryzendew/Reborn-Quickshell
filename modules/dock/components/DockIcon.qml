import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.Services
import qs.Settings

Rectangle {
    id: dockIcon
    
    // Properties
    property string appId: ""
    property bool isPinned: false
    property bool isRunning: false
    property int workspace: 1
    property var dockWindow: null
    


            // Function to get icon path using the robust IconService with fuzzy search fallback
        function getIconPath(appId) {
            if (appId === 'cursor' || appId === 'equibop' || appId === 'AffinityPhoto.desktop' || appId === 'AffinityDesigner.desktop') {
                // console.log(`DockIcon: Getting icon for "${appId}"`)
            }
            
            // First try the comprehensive IconService
            const iconPath = IconService.getIconPath(appId)
            if (appId === 'cursor' || appId === 'equibop' || appId === 'AffinityPhoto.desktop' || appId === 'AffinityDesigner.desktop') {
                // console.log(`DockIcon: IconService returned for "${appId}": ${iconPath}`)
            }
            
            if (iconPath && iconPath !== "image://icon/application-x-executable") {
                return iconPath
            }
            
            // If IconService returns fallback, try FuzzySearch for better matching
            try {
                if (typeof FuzzySearch !== 'undefined') {
                    if (appId === 'cursor' || appId === 'equibop') {
                        // console.log(`DockIcon: Trying FuzzySearch fallback for "${appId}"`)
                    }
                    const fuzzyIcon = FuzzySearch.findBestIcon(appId)
                    if (appId === 'cursor' || appId === 'equibop') {
                        // console.log(`DockIcon: FuzzySearch returned for "${appId}": ${fuzzyIcon}`)
                    }
                    if (fuzzyIcon && fuzzyIcon !== "image://icon/application-x-executable") {
                        return fuzzyIcon
                    }
                }
            } catch (e) {
                if (appId === 'cursor' || appId === 'equibop') {
                    // console.log(`DockIcon: FuzzySearch error for "${appId}":`, e)
                }
            }
            
            // If all else fails, return the IconService result (which should be the fallback)
            return iconPath
        }
            

    // Signals
    signal appClicked()
    signal rightClicked()
    
    // Visual properties
    width: Settings.settings.dockIconSize || 48
    height: Settings.settings.dockIconSize || 48
    radius: (Settings.settings.dockIconSize || 48) / 2
    color: isRunning ? "#004a9eff" : (isHovered ? "#333333" : "transparent")
    border.color: isRunning ? "#00555555" : (isHovered ? "#555555" : "transparent")
    border.width: isRunning ? 1 : (isHovered ? 1 : 0)
    
    // Animated background indicator for running apps
    Rectangle {
        visible: isRunning
        anchors.fill: parent
        radius: (Settings.settings.dockIconSize || 48) / 2
        color: Settings.settings.dockActiveIndicatorColor || "#00ffff"
        opacity: 0.3
        
        // Animated glow for running apps
        SequentialAnimation on opacity {
            running: isRunning
            loops: Animation.Infinite
            NumberAnimation { to: 0.1; duration: 2000 }
            NumberAnimation { to: 0.4; duration: 2000 }
        }
    }
    
    // Outer cyan glow ring for running apps
    Rectangle {
        visible: isRunning
        anchors.centerIn: parent
        width: parent.width * 1.01
        height: parent.height * 1.01
        radius: parent.radius * 1.01
        color: "transparent"
        border.color: Settings.settings.dockActiveIndicatorColor || "#00ffff"
        border.width: 1
        opacity: 0.5
        
        // Animated outer glow
        SequentialAnimation on opacity {
            running: isRunning
            loops: Animation.Infinite
            NumberAnimation { to: 0.2; duration: 2500 }
            NumberAnimation { to: 0.6; duration: 2500 }
        }
    }
    
    // Additional bright cyan halo for running apps
    Rectangle {
        visible: isRunning
        anchors.centerIn: parent
        width: parent.width * 1.02
        height: parent.height * 1.02
        radius: parent.radius * 1.02
        color: Settings.settings.dockActiveIndicatorColor || "#00ffff"
        opacity: 0.08
        
        // Animated halo
        SequentialAnimation on opacity {
            running: isRunning
            loops: Animation.Infinite
            NumberAnimation { to: 0.02; duration: 3000 }
            NumberAnimation { to: 0.15; duration: 3000 }
        }
    }
    
    // Hover effect
    property bool isHovered: false
    

    
    // Icon container
    Item {
        id: iconContainer
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        width: (Settings.settings.dockIconSize || 48) * 0.67
        height: (Settings.settings.dockIconSize || 48) * 0.67
        

        

        
        // Use Quickshell's IconImage widget for proper icon handling
        IconImage {
            id: appIcon
            anchors.fill: parent
            source: getIconPath(appId)
            
            // Enhanced fallback handling with fuzzy search
            onStatusChanged: {
                if (status === Image.Error) {
                    // Try fuzzy search as a fallback when icon fails to load
                    try {
                        if (typeof FuzzySearch !== 'undefined') {
                            const fuzzyIcon = FuzzySearch.findBestIcon(appId)
                            if (fuzzyIcon && fuzzyIcon !== source) {
                                source = fuzzyIcon
                                return
                            }
                        }
                    } catch (e) {
                        // Ignore errors in fuzzy search
                    }
                    
                    // Final fallback to generic executable icon
                    source = "image://icon/application-x-executable"
                }
            }
        }
        
        // Fallback text when icon is not visible
        Text {
            id: fallbackText
            anchors.centerIn: parent
            text: appId ? appId.split('.').pop() : "?"
            color: "#ffffff"
            font.pixelSize: (Settings.settings.dockIconSize || 48) * 0.2
            font.bold: true
            visible: !appIcon.visible
        }
        
    
        
    }
    
    // Running indicator
    Rectangle {
        visible: isRunning
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        width: 4
        height: 4
        radius: 4
        color: Settings.settings.dockActiveIndicatorColor || "#00ffff"

        z: 5
    }
    
    
    // Context menu is handled directly in the mouse area
    
    // Mouse area for interactions
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        
        onEntered: {
            dockIcon.isHovered = true
            dockIcon.scale = 1.1
        }
        
        onExited: {
            dockIcon.isHovered = false
            dockIcon.scale = 1.0
        }
        
        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                dockIcon.appClicked()
            } else if (mouse.button === Qt.RightButton) {
                dockIcon.rightClicked()
                // Debug logging disabled
                
                // Open context menu
                if (dockWindow && dockWindow.contextMenu) {
                            // If menu is already visible, close it
                            if (dockWindow.contextMenu.visible) {
                                dockWindow.contextMenu.hideMenu()
                                return
                            }
                            
                            // Get app info from HyprlandManager
                            let appInfo = null
                            let isPinned = false
                            
                            if (dockWindow.hyprlandManager) {
                                // Check if it's a running app
                                const runningApps = dockWindow.hyprlandManager.runningApps
                                const appWorkspaces = dockWindow.hyprlandManager.appWorkspaces
                                const appWindows = dockWindow.hyprlandManager.appWindows
                                
                                if (runningApps.includes(appId)) {
                                    // Get the launch command for this app
                                    const launchCommand = dockWindow.hyprlandManager.extractAppName(appId)
                                    appInfo = {
                                        class: appId,
                                        name: appId,
                                        execString: launchCommand,
                                        toplevels: appWindows[appId] || []
                                    }
                                                                          // Debug logging disabled
                                }
                            }
                            
                            // Check if it's a pinned app
                            if (dockWindow.pinnedAppsManager && dockWindow.pinnedAppsManager.pinnedApps) {
                                                                  // Debug logging disabled
                                
                                // Use the same logic as RunningApps to check if pinned
                                let foundPinned = false
                                for (var i = 0; i < dockWindow.pinnedAppsManager.pinnedApps.length; i++) {
                                    var pinnedApp = dockWindow.pinnedAppsManager.pinnedApps[i]
                                    
                                    // Handle both string and object cases
                                    if (typeof pinnedApp === 'string') {
                                        // Direct string match
                                        if (pinnedApp === appId) {
                                            foundPinned = true
                                            break
                                        }
                                        
                                        // Case-insensitive match
                                        if (pinnedApp.toLowerCase() === appId.toLowerCase()) {
                                            foundPinned = true
                                            break
                                        }
                                        
                                        // Special handling for complex app IDs like org.gnome.ptyxis
                                        if (appId.includes(".")) {
                                            const parts = appId.split(".")
                                            const lastPart = parts[parts.length - 1]
                                            
                                            if (pinnedApp.toLowerCase().includes(lastPart.toLowerCase())) {
                                                foundPinned = true
                                                break
                                            }
                                        }
                                    } else if (typeof pinnedApp === 'object') {
                                        // Handle object case
                                        if (pinnedApp.class === appId || pinnedApp.id === appId || pinnedApp.execString === appId) {
                                            foundPinned = true
                                            break
                                        }
                                        
                                        // Case-insensitive match
                                        if (pinnedApp.class && pinnedApp.class.toLowerCase() === appId.toLowerCase()) {
                                            foundPinned = true
                                            break
                                        }
                                        if (pinnedApp.id && pinnedApp.id.toLowerCase() === appId.toLowerCase()) {
                                            foundPinned = true
                                            break
                                        }
                                        
                                        // Special handling for complex app IDs
                                        if (appId.includes(".")) {
                                            const parts = appId.split(".")
                                            const lastPart = parts[parts.length - 1]
                                            
                                            if (pinnedApp.class && pinnedApp.class.toLowerCase().includes(lastPart.toLowerCase())) {
                                                foundPinned = true
                                                break
                                            }
                                            if (pinnedApp.id && pinnedApp.id.toLowerCase().includes(lastPart.toLowerCase())) {
                                                foundPinned = true
                                                break
                                            }
                                        }
                                    }
                                }
                                
                                if (foundPinned) {
                                    isPinned = true
                                                                          // Debug logging disabled
                                } else {
                                                                          // Debug logging disabled
                                }
                            }
                            
                            // Always ensure we have app info, even if app is not running or pinned
                            if (!appInfo) {
                                appInfo = {
                                    class: appId,
                                    id: appId,
                                    name: appId
                                }
                                                                      // Debug logging disabled
                            }
                            
                            // Set context and show menu
                                                              // Debug logging disabled
                            dockWindow.contextMenu.contextAppInfo = appInfo
                            dockWindow.contextMenu.contextIsPinned = isPinned
                            
                            // Position menu above the dock icon
                            const menuX = (width / 2) - (dockWindow.contextMenu.width / 2)
                            const menuY = -dockWindow.contextMenu.height + 15 // Above the icon
                                                          // Debug logging disabled
                            dockWindow.contextMenu.showAt(dockIcon, menuX, menuY)
                }
            }
        }
    }
    
    // Smooth scale animation
    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutQuad
        }
    }
   
} 