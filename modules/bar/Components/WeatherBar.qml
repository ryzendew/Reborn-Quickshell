import QtQuick
import QtQuick.Layouts
import qs.Settings
import qs.Services

Rectangle {
    id: weatherBar
    implicitWidth: weatherLayout.implicitWidth
    implicitHeight: weatherLayout.implicitHeight
    color: "transparent"
    
    // Hover effects - simple magnification
    property bool isHovered: false
    
    // Hover magnification animation
    scale: isHovered ? 1.1 : 1.0
    Behavior on scale {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
    
    // Weather data properties
    property var currentWeather: ({})
    
    // Connect to weather service signals
    Connections {
        target: WeatherService
        
        function onWeatherUpdated(weather) {
            currentWeather = weather
        }
    }
    
    // Content layout
    RowLayout {
        id: weatherLayout
        anchors.centerIn: parent
        spacing: 4
        
        // Weather emoji
        Text {
            text: getWeatherIcon(currentWeather?.current?.condition || "Unknown")
            font.pixelSize: 16
            color: "#ffffff"
            Layout.alignment: Qt.AlignVCenter
        }
        
        // Separator
        Text {
            text: "|"
            font.pixelSize: 12
            color: "#666666"
            Layout.alignment: Qt.AlignVCenter
        }
        
        // Temperature with unit
        Text {
            text: currentWeather?.current?.temp ? 
                currentWeather.current.temp + (Settings.settings?.useFahrenheit ? "°F" : "°C") : 
                "--"
            font.pixelSize: 14
            font.weight: Font.Medium
            color: "#ffffff"
            Layout.alignment: Qt.AlignVCenter
        }
        
        // Separator
        Text {
            text: "|"
            font.pixelSize: 12
            color: "#666666"
            Layout.alignment: Qt.AlignVCenter
        }
        
        // Real temperature with unit (no emoji)
        Text {
            text: currentWeather?.current?.temp ? 
                currentWeather.current.temp + (Settings.settings?.useFahrenheit ? "°F" : "°C") : 
                "--"
            font.pixelSize: 14
            font.weight: Font.Medium
            color: "#ffffff"
            Layout.alignment: Qt.AlignVCenter
        }
    }
    
    // Mouse area for clicking - transparent overlay
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onEntered: {
            weatherBar.isHovered = true
        }
        
        onExited: {
            weatherBar.isHovered = false
        }
        
        onClicked: {
            // Open settings window with weather tab
            openWeatherTab()
        }
    }
    
    // Helper function to get weather icon
    function getWeatherIcon(condition) {
        if (!condition) return "❓"
        condition = condition.toLowerCase()

        if (condition.includes("clear")) return "☀️"
        if (condition.includes("mainly clear")) return "🌤️"
        if (condition.includes("partly cloudy")) return "⛅"
        if (condition.includes("cloud") || condition.includes("overcast")) return "☁️"
        if (condition.includes("fog") || condition.includes("mist")) return "🌫️"
        if (condition.includes("drizzle")) return "🌦️"
        if (condition.includes("rain") || condition.includes("showers")) return "🌧️"
        if (condition.includes("freezing rain")) return "🌧️❄️"
        if (condition.includes("snow") || condition.includes("snow grains") || condition.includes("snow showers")) return "❄️"
        if (condition.includes("thunderstorm")) return "⛈️"
        if (condition.includes("wind")) return "🌬️"
        return "❓"
    }
    
    // Function to open weather tab
    function openWeatherTab() {
        // Use the SettingsManager service to open the weather tab
        SettingsManager.openWeatherTab()
    }
} 