import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Item {
    id: hyprlandManager
    
    // Properties
    property var runningApps: []
    property var appWorkspaces: {} // Maps appId to workspace
    property var appWindows: {} // Maps appId to window list
    
    // Direct window list for instant detection (like HyprlandDE)
    property var windowList: []
    
    // Component initialization
    Component.onCompleted: {
        updateRunningApps()
    }
    
    // Hidden Repeater to access workspaces like the bar does
    Repeater {
        id: workspaceRepeater
        model: Hyprland.workspaces
        visible: false
        
        Item {
            id: workspaceItem
            property var workspaceData: modelData
            
            Component.onCompleted: {
            }
            
            // Hidden Repeater for toplevels (windows) in this workspace
            Repeater {
                id: windowRepeater
                model: workspaceItem.workspaceData ? workspaceItem.workspaceData.toplevels : null
                visible: false
                
                Item {
                    id: windowItem
                    property var windowData: modelData
                    
                    Component.onCompleted: {
                        // Try to get app ID from different sources
                        let appId = null
                        
                        if (modelData && modelData.class) {
                            appId = hyprlandManager.extractAppId(modelData.class)
                        } else if (modelData && modelData.appId) {
                            appId = hyprlandManager.extractAppId(modelData.appId)
                        } else if (modelData && modelData.wayland && modelData.wayland.appId) {
                            appId = hyprlandManager.extractAppId(modelData.wayland.appId)
                        }
                        
                        if (appId) {
                            if (appId && !hyprlandManager.runningApps.includes(appId)) {
                                hyprlandManager.runningApps.push(appId)
                                if (!hyprlandManager.appWorkspaces) hyprlandManager.appWorkspaces = {}
                                if (!hyprlandManager.appWindows) hyprlandManager.appWindows = {}
                                hyprlandManager.appWorkspaces[appId] = [workspaceItem.workspaceData.id]
                                hyprlandManager.appWindows[appId] = [modelData]
                                hyprlandManager.runningAppsChanged()
                            } else if (appId && hyprlandManager.runningApps.includes(appId)) {
                                // Add workspace and window to existing app
                                if (!hyprlandManager.appWorkspaces) hyprlandManager.appWorkspaces = {}
                                if (!hyprlandManager.appWindows) hyprlandManager.appWindows = {}
                                if (!hyprlandManager.appWorkspaces[appId]) {
                                    hyprlandManager.appWorkspaces[appId] = []
                                }
                                if (!hyprlandManager.appWindows[appId]) {
                                    hyprlandManager.appWindows[appId] = []
                                }
                                if (!hyprlandManager.appWorkspaces[appId].includes(workspaceItem.workspaceData.id)) {
                                    hyprlandManager.appWorkspaces[appId].push(workspaceItem.workspaceData.id)
                                }
                                if (!hyprlandManager.appWindows[appId].includes(modelData)) {
                                    hyprlandManager.appWindows[appId].push(modelData)
                                }
                            }
                        } else if (modelData && modelData.appId) {
                            const appId = hyprlandManager.extractAppId(modelData.appId)
                            if (appId && !hyprlandManager.runningApps.includes(appId)) {
                                hyprlandManager.runningApps.push(appId)
                                if (!hyprlandManager.appWorkspaces) hyprlandManager.appWorkspaces = {}
                                if (!hyprlandManager.appWindows) hyprlandManager.appWindows = {}
                                hyprlandManager.appWorkspaces[appId] = [workspaceItem.workspaceData.id]
                                hyprlandManager.appWindows[appId] = [modelData]
                                hyprlandManager.runningAppsChanged()
                            } else if (appId && hyprlandManager.runningApps.includes(appId)) {
                                // Add workspace and window to existing app
                                if (!hyprlandManager.appWorkspaces) hyprlandManager.appWorkspaces = {}
                                if (!hyprlandManager.appWindows) hyprlandManager.appWindows = {}
                                if (!hyprlandManager.appWorkspaces[appId]) {
                                    hyprlandManager.appWorkspaces[appId] = []
                                }
                                if (!hyprlandManager.appWindows[appId]) {
                                    hyprlandManager.appWindows[appId] = []
                                }
                                if (!hyprlandManager.appWorkspaces[appId].includes(workspaceItem.workspaceData.id)) {
                                    hyprlandManager.appWorkspaces[appId].push(workspaceItem.workspaceData.id)
                                }
                                if (!hyprlandManager.appWindows[appId].includes(modelData)) {
                                    hyprlandManager.appWindows[appId].push(modelData)
                                }
                            }
                        } else if (modelData.wayland && modelData.wayland.appId) {
                            const appId = hyprlandManager.extractAppId(modelData.wayland.appId)
                            if (appId && !hyprlandManager.runningApps.includes(appId)) {
                                hyprlandManager.runningApps.push(appId)
                                if (!hyprlandManager.appWorkspaces) hyprlandManager.appWorkspaces = {}
                                if (!hyprlandManager.appWindows) hyprlandManager.appWindows = {}
                                hyprlandManager.appWorkspaces[appId] = [workspaceItem.workspaceData.id]
                                hyprlandManager.appWindows[appId] = [modelData]
                                hyprlandManager.runningAppsChanged()
                            } else if (appId && hyprlandManager.runningApps.includes(appId)) {
                                // Add workspace and window to existing app
                                if (!hyprlandManager.appWorkspaces) hyprlandManager.appWorkspaces = {}
                                if (!hyprlandManager.appWindows) hyprlandManager.appWindows = {}
                                if (!hyprlandManager.appWorkspaces[appId]) {
                                    hyprlandManager.appWorkspaces[appId] = []
                                }
                                if (!hyprlandManager.appWindows[appId]) {
                                    hyprlandManager.appWindows[appId] = []
                                }
                                if (!hyprlandManager.appWorkspaces[appId].includes(workspaceItem.workspaceData.id)) {
                                    hyprlandManager.appWorkspaces[appId].push(workspaceItem.workspaceData.id)
                                }
                                if (!hyprlandManager.appWindows[appId].includes(modelData)) {
                                    hyprlandManager.appWindows[appId].push(modelData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Update running apps list
    function updateRunningApps() {
        var previousApps = runningApps.slice() // Copy previous list
        
        // Clear previous data
        runningApps = []
        appWorkspaces = {}
        appWindows = {}
        
        // Force the repeater to update
        workspaceRepeater.model = null
        workspaceRepeater.model = Hyprland.workspaces
        
        runningAppsChanged()
    }
    
    // Connect to Hyprland events
    Connections {
        target: Hyprland
        
        function onRawEvent(event) {
            if (event.name.includes("window") || event.name.includes("open") || event.name.includes("close") || 
                event.name.includes("add") || event.name.includes("remove")) {
                Qt.callLater(updateRunningApps)
            }
        }
    }
    
    // Validate window address before using it
    function validateWindowAddress(address) {
        if (!address) return false
        
        // Force update the running apps to get fresh window data
        updateRunningApps()
        
        // Check if the window still exists in the current window list
        for (const appId in appWindows) {
            const windows = appWindows[appId]
            if (windows && windows.some(window => window.address === address)) {
                return true
            }
        }
        return false
    }
    
    // Clean up invalid windows from the appWindows list
    function cleanupInvalidWindows() {
        for (const appId in appWindows) {
            const windows = appWindows[appId]
            if (windows) {
                // Remove windows that no longer exist
                for (let i = windows.length - 1; i >= 0; i--) {
                    const window = windows[i]
                    if (!validateWindowAddress(window.address)) {
                        windows.splice(i, 1)
                    }
                }
                // If no windows left for this app, remove the app from runningApps
                if (windows.length === 0) {
                    const index = runningApps.indexOf(appId)
                    if (index > -1) {
                        runningApps.splice(index, 1)
                        runningAppsChanged()
                    }
                }
            }
        }
    }
    
    // Check if an app is running
    function isAppRunning(appId) {
        // Direct match
        if (runningApps.includes(appId)) return true
        
        // Case-insensitive match
        for (var i = 0; i < runningApps.length; i++) {
            if (runningApps[i].toLowerCase() === appId.toLowerCase()) return true
        }
        
        // Check with .desktop extension
        if (runningApps.includes(appId + ".desktop")) return true
        
        // Check without .desktop extension
        if (appId.endsWith(".desktop")) {
            var withoutDesktop = appId.substring(0, appId.length - 8)
            if (runningApps.includes(withoutDesktop)) return true
        }
        
        // Check for common variations
        var variations = [
            appId,
            appId + ".desktop",
            appId.replace(/-/g, ""),
            appId.replace(/-/g, "") + ".desktop"
        ]
        
        for (var i = 0; i < variations.length; i++) {
            if (runningApps.includes(variations[i])) return true
        }
        
        return false
    }
    
    // Get the workspace where an app is running
    function getAppWorkspace(appId) {
        // Direct match
        if (appWorkspaces && appWorkspaces[appId] && appWorkspaces[appId].length > 0) {
            return appWorkspaces[appId][0] // Return first workspace
        }
        
        // Case-insensitive match
        for (var key in appWorkspaces) {
            if (key.toLowerCase() === appId.toLowerCase() && appWorkspaces[key].length > 0) {
                return appWorkspaces[key][0]
            }
        }
        
        // Check with .desktop extension
        if (appId.endsWith(".desktop")) {
            var withoutDesktop = appId.substring(0, appId.length - 8)
            if (appWorkspaces && appWorkspaces[withoutDesktop] && appWorkspaces[withoutDesktop].length > 0) {
                return appWorkspaces[withoutDesktop][0]
            }
        } else {
            // Check without .desktop extension
            var withDesktop = appId + ".desktop"
            if (appWorkspaces && appWorkspaces[withDesktop] && appWorkspaces[withDesktop].length > 0) {
                return appWorkspaces[withDesktop][0]
            }
        }
        
        // Check for common variations
        var variations = [
            appId,
            appId + ".desktop",
            appId.replace(/-/g, ""),
            appId.replace(/-/g, "") + ".desktop"
        ]
        
        for (var i = 0; i < variations.length; i++) {
            if (appWorkspaces && appWorkspaces[variations[i]] && appWorkspaces[variations[i]].length > 0) {
                return appWorkspaces[variations[i]][0]
            }
        }
        
        return 1
    }
    
    // Get all workspaces where an app is running
    function getAppWorkspaces(appId) {
        return []
    }
    
    // Handle app click (switch to workspace or launch)
    function handleAppClick(appId, isRunning) {
        if (isRunning) {
            // Switch to the workspace where the app is running
            const workspace = getAppWorkspace(appId)
            Hyprland.dispatch("workspace " + workspace)
            
            // Focus the app window using proper window address
            const windows = appWindows && appWindows[appId]
            if (windows && windows.length > 0) {
                const window = windows[0]
                if (validateWindowAddress(window.address)) {
                    Hyprland.dispatch("focuswindow " + window.address)
                }
            }
        } else {
            // Launch the app
            launchApp(appId)
        }
    }
    
    // Launch an app
    function launchApp(appId) {
        const appName = extractAppName(appId)
        if (appName) {
            // Use Hyprland dispatch to launch the app
            try {
                Hyprland.dispatch("exec " + appName)
            } catch (error) {
                // Fallback: try with different variations
                const variations = [
                    appName,
                    appName + " &",
                    "nohup " + appName + " > /dev/null 2>&1 &",
                    "gtk-launch " + appName,
                    "gtk-launch " + appName + ".desktop"
                ]
                
                for (let i = 0; i < variations.length; i++) {
                    try {
                        Hyprland.dispatch("exec " + variations[i])
                        break
                    } catch (e) {
                        // Continue to next variation
                    }
                }
            }
        }
    }
    
    // Move an app to a specific workspace
    function moveAppToWorkspace(appId, workspace) {
        const appClass = getAppClass(appId)
        if (appClass) {
            try {
                // Use the correct Hyprland syntax for moving windows to workspace
                Hyprland.dispatch("movetoworkspace " + workspace + ",class:" + appClass)
            } catch (error) {
                // Error handling
            }
        }
    }
    
    // Toggle floating mode for an app
    function toggleAppFloating(appId) {
        // Use the correct Hyprland syntax for app-based floating toggle
        const appClass = getAppClass(appId)
        if (appClass) {
            try {
                // Use the correct Hyprland syntax
                Hyprland.dispatch("togglefloating class:" + appClass)
            } catch (error) {
                // Error handling
            }
        }
    }
    
    // Get app class name from app ID
    function getAppClass(appId) {
        // Map app IDs to their actual class names
        const appClassMap = {
            "microsoftedgedev": "microsoft-edge-dev",
            "orggnomeptyxis": "org.gnome.Ptyxis",
            "vesktop": "vesktop",
            "cursor": "cursor"
        }
        return appClassMap[appId] || appId
    }
    
    // Close a specific app window
    function closeApp(appId) {
        const appClass = getAppClass(appId)
        if (appClass) {
            try {
                Hyprland.dispatch("closewindow class:" + appClass)
            } catch (error) {
                // Error handling
            }
        }
    }
    
    // Close all windows of an app
    function closeAllAppWindows(appId) {
        const appClass = getAppClass(appId)
        if (appClass) {
            try {
                Hyprland.dispatch("closewindow class:" + appClass)
            } catch (error) {
                // Error handling
            }
        }
    }
    
    // Extract app ID from window class
    function extractAppId(windowClass) {
        if (!windowClass) return ""
        
        // Keep the original window class name, just convert to lowercase
        // This preserves hyphens, dots, and other separators that are important for icon names
        return windowClass.toLowerCase()
    }
    
    // Extract app name from app ID for launching
    function extractAppName(appId) {
        if (!appId) return ""
        
        // Map app IDs to their actual launch commands
        const appLaunchMap = {
            "microsoftedgedev": "microsoft-edge-dev",
            "orggnomeptyxis": "ptyxis",
            "vesktop": "vesktop",
            "cursor": "cursor",
            "code": "code",
            "firefox": "firefox",
            "chrome": "google-chrome",
            "googlechrome": "google-chrome",
            "discord": "discord",
            "spotify": "spotify",
            "steam": "steam",
            "telegram": "telegram-desktop",
            "thunderbird": "thunderbird",
            "libreoffice": "libreoffice",
            "gimp": "gimp",
            "inkscape": "inkscape",
            "blender": "blender",
            "audacity": "audacity",
            "vlc": "vlc",
            "mpv": "mpv",
            "obs": "obs",
            "kdenlive": "kdenlive",
            "davinci": "davinci-resolve",
            "krita": "krita",
            "darktable": "darktable",
            "rawtherapee": "rawtherapee",
            "digikam": "digikam",
            "shotwell": "shotwell",
            "gwenview": "gwenview",
            "okular": "okular",
            "evince": "evince",
            "calibre": "calibre",
            "qbittorrent": "qbittorrent",
            "transmission": "transmission-gtk",
            "deluge": "deluge",
            "filezilla": "filezilla",
            "wireshark": "wireshark",
            "virtualbox": "virtualbox",
            "vmware": "vmware",
            "docker": "docker",
            "postman": "postman",
            "insomnia": "insomnia",
            "dbeaver": "dbeaver",
            "mysql": "mysql-workbench",
            "pgadmin": "pgadmin4",
            "mongodb": "mongodb-compass",
            "redis": "redis-desktop-manager",
            "gitkraken": "gitkraken",
            "sourcetree": "sourcetree",
            "android": "android-studio",
            "intellij": "intellij-idea-community",
            "eclipse": "eclipse",
            "netbeans": "netbeans",
            "sublime": "sublime_text",
            "atom": "atom",
            "vim": "gvim",
            "emacs": "emacs",
            "neovim": "nvim",
            "terminator": "terminator",
            "tilix": "tilix",
            "konsole": "konsole",
            "gnome-terminal": "gnome-terminal",
            "xfce4-terminal": "xfce4-terminal",
            "alacritty": "alacritty",
            "kitty": "kitty",
            "wezterm": "wezterm",
            "foot": "foot",
            "st": "st",
            "urxvt": "urxvt",
            "xterm": "xterm",
            "rxvt": "rxvt-unicode",
            "dolphin": "dolphin",
            "nautilus": "nautilus",
            "thunar": "thunar",
            "pcmanfm": "pcmanfm",
            "caja": "caja",
            "nemo": "nemo",
            "krusader": "krusader",
            "doublecmd": "doublecmd",
            "mc": "mc",
            "ranger": "ranger",
            "nnn": "nnn",
            "lf": "lf",
            "joshuto": "joshuto",
            "broot": "broot",
            "fzf": "fzf",
            "ripgrep": "rg",
            "fd": "fd",
            "bat": "bat",
            "exa": "exa",
            "lsd": "lsd",
            "tree": "tree",
            "htop": "htop",
            "btop": "btop",
            "glances": "glances",
            "iotop": "iotop",
            "nethogs": "nethogs",
            "wireshark": "wireshark",
            "nmap": "nmap",
            "zenmap": "zenmap",
            "metasploit": "msfconsole",
            "burp": "burp-suite",
            "wireshark": "wireshark",
            "tcpdump": "tcpdump",
            "nethogs": "nethogs",
            "iftop": "iftop",
            "bmon": "bmon",
            "speedtest": "speedtest-cli",
            "ping": "ping",
            "traceroute": "traceroute",
            "dig": "dig",
            "nslookup": "nslookup",
            "whois": "whois",
            "ssh": "ssh",
            "scp": "scp",
            "rsync": "rsync",
            "sftp": "sftp",
            "ftp": "ftp",
            "telnet": "telnet",
            "nc": "nc",
            "netcat": "netcat",
            "curl": "curl",
            "wget": "wget",
            "aria2": "aria2c",
            "transmission": "transmission-gtk",
            "qbittorrent": "qbittorrent",
            "deluge": "deluge",
            "rtorrent": "rtorrent",
            "ktorrent": "ktorrent",
            "frostwire": "frostwire",
            "limewire": "limewire",
            "emule": "emule",
            "amule": "amule",
            "bittorrent": "bittorrent",
            "utorrent": "utorrent",
            "vuze": "vuze",
            "azureus": "azureus",
            "bitcomet": "bitcomet",
            "bitlord": "bitlord",
            "bitrocket": "bitrocket",
            "bitspirit": "bitspirit",
            "bitstorm": "bitstorm",
            "bitstormlite": "bitstormlite",
            "bitstormlite2": "bitstormlite2",
            "bitstormlite3": "bitstormlite3",
            "bitstormlite4": "bitstormlite4",
            "bitstormlite5": "bitstormlite5",
            "bitstormlite6": "bitstormlite6",
            "bitstormlite7": "bitstormlite7",
            "bitstormlite8": "bitstormlite8",
            "bitstormlite9": "bitstormlite9",
            "bitstormlite10": "bitstormlite10"
        }
        
        // First try the direct mapping
        if (appLaunchMap[appId]) {
            return appLaunchMap[appId]
        }
        
        // If no direct mapping, try to convert common patterns
        let convertedName = appId
        
        // Convert camelCase to kebab-case
        convertedName = convertedName.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase()
        
        // Convert underscores to hyphens
        convertedName = convertedName.replace(/_/g, '-')
        
        // Remove common prefixes
        const prefixes = ['org.gnome.', 'org.kde.', 'com.microsoft.', 'com.google.', 'com.github.', 'org.', 'com.', 'io.', 'net.', 'dev.']
        for (let i = 0; i < prefixes.length; i++) {
            if (convertedName.startsWith(prefixes[i])) {
                convertedName = convertedName.substring(prefixes[i].length)
                break
            }
        }
        
        // Remove common suffixes
        const suffixes = ['-dev', '-stable', '-beta', '-alpha', '-nightly', '-canary', '.desktop']
        for (let i = 0; i < suffixes.length; i++) {
            if (convertedName.endsWith(suffixes[i])) {
                convertedName = convertedName.substring(0, convertedName.length - suffixes[i].length)
                break
            }
        }
        
        // Clean up multiple hyphens
        convertedName = convertedName.replace(/-+/g, '-')
        convertedName = convertedName.replace(/^-+|-+$/g, '')
        
        return convertedName || appId
    }
    
    // Get current workspace
    function getCurrentWorkspace() {
        const activeWorkspace = Hyprland.workspaces.find(w => w.active)
        return activeWorkspace ? activeWorkspace.id : 1
    }
    
    // The runningAppsChanged signal is automatically generated by Qt for the runningApps property
} 