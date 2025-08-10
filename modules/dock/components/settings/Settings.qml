pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property string shellName: "Quickshell"
    property string settingsDir: Quickshell.env("QUICKSHELL_SETTINGS_DIR") || (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/" + shellName + "/"
    property string settingsFile: Quickshell.env("QUICKSHELL_SETTINGS_FILE") || (Quickshell.env("HOME") + "/.local/state/Quickshell/Settings.conf")
    property string themeFile: Quickshell.env("QUICKSHELL_THEME_FILE") || (settingsDir + "Theme.json")
    property var settings: settingAdapter

    Item {
        Component.onCompleted: {
            // ensure settings dir
            Quickshell.execDetached(["mkdir", "-p", settingsDir]);
            
            // Log current settings for debugging
            // console.log("Dock settings loaded:");
            // console.log("showDock:", settings.showDock);
            // console.log("dockIconSize:", settings.dockIconSize);
            // console.log("dockHeight:", settings.dockHeight);
            // console.log("dockIconSpacing:", settings.dockIconSpacing);
            // console.log("dockBorderWidth:", settings.dockBorderWidth);
            // console.log("dockBorderColor:", settings.dockBorderColor);
            // console.log("dockActiveIndicatorColor:", settings.dockActiveIndicatorColor);
        }
    }

    FileView {
        id: settingFileView
        path: settingsFile
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        
        Component.onCompleted: function() {
            reload()
        }
        
        onLoaded: function() {
            Qt.callLater(function () {
                // Initialize wallpaper if needed
                if (settings.currentWallpaper) {
                    // WallpaperManager.setCurrentWallpaper(settings.currentWallpaper, true);
                }
            })
        }
        
        onLoadFailed: function(error) {
            // Create a default settings object with all required properties
            settingAdapter = {
                weatherCity: "Dinslaken",
                useFahrenheit: false,
                profileImage: Quickshell.env("HOME") + "/.face",
                wallpaperFolder: Quickshell.env("HOME") + "/.config/quickshell/Wallpaper",
                currentWallpaper: "",
                randomWallpaper: false,
                useWallpaperTheme: false,
                wallpaperInterval: 300,
                wallpaperResize: "crop",
                transitionFps: 60,
                transitionType: "random",
                transitionDuration: 1.1,
                useSWWW: true,
                bingCountry: "United States",
                bingResolution: "4K",
                bingMonth: "Current",
                videoPath: "~/Videos/",
                showActiveWindowIcon: false,
                showSystemInfoInBar: false,
                showCorners: true,
                showTaskbar: true,
                showMediaInBar: false,
                dimPanels: true,
                fontSizeMultiplier: 1.0,
                taskbarIconSize: 24,
                showDock: true,
                dockExclusive: false,
                pinnedExecs: [],
                dockIconSize: 48,
                dockHeight: 60,
                dockIconSpacing: 8,
                dockBorderWidth: 1,
                dockBorderColor: "#5700eeff",
                dockActiveIndicatorColor: "#00ffff",
                visualizerType: "radial",
                reverseDayMonth: false,
                use12HourClock: false
            }
            writeAdapter()
        }

        JsonAdapter {
            id: settingAdapter
            
            // Weather settings
            property string weatherCity: "Dinslaken"
            property bool useFahrenheit: false
            property bool weatherAutoLocation: true
            property real weatherLatitude: 51.5683
            property real weatherLongitude: 6.7303
            property string weatherCountry: "Germany"
            property string weatherRegion: "North Rhine-Westphalia"
            
            // User profile
            property string profileImage: Quickshell.env("HOME") + "/.face"
            
            // Wallpaper settings
            property string wallpaperFolder: Quickshell.env("HOME") + "/.config/quickshell/Wallpaper"
            property string currentWallpaper: ""
            property bool randomWallpaper: false
            property bool useWallpaperTheme: false
            property int wallpaperInterval: 300
            property string wallpaperResize: "crop"
            property int transitionFps: 60
            property string transitionType: "random"
            property real transitionDuration: 1.1
            property bool useSWWW: true
            
            // Bing wallpaper settings
            property string bingCountry: "United States"
            property string bingResolution: "4K"
            property string bingMonth: "Current"
            
            // Video settings
            property string videoPath: "~/Videos/"
            
            // UI settings
            property bool showActiveWindowIcon: false
            property bool showSystemInfoInBar: false
            property bool showCorners: true
            property bool showTaskbar: true
            property bool showMediaInBar: false
            property bool dimPanels: true
            property real fontSizeMultiplier: 1.0
            property int taskbarIconSize: 24
            
            // Dock settings
            property bool showDock: true
            property bool dockExclusive: false
            property var pinnedExecs: []
            property int dockIconSize: 48
            property int dockHeight: 60
            property int dockIconSpacing: 8
            property int dockBorderWidth: 1
            property string dockBorderColor: "#5700eeff"
            property string dockActiveIndicatorColor: "#00ffff"
            
            // Visualizer settings
            property string visualizerType: "radial"
            
            // Time/Date settings
            property bool reverseDayMonth: false
            property bool use12HourClock: false
        }
    }

    Connections {
        target: settingAdapter
        
        function onRandomWallpaperChanged() {
            // WallpaperManager.toggleRandomWallpaper()
        }
        
        function onWallpaperIntervalChanged() {
            // WallpaperManager.restartRandomWallpaperTimer()
        }
        
        function onWallpaperFolderChanged() {
            // WallpaperManager.loadWallpapers()
        }
    }
} 