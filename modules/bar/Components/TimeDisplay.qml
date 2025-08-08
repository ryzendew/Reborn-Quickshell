import QtQuick
import QtQuick.Layouts
import qs.Settings

ColumnLayout {
    id: timeDisplay
    spacing: 2
    
    property string currentDate: ""
    property string currentTime: ""
    
    // Date display (top)
    Text {
        id: dateText
        text: timeDisplay.currentDate
        color: "#ffffff"
        font.pixelSize: 11 * (Settings.settings.fontSizeMultiplier || 1.0)
        font.family: "Inter, sans-serif"
        horizontalAlignment: Text.AlignHCenter
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        opacity: 1.0  // Ensure text is fully opaque
    }
    
    // Time display (bottom)
    Text {
        id: timeText
        text: timeDisplay.currentTime
        color: "#ffffff"
        font.pixelSize: 14 * (Settings.settings.fontSizeMultiplier || 1.0)
        font.family: "Inter, sans-serif"
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
            var now = new Date()
            timeDisplay.currentDate = Qt.formatDate(now, "MMM dd")
            timeDisplay.currentTime = Qt.formatTime(now, "hh:mm AP")
        }
    }
    
    // Initialize time immediately
    Component.onCompleted: {
        var now = new Date()
        timeDisplay.currentDate = Qt.formatDate(now, "MMM dd")
        timeDisplay.currentTime = Qt.formatTime(now, "hh:mm AP")
    }
} 