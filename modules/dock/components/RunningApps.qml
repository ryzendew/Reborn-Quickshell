import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.modules.dock.components

Row {
    id: runningAppsContainer
    spacing: 4
    
    // Property to receive the running apps from parent
    property var runningApps: []
    property var pinnedApps: []
    property var hyprlandManager: null
    property var dockWindow: null
    
    // ListModel for unpinned running apps - this is reactive
    ListModel {
        id: unpinnedAppsModel
    }
    
    // Function to update the model
    function updateUnpinnedApps() {
        unpinnedAppsModel.clear()
        
        // Create a function to check if an app is pinned (handles .desktop extensions)
        function isAppPinned(appId) {
            // Direct match
            if (pinnedApps.includes(appId)) return true
            
            // Case-insensitive match
            for (var i = 0; i < pinnedApps.length; i++) {
                if (pinnedApps[i].toLowerCase() === appId.toLowerCase()) return true
            }
            
            // Check with .desktop extension
            if (pinnedApps.includes(appId + ".desktop")) return true
            
            // Check without .desktop extension
            if (appId.endsWith(".desktop")) {
                var withoutDesktop = appId.substring(0, appId.length - 8)
                if (pinnedApps.includes(withoutDesktop)) return true
            }
            
            // Check for common variations
            var variations = [
                appId,
                appId + ".desktop",
                appId.replace(/-/g, ""),
                appId.replace(/-/g, "") + ".desktop"
            ]
            
            for (var i = 0; i < variations.length; i++) {
                if (pinnedApps.includes(variations[i])) return true
            }
            
            return false
        }
        
        var unpinnedApps = runningApps.filter(app => !isAppPinned(app))
        for (var i = 0; i < unpinnedApps.length; i++) {
            unpinnedAppsModel.append({"appId": unpinnedApps[i]})
        }
    }
    
    // Update when running apps change
    onRunningAppsChanged: {
        updateUnpinnedApps()
    }
    
    // Update when pinned apps change
    onPinnedAppsChanged: {
        updateUnpinnedApps()
    }
    
    // Repeater for running unpinned apps
    Repeater {
        model: unpinnedAppsModel
        
        DockIcon {
            appId: model.appId
            isPinned: false
            isRunning: true
            workspace: hyprlandManager ? hyprlandManager.getAppWorkspace(model.appId) : 1
            dockWindow: runningAppsContainer.dockWindow
            onAppClicked: {
                if (hyprlandManager) {
                    hyprlandManager.handleAppClick(model.appId, true)
                }
            }
        }
    }
    
    // Initialize on component creation
    Component.onCompleted: {
        updateUnpinnedApps()
    }
} 