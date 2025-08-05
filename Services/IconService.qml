pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * IconService - A robust icon resolution service
 * Handles finding icons for applications through multiple methods:
 * 1. Direct desktop entry lookup
 * 2. AppSearch.guessIcon fallback
 * 3. Executable name matching
 * 4. Name-based fuzzy matching
 */
QtObject {
    id: root
    
    // Get all desktop entries for lookup (both system and user)
    readonly property var desktopEntries: Array.from(DesktopEntries.applications.values)
    
    /**
     * Main function to get icon path for an application
     * @param appId - The application identifier (desktop entry ID, exec name, etc.)
     * @returns The icon path or fallback icon
     */
    function getIconPath(appId) {
        if (!appId || appId === "") {
            return "image://icon/application-x-executable"
        }
        

        
        // Method 1: Try to find exact desktop entry match
        const desktopEntry = findDesktopEntry(appId)
        if (desktopEntry && desktopEntry.icon) {
            const iconPath = Quickshell.iconPath(desktopEntry.icon, true)
            if (iconPath.length > 0) {
                return iconPath
            }
        }
        
        // Method 2: Try AppSearch.guessIcon
        const guessedIcon = AppSearch.guessIcon(appId)
        if (guessedIcon) {
            const iconPath = Quickshell.iconPath(guessedIcon, true)
            if (iconPath.length > 0) {
                return iconPath
            }
        }
        
        // Method 3: Try executable name matching
        const execIcon = findIconByExecutable(appId)
        if (execIcon) {
            return execIcon
        }
        
        // Method 4: Try name-based fuzzy matching
        const fuzzyIcon = findIconByName(appId)
        if (fuzzyIcon) {
            return fuzzyIcon
        }
        

        // Fallback
        return "image://icon/application-x-executable"
    }
    
    /**
     * Find desktop entry by various identifiers
     */
    function findDesktopEntry(appId) {
        const cleanId = appId.endsWith('.desktop') ? appId.slice(0, -8) : appId
        

        
        for (let i = 0; i < desktopEntries.length; i++) {
            const entry = desktopEntries[i]
            
            // Try to match by desktop entry ID (if available)
            if (entry.desktopId && entry.desktopId === cleanId) {
                return entry
            }
            
            // Try to match by exec
            if (entry.exec === appId || entry.execString === appId) {
                return entry
            }
            
            // Try to match by name (case insensitive)
            if (entry.name && entry.name.toLowerCase() === appId.toLowerCase()) {
                return entry
            }
            
            // Try to match by name containing the appId (for cases like "Affinity Designer" vs "AffinityDesigner")
            if (entry.name && entry.name.toLowerCase().replace(/\s+/g, '').includes(cleanId.toLowerCase())) {
                return entry
            }
            
            // Try to match by name with spaces added (e.g., "coolercontrols" -> "cooler controls")
            const spacedId = cleanId.replace(/([a-z])([A-Z])/g, '$1 $2').toLowerCase()
            if (entry.name && entry.name.toLowerCase().includes(spacedId)) {
                return entry
            }
            
            // Try to match by name with spaces removed
            if (entry.name && entry.name.toLowerCase().replace(/\s+/g, '') === cleanId.toLowerCase()) {
                return entry
            }
            
            // Try to match by partial name (for cases like "org.coolercontrol.coolercontrol" -> "CoolerControl")
            const appIdParts = cleanId.split('.')
            const lastPart = appIdParts[appIdParts.length - 1]
            if (entry.name && entry.name.toLowerCase().includes(lastPart.toLowerCase())) {
                return entry
            }
            
            // Debug: Check if this entry contains "cooler" or "control"
            if (entry.name && (entry.name.toLowerCase().includes('cooler') || entry.name.toLowerCase().includes('control'))) {
    
            }
        }
        

        return null
    }
    
    /**
     * Find icon by looking for applications with matching executable names
     */
    function findIconByExecutable(appId) {
        const cleanId = appId.toLowerCase()
        
        for (let i = 0; i < desktopEntries.length; i++) {
            const entry = desktopEntries[i]
            const exec = (entry.exec || entry.execString || "").toLowerCase()
            
            // Check if executable name contains the appId
            if (exec.includes(cleanId) || cleanId.includes(exec.split('/').pop())) {
                if (entry.icon) {
                    const iconPath = Quickshell.iconPath(entry.icon, true)
                    if (iconPath.length > 0) {
                        return iconPath
                    }
                }
            }
        }
        
        return null
    }
    
    /**
     * Find icon by fuzzy name matching
     */
    function findIconByName(appId) {
        const cleanId = appId.toLowerCase().replace(/[^a-z0-9]/g, '')
        
        for (let i = 0; i < desktopEntries.length; i++) {
            const entry = desktopEntries[i]
            if (!entry.name) continue
            
            const entryName = entry.name.toLowerCase().replace(/[^a-z0-9]/g, '')
            
            // Check for exact matches first
            if (entryName === cleanId) {
                if (entry.icon) {
                    const iconPath = Quickshell.iconPath(entry.icon, true)
                    if (iconPath.length > 0) {
                        return iconPath
                    }
                }
            }
            
            // Check for partial matches
            if (entryName.includes(cleanId) || cleanId.includes(entryName)) {
                if (entry.icon) {
                    const iconPath = Quickshell.iconPath(entry.icon, true)
                    if (iconPath.length > 0) {
                        return iconPath
                    }
                }
            }
        }
        
        // Try with spaces added (e.g., "coolercontrols" -> "cooler controls")
        const spacedId = cleanId.replace(/([a-z])([A-Z])/g, '$1 $2').toLowerCase()
        for (let i = 0; i < desktopEntries.length; i++) {
            const entry = desktopEntries[i]
            if (!entry.name) continue
            
            const entryName = entry.name.toLowerCase()
            
            if (entryName.includes(spacedId) || spacedId.includes(entryName.replace(/\s+/g, ''))) {
                if (entry.icon) {
                    const iconPath = Quickshell.iconPath(entry.icon, true)
                    if (iconPath.length > 0) {
                        return iconPath
                    }
                }
            }
        }
        
        return null
    }
    
    /**
     * Get all possible icon variations for an app (useful for debugging)
     */
    function getIconVariations(appId) {
        const variations = []
        
        // Try desktop entry
        const desktopEntry = findDesktopEntry(appId)
        if (desktopEntry && desktopEntry.icon) {
            variations.push({
                method: "desktop_entry",
                icon: desktopEntry.icon,
                path: Quickshell.iconPath(desktopEntry.icon, true)
            })
        }
        
        // Try AppSearch
        const guessedIcon = AppSearch.guessIcon(appId)
        if (guessedIcon) {
            variations.push({
                method: "appsearch",
                icon: guessedIcon,
                path: Quickshell.iconPath(guessedIcon, true)
            })
        }
        
        // Try executable matching
        const execIcon = findIconByExecutable(appId)
        if (execIcon) {
            variations.push({
                method: "executable",
                icon: "exec_match",
                path: execIcon
            })
        }
        
        // Try name matching
        const nameIcon = findIconByName(appId)
        if (nameIcon) {
            variations.push({
                method: "name_match",
                icon: "name_match",
                path: nameIcon
            })
        }
        
        return variations
    }
} 