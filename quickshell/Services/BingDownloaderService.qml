import QtQuick
import Quickshell
import Quickshell.Io
import qs.Settings

pragma Singleton

QtObject {
    id: bingDownloaderService
    
    // Properties
    property bool downloading: false
    property string currentPreview: ""
    
    // Signals
    signal statusChanged(string message)
    signal downloadComplete(string filename)
    signal downloadError(string error)
    
    // Methods
    function downloadCurrent() {
        var country = (Settings.settings && Settings.settings.bingCountry) ? Settings.settings.bingCountry : "United States"
        var resolution = (Settings.settings && Settings.settings.bingResolution) ? Settings.settings.bingResolution : "4K"
        var downloadFolder = (Settings.settings && Settings.settings.wallpaperFolder) ? Settings.settings.wallpaperFolder : Quickshell.env("HOME") + "/.config/quickshell/Wallpaper"
        
        downloadWallpaper(country, "current", resolution, downloadFolder)
    }
    
    function downloadMonth() {
        var country = (Settings.settings && Settings.settings.bingCountry) ? Settings.settings.bingCountry : "United States"
        var month = (Settings.settings && Settings.settings.bingMonth) ? Settings.settings.bingMonth : "current"
        var resolution = (Settings.settings && Settings.settings.bingResolution) ? Settings.settings.bingResolution : "4K"
        var downloadFolder = (Settings.settings && Settings.settings.wallpaperFolder) ? Settings.settings.wallpaperFolder : Quickshell.env("HOME") + "/.config/quickshell/Wallpaper"
        
        if (month === "Current") {
            downloadWallpaper(country, "current", resolution, downloadFolder)
        } else {
            downloadWallpaper(country, month, resolution, downloadFolder)
        }
    }
    
    function downloadWallpaper(country, month, resolution, downloadFolder) {
        downloading = true
        statusChanged("Starting download for " + country + " (" + month + ") at " + resolution + " resolution...")
        
        // Build the download URL based on the Bing wallpaper service
        var baseUrl = "https://bingwallpaper.anerg.com/"
        var downloadUrl = ""
        var filename = ""
        
        if (month === "current") {
            // Current wallpaper
            downloadUrl = baseUrl + "download/" + country + "/current"
            filename = "bing_" + country.toLowerCase().replace(/\s+/g, "_") + "_current.jpg"
        } else {
            // Specific month
            downloadUrl = baseUrl + "download/" + country + "/" + month
            filename = "bing_" + country.toLowerCase().replace(/\s+/g, "_") + "_" + month + ".jpg"
        }
        
        // Add resolution parameter
        if (resolution === "4K") {
            downloadUrl += "?resolution=4k"
        } else if (resolution === "2K") {
            downloadUrl += "?resolution=2k"
        } else {
            downloadUrl += "?resolution=1080p"
        }
        
        var fullPath = downloadFolder + "/" + filename
        
        // First ensure directory exists, then check file, then download
        Quickshell.Io.Process.exec("mkdir -p \"" + downloadFolder + "\"", function(exitCode, stdout, stderr) {
            // Now check if file exists
            Quickshell.Io.Process.exec("test -f \"" + fullPath + "\"", function(exitCode2, stdout2, stderr2) {
                if (exitCode2 === 0) {
                    statusChanged("File already exists: " + filename)
                    downloading = false
                    downloadComplete(filename)
                    return
                }
                
                // File doesn't exist, proceed with download
                statusChanged("Downloading from: " + downloadUrl)
                
                // Use curl to download the wallpaper
                var curlCommand = "curl -L -o \"" + fullPath + "\" \"" + downloadUrl + "\""
                
                Quickshell.Io.Process.exec(curlCommand, function(exitCode3, stdout3, stderr3) {
                    downloading = false
                    
                    if (exitCode3 === 0) {
                        statusChanged("Download completed: " + filename)
                        downloadComplete(filename)
                        
                        // Update preview
                        currentPreview = fullPath
                    } else {
                        var errorMsg = "Download failed: " + stderr3
                        statusChanged(errorMsg)
                        downloadError(errorMsg)
                    }
                })
            })
        })
    }
    
    function getCurrentPreview() {
        var country = (Settings.settings && Settings.settings.bingCountry) ? Settings.settings.bingCountry : "United States"
        var resolution = (Settings.settings && Settings.settings.bingResolution) ? Settings.settings.bingResolution : "4K"
        
        // Build preview URL
        var baseUrl = "https://bingwallpaper.anerg.com/"
        var previewUrl = baseUrl + "preview/" + country + "/current"
        
        if (resolution === "4K") {
            previewUrl += "?resolution=4k"
        } else if (resolution === "2K") {
            previewUrl += "?resolution=2k"
        } else {
            previewUrl += "?resolution=1080p"
        }
        
        currentPreview = previewUrl
        return previewUrl
    }
    
    // Initialize
    Component.onCompleted: {
        // Get initial preview
        getCurrentPreview()
    }
} 