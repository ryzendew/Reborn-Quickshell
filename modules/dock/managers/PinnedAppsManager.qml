import QtQuick
import QtCore
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Item {
    id: pinnedAppsManager
    
    // Properties
    property var pinnedApps: []
    property string pinnedAppsFilePath: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.local/state/Quickshell/Dock/PinnedApps.conf"
    
    Component.onCompleted: {
        // Initialize with empty array, FileView will load the data
        pinnedApps = [];
    }
    
    // FileView to manage pinned apps storage (like HyprlandDE-Quickshell)
    FileView {
        id: pinnedAppsFileView
        path: pinnedAppsFilePath
        
        onLoaded: {
            try {
                var content = text();
                if (content && content.trim() !== '') {
                    var arr = JSON.parse(content);
                    if (Array.isArray(arr)) {
                        pinnedApps = arr;
                    }
                }
            } catch (e) {
                pinnedApps = [];
            }
        }
        
        onLoadFailed: {
            pinnedApps = [];
            // Create the file with empty list
            savePinnedApps();
        }
    }
    
    // Save pinned apps to configuration file (like HyprlandDE-Quickshell)
    function savePinnedApps() {
        try {
            console.log("=== savePinnedApps ===")
            console.log("Pinned apps to save:", pinnedApps)
            
            // Create the directory if it doesn't exist
            var dirPath = pinnedAppsFilePath.replace('file://', '').replace('/PinnedApps.conf', '');
            console.log("Creating directory:", dirPath)
            Hyprland.dispatch(`exec mkdir -p '${dirPath}'`);
            
            // Write the JSON content to the file using a more reliable method
            var jsonContent = JSON.stringify(pinnedApps, null, 2);
            console.log("JSON content to write:", jsonContent)
            
            // Use a temporary file approach to avoid shell escaping issues
            var tempFile = dirPath + '/PinnedApps.tmp'
            var finalFile = pinnedAppsFilePath.replace('file://', '')
            
            // Write to temp file first
            var writeCommand = `echo '${jsonContent.replace(/'/g, "'\"'\"'")}' > '${tempFile}'`
            console.log("Write command:", writeCommand)
            Hyprland.dispatch(`exec ${writeCommand}`)
            
            // Move temp file to final location
            Hyprland.dispatch(`exec mv '${tempFile}' '${finalFile}'`)
            
            console.log("✓ File saved successfully to:", finalFile)
            
            // Reload the FileView to reflect changes
            pinnedAppsFileView.reload();
        } catch (e) {
            console.log("✗ Error saving pinned apps:", e)
            console.log("Error details:", e.message || e)
        }
    }
    
    // Check if an app is pinned
    function isPinned(appId) {
        return pinnedApps.findIndex(app => {
            if (typeof app === 'string') {
                return app === appId
            } else if (typeof app === 'object') {
                return app.id === appId || app.class === appId || app.execString === appId
            }
            return false
        }) !== -1
    }
    
    // Pin an app to the dock
    function pinApp(appInfo) {
        console.log("=== PinnedAppsManager.pinApp ===")
        console.log("App info:", appInfo)
        
        if (!appInfo) {
            console.log("✗ No app info provided")
            return
        }
        
        const appId = appInfo.class || appInfo.id || appInfo.execString
        console.log("App ID:", appId)
        
        if (!appId) {
            console.log("✗ No app ID found")
            return
        }
        
        // Check if already pinned
        const existingIndex = pinnedApps.findIndex(app => {
            if (typeof app === 'string') {
                return app === appId
            } else if (typeof app === 'object') {
                return app.id === appId || app.class === appId || app.execString === appId
            }
            return false
        })
        
        console.log("Existing index:", existingIndex)
        console.log("Current pinned apps:", pinnedApps)
        
        if (existingIndex === -1) {
            // Add the app to pinned apps - use the appId as a string for consistency
            const appIdToPin = appInfo.class || appInfo.id || appInfo.execString
            pinnedApps.push(appIdToPin)
            console.log("✓ App added to pinned apps:", appIdToPin)
            savePinnedApps()
            pinnedAppsChanged()
        } else {
            console.log("✓ App already pinned")
        }
    }
    
    // Unpin an app from the dock
    function unpinApp(appId) {
        console.log("=== PinnedAppsManager.unpinApp ===")
        console.log("App ID to unpin:", appId)
        console.log("Current pinned apps:", pinnedApps)
        
        const index = pinnedApps.findIndex(app => {
            if (typeof app === 'string') {
                return app === appId
            } else if (typeof app === 'object') {
                return app.id === appId || app.class === appId || app.execString === appId
            }
            return false
        })
        
        console.log("Found at index:", index)
        
        if (index > -1) {
            const removedApp = pinnedApps[index]
            pinnedApps.splice(index, 1)
            console.log("✓ App removed:", removedApp)
            savePinnedApps()
            pinnedAppsChanged()
        } else {
            console.log("✗ App not found in pinned apps")
        }
    }
    
    // Get all pinned apps
    function getPinnedApps() {
        return pinnedApps
    }
    
    // Clear all pinned apps
    function clearPinnedApps() {
        pinnedApps = []
        savePinnedApps()
        pinnedAppsChanged()
    }
    
    // The pinnedAppsChanged signal is automatically generated by Qt for the pinnedApps property
} 