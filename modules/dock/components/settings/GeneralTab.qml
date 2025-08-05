import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: generalTab
    color: "transparent"
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16
        
        // Content header with navigation
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            spacing: 16
            
            // Back button
            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: backMouseArea.containsMouse ? "#333333" : "transparent"
                border.color: backMouseArea.containsMouse ? "#555555" : "transparent"
                border.width: 1
                
                Text {
                    anchors.centerIn: parent
                    text: "arrow_back"
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 18
                    color: "#cccccc"
                }
                
                MouseArea {
                    id: backMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
            
            // Forward button
            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: forwardMouseArea.containsMouse ? "#333333" : "transparent"
                border.color: forwardMouseArea.containsMouse ? "#555555" : "transparent"
                border.width: 1
                
                Text {
                    anchors.centerIn: parent
                    text: "arrow_forward"
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 18
                    color: "#cccccc"
                }
                
                MouseArea {
                    id: forwardMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
            
            // Page title
            Text {
                text: "General"
                font.pixelSize: 18
                font.weight: Font.Bold
                color: "#ffffff"
                Layout.fillWidth: true
            }
            
            // Help button
            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: helpMouseArea.containsMouse ? "#333333" : "transparent"
                border.color: helpMouseArea.containsMouse ? "#555555" : "transparent"
                border.width: 1
                
                Text {
                    anchors.centerIn: parent
                    text: "help"
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 18
                    color: "#cccccc"
                }
                
                MouseArea {
                    id: helpMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
        }
        
        // Settings content
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            ColumnLayout {
                width: parent.width
                spacing: 16
                
                // Example settings
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    color: "#2a2a2a"
                    radius: 8
                    border.color: "#33ffffff"
                    border.width: 1
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16
                        
                        ColumnLayout {
                            spacing: 4
                            
                            Text {
                                text: "Auto-hide Dock"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#ffffff"
                            }
                            
                            Text {
                                text: "Automatically hide the dock when not in use"
                                font.pixelSize: 11
                                color: "#cccccc"
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Toggle switch
                        Rectangle {
                            width: 44
                            height: 24
                            radius: 12
                            color: "#333333"
                            border.color: "#555555"
                            border.width: 1
                            
                            Rectangle {
                                width: 18
                                height: 18
                                radius: 9
                                color: "#ffffff"
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    left: parent.left
                                    leftMargin: 3
                                }
                            }
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    color: "#2a2a2a"
                    radius: 8
                    border.color: "#33ffffff"
                    border.width: 1
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16
                        
                        ColumnLayout {
                            spacing: 4
                            
                            Text {
                                text: "Show Application Menu"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#ffffff"
                            }
                            
                            Text {
                                text: "Display the application launcher menu"
                                font.pixelSize: 11
                                color: "#cccccc"
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Toggle switch
                        Rectangle {
                            width: 44
                            height: 24
                            radius: 12
                            color: "#5700eeff"
                            border.color: "#7700eeff"
                            border.width: 1
                            
                            Rectangle {
                                width: 18
                                height: 18
                                radius: 9
                                color: "#ffffff"
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    right: parent.right
                                    rightMargin: 3
                                }
                            }
                        }
                    }
                }
                
                // System info section
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    color: "#2a2a2a"
                    radius: 8
                    border.color: "#33ffffff"
                    border.width: 1
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 8
                        
                        Text {
                            text: "System Information"
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            color: "#ffffff"
                        }
                        
                        Text {
                            text: "QuickShell v1.0.0"
                            font.pixelSize: 12
                            color: "#cccccc"
                        }
                        
                        Text {
                            text: "Last updated: Today at 3:43 PM"
                            font.pixelSize: 12
                            color: "#cccccc"
                        }
                        
                        Text {
                            text: "Your system is up to date."
                            font.pixelSize: 12
                            color: "#00ff00"
                        }
                    }
                }
            }
        }
    }
} 