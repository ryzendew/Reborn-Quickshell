import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Settings

Rectangle {
    id: barSizingTab
    color: "transparent"
    
    // Function to save settings
    function saveBarSettings() {
        // Settings are automatically saved when properties change
    }
    
    // Function to load settings
    function loadBarSettings() {
        // Settings are automatically loaded by the Settings service
    }
    
    Component.onCompleted: {
        loadBarSettings()
    }
    
    ScrollView {
        anchors.fill: parent
        clip: true
        
        ColumnLayout {
            width: parent.width
            spacing: 20
            
            // Bar Height Section
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: "#333333"
                radius: 8
                border.color: "#44ffffff"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    Text {
                        text: "Bar Height"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Bar Height"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Bar height slider
                        Rectangle {
                            width: 120
                            height: 40
                            color: "transparent"
                            
                            Slider {
                                id: barHeightSlider
                                anchors.fill: parent
                                from: 20
                                to: 80
                                value: Settings.settings.barHeight || 40
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: barHeightSlider.leftPadding
                                    y: barHeightSlider.topPadding + barHeightSlider.availableHeight / 2 - height / 2
                                    width: barHeightSlider.availableWidth
                                    height: 6
                                    radius: 3
                                    color: "#444444"
                                    
                                    Rectangle {
                                        width: barHeightSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#5700eeff"
                                        radius: 3
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: barHeightSlider.leftPadding + barHeightSlider.visualPosition * (barHeightSlider.availableWidth - width)
                                    y: barHeightSlider.topPadding + barHeightSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: barHeightSlider.pressed ? "#5700eeff" : "#ffffff"
                                    border.color: "#5700eeff"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    Settings.settings.barHeight = Math.round(value)
                                    saveBarSettings()
                                }
                            }
                        }
                        
                        Text {
                            text: Settings.settings.barHeight + "px"
                            font.pixelSize: 12
                            color: "#888888"
                            Layout.preferredWidth: 30
                        }
                    }
                }
            }
            
            // Component Sizing Section
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 320
                color: "#333333"
                radius: 8
                border.color: "#44ffffff"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    Text {
                        text: "Component Sizing"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "System Tray Size"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // System tray size slider
                        Rectangle {
                            width: 120
                            height: 40
                            color: "transparent"
                            
                            Slider {
                                id: systemTraySizeSlider
                                anchors.fill: parent
                                from: 16
                                to: 48
                                value: Settings.settings.systemTraySize || 24
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: systemTraySizeSlider.leftPadding
                                    y: systemTraySizeSlider.topPadding + systemTraySizeSlider.availableHeight / 2 - height / 2
                                    width: systemTraySizeSlider.availableWidth
                                    height: 6
                                    radius: 3
                                    color: "#444444"
                                    
                                    Rectangle {
                                        width: systemTraySizeSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#5700eeff"
                                        radius: 3
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: systemTraySizeSlider.leftPadding + systemTraySizeSlider.visualPosition * (systemTraySizeSlider.availableWidth - width)
                                    y: systemTraySizeSlider.topPadding + systemTraySizeSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: systemTraySizeSlider.pressed ? "#5700eeff" : "#ffffff"
                                    border.color: "#5700eeff"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    Settings.settings.systemTraySize = Math.round(value)
                                    saveBarSettings()
                                }
                            }
                        }
                        
                        Text {
                            text: Settings.settings.systemTraySize + "px"
                            font.pixelSize: 12
                            color: "#888888"
                            Layout.preferredWidth: 30
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Indicators Size"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Indicators size slider
                        Rectangle {
                            width: 120
                            height: 40
                            color: "transparent"
                            
                            Slider {
                                id: indicatorsSizeSlider
                                anchors.fill: parent
                                from: 16
                                to: 48
                                value: Settings.settings.indicatorsSize || 24
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: indicatorsSizeSlider.leftPadding
                                    y: indicatorsSizeSlider.topPadding + indicatorsSizeSlider.availableHeight / 2 - height / 2
                                    width: indicatorsSizeSlider.availableWidth
                                    height: 6
                                    radius: 3
                                    color: "#444444"
                                    
                                    Rectangle {
                                        width: indicatorsSizeSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#5700eeff"
                                        radius: 3
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: indicatorsSizeSlider.leftPadding + indicatorsSizeSlider.visualPosition * (indicatorsSizeSlider.availableWidth - width)
                                    y: indicatorsSizeSlider.topPadding + indicatorsSizeSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: indicatorsSizeSlider.pressed ? "#5700eeff" : "#ffffff"
                                    border.color: "#5700eeff"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    Settings.settings.indicatorsSize = Math.round(value)
                                    saveBarSettings()
                                }
                            }
                        }
                        
                        Text {
                            text: Settings.settings.indicatorsSize + "px"
                            font.pixelSize: 12
                            color: "#888888"
                            Layout.preferredWidth: 30
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Bar Logo Size"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Bar logo size slider
                        Rectangle {
                            width: 120
                            height: 40
                            color: "transparent"
                            
                            Slider {
                                id: barLogoSizeSlider
                                anchors.fill: parent
                                from: 16
                                to: 48
                                value: Settings.settings.barLogoSize || 24
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: barLogoSizeSlider.leftPadding
                                    y: barLogoSizeSlider.topPadding + barLogoSizeSlider.availableHeight / 2 - height / 2
                                    width: barLogoSizeSlider.availableWidth
                                    height: 6
                                    radius: 3
                                    color: "#444444"
                                    
                                    Rectangle {
                                        width: barLogoSizeSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#5700eeff"
                                        radius: 3
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: barLogoSizeSlider.leftPadding + barLogoSizeSlider.visualPosition * (barLogoSizeSlider.availableWidth - width)
                                    y: barLogoSizeSlider.topPadding + barLogoSizeSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: barLogoSizeSlider.pressed ? "#5700eeff" : "#ffffff"
                                    border.color: "#5700eeff"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    Settings.settings.barLogoSize = Math.round(value)
                                    saveBarSettings()
                                }
                            }
                        }
                        
                        Text {
                            text: Settings.settings.barLogoSize + "px"
                            font.pixelSize: 12
                            color: "#888888"
                            Layout.preferredWidth: 30
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Taskbar Icon Size"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Taskbar icon size slider
                        Rectangle {
                            width: 120
                            height: 40
                            color: "transparent"
                            
                            Slider {
                                id: taskbarIconSizeSlider
                                anchors.fill: parent
                                from: 16
                                to: 48
                                value: Settings.settings.taskbarIconSize || 24
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: taskbarIconSizeSlider.leftPadding
                                    y: taskbarIconSizeSlider.topPadding + taskbarIconSizeSlider.availableHeight / 2 - height / 2
                                    width: taskbarIconSizeSlider.availableWidth
                                    height: 6
                                    radius: 3
                                    color: "#444444"
                                    
                                    Rectangle {
                                        width: taskbarIconSizeSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#5700eeff"
                                        radius: 3
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: taskbarIconSizeSlider.leftPadding + taskbarIconSizeSlider.visualPosition * (taskbarIconSizeSlider.availableWidth - width)
                                    y: taskbarIconSizeSlider.topPadding + taskbarIconSizeSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: taskbarIconSizeSlider.pressed ? "#5700eeff" : "#ffffff"
                                    border.color: "#5700eeff"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    Settings.settings.taskbarIconSize = Math.round(value)
                                    saveBarSettings()
                                }
                            }
                        }
                        
                        Text {
                            text: Settings.settings.taskbarIconSize + "px"
                            font.pixelSize: 12
                            color: "#888888"
                            Layout.preferredWidth: 30
                        }
                    }
                }
            }
        }
    }
} 