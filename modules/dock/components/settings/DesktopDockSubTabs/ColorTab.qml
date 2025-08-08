import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import qs.Services
import qs.Settings

Rectangle {
    id: colorTab
    color: "transparent"
    
    // Border color RGBA values
    property int borderRedValue: 87
    property int borderGreenValue: 0
    property int borderBlueValue: 238
    property int borderAlphaValue: 255
    
    // Active indicator color RGBA values
    property int activeRedValue: 0
    property int activeGreenValue: 255
    property int activeBlueValue: 255
    property int activeAlphaValue: 255
    
    // Load saved color values on component creation
    Component.onCompleted: {
        loadSavedColors()
        // Initialize sliders after loading colors
        initTimer.start()
    }
    
    Timer {
        id: initTimer
        interval: 100
        repeat: false
        onTriggered: {
            // Force update slider values to ensure proper binding
            borderRedSlider.value = borderRedValue
            borderGreenSlider.value = borderGreenValue
            borderBlueSlider.value = borderBlueValue
            borderAlphaSlider.value = borderAlphaValue
            
            activeRedSlider.value = activeRedValue
            activeGreenSlider.value = activeGreenValue
            activeBlueSlider.value = activeBlueValue
            activeAlphaSlider.value = activeAlphaValue
        }
    }
    
    function loadSavedColors() {
        // Load border color
        var savedBorderColor = Settings.settings.dockBorderColor || "#5700eeff"
        var borderColor = Qt.color(savedBorderColor)
        borderRedValue = Math.round(borderColor.r * 255)
        borderGreenValue = Math.round(borderColor.g * 255)
        borderBlueValue = Math.round(borderColor.b * 255)
        borderAlphaValue = Math.round(borderColor.a * 255)
        
        // Load active indicator color
        var savedActiveColor = Settings.settings.dockActiveIndicatorColor || "#00ffff"
        var activeColor = Qt.color(savedActiveColor)
        activeRedValue = Math.round(activeColor.r * 255)
        activeGreenValue = Math.round(activeColor.g * 255)
        activeBlueValue = Math.round(activeColor.b * 255)
        activeAlphaValue = Math.round(activeColor.a * 255)
    }
    
    function saveBorderColor() {
        var colorString = "#" + borderRedValue.toString(16).padStart(2, '0') + 
                         borderGreenValue.toString(16).padStart(2, '0') + 
                         borderBlueValue.toString(16).padStart(2, '0') + 
                         borderAlphaValue.toString(16).padStart(2, '0')
        
        Settings.settings.dockBorderColor = colorString
    }
    
    function saveActiveColor() {
        var colorString = "#" + activeRedValue.toString(16).padStart(2, '0') + 
                         activeGreenValue.toString(16).padStart(2, '0') + 
                         activeBlueValue.toString(16).padStart(2, '0') + 
                         activeAlphaValue.toString(16).padStart(2, '0')
        
        Settings.settings.dockActiveIndicatorColor = colorString
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
                        text: "Dock Color Preview"
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                    }
                    
                    // Preview area with dock mockup
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 20
                        
                        // Border color preview
                        Rectangle {
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 80
                            color: "#1a1a1a"
                            radius: 8
                            border.color: Qt.rgba(borderRedValue/255, borderGreenValue/255, borderBlueValue/255, borderAlphaValue/255)
                            border.width: 2
                            
                            Label {
                                anchors.centerIn: parent
                                text: "Border"
                                color: "white"
                                font.pixelSize: 12
                            }
                            
                            Label {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottomMargin: 4
                                text: "#" + borderRedValue.toString(16).padStart(2, '0') + 
                                     borderGreenValue.toString(16).padStart(2, '0') + 
                                     borderBlueValue.toString(16).padStart(2, '0') + 
                                     borderAlphaValue.toString(16).padStart(2, '0')
                                color: "white"
                                font.pixelSize: 10
                            }
                        }
                        
                        // Active indicator color preview
                        Rectangle {
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 80
                            color: "#1a1a1a"
                            radius: 8
                            border.color: "#404040"
                            border.width: 1
                            
                            Rectangle {
                                anchors.centerIn: parent
                                width: 40
                                height: 40
                                radius: 20
                                color: Qt.rgba(activeRedValue/255, activeGreenValue/255, activeBlueValue/255, activeAlphaValue/255)
                            }
                            
                            Label {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottomMargin: 4
                                text: "Active"
                                color: "white"
                                font.pixelSize: 12
                            }
                            
                            Label {
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.topMargin: 4
                                text: "#" + activeRedValue.toString(16).padStart(2, '0') + 
                                     activeGreenValue.toString(16).padStart(2, '0') + 
                                     activeBlueValue.toString(16).padStart(2, '0') + 
                                     activeAlphaValue.toString(16).padStart(2, '0')
                                color: "white"
                                font.pixelSize: 10
                            }
                        }
                    }
                }
            }
            
            // Border Color RGB Controls Section
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
                        text: "Border Color RGBA Controls"
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
                                text: borderRedValue
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
                                id: borderRedSlider
                                anchors.fill: parent
                                from: 0
                                to: 255
                                value: borderRedValue
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: borderRedSlider.leftPadding
                                    y: borderRedSlider.topPadding + borderRedSlider.availableHeight / 2 - height / 2
                                    width: borderRedSlider.availableWidth
                                    height: 4
                                    radius: 2
                                    color: "#404040"
                                    
                                    Rectangle {
                                        width: borderRedSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#ff6b6b"
                                        radius: 2
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: borderRedSlider.leftPadding + borderRedSlider.visualPosition * (borderRedSlider.availableWidth - width)
                                    y: borderRedSlider.topPadding + borderRedSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: borderRedSlider.pressed ? "#ff6b6b" : "#ffffff"
                                    border.color: "#ff6b6b"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    var newValue = Math.round(value)
                                    if (newValue !== borderRedValue) {
                                        borderRedValue = newValue
                                        saveBorderColor()
                                    }
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
                                text: borderGreenValue
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
                                id: borderGreenSlider
                                anchors.fill: parent
                                from: 0
                                to: 255
                                value: borderGreenValue
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: borderGreenSlider.leftPadding
                                    y: borderGreenSlider.topPadding + borderGreenSlider.availableHeight / 2 - height / 2
                                    width: borderGreenSlider.availableWidth
                                    height: 4
                                    radius: 2
                                    color: "#404040"
                                    
                                    Rectangle {
                                        width: borderGreenSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#51cf66"
                                        radius: 2
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: borderGreenSlider.leftPadding + borderGreenSlider.visualPosition * (borderGreenSlider.availableWidth - width)
                                    y: borderGreenSlider.topPadding + borderGreenSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: borderGreenSlider.pressed ? "#51cf66" : "#ffffff"
                                    border.color: "#51cf66"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    borderGreenValue = Math.round(value)
                                    saveBorderColor()
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
                                text: borderBlueValue
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
                                id: borderBlueSlider
                                anchors.fill: parent
                                from: 0
                                to: 255
                                value: borderBlueValue
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: borderBlueSlider.leftPadding
                                    y: borderBlueSlider.topPadding + borderBlueSlider.availableHeight / 2 - height / 2
                                    width: borderBlueSlider.availableWidth
                                    height: 4
                                    radius: 2
                                    color: "#404040"
                                    
                                    Rectangle {
                                        width: borderBlueSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#339af0"
                                        radius: 2
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: borderBlueSlider.leftPadding + borderBlueSlider.visualPosition * (borderBlueSlider.availableWidth - width)
                                    y: borderBlueSlider.topPadding + borderBlueSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: borderBlueSlider.pressed ? "#339af0" : "#ffffff"
                                    border.color: "#339af0"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    borderBlueValue = Math.round(value)
                                    saveBorderColor()
                                }
                            }
                        }
                    }
                    
                    // Alpha slider
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Label {
                                text: "Alpha"
                                color: "#ffffff"
                                font.pixelSize: 14
                                font.bold: true
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Label {
                                text: borderAlphaValue
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
                                id: borderAlphaSlider
                                anchors.fill: parent
                                from: 0
                                to: 255
                                value: borderAlphaValue
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: borderAlphaSlider.leftPadding
                                    y: borderAlphaSlider.topPadding + borderAlphaSlider.availableHeight / 2 - height / 2
                                    width: borderAlphaSlider.availableWidth
                                    height: 4
                                    radius: 2
                                    color: "#404040"
                                    
                                    Rectangle {
                                        width: borderAlphaSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#ffffff"
                                        radius: 2
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: borderAlphaSlider.leftPadding + borderAlphaSlider.visualPosition * (borderAlphaSlider.availableWidth - width)
                                    y: borderAlphaSlider.topPadding + borderAlphaSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: borderAlphaSlider.pressed ? "#ffffff" : "#ffffff"
                                    border.color: "#cccccc"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    borderAlphaValue = Math.round(value)
                                    saveBorderColor()
                                }
                            }
                        }
                    }
                }
            }
            
            // Active Indicator Color RGB Controls Section
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
                        text: "Active Indicator Color RGBA Controls"
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
                                text: activeRedValue
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
                                id: activeRedSlider
                                anchors.fill: parent
                                from: 0
                                to: 255
                                value: activeRedValue
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: activeRedSlider.leftPadding
                                    y: activeRedSlider.topPadding + activeRedSlider.availableHeight / 2 - height / 2
                                    width: activeRedSlider.availableWidth
                                    height: 4
                                    radius: 2
                                    color: "#404040"
                                    
                                    Rectangle {
                                        width: activeRedSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#ff6b6b"
                                        radius: 2
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: activeRedSlider.leftPadding + activeRedSlider.visualPosition * (activeRedSlider.availableWidth - width)
                                    y: activeRedSlider.topPadding + activeRedSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: activeRedSlider.pressed ? "#ff6b6b" : "#ffffff"
                                    border.color: "#ff6b6b"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    activeRedValue = Math.round(value)
                                    saveActiveColor()
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
                                text: activeGreenValue
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
                                id: activeGreenSlider
                                anchors.fill: parent
                                from: 0
                                to: 255
                                value: activeGreenValue
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: activeGreenSlider.leftPadding
                                    y: activeGreenSlider.topPadding + activeGreenSlider.availableHeight / 2 - height / 2
                                    width: activeGreenSlider.availableWidth
                                    height: 4
                                    radius: 2
                                    color: "#404040"
                                    
                                    Rectangle {
                                        width: activeGreenSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#51cf66"
                                        radius: 2
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: activeGreenSlider.leftPadding + activeGreenSlider.visualPosition * (activeGreenSlider.availableWidth - width)
                                    y: activeGreenSlider.topPadding + activeGreenSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: activeGreenSlider.pressed ? "#51cf66" : "#ffffff"
                                    border.color: "#51cf66"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    activeGreenValue = Math.round(value)
                                    saveActiveColor()
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
                                text: activeBlueValue
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
                                id: activeBlueSlider
                                anchors.fill: parent
                                from: 0
                                to: 255
                                value: activeBlueValue
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: activeBlueSlider.leftPadding
                                    y: activeBlueSlider.topPadding + activeBlueSlider.availableHeight / 2 - height / 2
                                    width: activeBlueSlider.availableWidth
                                    height: 4
                                    radius: 2
                                    color: "#404040"
                                    
                                    Rectangle {
                                        width: activeBlueSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#339af0"
                                        radius: 2
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: activeBlueSlider.leftPadding + activeBlueSlider.visualPosition * (activeBlueSlider.availableWidth - width)
                                    y: activeBlueSlider.topPadding + activeBlueSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: activeBlueSlider.pressed ? "#339af0" : "#ffffff"
                                    border.color: "#339af0"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    activeBlueValue = Math.round(value)
                                    saveActiveColor()
                                }
                            }
                        }
                    }
                    
                    // Alpha slider
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Label {
                                text: "Alpha"
                                color: "#ffffff"
                                font.pixelSize: 14
                                font.bold: true
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Label {
                                text: activeAlphaValue
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
                                id: activeAlphaSlider
                                anchors.fill: parent
                                from: 0
                                to: 255
                                value: activeAlphaValue
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: activeAlphaSlider.leftPadding
                                    y: activeAlphaSlider.topPadding + activeAlphaSlider.availableHeight / 2 - height / 2
                                    width: activeAlphaSlider.availableWidth
                                    height: 4
                                    radius: 2
                                    color: "#404040"
                                    
                                    Rectangle {
                                        width: activeAlphaSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#ffffff"
                                        radius: 2
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: activeAlphaSlider.leftPadding + activeAlphaSlider.visualPosition * (activeAlphaSlider.availableWidth - width)
                                    y: activeAlphaSlider.topPadding + activeAlphaSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: activeAlphaSlider.pressed ? "#ffffff" : "#ffffff"
                                    border.color: "#cccccc"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    activeAlphaValue = Math.round(value)
                                    saveActiveColor()
                                }
                            }
                        }
                    }
                }
            }
            
            // Quick Color Presets Section
            Rectangle {
                Layout.fillWidth: true
                height: 150
                color: "#2a2a2a"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    Label {
                        text: "Quick Color Presets"
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        Repeater {
                            model: [
                                {name: "Blue", border: "#5700eeff", active: "#00ffff"},
                                {name: "Green", border: "#4CAF50", active: "#8BC34A"},
                                {name: "Purple", border: "#9C27B0", active: "#E1BEE7"},
                                {name: "Orange", border: "#FF9800", active: "#FFCC02"}
                            ]
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 32
                                color: colorPresetMouseArea.containsMouse ? "#444444" : "transparent"
                                radius: 4
                                border.color: "#666666"
                                border.width: 1
                                
                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    
                                    Rectangle {
                                        width: 16
                                        height: 16
                                        radius: 2
                                        color: modelData.border
                                        border.color: "#333333"
                                        border.width: 1
                                    }
                                    
                                    Rectangle {
                                        width: 16
                                        height: 16
                                        radius: 2
                                        color: modelData.active
                                        border.color: "#333333"
                                        border.width: 1
                                    }
                                    
                                    Text {
                                        text: modelData.name
                                        font.pixelSize: 10
                                        color: "#cccccc"
                                    }
                                }
                                
                                MouseArea {
                                    id: colorPresetMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        // Parse the preset colors and update RGBA values
                                        var borderColor = Qt.color(modelData.border)
                                        borderRedValue = Math.round(borderColor.r * 255)
                                        borderGreenValue = Math.round(borderColor.g * 255)
                                        borderBlueValue = Math.round(borderColor.b * 255)
                                        borderAlphaValue = Math.round(borderColor.a * 255)
                                        
                                        var activeColor = Qt.color(modelData.active)
                                        activeRedValue = Math.round(activeColor.r * 255)
                                        activeGreenValue = Math.round(activeColor.g * 255)
                                        activeBlueValue = Math.round(activeColor.b * 255)
                                        activeAlphaValue = Math.round(activeColor.a * 255)
                                        
                                        // Update slider values
                                        borderRedSlider.value = borderRedValue
                                        borderGreenSlider.value = borderGreenValue
                                        borderBlueSlider.value = borderBlueValue
                                        borderAlphaSlider.value = borderAlphaValue
                                        activeRedSlider.value = activeRedValue
                                        activeGreenSlider.value = activeGreenValue
                                        activeBlueSlider.value = activeBlueValue
                                        activeAlphaSlider.value = activeAlphaValue
                                        
                                        // Save the colors
                                        saveBorderColor()
                                        saveActiveColor()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
} 