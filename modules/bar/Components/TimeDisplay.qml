import QtQuick
import QtQuick.Layouts
import qs.Settings
import qs.Services

ColumnLayout {
    id: timeDisplay
    spacing: TimeService.timeSpacing
    
    property string currentDate: ""
    property string currentTime: ""
    
    // Date display (top)
    Text {
        id: dateText
        text: timeDisplay.currentDate
        color: TimeService.dateColor
        font.pixelSize: TimeService.dateSize * (Settings.settings.fontSizeMultiplier || 1.0)
        font.family: "Inter, sans-serif"
        font.bold: TimeService.dateBold
        horizontalAlignment: Text.AlignHCenter
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        opacity: 1.0  // Ensure text is fully opaque
        visible: TimeService.showDate
    }
    
    // Time display (bottom)
    Text {
        id: timeText
        text: timeDisplay.currentTime
        color: TimeService.timeColor
        font.pixelSize: TimeService.timeSize * (Settings.settings.fontSizeMultiplier || 1.0)
        font.family: "Inter, sans-serif"
        font.bold: TimeService.timeBold
        horizontalAlignment: Text.AlignHCenter
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        opacity: 1.0  // Ensure text is fully opaque
    }
    
    // Update time every second
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            updateTime()
        }
    }
    
    // Listen for time service changes
    Connections {
        target: TimeService
        function onTimeSettingsChanged() {
            updateTime()
        }
    }
    
    function updateTime() {
            var now = new Date()
        timeDisplay.currentDate = TimeService.formatDate(now)
        timeDisplay.currentTime = TimeService.formatTime(now)
    }
    
    // Initialize time immediately
    Component.onCompleted: {
        updateTime()
    }
} 