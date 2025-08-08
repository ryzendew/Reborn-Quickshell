import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Settings

Rectangle {
    id: systemTab
    color: "transparent"
    
    // Current sub-tab
    property int currentSubTab: 0
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 24
        
        // Header
        ColumnLayout {
            spacing: 8
            
            Text {
                text: "System"
                font.pixelSize: 28
                font.weight: Font.Bold
                color: "#ffffff"
            }
            
            Text {
                text: "Manage system settings, time, user accounts, and system information"
                font.pixelSize: 14
                color: "#cccccc"
            }
        }
        
        // Sub-tab navigation
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            color: "#2a2a2a"
            radius: 8
            border.color: "#33ffffff"
            border.width: 1
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 0
                
                // Time tab
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: currentSubTab === 0 ? "#5700eeff" : "transparent"
                    radius: 6
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Time"
                        font.pixelSize: 14
                        font.weight: currentSubTab === 0 ? Font.Medium : Font.Normal
                        color: currentSubTab === 0 ? "#ffffff" : "#cccccc"
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: currentSubTab = 0
                    }
                }
                
                // User tab
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: currentSubTab === 1 ? "#5700eeff" : "transparent"
                    radius: 6
                    
                    Text {
                        anchors.centerIn: parent
                        text: "User"
                        font.pixelSize: 14
                        font.weight: currentSubTab === 1 ? Font.Medium : Font.Normal
                        color: currentSubTab === 1 ? "#ffffff" : "#cccccc"
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: currentSubTab = 1
                    }
                }
                
                // System Info tab
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: currentSubTab === 2 ? "#5700eeff" : "transparent"
                    radius: 6
                    
                    Text {
                        anchors.centerIn: parent
                        text: "System Info"
                        font.pixelSize: 14
                        font.weight: currentSubTab === 2 ? Font.Medium : Font.Normal
                        color: currentSubTab === 2 ? "#ffffff" : "#cccccc"
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: currentSubTab = 2
                    }
                }
            }
        }
        
        // Sub-tab content
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#2a2a2a"
            radius: 8
            border.color: "#33ffffff"
            border.width: 1
            
            // Time sub-tab content
            Loader {
                visible: currentSubTab === 0
                anchors.fill: parent
                source: "SystemSubTabs/TimeTab.qml"
            }
            
            // User sub-tab content
            Loader {
                visible: currentSubTab === 1
                anchors.fill: parent
                source: "SystemSubTabs/UserTab.qml"
            }
            
            // System Info sub-tab content
            Loader {
                visible: currentSubTab === 2
                anchors.fill: parent
                source: "SystemSubTabs/SystemInfoTab.qml"
            }
        }
    }
} 