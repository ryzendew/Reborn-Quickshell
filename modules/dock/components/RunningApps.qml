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
            // Check if any pinned app matches this appId
            for (var i = 0; i < pinnedApps.length; i++) {
                var pinnedApp = pinnedApps[i]
                
                // Handle both string and object cases
                if (typeof pinnedApp === 'string') {
                    // Direct string match
                    if (pinnedApp === appId) return true
                    
                    // Case-insensitive match
                    if (pinnedApp.toLowerCase() === appId.toLowerCase()) return true
                    
                    // Check with .desktop extension
                    if (pinnedApp === appId + ".desktop") return true
                    
                    // Check without .desktop extension
                    if (appId.endsWith(".desktop")) {
                        var withoutDesktop = appId.substring(0, appId.length - 8)
                        if (pinnedApp === withoutDesktop) return true
                    }
                } else if (typeof pinnedApp === 'object') {
                    // Handle object case (legacy support)
                    if (pinnedApp.class === appId || pinnedApp.id === appId || pinnedApp.execString === appId) {
                        return true
                    }
                    
                    // Case-insensitive match
                    if (pinnedApp.class && pinnedApp.class.toLowerCase() === appId.toLowerCase()) return true
                    if (pinnedApp.id && pinnedApp.id.toLowerCase() === appId.toLowerCase()) return true
                    if (pinnedApp.execString && pinnedApp.execString.toLowerCase() === appId.toLowerCase()) return true
                    
                    // Check with .desktop extension
                    if (pinnedApp.class === appId + ".desktop" || pinnedApp.id === appId + ".desktop") return true
                    
                    // Check without .desktop extension
                    if (appId.endsWith(".desktop")) {
                        var withoutDesktop = appId.substring(0, appId.length - 8)
                        if (pinnedApp.class === withoutDesktop || pinnedApp.id === withoutDesktop) return true
                    }
                }
            }
            
            return false
        }
        
        // Function to get the simplified app ID for grouping
        function getSimplifiedAppId(appId) {
            // For desktop entries, use the full name without .desktop extension
            if (appId.endsWith(".desktop")) {
                return appId.substring(0, appId.length - 8).toLowerCase()
            }
            // For complex app IDs like org.gnome.ptyxis, extract the last part
            if (appId.includes(".")) {
                const parts = appId.split(".")
                return parts[parts.length - 1].toLowerCase()
            }
            return appId.toLowerCase()
        }
        
        // Group apps by their simplified ID
        var groupedApps = {}
        var unpinnedApps = runningApps.filter(app => !isAppPinned(app)) // Filter out pinned apps to avoid duplication
        
        // Debug logging disabled
        
        for (var i = 0; i < unpinnedApps.length; i++) {
            var appId = unpinnedApps[i]
            var simplifiedId = getSimplifiedAppId(appId)
            
            // Debug logging disabled
            
            if (!groupedApps[simplifiedId]) {
                groupedApps[simplifiedId] = appId
                // Debug logging disabled
            } else {
                // Debug logging disabled
            }
        }
        
        // Debug logging disabled
        
        // Add one icon per group
        for (var simplifiedId in groupedApps) {
            unpinnedAppsModel.append({"appId": groupedApps[simplifiedId]})
            

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