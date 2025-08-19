pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Qt.labs.platform



Singleton {
    id: manager

    signal configUpdated()
    property var config: {}
    property string configFile: Quickshell.shellDir + "/config.json"
    property string settingsFile: `${StandardPaths.writableLocation(StandardPaths.HomeLocation)}/.local/state/Quickshell/Settings.conf`

    function loadConfig() {
        try {
            // Try to read existing config file
            var configData = Quickshell.Io.readFile(configFile)
            if (configData && configData.length > 0) {
                config = JSON.parse(configData)
                console.log("Loaded config from file")
            } else {
                config = {}
                console.log("No existing config, using empty config")
            }
        } catch (e) {
            config = {}
            console.log("Error loading config, using empty config:", e)
        }
    }

    function saveConfig() {
        try {
            var configJson = JSON.stringify(config, null, 2)
            Quickshell.Io.writeFile(configFile, configJson)
            console.log("Config saved to file")
        } catch (e) {
            console.log("Error saving config:", e)
        }
    }
    
    function loadSettings() {
        try {
            var settingsData = Quickshell.Io.readFile(settingsFile)
            if (settingsData && settingsData.length > 0) {
                var settings = JSON.parse(settingsData)
                return settings
            } else {
                return {}
            }
        } catch (e) {
            console.log("Error loading settings, using empty settings:", e)
            return {}
        }
    }
    
    function saveSettings(settings) {
        try {
            // Use Hyprland.dispatch to create directory and write file (like the reference implementation)
            var dirPath = `${StandardPaths.writableLocation(StandardPaths.HomeLocation)}/.local/state/Quickshell`
            console.log("Creating directory:", dirPath)
            
            // Create directory using Hyprland.dispatch
            Hyprland.dispatch(`exec mkdir -p '${dirPath}'`)
            
            var settingsJson = JSON.stringify(settings, null, 2)
            console.log("About to save settings:", settingsJson)
            console.log("To file:", settingsFile)
            
            // Write file using Hyprland.dispatch (escape single quotes properly)
            var escapedJson = settingsJson.replace(/'/g, "'\"'\"'")
            Hyprland.dispatch(`exec echo '${escapedJson}' > '${settingsFile.replace('file://', '')}'`)
            
            console.log("Settings saved to Settings.conf successfully using Hyprland.dispatch")
        } catch (e) {
            console.log("Error saving settings:", e)
            console.log("Error details:", e.message)
        }
    }

    function getValue(path) {
        var keys = path.split('.')
        var value = config
        for (var i = 0; i < keys.length; i++) {
            if (value && typeof value === 'object' && keys[i] in value) {
                value = value[keys[i]]
            } else {
                return null
            }
        }
        return value
    }

    function setValue(path, newValue) {
        var keys = path.split('.')
        var current = config
        for (var i = 0; i < keys.length - 1; i++) {
            if (!(keys[i] in current) || typeof current[keys[i]] !== 'object') {
                current[keys[i]] = {}
            }
            current = current[keys[i]]
        }
        current[keys[keys.length - 1]] = newValue
        saveConfig()
        configUpdated()
    }

    Component.onCompleted: {
        loadConfig()
    }


} 