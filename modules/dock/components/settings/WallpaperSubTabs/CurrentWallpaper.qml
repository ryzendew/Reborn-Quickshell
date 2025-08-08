import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Services
import qs.Settings

Rectangle {
    id: currentWallpaperTab
    color: "transparent"
    
    ScrollView {
        anchors.fill: parent
        clip: true
        
        ColumnLayout {
            width: parent.width
            spacing: 20
            
            // Current Wallpaper Preview
            Rectangle {
                Layout.fillWidth: true
                height: 300
                color: "#1a1a1a"
                radius: 12
                border.color: "#33ffffff"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 16
                    
                    Label {
                        text: "Current Wallpaper"
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
                            id: currentWallpaperImage
                            anchors.fill: parent
                            anchors.margins: 8
                            source: Settings.settings.currentWallpaper || Quickshell.env("HOME") + "/.config/quickshell/assets/images/default_wallpaper.png"
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
                            visible: currentWallpaperImage.status === Image.Loading
                            
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
                            visible: currentWallpaperImage.status === Image.Error
                            
                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 12
                                
                                Text {
                                    text: "wallpaper"
                                    font.family: "Material Symbols Outlined"
                                    font.pixelSize: 48
                                    color: "#404040"
                                }
                                
                                Label {
                                    text: "No wallpaper set"
                                    color: "#808080"
                                    font.pixelSize: 16
                                    font.weight: Font.Medium
                                }
                                
                                Label {
                                    text: "Select a wallpaper from the Library tab"
                                    color: "#606060"
                                    font.pixelSize: 14
                                }
                            }
                        }
                    }
                }
            }
            
            // SWWW Settings
            Rectangle {
                Layout.fillWidth: true
                height: 280
                color: "#1a1a1a"
                radius: 12
                border.color: "#33ffffff"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 16
                    
                    Label {
                        text: "SWWW Settings"
                        font.pixelSize: 18
                        font.weight: Font.Medium
                        color: "white"
                    }
                    
                                            CheckBox {
                            id: useSWWWCheck
                            text: "Use SWWW for wallpaper management"
                            checked: Settings.settings && Settings.settings.useSWWW
                            onCheckedChanged: {
                                if (Settings.settings) {
                                    Settings.settings.useSWWW = checked
                                    // If enabling SWWW and we have a current wallpaper, apply it
                                    if (checked && Settings.settings.currentWallpaper) {
                                        Wallpaper.setCurrentWallpaper(Settings.settings.currentWallpaper)
                                    }
                                }
                            }
                        
                        indicator: Rectangle {
                            width: 20
                            height: 20
                            radius: 4
                            border.color: "#404040"
                            border.width: 1
                            color: parent.checked ? "#007acc" : "transparent"
                            
                            Rectangle {
                                anchors.centerIn: parent
                                width: 12
                                height: 12
                                radius: 2
                                color: "white"
                                visible: parent.checked
                            }
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 14
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: parent.indicator.width + parent.spacing
                        }
                    }
                    
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 12
                        columnSpacing: 16
                        enabled: Settings.settings.useSWWW
                        
                        Label {
                            text: "Transition Type:"
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
                                id: transitionTypeText
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                text: Settings.settings.transitionType || "random"
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
                                    var options = ["random", "fade", "left", "right", "top", "bottom", "wipe", "wave", "grow", "center", "any", "outer"]
                                    var currentIndex = options.indexOf(Settings.settings.transitionType || "random")
                                    var nextIndex = (currentIndex + 1) % options.length
                                    Settings.settings.transitionType = options[nextIndex]
                                    transitionTypeText.text = options[nextIndex]
                                }
                            }
                        }
                        
                        Label {
                            text: "Resize Mode:"
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
                                id: resizeModeText
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                text: Settings.settings.wallpaperResize || "crop"
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
                                    var options = ["crop", "fit", "no", "scale-down"]
                                    var currentIndex = options.indexOf(Settings.settings.wallpaperResize || "crop")
                                    var nextIndex = (currentIndex + 1) % options.length
                                    Settings.settings.wallpaperResize = options[nextIndex]
                                    resizeModeText.text = options[nextIndex]
                                }
                            }
                        }
                        
                        Label {
                            text: "Transition FPS:"
                            color: "#b0b0b0"
                            font.pixelSize: 14
                        }
                        
                        SpinBox {
                            id: fpsSpinBox
                            from: 30
                            to: 120
                            value: Settings.settings.transitionFps || 60
                            onValueChanged: {
                                Settings.settings.transitionFps = value
                            }
                            
                            background: Rectangle {
                                color: "#0a0a0a"
                                radius: 6
                                border.color: "#404040"
                                border.width: 1
                            }
                            
                            contentItem: TextInput {
                                text: parent.textFromValue(parent.value, parent.locale)
                                color: "white"
                                font: parent.font
                                horizontalAlignment: Qt.AlignHCenter
                                verticalAlignment: Qt.AlignVCenter
                                readOnly: true
                                validator: parent.validator
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                            }
                        }
                        
                        Label {
                            text: "Duration (s):"
                            color: "#b0b0b0"
                            font.pixelSize: 14
                        }
                        
                        TextField {
                            id: durationField
                            width: 200
                            height: 36
                            text: (Settings.settings.transitionDuration || 1.0).toString()
                            validator: DoubleValidator {
                                bottom: 0.1
                                top: 5.0
                                decimals: 1
                                notation: DoubleValidator.StandardNotation
                            }
                            onTextChanged: {
                                var value = parseFloat(text)
                                if (!isNaN(value) && value >= 0.1 && value <= 5.0) {
                                    Settings.settings.transitionDuration = value
                                }
                            }
                            
                            background: Rectangle {
                                color: "#0a0a0a"
                                radius: 6
                                border.color: "#404040"
                                border.width: 1
                            }
                            
                            color: "white"
                            font.pixelSize: 14
                            horizontalAlignment: TextInput.AlignHCenter
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                        }
                    }
                }
            }
        }
    }
} 