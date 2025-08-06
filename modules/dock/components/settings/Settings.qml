pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property string shellName: "Quickshell"
    property string settingsDir: Quickshell.env("QUICKSHELL_SETTINGS_DIR") || (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/" + shellName + "/"
    property string settingsFile: Quickshell.env("QUICKSHELL_SETTINGS_FILE") || (settingsDir + "Settings.json")
    property string themeFile: Quickshell.env("QUICKSHELL_THEME_FILE") || (settingsDir + "Theme.json")
    property var settings: settingAdapter

    Item {
        Component.onCompleted: {
            // ensure settings dir
            Quickshell.execDetached(["mkdir", "-p", settingsDir]);
            
            // Log current settings for debugging
            console.log("Dock settings loaded:");
            console.log("showDock:", settings.showDock);
            console.log("dockIconSize:", settings.dockIconSize);
            console.log("dockHeight:", settings.dockHeight);
            console.log("dockIconSpacing:", settings.dockIconSpacing);
            console.log("dockBorderWidth:", settings.dockBorderWidth);
            console.log("dockBorderColor:", settings.dockBorderColor);
            console.log("dockActiveIndicatorColor:", settings.dockActiveIndicatorColor);
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
            settingAdapter = {}
            writeAdapter()
        }

        JsonAdapter {
            id: settingAdapter
            
            // Weather settings
            property string weatherCity: "Dinslaken"
            property bool useFahrenheit: false
            
            // User profile
            property string profileImage: Quickshell.env("HOME") + "/.face"
            
            // Wallpaper settings
            property string wallpaperFolder: "~/Pictures/Wallpapers"
            property string currentWallpaper: ""
            property bool randomWallpaper: false
            property bool useWallpaperTheme: false
            property int wallpaperInterval: 300
            property string wallpaperResize: "crop"
            property int transitionFps: 60
            property string transitionType: "random"
            property real transitionDuration: 1.1
            property bool useSWWW: false
            
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