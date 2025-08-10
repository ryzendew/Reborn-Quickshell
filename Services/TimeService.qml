pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Settings

/**
 * Time Service
 * Manages time display settings and formatting across the application
 */
Singleton {
    id: root

    // Time format settings
    property string timeFormat: "12h" // "12h" or "24h"
    property string dateFormat: "MMM dd" // "MMM dd", "MM/dd", "dd/MM", "MM-dd", "dd-MM", "MMM dd yyyy", etc.
    property string timezone: "UTC"
    property bool showSeconds: false
    property bool showDate: true
    
    // Text styling settings
    property bool timeBold: false
    property bool dateBold: false
    property int timeSize: 14
    property int dateSize: 11
    property int timeSpacing: 2
    property string timeColor: "#ffffff"
    property string dateColor: "#ffffff"
    
    // Month format settings
    property string monthFormat: "short" // "short" (Aug), "long" (August), "numeric" (08)
    
    // Signal when settings change
    signal timeSettingsChanged()
    
    // Update interval
    property int updateInterval: 1000 // 1 second
    
    // Main update timer
    Timer {
        interval: root.updateInterval
        running: true
        repeat: true
        onTriggered: {
            timeSettingsChanged()
        }
    }
    
    // Load settings on startup
    Component.onCompleted: {
        loadSettings()
        // console.log("TimeService: Settings loaded")
    }
    
    // Format time based on current settings
    function formatTime(date) {
        var hours = date.getHours()
        var minutes = date.getMinutes()
        var seconds = date.getSeconds()
        
        if (timeFormat === "24h") {
            var timeStr = hours.toString().padStart(2, '0') + ":" + 
                         minutes.toString().padStart(2, '0')
            if (showSeconds) {
                timeStr += ":" + seconds.toString().padStart(2, '0')
            }
            return timeStr
        } else {
            var ampm = hours >= 12 ? "PM" : "AM"
            hours = hours % 12
            hours = hours ? hours : 12
            var timeStr = hours.toString().padStart(2, '0') + ":" + 
                         minutes.toString().padStart(2, '0')
            if (showSeconds) {
                timeStr += ":" + seconds.toString().padStart(2, '0')
            }
            timeStr += " " + ampm
            return timeStr
        }
    }
    
    // Format date based on current settings
    function formatDate(date) {
        if (!showDate) return ""
        
        var day = date.getDate()
        var month = date.getMonth() + 1
        var year = date.getFullYear()
        var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                         "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        var monthNamesLong = ["January", "February", "March", "April", "May", "June",
                             "July", "August", "September", "October", "November", "December"]
        
        switch(dateFormat) {
            case "MMM dd":
                return monthNames[date.getMonth()] + " " + day.toString().padStart(2, '0')
            case "MMM dd yyyy":
                return monthNames[date.getMonth()] + " " + day.toString().padStart(2, '0') + " " + year
            case "MM/dd":
                return month.toString().padStart(2, '0') + "/" + day.toString().padStart(2, '0')
            case "MM/dd/yyyy":
                return month.toString().padStart(2, '0') + "/" + day.toString().padStart(2, '0') + "/" + year
            case "dd/MM":
                return day.toString().padStart(2, '0') + "/" + month.toString().padStart(2, '0')
            case "dd/MM/yyyy":
                return day.toString().padStart(2, '0') + "/" + month.toString().padStart(2, '0') + "/" + year
            case "yyyy-MM-dd":
                return year + "-" + month.toString().padStart(2, '0') + "-" + day.toString().padStart(2, '0')
            case "MM-dd":
                return month.toString().padStart(2, '0') + "-" + day.toString().padStart(2, '0')
            case "dd-MM":
                return day.toString().padStart(2, '0') + "-" + month.toString().padStart(2, '0')
            case "MMMM dd":
                return monthNamesLong[date.getMonth()] + " " + day.toString().padStart(2, '0')
            case "MMMM dd, yyyy":
                return monthNamesLong[date.getMonth()] + " " + day.toString().padStart(2, '0') + ", " + year
            default:
                return monthNames[date.getMonth()] + " " + day.toString().padStart(2, '0')
        }
    }
    
    // Save settings using Settings service
    function saveSettings() {
        try {
            // Save to Settings service
            Settings.settings.timeFormat = timeFormat
            Settings.settings.dateFormat = dateFormat
            Settings.settings.timezone = timezone
            Settings.settings.showSeconds = showSeconds
            Settings.settings.showDate = showDate
            Settings.settings.timeBold = timeBold
            Settings.settings.dateBold = dateBold
            Settings.settings.timeSize = timeSize
            Settings.settings.dateSize = dateSize
            Settings.settings.timeSpacing = timeSpacing
            Settings.settings.timeColor = timeColor
            Settings.settings.dateColor = dateColor
            Settings.settings.monthFormat = monthFormat
        } catch (e) {
            // Error saving settings
        }
    }
    
    // Load settings from Settings service
    function loadSettings() {
        try {
            // Load from Settings service
            if (Settings.settings.timeFormat) timeFormat = Settings.settings.timeFormat
            if (Settings.settings.dateFormat) dateFormat = Settings.settings.dateFormat
            if (Settings.settings.timezone) timezone = Settings.settings.timezone
            if (Settings.settings.showSeconds !== undefined) showSeconds = Settings.settings.showSeconds
            if (Settings.settings.showDate !== undefined) showDate = Settings.settings.showDate
            if (Settings.settings.timeBold !== undefined) timeBold = Settings.settings.timeBold
            if (Settings.settings.dateBold !== undefined) dateBold = Settings.settings.dateBold
            if (Settings.settings.timeSize) timeSize = Settings.settings.timeSize
            if (Settings.settings.dateSize) dateSize = Settings.settings.dateSize
            if (Settings.settings.timeSpacing) timeSpacing = Settings.settings.timeSpacing
            if (Settings.settings.timeColor) timeColor = Settings.settings.timeColor
            if (Settings.settings.dateColor) dateColor = Settings.settings.dateColor
            if (Settings.settings.monthFormat) monthFormat = Settings.settings.monthFormat
        } catch (e) {
            // Error loading settings
        }
    }
    
    // Sync with Settings service changes
    Connections {
        target: Settings.settings
        
        function onTimeFormatChanged() {
            if (Settings.settings.timeFormat !== timeFormat) {
                timeFormat = Settings.settings.timeFormat
            }
        }
        
        function onDateFormatChanged() {
            if (Settings.settings.dateFormat !== dateFormat) {
                dateFormat = Settings.settings.dateFormat
            }
        }
        
        function onTimezoneChanged() {
            if (Settings.settings.timezone !== timezone) {
                timezone = Settings.settings.timezone
            }
        }
        
        function onShowSecondsChanged() {
            if (Settings.settings.showSeconds !== showSeconds) {
                showSeconds = Settings.settings.showSeconds
            }
        }
        
        function onShowDateChanged() {
            if (Settings.settings.showDate !== showDate) {
                showDate = Settings.settings.showDate
            }
        }
        
        function onTimeBoldChanged() {
            if (Settings.settings.timeBold !== timeBold) {
                timeBold = Settings.settings.timeBold
            }
        }
        
        function onDateBoldChanged() {
            if (Settings.settings.dateBold !== dateBold) {
                dateBold = Settings.settings.dateBold
            }
        }
        
        function onTimeSizeChanged() {
            if (Settings.settings.timeSize !== timeSize) {
                timeSize = Settings.settings.timeSize
            }
        }
        
        function onDateSizeChanged() {
            if (Settings.settings.dateSize !== dateSize) {
                dateSize = Settings.settings.dateSize
            }
        }
        
        function onTimeSpacingChanged() {
            if (Settings.settings.timeSpacing !== timeSpacing) {
                timeSpacing = Settings.settings.timeSpacing
            }
        }
        
        function onTimeColorChanged() {
            if (Settings.settings.timeColor !== timeColor) {
                timeColor = Settings.settings.timeColor
            }
        }
        
        function onDateColorChanged() {
            if (Settings.settings.dateColor !== dateColor) {
                dateColor = Settings.settings.dateColor
            }
        }
        
        function onMonthFormatChanged() {
            if (Settings.settings.monthFormat !== monthFormat) {
                monthFormat = Settings.settings.monthFormat
            }
        }
    }
} 