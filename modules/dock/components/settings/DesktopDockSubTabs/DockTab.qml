import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Settings

Rectangle {
    id: dockTab
    color: "transparent"
    
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
                            height: 6
                            radius: 3
                            color: "#444444"
                            
                            Rectangle {
                                width: parent.width * (Settings.settings.dockIconSize / 80.0)
                                height: parent.height
                                radius: 3
                                color: "#5700eeff"
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var newSize = Math.round((mouseX / parent.width) * 80)
                                    Settings.settings.dockIconSize = Math.max(32, Math.min(80, newSize))
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
                            height: 6
                            radius: 3
                            color: "#444444"
                            
                            Rectangle {
                                width: parent.width * (Settings.settings.dockHeight / 120.0)
                                height: parent.height
                                radius: 3
                                color: "#5700eeff"
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var newHeight = Math.round((mouseX / parent.width) * 120)
                                    Settings.settings.dockHeight = Math.max(40, Math.min(120, newHeight))
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
                            height: 6
                            radius: 3
                            color: "#444444"
                            
                            Rectangle {
                                width: parent.width * (Settings.settings.dockIconSpacing / 20.0)
                                height: parent.height
                                radius: 3
                                color: "#5700eeff"
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var newSpacing = Math.round((mouseX / parent.width) * 20)
                                    Settings.settings.dockIconSpacing = Math.max(2, Math.min(30, newSpacing))
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
                            height: 6
                            radius: 3
                            color: "#444444"
                            
                            Rectangle {
                                width: parent.width * (Settings.settings.dockBorderWidth / 5.0)
                                height: parent.height
                                radius: 3
                                color: "#5700eeff"
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var newWidth = Math.round((mouseX / parent.width) * 5)
                                    Settings.settings.dockBorderWidth = Math.max(0, Math.min(8, newWidth))
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
                }
            }
            
            // Dock Colors Section
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
                        text: "Dock Colors"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Border Color"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Border color preview
                        Rectangle {
                            width: 40
                            height: 24
                            radius: 4
                            color: Settings.settings.dockBorderColor
                            border.color: "#666666"
                            border.width: 1
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    // TODO: Implement color picker
                                    console.log("Border color picker clicked")
                                }
                            }
                        }
                        
                        Text {
                            text: Settings.settings.dockBorderColor
                            font.pixelSize: 12
                            color: "#888888"
                            Layout.preferredWidth: 80
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Active Indicator Color"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Active indicator color preview
                        Rectangle {
                            width: 40
                            height: 24
                            radius: 4
                            color: Settings.settings.dockActiveIndicatorColor
                            border.color: "#666666"
                            border.width: 1
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    // TODO: Implement color picker
                                    console.log("Active indicator color picker clicked")
                                }
                            }
                        }
                        
                        Text {
                            text: Settings.settings.dockActiveIndicatorColor
                            font.pixelSize: 12
                            color: "#888888"
                            Layout.preferredWidth: 80
                        }
                    }
                    
                    // Quick color presets
                    Text {
                        text: "Quick Color Presets"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: "#cccccc"
                        Layout.topMargin: 8
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
                                        Settings.settings.dockBorderColor = modelData.border
                                        Settings.settings.dockActiveIndicatorColor = modelData.active
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Pinned Applications Section
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
                        text: "Pinned Applications"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    Text {
                        text: "Manage applications that appear in your dock"
                        font.pixelSize: 12
                        color: "#888888"
                    }
                    
                    // Pinned apps list
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#222222"
                        radius: 6
                        border.color: "#33ffffff"
                        border.width: 1
                        
                        ListView {
                            anchors.fill: parent
                            anchors.margins: 8
                            clip: true
                            model: Settings.settings.pinnedExecs || []
                            
                            delegate: Rectangle {
                                width: parent.width
                                height: 40
                                color: "transparent"
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 12
                                    
                                    Text {
                                        text: "apps"
                                        font.family: "Material Symbols Outlined"
                                        font.pixelSize: 20
                                        color: "#cccccc"
                                    }
                                    
                                    Text {
                                        text: modelData
                                        font.pixelSize: 14
                                        color: "#cccccc"
                                        Layout.fillWidth: true
                                    }
                                    
                                    Rectangle {
                                        width: 24
                                        height: 24
                                        radius: 12
                                        color: removeMouseArea.containsMouse ? "#ff4444" : "#444444"
                                        border.color: "#666666"
                                        border.width: 1
                                        
                                        Text {
                                            text: "close"
                                            font.family: "Material Symbols Outlined"
                                            font.pixelSize: 14
                                            color: "#ffffff"
                                            anchors.centerIn: parent
                                        }
                                        
                                        MouseArea {
                                            id: removeMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                var pinned = Settings.settings.pinnedExecs || []
                                                pinned.splice(index, 1)
                                                Settings.settings.pinnedExecs = pinned
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
    }
} 