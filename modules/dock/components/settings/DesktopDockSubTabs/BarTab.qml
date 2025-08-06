import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Services

Rectangle {
    id: barTab
    color: "transparent"
    
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
                        
                        // Toggle switch for show bar (using showTaskbar setting)
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
                                }
                            }
                        }
                    }
                }
            }
            
            // Bar Content Section
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                color: "#333333"
                radius: 8
                border.color: "#44ffffff"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    Text {
                        text: "Bar Content"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Show System Info"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Toggle switch for system info
                        Rectangle {
                            width: 50
                            height: 24
                            radius: 12
                            color: Settings.settings.showSystemInfoInBar ? "#5700eeff" : "#444444"
                            border.color: Settings.settings.showSystemInfoInBar ? "#7700eeff" : "#666666"
                            border.width: 1
                            
                            Rectangle {
                                width: 20
                                height: 20
                                radius: 10
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: Settings.settings.showSystemInfoInBar ? 26 : 2
                                
                                Behavior on anchors.leftMargin {
                                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    Settings.settings.showSystemInfoInBar = !Settings.settings.showSystemInfoInBar
                                }
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Show Media Controls"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Toggle switch for media controls
                        Rectangle {
                            width: 50
                            height: 24
                            radius: 12
                            color: Settings.settings.showMediaInBar ? "#5700eeff" : "#444444"
                            border.color: Settings.settings.showMediaInBar ? "#7700eeff" : "#666666"
                            border.width: 1
                            
                            Rectangle {
                                width: 20
                                height: 20
                                radius: 10
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: Settings.settings.showMediaInBar ? 26 : 2
                                
                                Behavior on anchors.leftMargin {
                                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    Settings.settings.showMediaInBar = !Settings.settings.showMediaInBar
                                }
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Show Active Window Icon"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Toggle switch for active window icon
                        Rectangle {
                            width: 50
                            height: 24
                            radius: 12
                            color: Settings.settings.showActiveWindowIcon ? "#5700eeff" : "#444444"
                            border.color: Settings.settings.showActiveWindowIcon ? "#7700eeff" : "#666666"
                            border.width: 1
                            
                            Rectangle {
                                width: 20
                                height: 20
                                radius: 10
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: Settings.settings.showActiveWindowIcon ? 26 : 2
                                
                                Behavior on anchors.leftMargin {
                                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    Settings.settings.showActiveWindowIcon = !Settings.settings.showActiveWindowIcon
                                }
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Show Corners"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Toggle switch for corners
                        Rectangle {
                            width: 50
                            height: 24
                            radius: 12
                            color: Settings.settings.showCorners ? "#5700eeff" : "#444444"
                            border.color: Settings.settings.showCorners ? "#7700eeff" : "#666666"
                            border.width: 1
                            
                            Rectangle {
                                width: 20
                                height: 20
                                radius: 10
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: Settings.settings.showCorners ? 26 : 2
                                
                                Behavior on anchors.leftMargin {
                                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    Settings.settings.showCorners = !Settings.settings.showCorners
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
                            height: 6
                            radius: 3
                            color: "#444444"
                            
                            Rectangle {
                                width: parent.width * Settings.settings.fontSizeMultiplier
                                height: parent.height
                                radius: 3
                                color: "#5700eeff"
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var newMultiplier = Math.max(0.5, Math.min(2.0, mouseX / parent.width))
                                    Settings.settings.fontSizeMultiplier = Math.round(newMultiplier * 10) / 10
                                }
                            }
                        }
                        
                        Text {
                            text: "x" + Settings.settings.fontSizeMultiplier.toFixed(1)
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