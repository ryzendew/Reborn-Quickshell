import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Services
import qs.Settings

Rectangle {
    id: logoTab
    color: "transparent"
    
    property int currentSubTab: 0
    
    // Header with sub-tab navigation
    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: "#2a2a2a"
        radius: 8
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 0
            
            Label {
                text: "Logo Settings"
                font.pixelSize: 18
                font.bold: true
                color: "white"
            }
            
            Item { Layout.fillWidth: true }
            
            // Sub-tab buttons
            Row {
                spacing: 4
                
                Rectangle {
                    width: 80
                    height: 32
                    radius: 6
                    color: currentSubTab === 0 ? "#505050" : "#404040"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Logos"
                        color: "white"
                        font.pixelSize: 12
                        font.bold: true
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: currentSubTab = 0
                    }
                }
                
                Rectangle {
                    width: 80
                    height: 32
                    radius: 6
                    color: currentSubTab === 1 ? "#505050" : "#404040"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Color"
                        color: "white"
                        font.pixelSize: 12
                        font.bold: true
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: currentSubTab = 1
                    }
                }
            }
        }
    }
    
    // Sub-tab content area
    Rectangle {
        id: contentArea
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 12
        color: "transparent"
        
        Loader {
            id: subTabLoader
            anchors.fill: parent
            source: {
                switch(logoTab.currentSubTab) {
                    case 0: return "LogoSubTabs/LogoSelection.qml"
                    case 1: return "LogoSubTabs/LogoColor.qml"
                    default: return "LogoSubTabs/LogoSelection.qml"
                }
            }
            
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
        }
    }
} 