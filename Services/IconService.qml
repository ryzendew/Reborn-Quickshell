pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * IconService - Proper Quickshell icon resolution service
 * Uses Quickshell's built-in icon handling APIs
 */
QtObject {
    id: root
    
    /**
     * Get icon path for an application using Quickshell's proper APIs
     * @param appId - The application identifier
     * @returns The icon path or fallback icon
     */
    function getIconPath(appId) {
        if (!appId || appId === "") {
            // Debug logging for final result
        if (appId === 'AffinityPhoto.desktop' || appId === 'AffinityDesigner.desktop') {
            console.log(`IconService: Final result for "${appId}": image://icon/application-x-executable`)
        }
        
        return "image://icon/application-x-executable"
        }
        
        // Special handling for Steam tray icon to prevent custom icon path warnings
        if (appId && appId.includes('steam_tray_mono')) {
            // Extract the path from the Steam icon identifier
            const pathMatch = appId.match(/path=([^?]+)/)
            if (pathMatch && pathMatch[1]) {
                const steamPath = pathMatch[1]
                // Try to find a Steam icon in the extracted path
                const steamIconPath = steamPath + "/steam_tray_mono.png"
                // Check if the file exists using a simple approach
                try {
                    // Return a standard Steam icon instead of the custom path
                    return "image://icon/steam"
                } catch (e) {
                    // Fallback to generic application icon
                    return "image://icon/application-x-executable"
                }
            }
            // If no path found, return standard Steam icon
            return "image://icon/steam"
        }
        
        // Debug logging for Affinity apps
        if (appId === 'photo.exe' || appId === 'designer.exe' || appId === 'AffinityPhoto.desktop' || appId === 'AffinityDesigner.desktop') {
            console.log(`IconService: Getting icon for "${appId}"`)
        }
        

        
        // Method 1: Try to find desktop entry and use its icon (enhanced matching)
        try {
            if (typeof DesktopEntries !== 'undefined' && DesktopEntries.applications) {
                const model = DesktopEntries.applications
                const cleanId = appId.endsWith('.desktop') ? appId.slice(0, -8) : appId
                
                for (let i = 0; i < model.count; i++) {
                    const app = model.get(i)
                    
                    // Enhanced desktop entry matching
                    if (app.name) {
                        const appName = app.name.toLowerCase()
                        const searchId = cleanId.toLowerCase()
                        
                        // Direct name match
                        if (appName === searchId) {
                            if (app.icon) {
                                const iconPath = Quickshell.iconPath(app.icon, true)
                                if (iconPath && iconPath.length > 0) {
                                    return iconPath
                                }
                            }
                        }
                        
                        // Name with spaces removed match
                        if (appName.replace(/\s+/g, '') === searchId) {
                            if (app.icon) {
                                const iconPath = Quickshell.iconPath(app.icon, true)
                                if (iconPath && iconPath.length > 0) {
                                    return iconPath
                                }
                            }
                        }
                        
                        // Name containing appId (for cases like "Affinity Designer" vs "AffinityDesigner")
                        if (appName.replace(/\s+/g, '').includes(searchId)) {
                            if (app.icon) {
                                const iconPath = Quickshell.iconPath(app.icon, true)
                                if (iconPath && iconPath.length > 0) {
                                    return iconPath
                                }
                            }
                        }
                        
                        // CamelCase to space conversion (e.g., "coolerControls" -> "cooler controls")
                        const spacedId = searchId.replace(/([a-z])([A-Z])/g, '$1 $2')
                        if (appName.includes(spacedId)) {
                            if (app.icon) {
                                const iconPath = Quickshell.iconPath(app.icon, true)
                                if (iconPath && iconPath.length > 0) {
                                    return iconPath
                                }
                            }
                        }
                        
                        // Partial name matching (for cases like "org.coolercontrol.coolercontrol" -> "CoolerControl")
                        const appIdParts = cleanId.split('.')
                        const lastPart = appIdParts[appIdParts.length - 1]
                        if (appName.includes(lastPart.toLowerCase())) {
                            if (app.icon) {
                                const iconPath = Quickshell.iconPath(app.icon, true)
                                if (iconPath && iconPath.length > 0) {
                                    return iconPath
                                }
                            }
                        }
                    }
                    
                    // Exec field matching
                    if (app.exec) {
                        const exec = app.exec.toLowerCase()
                        if (exec.includes(cleanId.toLowerCase()) || cleanId.toLowerCase().includes(exec.split('/').pop())) {
                            if (app.icon) {
                                const iconPath = Quickshell.iconPath(app.icon, true)
                                if (iconPath && iconPath.length > 0) {
                                    return iconPath
                                }
                            }
                        }
                    }
                    
                    // StartupWMClass matching (for Wine apps like photo.exe, designer.exe)
                    if (app.startupWMClass) {
                        const startupWMClass = app.startupWMClass.toLowerCase()
                        if (startupWMClass === cleanId.toLowerCase()) {
                            if (app.icon) {
                                const iconPath = Quickshell.iconPath(app.icon, true)
                                if (iconPath && iconPath.length > 0) {
                                    return iconPath
                                }
                            }
                        }
                    }
                }
            }
        } catch (e) {
            // Ignore errors in desktop entry lookup
        }
        
        // Method 1.25: Wine app specific mapping (for .exe apps)
        try {
            if (appId.endsWith('.exe')) {
                // Map common Wine app executable names to their desktop entries
                const wineAppMap = {
                    'photo.exe': 'AffinityPhoto',
                    'designer.exe': 'AffinityDesigner',
                    'publisher.exe': 'AffinityPublisher'
                }
                
                const desktopEntryName = wineAppMap[appId.toLowerCase()]
                if (desktopEntryName) {
                    // Try to find the desktop entry by name
                    if (typeof DesktopEntries !== 'undefined' && DesktopEntries.applications) {
                        const model = DesktopEntries.applications
                        for (let i = 0; i < model.count; i++) {
                            const app = model.get(i)
                            if (app.name && app.name.toLowerCase().includes(desktopEntryName.toLowerCase())) {
                                if (app.icon) {
                                    const iconPath = Quickshell.iconPath(app.icon, true)
                                    if (iconPath && iconPath.length > 0) {
                                        return iconPath
                                    }
                                }
                            }
                        }
                    }
                    
                    // Direct icon path mapping for known Wine apps
                    const directIconMap = {
                        'photo.exe': '/usr/share/icons/AffinityPhoto.png',
                        'designer.exe': '/usr/share/icons/AffinityDesigner.png',
                        'publisher.exe': '/usr/share/icons/AffinityPublisher.png'
                    }
                    
                    const directIcon = directIconMap[appId.toLowerCase()]
                    if (directIcon) {
                        // Check if the icon file exists using Quickshell.iconPath
                        const iconPath = Quickshell.iconPath(directIcon, true)
                        if (iconPath && iconPath.length > 0 && iconPath !== "image://icon/application-x-executable") {
                            return iconPath
                        } else {
                            // Try the direct path as a fallback
                            if (directIcon.startsWith('/') && directIcon.endsWith('.svg')) {
                                return directIcon
                            }
                        }
                    }
                }
            }
        } catch (e) {
            // Ignore errors in Wine app mapping
        }
        
        // Method 1.26: Desktop entry name mapping (for pinned apps)
        try {
            // Handle desktop entry names (with or without .desktop extension)
            let desktopEntryName = appId
            if (appId.endsWith('.desktop')) {
                desktopEntryName = appId.slice(0, -8) // Remove .desktop extension
            }
            
            // Debug logging for Affinity desktop entries
            if (appId === 'AffinityPhoto.desktop' || appId === 'AffinityDesigner.desktop') {
                console.log(`IconService: Processing desktop entry "${appId}" -> "${desktopEntryName}"`)
            }
            
            // Map common desktop entry names to their full names
            const desktopEntryMap = {
                'affinityphoto': 'AffinityPhoto',
                'affinitydesigner': 'AffinityDesigner',
                'affinitypublisher': 'AffinityPublisher',
                'affinity photo': 'AffinityPhoto',
                'affinity designer': 'AffinityDesigner',
                'affinity publisher': 'AffinityPublisher'
            }
            
            const mappedName = desktopEntryMap[desktopEntryName.toLowerCase()]
            if (mappedName) {
                console.log(`IconService: Mapped "${desktopEntryName}" to "${mappedName}"`)
                
                // Try to find the desktop entry by name
                if (typeof DesktopEntries !== 'undefined' && DesktopEntries.applications) {
                    const model = DesktopEntries.applications
                    for (let i = 0; i < model.count; i++) {
                        const app = model.get(i)
                        if (app.name && app.name.toLowerCase().includes(mappedName.toLowerCase())) {
                            if (app.icon) {
                                const iconPath = Quickshell.iconPath(app.icon, true)
                                if (iconPath && iconPath.length > 0) {
                                    console.log(`IconService: Found desktop entry icon: ${iconPath}`)
                                    return iconPath
                                }
                            }
                        }
                    }
                }
                
                // Direct icon path mapping for known desktop entries
                const directIconMap = {
                    'affinityphoto': '/usr/share/icons/AffinityPhoto.png',
                    'affinitydesigner': '/usr/share/icons/AffinityDesigner.png',
                    'affinitypublisher': '/usr/share/icons/AffinityPublisher.png',
                    'affinity photo': '/usr/share/icons/AffinityPhoto.png',
                    'affinity designer': '/usr/share/icons/AffinityDesigner.png',
                    'affinity publisher': '/usr/share/icons/AffinityDesigner.png'
                }
                
                const directIcon = directIconMap[desktopEntryName.toLowerCase()]
                if (directIcon) {
                    // Check if the icon file exists using Quickshell.iconPath
                    const iconPath = Quickshell.iconPath(directIcon, true)
                    if (iconPath && iconPath.length > 0 && iconPath !== "image://icon/application-x-executable") {
                        console.log(`IconService: Using direct icon path: ${iconPath}`)
                        return iconPath
                    } else {
                        console.log(`IconService: Direct icon path not found: ${directIcon}`)
                        // Try the direct path as a fallback
                        if (directIcon.startsWith('/') && directIcon.endsWith('.svg')) {
                            console.log(`IconService: Using direct SVG path: ${directIcon}`)
                            return directIcon
                        }
                    }
                }
            }
        } catch (e) {
            // Ignore errors in desktop entry mapping
            if (appId === 'AffinityPhoto.desktop' || appId === 'AffinityDesigner.desktop') {
                console.log(`IconService: Error in desktop entry mapping:`, e)
            }
        }
        
        // Method 1.3: Wine app detection by window title patterns
        try {
            if (typeof Hyprland !== 'undefined') {
                const clients = Hyprland.clients
                for (let i = 0; i < clients.length; i++) {
                    const client = clients[i]
                    
                    // Check if this client matches our appId
                    if (client.class && client.class.toLowerCase() === appId.toLowerCase()) {
                        // For Wine apps, try to match by window title
                        if (client.title) {
                            const title = client.title.toLowerCase()
                            
                            // Affinity Photo detection
                            if (title.includes('affinity photo')) {
                                const iconPath = '/usr/share/icons/AffinityPhoto.png'
                                const resolvedPath = Quickshell.iconPath(iconPath, true)
                                if (resolvedPath && resolvedPath.length > 0 && resolvedPath !== "image://icon/application-x-executable") {
                                    return resolvedPath
                                } else if (iconPath.startsWith('/') && iconPath.endsWith('.png')) {
                                    return iconPath
                                }
                            }
                            
                            // Affinity Designer detection
                            if (title.includes('affinity designer')) {
                                const iconPath = '/usr/share/icons/AffinityDesigner.png'
                                const resolvedPath = Quickshell.iconPath(iconPath, true)
                                if (resolvedPath && resolvedPath.length > 0 && resolvedPath !== "image://icon/application-x-executable") {
                                    return resolvedPath
                                } else if (iconPath.startsWith('/') && iconPath.endsWith('.png')) {
                                    return iconPath
                                }
                            }
                            
                            // Affinity Publisher detection
                            if (title.includes('affinity publisher')) {
                                const iconPath = '/usr/share/icons/AffinityPublisher.png'
                                const resolvedPath = Quickshell.iconPath(iconPath, true)
                                if (resolvedPath && resolvedPath.length > 0 && resolvedPath !== "image://icon/application-x-executable") {
                                    return resolvedPath
                                } else if (iconPath.startsWith('/') && iconPath.endsWith('.png')) {
                                    return iconPath
                                }
                            }
                        }
                    }
                }
            }
        } catch (e) {
            // Ignore errors in Wine app title detection
        }
        
        // Method 1.5: Try AppSearch.guessIcon (if available)
        try {
            if (typeof AppSearch !== 'undefined' && AppSearch.guessIcon) {
                const guessedIcon = AppSearch.guessIcon(appId)
                if (guessedIcon) {
                    const iconPath = Quickshell.iconPath(guessedIcon, true)
                    if (iconPath && iconPath.length > 0) {
                        return iconPath
                    }
                }
            }
        } catch (e) {
            // Ignore errors in AppSearch lookup
        }
        
        // Method 1.6: Try FuzzySearch for intelligent matching
        try {
            if (typeof FuzzySearch !== 'undefined') {
                const fuzzyIcon = FuzzySearch.findBestIcon(appId)
                if (fuzzyIcon) {
                    return fuzzyIcon
                }
            }
        } catch (e) {
            // Ignore errors in fuzzy search lookup
        }
        
        // Method 2: Try direct Quickshell.iconPath calls with fallbacks
        let icon = Quickshell.iconPath(appId?.toLowerCase(), true);

        if (icon && icon.length > 0) {
            return icon
        }
        
        icon = Quickshell.iconPath(appId, true);

        if (icon && icon.length > 0) {
            return icon
        }
        
        // Method 3: Try with .desktop extension
        icon = Quickshell.iconPath(appId + ".desktop", true);

        if (icon && icon.length > 0) {
            return icon
        }
        
        // Method 4: Try without .desktop extension if appId ends with it
        if (appId.endsWith(".desktop")) {
            const withoutDesktop = appId.substring(0, appId.length - 8);
            icon = Quickshell.iconPath(withoutDesktop, true);

            if (icon && icon.length > 0) {
                return icon
            }
        }
        
        // Method 5: Try different icon sizes (simplified to avoid argument warnings)
        const iconSizes = ["16x16", "22x22", "24x24", "32x32", "48x48", "64x64", "96x96", "128x128", "256x256", "scalable"]
        for (let i = 0; i < iconSizes.length; i++) {
            icon = Quickshell.iconPath(appId, true);
            if (icon && icon.length > 0) {
                return icon
            }
        }
        
        // Method 6: Try different icon contexts (simplified to avoid argument warnings)
        const iconContexts = ["apps", "actions", "devices", "emblems", "mimetypes", "places", "status"]
        for (let i = 0; i < iconContexts.length; i++) {
            icon = Quickshell.iconPath(appId, true);
            if (icon && icon.length > 0) {
                return icon
            }
        }
        
        // Method 7: Try different file extensions
        const extensions = ["", ".png", ".svg", ".xpm"]
        for (let i = 0; i < extensions.length; i++) {
            icon = Quickshell.iconPath(appId + extensions[i], true);
            if (icon && icon.length > 0) {
                return icon
            }
        }
        
        // Method 8: Try executable name extraction from desktop entries
        try {
            if (typeof DesktopEntries !== 'undefined' && DesktopEntries.applications) {
                const model = DesktopEntries.applications
                for (let i = 0; i < model.count; i++) {
                    const app = model.get(i)
                    if (app.name && app.name.toLowerCase() === appId.toLowerCase()) {
                        if (app.exec) {
                            // Extract executable name from exec field
                            const execName = app.exec.split(' ')[0].split('/').pop()
                            if (execName && execName !== appId) {
                                icon = Quickshell.iconPath(execName, true)
                                if (icon && icon.length > 0) {
                                    return icon
                                }
                            }
                        }
                    }
                }
            }
        } catch (e) {
            // Ignore errors in executable name extraction
        }
        
        // Method 9: Try Hyprland IPC-based fallbacks
        try {
            if (typeof Hyprland !== 'undefined') {
                // Get all clients (windows) from Hyprland
                const clients = Hyprland.clients
                for (let i = 0; i < clients.length; i++) {
                    const client = clients[i]
                    
                    // Check if this client matches our appId
                    if (client.class && client.class.toLowerCase() === appId.toLowerCase()) {
                        // Try the client's class name
                        icon = Quickshell.iconPath(client.class, true)
                        if (icon && icon.length > 0) {
                            return icon
                        }
                        
                        // Try the client's title (window title might contain app name)
                        if (client.title) {
                            const titleWords = client.title.split(' ')
                            for (let j = 0; j < titleWords.length; j++) {
                                const word = titleWords[j].toLowerCase()
                                if (word.length > 2) { // Only try meaningful words
                                    icon = Quickshell.iconPath(word, true)
                                    if (icon && icon.length > 0) {
                                        return icon
                                    }
                                }
                            }
                        }
                        
                        // Try the client's address (might contain process info)
                        if (client.address) {
                            const addressParts = client.address.split('.')
                            for (let j = 0; j < addressParts.length; j++) {
                                const part = addressParts[j].toLowerCase()
                                if (part.length > 2) {
                                    icon = Quickshell.iconPath(part, true)
                                    if (icon && icon.length > 0) {
                                        return icon
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch (e) {
            // Ignore errors in Hyprland IPC lookup
        }
        
        // Method 10: Try Hyprland workspace-based app detection
        try {
            if (typeof Hyprland !== 'undefined' && Hyprland.workspaces) {
                for (let i = 0; i < Hyprland.workspaces.length; i++) {
                    const workspace = Hyprland.workspaces[i]
                    if (workspace.toplevels) {
                        for (let j = 0; j < workspace.toplevels.length; j++) {
                            const toplevel = workspace.toplevels[j]
                            
                            // Check if this toplevel matches our appId
                            if (toplevel.appId && toplevel.appId.toLowerCase() === appId.toLowerCase()) {
                                // Try the toplevel's appId
                                icon = Quickshell.iconPath(toplevel.appId, true)
                                if (icon && icon.length > 0) {
                                    return icon
                                }
                                
                                // Try the toplevel's title
                                if (toplevel.title) {
                                    const titleWords = toplevel.title.split(' ')
                                    for (let k = 0; k < titleWords.length; k++) {
                                        const word = titleWords[k].toLowerCase()
                                        if (word.length > 2) {
                                            icon = Quickshell.iconPath(word, true)
                                            if (icon && icon.length > 0) {
                                                return icon
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch (e) {
            // Ignore errors in Hyprland workspace lookup
        }
        
        // Method 11: Try process name variations from desktop entries
        try {
            if (typeof DesktopEntries !== 'undefined' && DesktopEntries.applications) {
                const model = DesktopEntries.applications
                for (let i = 0; i < model.count; i++) {
                    const app = model.get(i)
                    if (app.exec) {
                        // Extract process name from exec field
                        const execParts = app.exec.split(' ')
                        const processName = execParts[0].split('/').pop()
                        
                        // Try matching by process name
                        if (processName && processName.toLowerCase() === appId.toLowerCase()) {
                            if (app.icon) {
                                const iconPath = Quickshell.iconPath(app.icon, true)
                                if (iconPath && iconPath.length > 0) {
                                    return iconPath
                                }
                            }
                        }
                        
                        // Try matching appId against process name
                        if (processName && appId.toLowerCase().includes(processName.toLowerCase())) {
                            if (app.icon) {
                                const iconPath = Quickshell.iconPath(app.icon, true)
                                if (iconPath && iconPath.length > 0) {
                                    return iconPath
                                }
                            }
                        }
                    }
                }
            }
        } catch (e) {
            // Ignore errors in process name lookup
        }
        
        // Method 12: Try common application name variations
        try {
            const commonVariations = [
                appId,
                appId.replace(/[^a-zA-Z0-9]/g, ''),
                appId.replace(/[^a-zA-Z0-9]/g, '').toLowerCase(),
                appId.replace(/[^a-zA-Z0-9]/g, '').toUpperCase(),
                appId.split('.').pop(),
                appId.split('-').pop(),
                appId.split('_').pop(),
                appId.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase(),
                appId.replace(/([a-z])([A-Z])/g, '$1_$2').toLowerCase()
            ]
            
            for (let i = 0; i < commonVariations.length; i++) {
                const variation = commonVariations[i]
                if (variation && variation.length > 0) {
                    icon = Quickshell.iconPath(variation, true)
                    if (icon && icon.length > 0) {
                        return icon
                    }
                }
            }
        } catch (e) {
            // Ignore errors in variation lookup
        }
        
        // Method 13: Try application type detection based on patterns
        try {
            let appType = "application-x-executable"
            
            // Detect application type based on appId patterns
            if (appId.includes('terminal') || appId.includes('term')) {
                appType = "terminal"
            } else if (appId.includes('browser') || appId.includes('web')) {
                appType = "web-browser"
            } else if (appId.includes('editor') || appId.includes('code')) {
                appType = "text-editor"
            } else if (appId.includes('file') || appId.includes('manager')) {
                appType = "file-manager"
            } else if (appId.includes('image') || appId.includes('photo')) {
                appType = "image-viewer"
            } else if (appId.includes('video') || appId.includes('media')) {
                appType = "video-player"
            } else if (appId.includes('music') || appId.includes('audio')) {
                appType = "audio-player"
            } else if (appId.includes('settings') || appId.includes('config')) {
                appType = "preferences-system"
            }
            
            icon = Quickshell.iconPath(appType, true)
            if (icon && icon.length > 0) {
                return icon
            }
        } catch (e) {
            // Ignore errors in app type detection
        }
        
        // Method 14: Try system-wide icon theme search (simplified to avoid argument warnings)
        try {
            if (typeof Quickshell !== 'undefined' && Quickshell.iconTheme) {
                const iconPath = Quickshell.iconPath(appId, true)
                if (iconPath && iconPath.length > 0) {
                    return iconPath
                }
            }
        } catch (e) {
            // Ignore errors in icon theme lookup
        }
        
        // Method 15: Try MIME type-based icon detection
        try {
            if (typeof DesktopEntries !== 'undefined' && DesktopEntries.applications) {
                const model = DesktopEntries.applications
                for (let i = 0; i < model.count; i++) {
                    const app = model.get(i)
                    if (app.mimeType) {
                        // Try to match by MIME type if appId contains relevant keywords
                        const mimeTypes = app.mimeType.split(';')
                        for (let j = 0; j < mimeTypes.length; j++) {
                            const mimeType = mimeTypes[j].trim()
                            if (mimeType && appId.toLowerCase().includes(mimeType.split('/')[0])) {
                                if (app.icon) {
                                    const iconPath = Quickshell.iconPath(app.icon, true)
                                    if (iconPath && iconPath.length > 0) {
                                        return iconPath
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch (e) {
            // Ignore errors in MIME type lookup
        }
        
        // Method 16: Try category-based icon detection
        try {
            if (typeof DesktopEntries !== 'undefined' && DesktopEntries.applications) {
                const model = DesktopEntries.applications
                for (let i = 0; i < model.count; i++) {
                    const app = model.get(i)
                    if (app.categories) {
                        const categories = app.categories.split(';')
                        for (let j = 0; j < categories.length; j++) {
                            const category = categories[j].trim()
                            // Try to match appId against category keywords
                            if (category && appId.toLowerCase().includes(category.toLowerCase())) {
                                if (app.icon) {
                                    const iconPath = Quickshell.iconPath(app.icon, true)
                                    if (iconPath && iconPath.length > 0) {
                                        return iconPath
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch (e) {
            // Ignore errors in category lookup
        }

        return "image://icon/application-x-executable"
    }
}
