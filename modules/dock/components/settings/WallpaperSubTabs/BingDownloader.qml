import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Services
import qs.Settings

Rectangle {
    id: bingDownloaderTab
    color: "transparent"
    
    ScrollView {
        anchors.fill: parent
        clip: true
        
        ColumnLayout {
            width: parent.width
            spacing: 20
            
            // Download Settings
            Rectangle {
                Layout.fillWidth: true
                height: 200
                color: "#1a1a1a"
                radius: 12
                border.color: "#33ffffff"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 16
                    
                    Label {
                        text: "Download Settings"
                        font.pixelSize: 18
                        font.weight: Font.Medium
                        color: "white"
                    }
                    
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 12
                        columnSpacing: 16
                        
                        Label {
                            text: "Country:"
                            color: "#b0b0b0"
                            font.pixelSize: 14
                        }
                        
                        Rectangle {
                            width: 200
                            height: 36
                            color: "#0a0a0a"
                            radius: 6
                            border.color: "#404040"
                            border.width: 1
                            
                            Text {
                                id: countryText
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                text: (Settings.settings && Settings.settings.bingCountry) ? Settings.settings.bingCountry : "United States"
                                color: "white"
                                font.pixelSize: 14
                            }
                            
                            Text {
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                text: "▼"
                                color: "#808080"
                                font.pixelSize: 12
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var countries = [
                                        "Australia", "Canada", "中国", "Deutschland", "España", 
                                        "France", "Italia", "日本", "New Zealand", "United Kingdom", "United States"
                                    ]
                                    var currentIndex = countries.indexOf((Settings.settings && Settings.settings.bingCountry) ? Settings.settings.bingCountry : "United States")
                                    var nextIndex = (currentIndex + 1) % countries.length
                                    if (Settings.settings) {
                                        Settings.settings.bingCountry = countries[nextIndex]
                                    }
                                    countryText.text = countries[nextIndex]
                                }
                            }
                        }
                        
                        Label {
                            text: "Resolution:"
                            color: "#b0b0b0"
                            font.pixelSize: 14
                        }
                        
                        Rectangle {
                            width: 200
                            height: 36
                            color: "#0a0a0a"
                            radius: 6
                            border.color: "#404040"
                            border.width: 1
                            
                            Text {
                                id: resolutionText
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                text: (Settings.settings && Settings.settings.bingResolution) ? Settings.settings.bingResolution : "4K"
                                color: "white"
                                font.pixelSize: 14
                            }
                            
                            Text {
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                text: "▼"
                                color: "#808080"
                                font.pixelSize: 12
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var resolutions = ["4K", "2K", "1080p"]
                                    var currentIndex = resolutions.indexOf((Settings.settings && Settings.settings.bingResolution) ? Settings.settings.bingResolution : "4K")
                                    var nextIndex = (currentIndex + 1) % resolutions.length
                                    if (Settings.settings) {
                                        Settings.settings.bingResolution = resolutions[nextIndex]
                                    }
                                    resolutionText.text = resolutions[nextIndex]
                                }
                            }
                        }
                        
                        Label {
                            text: "Month:"
                            color: "#b0b0b0"
                            font.pixelSize: 14
                        }
                        
                        Rectangle {
                            width: 200
                            height: 36
                            color: "#0a0a0a"
                            radius: 6
                            border.color: "#404040"
                            border.width: 1
                            
                            Text {
                                id: monthText
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                text: (Settings.settings && Settings.settings.bingMonth) ? Settings.settings.bingMonth : "Current"
                                color: "white"
                                font.pixelSize: 14
                            }
                            
                            Text {
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                text: "▼"
                                color: "#808080"
                                font.pixelSize: 12
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var months = ["Current", "202508", "202507", "202506", "202505", "202504", "202503", "202502", "202501"]
                                    var currentIndex = months.indexOf((Settings.settings && Settings.settings.bingMonth) ? Settings.settings.bingMonth : "Current")
                                    var nextIndex = (currentIndex + 1) % months.length
                                    if (Settings.settings) {
                                        Settings.settings.bingMonth = months[nextIndex]
                                    }
                                    monthText.text = months[nextIndex]
                                }
                            }
                        }
                        
                        Label {
                            text: "Download Folder:"
                            color: "#b0b0b0"
                            font.pixelSize: 14
                        }
                        
                        TextField {
                            id: downloadFolderField
                            width: 200
                            height: 36
                            text: Settings.settings.wallpaperFolder || Quickshell.env("HOME") + "/.config/quickshell/Wallpaper"
                            color: "white"
                            background: Rectangle {
                                color: "#0a0a0a"
                                radius: 6
                                border.color: "#404040"
                                border.width: 1
                            }
                            onTextChanged: {
                                Settings.settings.wallpaperFolder = text
                            }
                        }
                    }
                }
            }
            
            // Download Controls
            Rectangle {
                Layout.fillWidth: true
                height: 100
                color: "#1a1a1a"
                radius: 12
                border.color: "#33ffffff"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12
                    
                    Label {
                        text: "Download Controls"
                        font.pixelSize: 18
                        font.weight: Font.Medium
                        color: "white"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Button {
                            text: "Download Current"
                            enabled: !BingDownloader.downloading
                            background: Rectangle {
                                color: parent.pressed ? "#404040" : (parent.enabled ? "#505050" : "#303030")
                                radius: 6
                            }
                            contentItem: Text {
                                text: parent.text
                                color: parent.enabled ? "white" : "#606060"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                BingDownloader.downloadCurrent()
                            }
                        }
                        
                        Button {
                            text: "Download Month"
                            enabled: !BingDownloader.downloading
                            background: Rectangle {
                                color: parent.pressed ? "#404040" : (parent.enabled ? "#505050" : "#303030")
                                radius: 6
                            }
                            contentItem: Text {
                                text: parent.text
                                color: parent.enabled ? "white" : "#606060"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                BingDownloader.downloadMonth()
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        BusyIndicator {
                            running: BingDownloader.downloading
                            visible: running
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                        }
                        
                        Label {
                            text: BingDownloader.downloading ? "Downloading..." : ""
                            color: "#ffaa00"
                            font.pixelSize: 14
                            visible: BingDownloader.downloading
                        }
                    }
                }
            }
            
            // Download Status
            Rectangle {
                Layout.fillWidth: true
                height: 120
                color: "#1a1a1a"
                radius: 12
                border.color: "#33ffffff"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12
                    
                    Label {
                        text: "Download Status"
                        font.pixelSize: 18
                        font.weight: Font.Medium
                        color: "white"
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        
                        TextArea {
                            id: statusText
                            readOnly: true
                            text: "Ready to download Bing wallpapers..."
                            color: "#b0b0b0"
                            font.pixelSize: 12
                            background: Rectangle {
                                color: "#0a0a0a"
                                radius: 6
                                border.color: "#404040"
                                border.width: 1
                            }
                        }
                    }
                }
            }
            
            // Preview
            Rectangle {
                Layout.fillWidth: true
                height: 200
                color: "#1a1a1a"
                radius: 12
                border.color: "#33ffffff"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12
                    
                    Label {
                        text: "Current Bing Wallpaper"
                        font.pixelSize: 18
                        font.weight: Font.Medium
                        color: "white"
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#0a0a0a"
                        radius: 8
                        
                        Image {
                            id: bingPreviewImage
                            anchors.fill: parent
                            anchors.margins: 8
                            source: BingDownloader.currentPreview || ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: false
                        }
                        
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.color: "#404040"
                            border.width: 1
                            radius: 8
                        }
                        
                        // Loading indicator
                        Rectangle {
                            anchors.centerIn: parent
                            width: 40
                            height: 40
                            radius: 20
                            color: "#80000000"
                            visible: bingPreviewImage.status === Image.Loading
                            
                            BusyIndicator {
                                anchors.centerIn: parent
                                running: parent.visible
                                width: 24
                                height: 24
                            }
                        }
                        
                        // Error placeholder
                        Rectangle {
                            anchors.fill: parent
                            color: "#1a1a1a"
                            visible: bingPreviewImage.status === Image.Error
                            
                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 8
                                
                                Text {
                                    text: "download"
                                    font.family: "Material Symbols Outlined"
                                    font.pixelSize: 32
                                    color: "#404040"
                                }
                                
                                Label {
                                    text: "No preview available"
                                    color: "#808080"
                                    font.pixelSize: 14
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Connect to service signals
    Connections {
        target: BingDownloader
        
        function onStatusChanged(message) {
            statusText.text = message
        }
        
        function onDownloadComplete(filename) {
            statusText.text += "\nDownloaded: " + filename
            // Refresh wallpaper list
            Wallpaper.loadWallpapers()
        }
        
        function onDownloadError(error) {
            statusText.text += "\nError: " + error
        }
    }
} 