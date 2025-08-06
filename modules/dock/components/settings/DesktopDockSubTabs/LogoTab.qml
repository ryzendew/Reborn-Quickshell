import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Services

Rectangle {
    id: logoTab
    color: "transparent"
    
    ScrollView {
        anchors.fill: parent
        clip: true
        
        ColumnLayout {
            width: parent.width
            spacing: 20
            
            // Logo Behavior Section
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                color: "#333333"
                radius: 8
                border.color: "#44ffffff"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    Text {
                        text: "Logo Button Behavior"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    Text {
                        text: "Configure what happens when you click the logo button in the bar"
                        font.pixelSize: 12
                        color: "#888888"
                    }
                    
                    // Logo action selector
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        color: "#222222"
                        radius: 6
                        border.color: "#33ffffff"
                        border.width: 1
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8
                            
                            Text {
                                text: "Logo Click Action"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#cccccc"
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                
                                // Action options
                                Repeater {
                                    model: [
                                        {text: "Power Panel", value: "power"},
                                        {text: "Application Menu", value: "menu"},
                                        {text: "Settings", value: "settings"},
                                        {text: "None", value: "none"}
                                    ]
                                    
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        color: logoActionMouseArea.containsMouse ? "#444444" : "transparent"
                                        radius: 4
                                        border.color: "#666666"
                                        border.width: 1
                                        
                                        Text {
                                            text: modelData.text
                                            font.pixelSize: 12
                                            color: "#cccccc"
                                            anchors.centerIn: parent
                                        }
                                        
                                        MouseArea {
                                            id: logoActionMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                // TODO: Implement logo action setting
                                                console.log("Logo action selected:", modelData.value)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Power Panel Settings Section
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
                        text: "Power Panel Settings"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    Text {
                        text: "Configure the power profile panel that opens when clicking the logo"
                        font.pixelSize: 12
                        color: "#888888"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Show Power Panel"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Toggle switch for power panel
                        Rectangle {
                            width: 50
                            height: 24
                            radius: 12
                            color: "#5700eeff" // Always enabled for now
                            border.color: "#7700eeff"
                            border.width: 1
                            
                            Rectangle {
                                width: 20
                                height: 20
                                radius: 10
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 26
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    // TODO: Implement power panel toggle
                                    console.log("Power panel toggle clicked")
                                }
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Panel Position"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Position selector
                        Rectangle {
                            width: 120
                            height: 32
                            radius: 4
                            color: "#222222"
                            border.color: "#666666"
                            border.width: 1
                            
                            Text {
                                text: "Top Left"
                                font.pixelSize: 12
                                color: "#cccccc"
                                anchors.centerIn: parent
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    // TODO: Implement position selector
                                    console.log("Position selector clicked")
                                }
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Panel Size"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Size selector
                        Rectangle {
                            width: 120
                            height: 32
                            radius: 4
                            color: "#222222"
                            border.color: "#666666"
                            border.width: 1
                            
                            Text {
                                text: "200x100"
                                font.pixelSize: 12
                                color: "#cccccc"
                                anchors.centerIn: parent
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    // TODO: Implement size selector
                                    console.log("Size selector clicked")
                                }
                            }
                        }
                    }
                }
            }
            
            // Logo Appearance Section
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
                        text: "Logo Appearance"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Logo Style"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Logo style selector
                        Rectangle {
                            width: 120
                            height: 32
                            radius: 4
                            color: "#222222"
                            border.color: "#666666"
                            border.width: 1
                            
                            Text {
                                text: "Arch Linux"
                                font.pixelSize: 12
                                color: "#cccccc"
                                anchors.centerIn: parent
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    // TODO: Implement logo style selector
                                    console.log("Logo style selector clicked")
                                }
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Show Tooltip"
                            font.pixelSize: 14
                            color: "#cccccc"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Toggle switch for tooltip
                        Rectangle {
                            width: 50
                            height: 24
                            radius: 12
                            color: "#5700eeff" // Always enabled for now
                            border.color: "#7700eeff"
                            border.width: 1
                            
                            Rectangle {
                                width: 20
                                height: 20
                                radius: 10
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 26
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    // TODO: Implement tooltip toggle
                                    console.log("Tooltip toggle clicked")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
} 