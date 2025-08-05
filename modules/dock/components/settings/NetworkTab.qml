import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Services

Rectangle {
    id: networkTab
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
                text: "Network"
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
                    text: "info"
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
        
        // Network settings content
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            ColumnLayout {
                width: parent.width
                spacing: 16
                
                // Wi-Fi settings
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
                                text: "Wi-Fi"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#ffffff"
                            }
                            
                            Text {
                                text: "Connect to wireless networks"
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
                            color: Network.wifiEnabled ? "#5700eeff" : "#333333"
                            border.color: Network.wifiEnabled ? "#7700eeff" : "#555555"
                            border.width: 1
                            
                            Rectangle {
                                width: 18
                                height: 18
                                radius: 9
                                color: "#ffffff"
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    right: Network.wifiEnabled ? parent.right : parent.left
                                    rightMargin: Network.wifiEnabled ? 3 : undefined
                                    leftMargin: Network.wifiEnabled ? undefined : 3
                                }
                                
                                Behavior on anchors.rightMargin {
                                    NumberAnimation { duration: 150 }
                                }
                                Behavior on anchors.leftMargin {
                                    NumberAnimation { duration: 150 }
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    Network.toggleWifi();
                                }
                            }
                        }
                    }
                }
                
                // Ethernet settings
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
                                text: "Ethernet"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#ffffff"
                            }
                            
                            Text {
                                text: "Wired network connection"
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
                            color: Network.ethernet ? "#5700eeff" : "#333333"
                            border.color: Network.ethernet ? "#7700eeff" : "#555555"
                            border.width: 1
                            
                            Rectangle {
                                width: 18
                                height: 18
                                radius: 9
                                color: "#ffffff"
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    right: Network.ethernet ? parent.right : parent.left
                                    rightMargin: Network.ethernet ? 3 : undefined
                                    leftMargin: Network.ethernet ? undefined : 3
                                }
                                
                                Behavior on anchors.rightMargin {
                                    NumberAnimation { duration: 150 }
                                }
                                Behavior on anchors.leftMargin {
                                    NumberAnimation { duration: 150 }
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    // Toggle ethernet (placeholder)
                                    console.log("Ethernet toggle clicked");
                                }
                            }
                        }
                    }
                }
                
                // Network status section
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
                            text: "Network Status"
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            color: "#ffffff"
                        }
                        
                        Text {
                            text: "Connected to: " + (Network.ssid || "Home Network")
                            font.pixelSize: 12
                            color: "#cccccc"
                        }
                        
                        Text {
                            text: "IP Address: " + (Network.ipAddress || "192.168.1.100")
                            font.pixelSize: 12
                            color: "#cccccc"
                        }
                        
                        Text {
                            text: "Signal Strength: " + (Network.networkStrength > 80 ? "Excellent" : 
                                                        Network.networkStrength > 60 ? "Good" :
                                                        Network.networkStrength > 40 ? "Fair" :
                                                        Network.networkStrength > 20 ? "Poor" : "Very Poor")
                            font.pixelSize: 12
                            color: Network.networkStrength > 60 ? "#00ff00" : "#ffaa00"
                        }
                    }
                }
            }
        }
    }
} 