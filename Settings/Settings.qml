pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services

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
            
            // Bar settings
            property int barHeight: 40
            property string workspaceBorderColor: "#00ccff"
            property string workspaceIndicatorColor: "#00ffff"
            property int systemTraySize: 24
            property int indicatorsSize: 24
            property int barLogoSize: 24
            
            // Dock settings
            property bool showDock: true
            property bool dockExclusive: false
            property var pinnedExecs: []
            property int dockIconSize: 48
            property int dockHeight: 60
            property int dockIconSpacing: 8
            property int dockBorderWidth: 1
            property int dockRadius: 30
            property string dockBorderColor: "#5700eeff"
            property string dockActiveIndicatorColor: "#00ffff"
            
            // Visualizer settings
            property string visualizerType: "radial"
            
            // Logo settings
            property string barLogo: "arch-symbolic.svg"
            property string dockLogo: "arch-symbolic.svg"
            property string logoColor: "#ffffff"
            
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
            property bool reverseDayMonth: false
            property bool use12HourClock: false
            
            // Calendar settings
            property string calendarDateFormat: "MM/DD/YYYY"
            property string calendarTimeFormat: "12-hour"
            property string calendarWeekStart: "Sunday"
            property bool calendarShowWeekNumbers: false
            property bool calendarShowTodayHighlight: true
            property string calendarTodayColor: "#00eeff"
            property string calendarSelectedColor: "#5700eeff"
            property string calendarHolidayColor: "#ff6b6b"
            
            // User settings
            property string userImage: ""
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