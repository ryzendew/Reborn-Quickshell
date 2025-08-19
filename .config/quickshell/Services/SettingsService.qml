pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Settings

/**
 * Settings Service
 * Manages all application settings and saves them to Settings.conf
 */
Singleton {
    id: root

    // Signal when any settings change
    signal settingsChanged()
    
    // Time settings
    property string timeFormat: "12h"
    property string dateFormat: "MMM dd"
    property string timezone: "UTC"
    property bool showSeconds: false
    property bool showDate: true
    property bool timeBold: false
    property bool dateBold: false
    property int timeSize: 14
    property int dateSize: 11
    property int timeSpacing: 2
    property string timeColor: "#ffffff"
    property string dateColor: "#ffffff"
    property string monthFormat: "short"
    
    // User settings
    property string userImage: ""
    
    // Network settings
    property string networkMode: "dhcp" // dhcp or static
    property string staticIP: ""
    property string staticSubnet: ""
    property string staticGateway: ""
    property string staticDNS: ""
    
    // Power settings
    property string powerProfile: "balanced" // power-saver, balanced, performance
    property bool autoSuspend: true
    property int suspendTimeout: 30 // minutes
    property string lidCloseAction: "suspend" // suspend, hibernate, nothing
    
    // Sound settings
    property int masterVolume: 50
    property bool muteMaster: false
    property int headphoneVolume: 50
    property int speakerVolume: 50
    property int microphoneVolume: 50
    property bool muteMicrophone: false
    
    // Bluetooth settings
    property bool bluetoothEnabled: true
    property var bluetoothDevices: []
    
    // WiFi settings
    property bool wifiEnabled: true
    property var wifiNetworks: []
    
    // Wallpaper settings
    property string wallpaperPath: ""
    property string wallpaperMode: "fill" // fill, fit, stretch, center, tile
    property bool autoWallpaper: false
    property int wallpaperInterval: 3600 // seconds
    
    // Bar settings
    property int barHeight: 40
    property string barColor: "#2a2a2a"
    property real barOpacity: 0.9
    property bool barDimmed: true  // Bar transparency setting
    property string barPosition: "top" // top, bottom
    property bool barShowWorkspaces: true
    property bool barShowTime: true
    property bool barShowDate: true
    property bool barShowVolume: true
    property bool barShowNetwork: true
    property bool barShowBattery: true
    
    // Dock settings
    property int dockHeight: 60
    property string dockColor: "#2a2a2a"
    property real dockOpacity: 0.9
    property bool dockDimmed: true  // Dock transparency setting
    property string dockPosition: "bottom" // top, bottom, left, right
    property int dockIconSize: 48
    property bool dockShowLabels: true
    property bool dockAutoHide: true
    property int dockHideDelay: 1000 // milliseconds
    
    // General settings
    property string theme: "dark" // dark, light, auto
    property bool animations: true
    property int animationsDuration: 200 // milliseconds
    property bool notifications: true
    property string notificationPosition: "top-right"
    property int notificationDuration: 5000 // milliseconds
    property var startupApps: []
    property string language: "en_US"
    
    // Logo settings (existing)
    property string barLogo: "arch-symbolic.svg"
    property string dockLogo: "arch-symbolic.svg"
    property string logoColor: "#ffffff"
    
    // Load all settings from Settings.conf
    function loadAllSettings() {
        try {
            var settings = ConfigService.loadSettings()
            
            // Time settings
            if (settings.timeFormat) timeFormat = settings.timeFormat
            if (settings.dateFormat) dateFormat = settings.dateFormat
            if (settings.timezone) timezone = settings.timezone
            if (settings.showSeconds !== undefined) showSeconds = settings.showSeconds
            if (settings.showDate !== undefined) showDate = settings.showDate
            if (settings.timeBold !== undefined) timeBold = settings.timeBold
            if (settings.dateBold !== undefined) dateBold = settings.dateBold
            if (settings.timeSize) timeSize = settings.timeSize
            if (settings.dateSize) dateSize = settings.dateSize
            if (settings.timeSpacing) timeSpacing = settings.timeSpacing
            if (settings.timeColor) timeColor = settings.timeColor
            if (settings.dateColor) dateColor = settings.dateColor
            if (settings.monthFormat) monthFormat = settings.monthFormat
            
            // User settings
            if (settings.userImage) userImage = settings.userImage
            
            // Network settings
            if (settings.networkMode) networkMode = settings.networkMode
            if (settings.staticIP) staticIP = settings.staticIP
            if (settings.staticSubnet) staticSubnet = settings.staticSubnet
            if (settings.staticGateway) staticGateway = settings.staticGateway
            if (settings.staticDNS) staticDNS = settings.staticDNS
            
            // Power settings
            if (settings.powerProfile) powerProfile = settings.powerProfile
            if (settings.autoSuspend !== undefined) autoSuspend = settings.autoSuspend
            if (settings.suspendTimeout) suspendTimeout = settings.suspendTimeout
            if (settings.lidCloseAction) lidCloseAction = settings.lidCloseAction
            
            // Sound settings
            if (settings.masterVolume) masterVolume = settings.masterVolume
            if (settings.muteMaster !== undefined) muteMaster = settings.muteMaster
            if (settings.headphoneVolume) headphoneVolume = settings.headphoneVolume
            if (settings.speakerVolume) speakerVolume = settings.speakerVolume
            if (settings.microphoneVolume) microphoneVolume = settings.microphoneVolume
            if (settings.muteMicrophone !== undefined) muteMicrophone = settings.muteMicrophone
            
            // Bluetooth settings
            if (settings.bluetoothEnabled !== undefined) bluetoothEnabled = settings.bluetoothEnabled
            if (settings.bluetoothDevices) bluetoothDevices = settings.bluetoothDevices
            
            // WiFi settings
            if (settings.wifiEnabled !== undefined) wifiEnabled = settings.wifiEnabled
            if (settings.wifiNetworks) wifiNetworks = settings.wifiNetworks
            
            // Wallpaper settings
            if (settings.wallpaperPath) wallpaperPath = settings.wallpaperPath
            if (settings.wallpaperMode) wallpaperMode = settings.wallpaperMode
            if (settings.autoWallpaper !== undefined) autoWallpaper = settings.autoWallpaper
            if (settings.wallpaperInterval) wallpaperInterval = settings.wallpaperInterval
            
            // Bar settings
            if (settings.barHeight) barHeight = settings.barHeight
            if (settings.barColor) barColor = settings.barColor
            if (settings.barOpacity) barOpacity = settings.barOpacity
            if (settings.barDimmed !== undefined) barDimmed = settings.barDimmed
            if (settings.barPosition) barPosition = settings.barPosition
            if (settings.barShowWorkspaces !== undefined) barShowWorkspaces = settings.barShowWorkspaces
            if (settings.barShowTime !== undefined) barShowTime = settings.barShowTime
            if (settings.barShowDate !== undefined) barShowDate = settings.barShowDate
            if (settings.barShowVolume !== undefined) barShowVolume = settings.barShowVolume
            if (settings.barShowNetwork !== undefined) barShowNetwork = settings.barShowNetwork
            if (settings.barShowBattery !== undefined) barShowBattery = settings.barShowBattery
            
            // Dock settings
            if (settings.dockHeight) dockHeight = settings.dockHeight
            if (settings.dockColor) dockColor = settings.dockColor
            if (settings.dockOpacity) dockOpacity = settings.dockOpacity
            if (settings.dockDimmed !== undefined) dockDimmed = settings.dockDimmed
            if (settings.dockPosition) dockPosition = settings.dockPosition
            if (settings.dockIconSize) dockIconSize = settings.dockIconSize
            if (settings.dockShowLabels !== undefined) dockShowLabels = settings.dockShowLabels
            if (settings.dockAutoHide !== undefined) dockAutoHide = settings.dockAutoHide
            if (settings.dockHideDelay) dockHideDelay = settings.dockHideDelay
            
            // General settings
            if (settings.theme) theme = settings.theme
            if (settings.animations !== undefined) animations = settings.animations
            if (settings.animationsDuration) animationsDuration = settings.animationsDuration
            if (settings.notifications !== undefined) notifications = settings.notifications
            if (settings.notificationPosition) notificationPosition = settings.notificationPosition
            if (settings.notificationDuration) notificationDuration = settings.notificationDuration
            if (settings.startupApps) startupApps = settings.startupApps
            if (settings.language) language = settings.language
            
            // Logo settings
            if (settings.barLogo) barLogo = settings.barLogo
            if (settings.dockLogo) dockLogo = settings.dockLogo
            if (settings.logoColor) logoColor = settings.logoColor
            
            console.log("SettingsService: All settings loaded from Settings.conf")
        } catch (e) {
            console.log("Error loading settings:", e)
        }
    }
    
    // Save all settings to Settings.conf
    function saveAllSettings() {
        try {
            var settings = {
                // Time settings
                timeFormat: timeFormat,
                dateFormat: dateFormat,
                timezone: timezone,
                showSeconds: showSeconds,
                showDate: showDate,
                timeBold: timeBold,
                dateBold: dateBold,
                timeSize: timeSize,
                dateSize: dateSize,
                timeSpacing: timeSpacing,
                timeColor: timeColor,
                dateColor: dateColor,
                monthFormat: monthFormat,
                
                // User settings
                userImage: userImage,
                
                // Network settings
                networkMode: networkMode,
                staticIP: staticIP,
                staticSubnet: staticSubnet,
                staticGateway: staticGateway,
                staticDNS: staticDNS,
                
                // Power settings
                powerProfile: powerProfile,
                autoSuspend: autoSuspend,
                suspendTimeout: suspendTimeout,
                lidCloseAction: lidCloseAction,
                
                // Sound settings
                masterVolume: masterVolume,
                muteMaster: muteMaster,
                headphoneVolume: headphoneVolume,
                speakerVolume: speakerVolume,
                microphoneVolume: microphoneVolume,
                muteMicrophone: muteMicrophone,
                
                // Bluetooth settings
                bluetoothEnabled: bluetoothEnabled,
                bluetoothDevices: bluetoothDevices,
                
                // WiFi settings
                wifiEnabled: wifiEnabled,
                wifiNetworks: wifiNetworks,
                
                // Wallpaper settings
                wallpaperPath: wallpaperPath,
                wallpaperMode: wallpaperMode,
                autoWallpaper: autoWallpaper,
                wallpaperInterval: wallpaperInterval,
                
                // Bar settings
                barHeight: barHeight,
                barColor: barColor,
                barOpacity: barOpacity,
                barDimmed: barDimmed,
                barPosition: barPosition,
                barShowWorkspaces: barShowWorkspaces,
                barShowTime: barShowTime,
                barShowDate: barShowDate,
                barShowVolume: barShowVolume,
                barShowNetwork: barShowNetwork,
                barShowBattery: barShowBattery,
                
                // Dock settings
                dockHeight: dockHeight,
                dockColor: dockColor,
                dockOpacity: dockOpacity,
                dockDimmed: dockDimmed,
                dockPosition: dockPosition,
                dockIconSize: dockIconSize,
                dockShowLabels: dockShowLabels,
                dockAutoHide: dockAutoHide,
                dockHideDelay: dockHideDelay,
                
                // General settings
                theme: theme,
                animations: animations,
                animationsDuration: animationsDuration,
                notifications: notifications,
                notificationPosition: notificationPosition,
                notificationDuration: notificationDuration,
                startupApps: startupApps,
                language: language,
                
                // Logo settings
                barLogo: barLogo,
                dockLogo: dockLogo,
                logoColor: logoColor
            }
            
            ConfigService.saveSettings(settings)
            console.log("SettingsService: All settings saved to Settings.conf")
            settingsChanged()
        } catch (e) {
            console.log("Error saving settings:", e)
        }
    }
    
    // Save specific settings (for individual tabs)
    function saveSettings(category, values) {
        try {
            var settings = ConfigService.loadSettings()
            
            // Update with new values
            for (var key in values) {
                settings[key] = values[key]
            }
            
            ConfigService.saveSettings(settings)
            console.log("SettingsService: Settings saved for category:", category)
            settingsChanged()
        } catch (e) {
            console.log("Error saving settings for category:", category, e)
        }
    }
    
    // Load settings on startup
    Component.onCompleted: {
        loadAllSettings()
    }
} 