import QtQuick
import Quickshell
import Quickshell.Io
import qs.Settings

pragma Singleton

QtObject {
    id: wallpaperService
    
    // Properties
    property var wallpaperList: []
    property bool scanning: false
    property bool randomWallpaperEnabled: false
    property Timer randomWallpaperTimer: Timer {
        interval: (Settings.settings.wallpaperInterval || 300) * 1000
        repeat: true
        onTriggered: {
            if (randomWallpaperEnabled && wallpaperList.length > 0) {
                var randomIndex = Math.floor(Math.random() * wallpaperList.length)
                setWallpaper(wallpaperList[randomIndex])
            }
        }
    }
    
    // Signals
    signal wallpaperChanged(string path)
    signal scanComplete(int count)
    signal scanError(string error)
    
    // Initialize
    Component.onCompleted: {
        scanWallpapers()
        if (Settings.settings.randomWallpaper) {
            toggleRandomWallpaper()
        }
    }
    
    // Methods
    function scanWallpapers() {
        scanning = true
        wallpaperList = []
        
        var wallpaperFolder = Settings.settings.wallpaperFolder || Quickshell.env("HOME") + "/.config/quickshell/Wallpaper"
        
        // Ensure directory exists
        var dir = Quickshell.Io.Dir.open(wallpaperFolder)
        if (!dir.exists()) {
            dir.mkpath(wallpaperFolder)
        }
        
        // Scan for image files
        var entries = dir.entryList(["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.webp"], Quickshell.Io.Dir.Files)
        
        for (var i = 0; i < entries.length; i++) {
            var filePath = wallpaperFolder + "/" + entries[i]
            wallpaperList.push(filePath)
        }
        
        scanning = false
        scanComplete(wallpaperList.length)
        console.log("Scanned", wallpaperList.length, "wallpapers from", wallpaperFolder)
    }
    
    function setWallpaper(path) {
        if (!path || path === "") {
            console.error("Invalid wallpaper path")
            return
        }
        
        // Update settings
        Settings.settings.currentWallpaper = path
        
        // Use SWWW if enabled
        if (Settings.settings.useSWWW) {
            var swwwCommand = "swww img"
            
            // Add transition options
            var transitionType = Settings.settings.transitionType || "random"
            var transitionFps = Settings.settings.transitionFps || 60
            var transitionDuration = Settings.settings.transitionDuration || 1.0
            var resizeMode = Settings.settings.wallpaperResize || "crop"
            
            swwwCommand += " --transition-type " + transitionType
            swwwCommand += " --transition-fps " + transitionFps
            swwwCommand += " --transition-duration " + transitionDuration
            swwwCommand += " --resize " + resizeMode
            swwwCommand += " " + path
            
            console.log("Executing SWWW command:", swwwCommand)
            
            // Execute SWWW command
            Quickshell.Io.Process.exec(swwwCommand, function(exitCode, stdout, stderr) {
                if (exitCode === 0) {
                    console.log("SWWW wallpaper set successfully")
                    wallpaperChanged(path)
                } else {
                    console.error("SWWW failed:", stderr)
                    // Fallback to basic wallpaper setting
                    setBasicWallpaper(path)
                }
            })
        } else {
            // Use basic wallpaper setting
            setBasicWallpaper(path)
        }
    }
    
    function setBasicWallpaper(path) {
        // Try different wallpaper setting methods
        var commands = [
            "swaybg -i " + path + " -m fill",
            "feh --bg-fill " + path,
            "nitrogen --set-zoom-fill " + path,
            "gsettings set org.gnome.desktop.background picture-uri " + path
        ]
        
        for (var i = 0; i < commands.length; i++) {
            Quickshell.Io.Process.exec(commands[i], function(exitCode, stdout, stderr) {
                if (exitCode === 0) {
                    console.log("Wallpaper set using:", commands[i])
                    wallpaperChanged(path)
                    return
                }
            })
        }
    }
    
    function toggleRandomWallpaper() {
        randomWallpaperEnabled = !randomWallpaperEnabled
        Settings.settings.randomWallpaper = randomWallpaperEnabled
        
        if (randomWallpaperEnabled) {
            randomWallpaperTimer.start()
            console.log("Random wallpaper enabled")
        } else {
            randomWallpaperTimer.stop()
            console.log("Random wallpaper disabled")
        }
    }
    
    function restartRandomWallpaperTimer() {
        if (randomWallpaperEnabled) {
            randomWallpaperTimer.interval = (Settings.settings.wallpaperInterval || 300) * 1000
            randomWallpaperTimer.restart()
        }
    }
    
    function setRandomWallpaper() {
        if (wallpaperList.length > 0) {
            var randomIndex = Math.floor(Math.random() * wallpaperList.length)
            setWallpaper(wallpaperList[randomIndex])
        }
    }
} 