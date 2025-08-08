import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Settings

Rectangle {
    id: barGeneralTab
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
            
            // Bar Visibility Section
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
                        text: "Bar Visibility"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Show Bar"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Toggle switch for show bar
                        Rectangle {
                            width: 50
                            height: 24
                            radius: 12
                            color: Settings.settings.showTaskbar ? "#5700eeff" : "#444444"
                            border.color: Settings.settings.showTaskbar ? "#7700eeff" : "#666666"
                            border.width: 1
                            
                            Rectangle {
                                width: 20
                                height: 20
                                radius: 10
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: Settings.settings.showTaskbar ? 26 : 2
                                
                                Behavior on anchors.leftMargin {
                                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    Settings.settings.showTaskbar = !Settings.settings.showTaskbar
                                    saveBarSettings()
                                }
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Dim Panels"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Toggle switch for dim panels
                        Rectangle {
                            width: 50
                            height: 24
                            radius: 12
                            color: Settings.settings.dimPanels ? "#5700eeff" : "#444444"
                            border.color: Settings.settings.dimPanels ? "#7700eeff" : "#666666"
                            border.width: 1
                            
                            Rectangle {
                                width: 20
                                height: 20
                                radius: 10
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: Settings.settings.dimPanels ? 26 : 2
                                
                                Behavior on anchors.leftMargin {
                                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    Settings.settings.dimPanels = !Settings.settings.dimPanels
                                    saveBarSettings()
                                }
                            }
                        }
                    }
                }
            }
            

            
            // Bar Appearance Section
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
                        text: "Bar Appearance"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Font Size Multiplier"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Font size slider
                        Rectangle {
                            width: 120
                            height: 40
                            color: "transparent"
                            
                            Slider {
                                id: fontSizeSlider
                                anchors.fill: parent
                                from: 0.5
                                to: 2.0
                                value: Settings.settings.fontSizeMultiplier || 1.0
                                stepSize: 0.1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: fontSizeSlider.leftPadding
                                    y: fontSizeSlider.topPadding + fontSizeSlider.availableHeight / 2 - height / 2
                                    width: fontSizeSlider.availableWidth
                                    height: 6
                                    radius: 3
                                    color: "#444444"
                                    
                                    Rectangle {
                                        width: fontSizeSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#5700eeff"
                                        radius: 3
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: fontSizeSlider.leftPadding + fontSizeSlider.visualPosition * (fontSizeSlider.availableWidth - width)
                                    y: fontSizeSlider.topPadding + fontSizeSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: fontSizeSlider.pressed ? "#5700eeff" : "#ffffff"
                                    border.color: "#5700eeff"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    Settings.settings.fontSizeMultiplier = Math.round(value * 10) / 10
                                    saveBarSettings()
                                }
                            }
                        }
                        
                        Text {
                            text: "x" + (Settings.settings.fontSizeMultiplier || 1.0).toFixed(1)
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