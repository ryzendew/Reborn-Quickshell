import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import qs.Services
import qs.Settings

Rectangle {
    id: logoColor
    color: "transparent"
    
    property int redValue: 255
    property int greenValue: 255
    property int blueValue: 255
    
    // Load saved color values on component creation
    Component.onCompleted: {
        loadSavedColor()
        // Ensure sliders are properly initialized
        initTimer.start()
        // Ensure sliders get focus
        focusTimer.start()
    }
    
    Timer {
        id: initTimer
        interval: 100
        repeat: false
        onTriggered: {
            redSlider.value = redValue
            greenSlider.value = greenValue
            blueSlider.value = blueValue
        }
    }
    
    Timer {
        id: focusTimer
        interval: 200
        repeat: false
        onTriggered: {
            // Enable all sliders to receive focus
            redSlider.forceActiveFocus()
            greenSlider.enabled = true
            blueSlider.enabled = true
        }
    }
    
    function loadSavedColor() {
        var savedColor = LogoService.logoColor || "#ffffff"
        var color = Qt.color(savedColor)
        redValue = Math.round(color.r * 255)
        greenValue = Math.round(color.g * 255)
        blueValue = Math.round(color.b * 255)
    }
    
    function saveColor() {
        var colorString = "#" + redValue.toString(16).padStart(2, '0') + 
                         greenValue.toString(16).padStart(2, '0') + 
                         blueValue.toString(16).padStart(2, '0')
        
        // Load current settings
        var currentSettings = settingsWindow.loadSettings()
        
        // Update logo color
        currentSettings.logoColor = colorString
        
        // Save updated settings
        settingsWindow.saveSettings(currentSettings)
        
        // Also update LogoService property
        LogoService.logoColor = colorString
    }
    
    ScrollView {
        anchors.fill: parent
        clip: true
        
        ColumnLayout {
            width: parent.width
            spacing: 20
            
            // Color Preview Section
            Rectangle {
                Layout.fillWidth: true
                height: 200
                color: "#2a2a2a"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16
                    
                    Label {
                        text: "Logo Color Preview"
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                    }
                    
                    // Preview area with sample logos
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 20
                        
                        // Bar logo preview
                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 80
                            color: "#1a1a1a"
                            radius: 8
                            border.color: "#404040"
                            border.width: 1
                            
                            Image {
                                id: barPreviewImage
                                anchors.centerIn: parent
                                width: 40
                                height: 40
                                source: LogoService.getLogoPath(LogoService.currentBarLogo)
                                fillMode: Image.PreserveAspectFit
                                smooth: false
                                mipmap: true
                                cache: true
                                sourceSize.width: 64
                                sourceSize.height: 64
                            }
                            
                            ColorOverlay {
                                anchors.fill: barPreviewImage
                                source: barPreviewImage
                                color: Qt.rgba(redValue/255, greenValue/255, blueValue/255, 1.0)
                            }
                            
                            Label {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottomMargin: 4
                                text: "Bar"
                                color: "white"
                                font.pixelSize: 10
                            }
                        }
                        
                        // Dock logo preview
                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 80
                            color: "#1a1a1a"
                            radius: 8
                            border.color: "#404040"
                            border.width: 1
                            
                            Image {
                                id: dockPreviewImage
                                anchors.centerIn: parent
                                width: 40
                                height: 40
                                source: LogoService.getLogoPath(LogoService.currentDockLogo)
                                fillMode: Image.PreserveAspectFit
                                smooth: false
                                mipmap: true
                                cache: true
                                sourceSize.width: 64
                                sourceSize.height: 64
                            }
                            
                            ColorOverlay {
                                anchors.fill: dockPreviewImage
                                source: dockPreviewImage
                                color: Qt.rgba(redValue/255, greenValue/255, blueValue/255, 1.0)
                            }
                            
                            Label {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottomMargin: 4
                                text: "Dock"
                                color: "white"
                                font.pixelSize: 10
                            }
                        }
                        
                        // Color swatch
                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 80
                            color: Qt.rgba(redValue/255, greenValue/255, blueValue/255, 1.0)
                            radius: 8
                            border.color: "#404040"
                            border.width: 1
                            
                            Label {
                                anchors.centerIn: parent
                                text: "#" + redValue.toString(16).padStart(2, '0') + 
                                     greenValue.toString(16).padStart(2, '0') + 
                                     blueValue.toString(16).padStart(2, '0')
                                color: (redValue + greenValue + blueValue) / 3 > 127 ? "black" : "white"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                    }
                }
            }
            
            // RGB Controls Section
            Rectangle {
                Layout.fillWidth: true
                height: 300
                color: "#2a2a2a"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16
                    
                    Label {
                        text: "RGB Color Controls"
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                    }
                    
                    // Red slider
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Label {
                                text: "Red"
                                color: "#ff6b6b"
                                font.pixelSize: 14
                                font.bold: true
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Label {
                                text: redValue
                                color: "white"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: "transparent"
                            
                            Slider {
                                id: redSlider
                                anchors.fill: parent
                                from: 0
                                to: 255
                                value: redValue
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                focus: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: redSlider.leftPadding
                                    y: redSlider.topPadding + redSlider.availableHeight / 2 - height / 2
                                    width: redSlider.availableWidth
                                    height: 4
                                    radius: 2
                                    color: "#404040"
                                    
                                    Rectangle {
                                        width: redSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#ff6b6b"
                                        radius: 2
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: redSlider.leftPadding + redSlider.visualPosition * (redSlider.availableWidth - width)
                                    y: redSlider.topPadding + redSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: redSlider.pressed ? "#ff6b6b" : "#ffffff"
                                    border.color: "#ff6b6b"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    redValue = Math.round(value)
                                    saveColor()
                                }
                                
                                onPressedChanged: {
                                    console.log("Red slider pressed:", pressed)
                                }
                                
                                onMoved: {
                                    console.log("Red slider moved to:", value)
                                }
                            }
                        }
                    }
                    
                    // Green slider
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Label {
                                text: "Green"
                                color: "#51cf66"
                                font.pixelSize: 14
                                font.bold: true
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Label {
                                text: greenValue
                                color: "white"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: "transparent"
                            
                            Slider {
                                id: greenSlider
                                anchors.fill: parent
                                from: 0
                                to: 255
                                value: greenValue
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                focus: true
                                hoverEnabled: true
                            
                            background: Rectangle {
                                x: greenSlider.leftPadding
                                y: greenSlider.topPadding + greenSlider.availableHeight / 2 - height / 2
                                width: greenSlider.availableWidth
                                height: 4
                                radius: 2
                                color: "#404040"
                                
                                Rectangle {
                                    width: greenSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: "#51cf66"
                                    radius: 2
                                }
                            }
                            
                            handle: Rectangle {
                                x: greenSlider.leftPadding + greenSlider.visualPosition * (greenSlider.availableWidth - width)
                                y: greenSlider.topPadding + greenSlider.availableHeight / 2 - height / 2
                                width: 16
                                height: 16
                                radius: 8
                                color: greenSlider.pressed ? "#51cf66" : "#ffffff"
                                border.color: "#51cf66"
                                border.width: 2
                            }
                            
                            onValueChanged: {
                                greenValue = Math.round(value)
                                saveColor()
                            }
                            
                            onPressedChanged: {
                                console.log("Green slider pressed:", pressed)
                            }
                            
                            onMoved: {
                                console.log("Green slider moved to:", value)
                            }
                        }
                    }
                    }
                    
                    // Blue slider
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Label {
                                text: "Blue"
                                color: "#339af0"
                                font.pixelSize: 14
                                font.bold: true
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Label {
                                text: blueValue
                                color: "white"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: "transparent"
                            
                            Slider {
                                id: blueSlider
                                anchors.fill: parent
                                from: 0
                                to: 255
                                value: blueValue
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                focus: true
                                hoverEnabled: true
                            
                            background: Rectangle {
                                x: blueSlider.leftPadding
                                y: blueSlider.topPadding + blueSlider.availableHeight / 2 - height / 2
                                width: blueSlider.availableWidth
                                height: 4
                                radius: 2
                                color: "#404040"
                                
                                Rectangle {
                                    width: blueSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: "#339af0"
                                    radius: 2
                                }
                            }
                            
                            handle: Rectangle {
                                x: blueSlider.leftPadding + blueSlider.visualPosition * (blueSlider.availableWidth - width)
                                y: blueSlider.topPadding + blueSlider.availableHeight / 2 - height / 2
                                width: 16
                                height: 16
                                radius: 8
                                color: blueSlider.pressed ? "#339af0" : "#ffffff"
                                border.color: "#339af0"
                                border.width: 2
                            }
                            
                            onValueChanged: {
                                blueValue = Math.round(value)
                                saveColor()
                            }
                            
                            onPressedChanged: {
                                console.log("Blue slider pressed:", pressed)
                            }
                            
                            onMoved: {
                                console.log("Blue slider moved to:", value)
                            }
                        }
                    }
                    }
                    
                    // Reset button
                    Button {
                        text: "Reset to White"
                        Layout.alignment: Qt.AlignHCenter
                        background: Rectangle {
                            color: parent.pressed ? "#404040" : "#505050"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            redValue = 255
                            greenValue = 255
                            blueValue = 255
                            redSlider.value = 255
                            greenSlider.value = 255
                            blueSlider.value = 255
                            saveColor()
                        }
                    }
                }
            }
        }
    }
} 