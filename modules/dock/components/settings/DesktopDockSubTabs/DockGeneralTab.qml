import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Settings

Rectangle {
    id: dockGeneralTab
    color: "transparent"
    
    // Function to save settings
    function saveDockSettings() {
        console.log("Saving dock settings...")
        // The Settings service automatically saves when properties change
        // but we can trigger a save if needed
    }
    
    // Function to load settings
    function loadDockSettings() {
        console.log("Loading dock settings...")
        // Settings are automatically loaded by the Settings service
    }
    
    Component.onCompleted: {
        loadDockSettings()
    }
    
    ScrollView {
        anchors.fill: parent
        clip: true
        
        ColumnLayout {
            width: parent.width
            spacing: 20
            
            // Dock Visibility Section
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
                        text: "Dock Visibility"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Show Dock"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Toggle switch for show dock
                        Rectangle {
                            width: 50
                            height: 24
                            radius: 12
                            color: Settings.settings.showDock ? "#5700eeff" : "#444444"
                            border.color: Settings.settings.showDock ? "#7700eeff" : "#666666"
                            border.width: 1
                            
                            Rectangle {
                                width: 20
                                height: 20
                                radius: 10
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: Settings.settings.showDock ? 26 : 2
                                
                                Behavior on anchors.leftMargin {
                                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    Settings.settings.showDock = !Settings.settings.showDock
                                    saveDockSettings()
                                }
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Exclusive Zone"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Toggle switch for exclusive zone
                        Rectangle {
                            width: 50
                            height: 24
                            radius: 12
                            color: Settings.settings.dockExclusive ? "#5700eeff" : "#444444"
                            border.color: Settings.settings.dockExclusive ? "#7700eeff" : "#666666"
                            border.width: 1
                            
                            Rectangle {
                                width: 20
                                height: 20
                                radius: 10
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: Settings.settings.dockExclusive ? 26 : 2
                                
                                Behavior on anchors.leftMargin {
                                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    Settings.settings.dockExclusive = !Settings.settings.dockExclusive
                                    saveDockSettings()
                                }
                            }
                        }
                    }
                }
            }
            
            // Dock Appearance Section
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
                        text: "Dock Appearance"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Icon Size"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Icon size slider
                        Rectangle {
                            width: 120
                            height: 40
                            color: "transparent"
                            
                            Slider {
                                id: iconSizeSlider
                                anchors.fill: parent
                                from: 32
                                to: 80
                                value: Settings.settings.dockIconSize || 48
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: iconSizeSlider.leftPadding
                                    y: iconSizeSlider.topPadding + iconSizeSlider.availableHeight / 2 - height / 2
                                    width: iconSizeSlider.availableWidth
                                    height: 6
                                    radius: 3
                                    color: "#444444"
                                    
                                    Rectangle {
                                        width: iconSizeSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#5700eeff"
                                        radius: 3
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: iconSizeSlider.leftPadding + iconSizeSlider.visualPosition * (iconSizeSlider.availableWidth - width)
                                    y: iconSizeSlider.topPadding + iconSizeSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: iconSizeSlider.pressed ? "#5700eeff" : "#ffffff"
                                    border.color: "#5700eeff"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    Settings.settings.dockIconSize = Math.round(value)
                                    saveDockSettings()
                                }
                            }
                        }
                        
                        Text {
                            text: Settings.settings.dockIconSize + "px"
                            font.pixelSize: 12
                            color: "#888888"
                            Layout.preferredWidth: 30
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Dock Height"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Dock height slider
                        Rectangle {
                            width: 120
                            height: 40
                            color: "transparent"
                            
                            Slider {
                                id: dockHeightSlider
                                anchors.fill: parent
                                from: 40
                                to: 120
                                value: Settings.settings.dockHeight || 60
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: dockHeightSlider.leftPadding
                                    y: dockHeightSlider.topPadding + dockHeightSlider.availableHeight / 2 - height / 2
                                    width: dockHeightSlider.availableWidth
                                    height: 6
                                    radius: 3
                                    color: "#444444"
                                    
                                    Rectangle {
                                        width: dockHeightSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#5700eeff"
                                        radius: 3
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: dockHeightSlider.leftPadding + dockHeightSlider.visualPosition * (dockHeightSlider.availableWidth - width)
                                    y: dockHeightSlider.topPadding + dockHeightSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: dockHeightSlider.pressed ? "#5700eeff" : "#ffffff"
                                    border.color: "#5700eeff"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    Settings.settings.dockHeight = Math.round(value)
                                    saveDockSettings()
                                }
                            }
                        }
                        
                        Text {
                            text: Settings.settings.dockHeight + "px"
                            font.pixelSize: 12
                            color: "#888888"
                            Layout.preferredWidth: 30
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Icon Spacing"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Icon spacing slider
                        Rectangle {
                            width: 120
                            height: 40
                            color: "transparent"
                            
                            Slider {
                                id: iconSpacingSlider
                                anchors.fill: parent
                                from: 2
                                to: 30
                                value: Settings.settings.dockIconSpacing || 8
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: iconSpacingSlider.leftPadding
                                    y: iconSpacingSlider.topPadding + iconSpacingSlider.availableHeight / 2 - height / 2
                                    width: iconSpacingSlider.availableWidth
                                    height: 6
                                    radius: 3
                                    color: "#444444"
                                    
                                    Rectangle {
                                        width: iconSpacingSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#5700eeff"
                                        radius: 3
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: iconSpacingSlider.leftPadding + iconSpacingSlider.visualPosition * (iconSpacingSlider.availableWidth - width)
                                    y: iconSpacingSlider.topPadding + iconSpacingSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: iconSpacingSlider.pressed ? "#5700eeff" : "#ffffff"
                                    border.color: "#5700eeff"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    Settings.settings.dockIconSpacing = Math.round(value)
                                    saveDockSettings()
                                }
                            }
                        }
                        
                        Text {
                            text: Settings.settings.dockIconSpacing + "px"
                            font.pixelSize: 12
                            color: "#888888"
                            Layout.preferredWidth: 30
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Border Width"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Border width slider
                        Rectangle {
                            width: 120
                            height: 40
                            color: "transparent"
                            
                            Slider {
                                id: borderWidthSlider
                                anchors.fill: parent
                                from: 0
                                to: 8
                                value: Settings.settings.dockBorderWidth || 1
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: borderWidthSlider.leftPadding
                                    y: borderWidthSlider.topPadding + borderWidthSlider.availableHeight / 2 - height / 2
                                    width: borderWidthSlider.availableWidth
                                    height: 6
                                    radius: 3
                                    color: "#444444"
                                    
                                    Rectangle {
                                        width: borderWidthSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#5700eeff"
                                        radius: 3
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: borderWidthSlider.leftPadding + borderWidthSlider.visualPosition * (borderWidthSlider.availableWidth - width)
                                    y: borderWidthSlider.topPadding + borderWidthSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: borderWidthSlider.pressed ? "#5700eeff" : "#ffffff"
                                    border.color: "#5700eeff"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    Settings.settings.dockBorderWidth = Math.round(value)
                                    saveDockSettings()
                                }
                            }
                        }
                        
                        Text {
                            text: Settings.settings.dockBorderWidth + "px"
                            font.pixelSize: 12
                            color: "#888888"
                            Layout.preferredWidth: 30
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Dock Radius"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Dock radius slider
                        Rectangle {
                            width: 120
                            height: 40
                            color: "transparent"
                            
                            Slider {
                                id: dockRadiusSlider
                                anchors.fill: parent
                                from: 0
                                to: 60
                                value: Settings.settings.dockRadius || 30
                                stepSize: 1
                                activeFocusOnTab: true
                                enabled: true
                                hoverEnabled: true
                                
                                background: Rectangle {
                                    x: dockRadiusSlider.leftPadding
                                    y: dockRadiusSlider.topPadding + dockRadiusSlider.availableHeight / 2 - height / 2
                                    width: dockRadiusSlider.availableWidth
                                    height: 6
                                    radius: 3
                                    color: "#444444"
                                    
                                    Rectangle {
                                        width: dockRadiusSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#5700eeff"
                                        radius: 3
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: dockRadiusSlider.leftPadding + dockRadiusSlider.visualPosition * (dockRadiusSlider.availableWidth - width)
                                    y: dockRadiusSlider.topPadding + dockRadiusSlider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: dockRadiusSlider.pressed ? "#5700eeff" : "#ffffff"
                                    border.color: "#5700eeff"
                                    border.width: 2
                                }
                                
                                onValueChanged: {
                                    Settings.settings.dockRadius = Math.round(value)
                                    saveDockSettings()
                                }
                            }
                        }
                        
                        Text {
                            text: Settings.settings.dockRadius + "px"
                            font.pixelSize: 12
                            color: "#888888"
                            Layout.preferredWidth: 30
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Transparency"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Transparency toggle switch
                        Rectangle {
                            width: 50
                            height: 24
                            radius: 12
                            color: Settings.settings.dockDimmed ? "#5700eeff" : "#444444"
                            border.color: Settings.settings.dockDimmed ? "#7700eeff" : "#666666"
                            border.width: 1
                            
                            Rectangle {
                                width: 20
                                height: 20
                                radius: 10
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: Settings.settings.dockDimmed ? 26 : 2
                                
                                Behavior on anchors.leftMargin {
                                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    Settings.settings.dockDimmed = !Settings.settings.dockDimmed
                                    saveDockSettings()
                                }
                            }
                        }
                        
                        Text {
                            text: Settings.settings.dockDimmed ? "Dimmed" : "Solid"
                            font.pixelSize: 12
                            color: "#888888"
                            Layout.preferredWidth: 40
                        }
                    }
                }
            }
        }
    }
} 