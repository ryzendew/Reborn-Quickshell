import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Services
import qs.Settings

Rectangle {
    id: weatherTab
    color: "transparent"
    
    // Main background behind everything
    Rectangle {
        anchors.fill: parent
        color: "#00747474"
        opacity: 0.8
        radius: 8
    }
    
    // Responsive scaling properties
    property real scaleFactor: Math.max(1.0, Math.min(parent.width / 1920, parent.height / 1080))
    property real baseSpacing: 24 * scaleFactor
    property real baseMargin: 12 * scaleFactor
    property real baseRadius: 12 * scaleFactor
    property real baseBorderWidth: 1 * scaleFactor
    
    // Card heights that scale with display resolution
    property real currentWeatherHeight: 140 * scaleFactor
    property real dailyForecastHeight: 290 * scaleFactor
    property real hourlyForecastHeight: 325 * scaleFactor
    
    // Font sizes that scale with display resolution
    property real largeFontSize: 64 * scaleFactor
    property real mediumFontSize: 48 * scaleFactor
    property real normalFontSize: 32 * scaleFactor
    property real smallFontSize: 24 * scaleFactor
    property real tinyFontSize: 16 * scaleFactor
    property real microFontSize: 12 * scaleFactor
    
    // Weather data properties
    property var currentWeather: ({})
    property var hourlyForecast: []
    property var dailyForecast: []
    
    // Location properties
    property string currentLocation: "Detecting location..."
    property string currentCountry: ""
    property string currentRegion: ""
    property real currentLatitude: 0
    property real currentLongitude: 0
    
    // Weather service - access singleton directly
    Component.onCompleted: {
        WeatherService.initialize()
    }
    
    // Robust location display function
    function getLocationDisplay() {
        if (currentLocation && currentLocation !== "Detecting location..." && currentLocation !== "auto") {
            return currentLocation
        }
        
        // Show city and state/province only
        if (currentCity && currentRegion) {
            return currentCity + ", " + currentRegion
        } else if (currentCity) {
            return currentCity
        } else if (currentRegion) {
            return currentRegion
        }
        
        // Fallback
        return "Location unavailable"
    }
    
    // Connect to weather service signals
    Connections {
        target: WeatherService
        onWeatherUpdated: {
            currentWeather = weather
            hourlyForecast = hourly
            dailyForecast = daily
        }
        onLocationUpdated: {
            console.log("WeatherTab: Received locationUpdated signal:", location, country, region, lat, lon);
            currentLocation = location
            currentCountry = country
            currentRegion = region
            currentLatitude = lat
            currentLongitude = lon
        }
    }
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: baseMargin
        clip: true
        
        ColumnLayout {
            anchors.fill: parent
            spacing: baseSpacing
            
            // Current Weather Card
            Rectangle {
                Layout.fillWidth: true
                height: currentWeatherHeight
                color: "transparent"
                radius: baseRadius
                border.color: "#33ffffff"
                border.width: baseBorderWidth
                
                // macOS Tahoe-style transparency effect
                Rectangle {
                    anchors.fill: parent
                    color: "#1a1a1a"
                    opacity: 0.8
                    radius: 12
                }
                
                // Dark mode backdrop
                Rectangle {
                    anchors.fill: parent
                    color: "#0a0a0a"
                    opacity: 0.3
                    radius: 12
                }
                
                // Semi-transparent white border overlay
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    radius: 12
                    border.color: "#40ffffff"
                    border.width: 1
                }
                
                // Semi-transparent white overlay for macOS-like shine
                Rectangle {
                    anchors.fill: parent
                    color: "#15ffffff"
                    radius: 12
                }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: baseMargin * 2
                    spacing: baseSpacing * 2
                    
                    // Left Section: Weather Icon & Temperature
                    ColumnLayout {
                        spacing: 12
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        
                        RowLayout {
                            spacing: baseSpacing * 0.67
                            Layout.alignment: Qt.AlignHCenter
                            
                            Text {
                                text: getWeatherIcon(currentWeather?.current?.condition || "Unknown")
                                font.pixelSize: largeFontSize
                                color: "#ffffff"
                            }
                            
                            Text {
                                text: currentWeather?.current?.temp ? 
                                    currentWeather.current.temp + (Settings.settings?.useFahrenheit ? "°F" : "°C") : 
                                    "--"
                                font.pixelSize: mediumFontSize
                                font.weight: Font.Bold
                                color: "#ffffff"
                            }
                        }
                        
                        Text {
                            text: currentWeather?.current?.condition ? 
                                currentWeather.current.condition : 
                                "Unknown"
                            font.pixelSize: normalFontSize
                            color: "#cccccc"
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                    
                    // Center Section: Location
                    ColumnLayout {
                        spacing: 8
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        
                        Text {
                            text: getLocationDisplay()
                            font.pixelSize: mediumFontSize
                            font.weight: Font.Medium
                            color: "#ffffff"
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        Text {
                            text: [currentRegion, currentCountry].filter(x => x).join(", ")
                            font.pixelSize: tinyFontSize * 0.875
                            color: "#aaaaaa"
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                    
                    // Right Section: Weather Details
                    RowLayout {
                        spacing: 32
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        
                        // Feels Like
                        ColumnLayout {
                            spacing: 4 * scaleFactor
                            Layout.alignment: Qt.AlignHCenter
                            
                            RowLayout {
                                spacing: 4 * scaleFactor
                                Layout.alignment: Qt.AlignHCenter
                                
                                Text {
                                    text: "🌡️"
                                    font.pixelSize: largeFontSize * 0.875
                                    color: "#ff6b6b"
                                }
                                
                                Text {
                                    text: currentWeather?.current?.feelsLike ? 
                                        currentWeather.current.feelsLike : 
                                        "--"
                                    font.pixelSize: mediumFontSize
                                    font.weight: Font.Bold
                                    color: "#ffffff"
                                }
                                
                                Text {
                                    text: Settings.settings?.useFahrenheit ? "°F" : "°C"
                                    font.pixelSize: normalFontSize
                                    color: "#888888"
                                    font.weight: Font.Medium
                                }
                            }
                            
                            Text {
                                text: "Feels like"
                                font.pixelSize: microFontSize * 0.83
                                color: "#888888"
                                font.weight: Font.Medium
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                        
                        // Humidity
                        ColumnLayout {
                            spacing: 4 * scaleFactor
                            Layout.alignment: Qt.AlignHCenter
                            
                            RowLayout {
                                spacing: 4 * scaleFactor
                                Layout.alignment: Qt.AlignHCenter
                                
                                Text {
                                    text: "💧"
                                    font.pixelSize: largeFontSize * 0.875
                                    color: "#74b9ff"
                                }
                                
                                Text {
                                    text: currentWeather?.current?.humidity ? 
                                        currentWeather.current.humidity : 
                                        "--"
                                    font.pixelSize: mediumFontSize
                                    font.weight: Font.Bold
                                    color: "#ffffff"
                                }
                                
                                Text {
                                    text: "%"
                                    font.pixelSize: normalFontSize
                                    color: "#888888"
                                    font.weight: Font.Medium
                                }
                            }
                            
                            Text {
                                text: "Humidity"
                                font.pixelSize: microFontSize * 0.83
                                color: "#888888"
                                font.weight: Font.Medium
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                        
                        // Wind
                        ColumnLayout {
                            spacing: 4 * scaleFactor
                            Layout.alignment: Qt.AlignHCenter
                            
                            RowLayout {
                                spacing: 4 * scaleFactor
                                Layout.alignment: Qt.AlignHCenter
                                
                                Text {
                                    text: "💨"
                                    font.pixelSize: largeFontSize * 0.875
                                    color: "#a29bfe"
                                }
                                
                                Text {
                                    text: currentWeather?.current?.wind ? 
                                        currentWeather.current.wind : 
                                        "--"
                                    font.pixelSize: mediumFontSize
                                    font.weight: Font.Bold
                                    color: "#ffffff"
                                }
                                
                                Text {
                                    text: "km/h"
                                    font.pixelSize: normalFontSize
                                    color: "#888888"
                                    font.weight: Font.Medium
                                }
                            }
                            
                            Text {
                                text: "Wind"
                                font.pixelSize: microFontSize * 0.83
                                color: "#888888"
                                font.weight: Font.Medium
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }
            }
            
            // 10-Day Forecast
            Rectangle {
                Layout.fillWidth: true
                height: dailyForecastHeight
                color: "transparent"
                radius: baseRadius
                border.color: "#33ffffff"
                border.width: baseBorderWidth
                
                // macOS Tahoe-style transparency effect
                Rectangle {
                    anchors.fill: parent
                    color: "#1a1a1a"
                    opacity: 0.8
                    radius: 12
                }
                
                // Dark mode backdrop
                Rectangle {
                    anchors.fill: parent
                    color: "#0a0a0a"
                    opacity: 0.3
                    radius: 12
                }
                
                // Semi-transparent white border overlay
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    radius: 12
                    border.color: "#40ffffff"
                    border.width: 1
                }
                
                // Semi-transparent white overlay for macOS-like shine
                Rectangle {
                    anchors.fill: parent
                    color: "#15ffffff"
                    radius: 12
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: baseMargin * 1.67
                    spacing: baseSpacing * 0.67
                    
                    Text {
                        text: "10-Day Forecast"
                        font.pixelSize: smallFontSize
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    // Horizontal forecast cards
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: baseSpacing * 0.5
                        
                        Repeater {
                            model: dailyForecast.slice(0, 10)
                            
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.preferredWidth: 127 * scaleFactor
                                color: "transparent"
                                radius: baseRadius * 0.67
                                border.color: "#33ffffff"
                                border.width: baseBorderWidth
                                
                                // macOS Tahoe-style transparency effect
                                Rectangle {
                                    anchors.fill: parent
                                    color: "#2a2a2a"
                                    opacity: 0.8
                                    radius: 8
                                }
                                
                                // Dark mode backdrop
                                Rectangle {
                                    anchors.fill: parent
                                    color: "#1a1a1a"
                                    opacity: 0.3
                                    radius: 8
                                }
                                
                                // Semi-transparent white border overlay
                                Rectangle {
                                    anchors.fill: parent
                                    color: "transparent"
                                    radius: 8
                                    border.color: "#40ffffff"
                                    border.width: 1
                                }
                                
                                // Semi-transparent white overlay for macOS-like shine
                                Rectangle {
                                    anchors.fill: parent
                                    color: "#15ffffff"
                                    radius: 8
                                }
                                
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: baseMargin
                                    spacing: baseSpacing * 0.33
                                    
                                    Text {
                                        text: modelData.date || "--"
                                        font.pixelSize: tinyFontSize
                                        font.weight: Font.Bold
                                        color: "#ffffff"
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                    
                                    RowLayout {
                                        spacing: 4 * scaleFactor
                                        Layout.alignment: Qt.AlignHCenter
                                        
                                        Text {
                                            text: getWeatherIcon(modelData.condition || "Unknown")
                                            font.pixelSize: normalFontSize
                                            color: "#ffffff"
                                        }
                                        
                                        Text {
                                            text: (modelData.tempMax || "--") + "°"
                                            font.pixelSize: tinyFontSize * 1.25
                                            font.weight: Font.Bold
                                            color: "#ffffff"
                                        }
                                    }
                                    
                                    Text {
                                        text: modelData.precipitation ? modelData.precipitation + "%" : ""
                                        font.pixelSize: microFontSize
                                        color: "#74b9ff"
                                        Layout.alignment: Qt.AlignHCenter
                                        visible: modelData.precipitation && modelData.precipitation > 0
                                    }
                                    
                                    Text {
                                        text: (modelData.tempMin || "--") + "°"
                                        font.pixelSize: smallFontSize
                                        color: "#aaaaaa"
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // 24-Hour Forecast
            Rectangle {
                Layout.fillWidth: true
                height: hourlyForecastHeight
                color: "transparent"
                radius: baseRadius
                border.color: "#33ffffff"
                border.width: baseBorderWidth
                
                // macOS Tahoe-style transparency effect
                Rectangle {
                    anchors.fill: parent
                    color: "#1a1a1a"
                    opacity: 0.8
                    radius: 12
                }
                
                // Dark mode backdrop
                Rectangle {
                    anchors.fill: parent
                    color: "#0a0a0a"
                    opacity: 0.3
                    radius: 12
                }
                
                // Semi-transparent white border overlay
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    radius: 12
                    border.color: "#40ffffff"
                    border.width: 1
                }
                
                // Semi-transparent white overlay for macOS-like shine
                Rectangle {
                    anchors.fill: parent
                    color: "#15ffffff"
                    radius: 12
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: baseMargin * 1.67
                    spacing: baseSpacing * 0.67
                    
                    Text {
                        text: "24-Hour Forecast"
                        font.pixelSize: smallFontSize
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        
                        ListView {
                            orientation: ListView.Horizontal
                            spacing: baseSpacing * 0.5
                            model: hourlyForecast.slice(0, 24)
                            
                            delegate: Rectangle {
                                width: 140 * scaleFactor
                                height: ListView.view.height - (40 * scaleFactor)
                                color: "transparent"
                                radius: baseRadius * 0.67
                                border.color: "#33ffffff"
                                border.width: baseBorderWidth
                                
                                // macOS Tahoe-style transparency effect
                                Rectangle {
                                    anchors.fill: parent
                                    color: "#2a2a2a"
                                    opacity: 0.8
                                    radius: 8
                                }
                                
                                // Dark mode backdrop
                                Rectangle {
                                    anchors.fill: parent
                                    color: "#1a1a1a"
                                    opacity: 0.3
                                    radius: 8
                                }
                                
                                // Semi-transparent white border overlay
                                Rectangle {
                                    anchors.fill: parent
                                    color: "transparent"
                                    radius: 8
                                    border.color: "#40ffffff"
                                    border.width: 1
                                }
                                
                                // Semi-transparent white overlay for macOS-like shine
                                Rectangle {
                                    anchors.fill: parent
                                    color: "#15ffffff"
                                    radius: 8
                                }
                                
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10 * scaleFactor
                                    spacing: 6 * scaleFactor
                                    
                                    Text {
                                        text: modelData.time || "--"
                                        font.pixelSize: tinyFontSize * 1.125
                                        font.weight: Font.Bold
                                        color: "#ffffff"
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                    
                                    // Spacer to add space between time and weather icon/temp
                                    Item {
                                        height: 16 * scaleFactor
                                    }
                                    
                                    RowLayout {
                                        spacing: 4 * scaleFactor
                                        Layout.alignment: Qt.AlignHCenter
                                        
                                        Text {
                                            text: getWeatherIcon(modelData.condition || "Unknown")
                                            font.pixelSize: normalFontSize * 1.125
                                            color: "#ffffff"
                                        }
                                        
                                        Text {
                                            text: (modelData.temp || "--") + "°"
                                            font.pixelSize: tinyFontSize * 1.25
                                            font.weight: Font.Bold
                                            color: "#ffffff"
                                        }
                                    }
                                    
                                    // Spacer to add more vertical space
                                    Item {
                                        height: 16 * scaleFactor
                                    }
                                    
                                    Text {
                                        text: modelData.precipitation ? modelData.precipitation + "%" : ""
                                        font.pixelSize: tinyFontSize * 1.25
                                        color: "#74b9ff"
                                        Layout.alignment: Qt.AlignHCenter
                                        visible: modelData.precipitation && modelData.precipitation > 0
                                    }
                                    
                                    Text {
                                        text: "💧 " + (modelData.humidity || "--")
                                        font.pixelSize: smallFontSize
                                        color: "#aaaaaa"
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                    
                                    Text {
                                        text: "💨 " + (modelData.wind ? modelData.wind.split(" ")[0] : "--")
                                        font.pixelSize: smallFontSize
                                        color: "#aaaaaa"
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Helper functions
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
    
    function getWeatherDescription(code) {
        const descriptions = {
            0: "Clear sky",
            1: "Mainly clear",
            2: "Partly cloudy",
            3: "Overcast",
            45: "Foggy",
            48: "Rime fog",
            51: "Light drizzle",
            53: "Moderate drizzle",
            55: "Dense drizzle",
            61: "Slight rain",
            63: "Moderate rain",
            65: "Heavy rain",
            71: "Slight snow",
            73: "Moderate snow",
            75: "Heavy snow",
            95: "Thunderstorm",
            96: "Thunderstorm with hail",
            99: "Thunderstorm with heavy hail"
        }
        return descriptions[code] || "Unknown"
    }
}
