import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Settings

Rectangle {
    id: barColorsTab
    color: "transparent"
    
    // Workspace border color RGBA values
    property int borderRedValue: 0
    property int borderGreenValue: 204
    property int borderBlueValue: 255
    property int borderAlphaValue: 255
    
    // Workspace indicator color RGBA values
    property int indicatorRedValue: 0
    property int indicatorGreenValue: 255
    property int indicatorBlueValue: 255
    property int indicatorAlphaValue: 255
    
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
            
            indicatorRedSlider.value = indicatorRedValue
            indicatorGreenSlider.value = indicatorGreenValue
            indicatorBlueSlider.value = indicatorBlueValue
            indicatorAlphaSlider.value = indicatorAlphaValue
        }
    }
    
    function loadSavedColors() {
        // Load workspace border color
        var savedBorderColor = Settings.settings.workspaceBorderColor || "#00ccff"
        var borderColor = Qt.color(savedBorderColor)
        borderRedValue = Math.round(borderColor.r * 255)
        borderGreenValue = Math.round(borderColor.g * 255)
        borderBlueValue = Math.round(borderColor.b * 255)
        borderAlphaValue = Math.round(borderColor.a * 255)
        
        // Load workspace indicator color
        var savedIndicatorColor = Settings.settings.workspaceIndicatorColor || "#00ffff"
        var indicatorColor = Qt.color(savedIndicatorColor)
        indicatorRedValue = Math.round(indicatorColor.r * 255)
        indicatorGreenValue = Math.round(indicatorColor.g * 255)
        indicatorBlueValue = Math.round(indicatorColor.b * 255)
        indicatorAlphaValue = Math.round(indicatorColor.a * 255)
    }
    
    function saveBorderColor() {
        var colorString = "#" + borderRedValue.toString(16).padStart(2, '0') + 
                         borderGreenValue.toString(16).padStart(2, '0') + 
                         borderBlueValue.toString(16).padStart(2, '0') + 
                         borderAlphaValue.toString(16).padStart(2, '0')
        
        Settings.settings.workspaceBorderColor = colorString
    }
    
    function saveIndicatorColor() {
        var colorString = "#" + indicatorRedValue.toString(16).padStart(2, '0') + 
                         indicatorGreenValue.toString(16).padStart(2, '0') + 
                         indicatorBlueValue.toString(16).padStart(2, '0') + 
                         indicatorAlphaValue.toString(16).padStart(2, '0')
        
        Settings.settings.workspaceIndicatorColor = colorString
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
                        text: "Workspace Color Preview"
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                    }
                    
                    // Preview area with workspace mockup
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 20
                        
                        // Workspace border color preview
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
                        
                        // Workspace indicator color preview
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
                                color: Qt.rgba(indicatorRedValue/255, indicatorGreenValue/255, indicatorBlueValue/255, indicatorAlphaValue/255)
                            }
                            
                            Label {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottomMargin: 4
                                text: "Indicator"
                                color: "white"
                                font.pixelSize: 12
                            }
                            
                            Label {
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.topMargin: 4
                                text: "#" + indicatorRedValue.toString(16).padStart(2, '0') + 
                                     indicatorGreenValue.toString(16).padStart(2, '0') + 
                                     indicatorBlueValue.toString(16).padStart(2, '0') + 
                                     indicatorAlphaValue.toString(16).padStart(2, '0')
                                color: "white"
                                font.pixelSize: 10
                            }
                        }
                    }
                }
            }
            
            // Workspace Border Color RGBA Controls Section
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
                        text: "Workspace Border Color RGBA Controls"
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
                                    var newValue = Math.round(value)
                                    if (newValue !== borderGreenValue) {
                                        borderGreenValue = newValue
                                        saveBorderColor()
                                    }
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
                                    var newValue = Math.round(value)
                                    if (newValue !== borderBlueValue) {
                                        borderBlueValue = newValue
                                        saveBorderColor()
                                    }
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
                                    var newValue = Math.round(value)
                                    if (newValue !== borderAlphaValue) {
                                        borderAlphaValue = newValue
                                        saveBorderColor()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Workspace Indicator Color RGBA Controls Section
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
                        text: "Workspace Indicator Color RGBA Controls"
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
                                text: indicatorRedValue
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
                                id: indicatorRedSlider
                                anchors.fill: parent
                                from: 0
                                to: 255
                                value: indicatorRedValue
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: indicatorRedSlider.leftPadding
                                    y: indicatorRedSlider.topPadding + indicatorRedSlider.availableHeight / 2 - height / 2
                                    width: indicatorRedSlider.availableWidth
                                    height: 4
                                    radius: 2
                                    color: "#404040"
                                    
                                    Rectangle {
                                        width: indicatorRedSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#ff6b6b"
                                        radius: 2
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: indicatorRedSlider.leftPadding + indicatorRedSlider.visualPosition * (indicatorRedSlider.availableWidth - width)
                                    y: indicatorRedSlider.topPadding + indicatorRedSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: indicatorRedSlider.pressed ? "#ff6b6b" : "#ffffff"
                                    border.color: "#ff6b6b"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    var newValue = Math.round(value)
                                    if (newValue !== indicatorRedValue) {
                                        indicatorRedValue = newValue
                                        saveIndicatorColor()
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
                                text: indicatorGreenValue
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
                                id: indicatorGreenSlider
                                anchors.fill: parent
                                from: 0
                                to: 255
                                value: indicatorGreenValue
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: indicatorGreenSlider.leftPadding
                                    y: indicatorGreenSlider.topPadding + indicatorGreenSlider.availableHeight / 2 - height / 2
                                    width: indicatorGreenSlider.availableWidth
                                    height: 4
                                    radius: 2
                                    color: "#404040"
                                    
                                    Rectangle {
                                        width: indicatorGreenSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#51cf66"
                                        radius: 2
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: indicatorGreenSlider.leftPadding + indicatorGreenSlider.visualPosition * (indicatorGreenSlider.availableWidth - width)
                                    y: indicatorGreenSlider.topPadding + indicatorGreenSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: indicatorGreenSlider.pressed ? "#51cf66" : "#ffffff"
                                    border.color: "#51cf66"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    var newValue = Math.round(value)
                                    if (newValue !== indicatorGreenValue) {
                                        indicatorGreenValue = newValue
                                        saveIndicatorColor()
                                    }
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
                                text: indicatorBlueValue
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
                                id: indicatorBlueSlider
                                anchors.fill: parent
                                from: 0
                                to: 255
                                value: indicatorBlueValue
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: indicatorBlueSlider.leftPadding
                                    y: indicatorBlueSlider.topPadding + indicatorBlueSlider.availableHeight / 2 - height / 2
                                    width: indicatorBlueSlider.availableWidth
                                    height: 4
                                    radius: 2
                                    color: "#404040"
                                    
                                    Rectangle {
                                        width: indicatorBlueSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#339af0"
                                        radius: 2
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: indicatorBlueSlider.leftPadding + indicatorBlueSlider.visualPosition * (indicatorBlueSlider.availableWidth - width)
                                    y: indicatorBlueSlider.topPadding + indicatorBlueSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: indicatorBlueSlider.pressed ? "#339af0" : "#ffffff"
                                    border.color: "#339af0"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    var newValue = Math.round(value)
                                    if (newValue !== indicatorBlueValue) {
                                        indicatorBlueValue = newValue
                                        saveIndicatorColor()
                                    }
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
                                text: indicatorAlphaValue
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
                                id: indicatorAlphaSlider
                                anchors.fill: parent
                                from: 0
                                to: 255
                                value: indicatorAlphaValue
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: indicatorAlphaSlider.leftPadding
                                    y: indicatorAlphaSlider.topPadding + indicatorAlphaSlider.availableHeight / 2 - height / 2
                                    width: indicatorAlphaSlider.availableWidth
                                    height: 4
                                    radius: 2
                                    color: "#404040"
                                    
                                    Rectangle {
                                        width: indicatorAlphaSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#ffffff"
                                        radius: 2
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: indicatorAlphaSlider.leftPadding + indicatorAlphaSlider.visualPosition * (indicatorAlphaSlider.availableWidth - width)
                                    y: indicatorAlphaSlider.topPadding + indicatorAlphaSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: indicatorAlphaSlider.pressed ? "#ffffff" : "#ffffff"
                                    border.color: "#cccccc"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    var newValue = Math.round(value)
                                    if (newValue !== indicatorAlphaValue) {
                                        indicatorAlphaValue = newValue
                                        saveIndicatorColor()
                                    }
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
                                {name: "Cyan", border: "#00ccff", indicator: "#00ffff"},
                                {name: "Blue", border: "#0066ff", indicator: "#3399ff"},
                                {name: "Purple", border: "#9933ff", indicator: "#cc66ff"},
                                {name: "Green", border: "#00ff66", indicator: "#33ff99"}
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
                                        color: modelData.indicator
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
                                        
                                        var indicatorColor = Qt.color(modelData.indicator)
                                        indicatorRedValue = Math.round(indicatorColor.r * 255)
                                        indicatorGreenValue = Math.round(indicatorColor.g * 255)
                                        indicatorBlueValue = Math.round(indicatorColor.b * 255)
                                        indicatorAlphaValue = Math.round(indicatorColor.a * 255)
                                        
                                        // Update slider values
                                        borderRedSlider.value = borderRedValue
                                        borderGreenSlider.value = borderGreenValue
                                        borderBlueSlider.value = borderBlueValue
                                        borderAlphaSlider.value = borderAlphaValue
                                        indicatorRedSlider.value = indicatorRedValue
                                        indicatorGreenSlider.value = indicatorGreenValue
                                        indicatorBlueSlider.value = indicatorBlueValue
                                        indicatorAlphaSlider.value = indicatorAlphaValue
                                        
                                        // Save the colors
                                        saveBorderColor()
                                        saveIndicatorColor()
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