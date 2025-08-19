import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import qs.Services
import qs.Settings

Rectangle {
    id: logoSelection
    color: "transparent"
    
    ScrollView {
        anchors.fill: parent
        clip: true
        
        ColumnLayout {
            width: parent.width
            spacing: 20
            
            // Logo Selection Section
            Rectangle {
                Layout.fillWidth: true
                height: 800
                color: "#2a2a2a"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Label {
                            text: "Available Logos"
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Label {
                            text: LogoService.scanning ? "Scanning..." : LogoService.logoList.length + " icons"
                            color: LogoService.scanning ? "#ffaa00" : "#90ee90"
                            font.pixelSize: 12
                        }
                        
                        BusyIndicator {
                            running: LogoService.scanning
                            visible: running
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                        }
                        
                        Button {
                            text: "Refresh"
                            background: Rectangle {
                                color: parent.pressed ? "#404040" : "#505050"
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                LogoService.loadLogos()
                            }
                        }
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        
                        GridView {
                            id: logoGrid
                            width: parent.width
                            height: parent.height
                            cellWidth: 80
                            cellHeight: 80
                            model: LogoService.logoList
                            
                            delegate: Rectangle {
                                width: 80
                                height: 80
                                color: "transparent"
                                
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    color: "#1a1a1a"
                                    radius: 6
                                    border.color: modelData === LogoService.currentBarLogo ? "#007acc" : "#404040"
                                    border.width: modelData === LogoService.currentBarLogo ? 2 : 1
                                    
                                    Image {
                                        id: logoThumbnail
                                        anchors.centerIn: parent
                                        width: 40
                                        height: 40
                                        source: LogoService.getLogoPath(modelData)
                                        fillMode: Image.PreserveAspectFit
                                        smooth: false
                                        mipmap: true
                                        cache: true
                                        sourceSize.width: 64
                                        sourceSize.height: 64
                                        asynchronous: true
                                    }
                                    
                                    // White color overlay for logo thumbnails
                                    ColorOverlay {
                                        anchors.fill: logoThumbnail
                                        source: logoThumbnail
                                        color: "#ffffff"
                                    }
                                    
                                    // Current logo indicator
                                    Rectangle {
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.margins: 4
                                        width: 12
                                        height: 12
                                        radius: 6
                                        color: modelData === LogoService.currentBarLogo ? "#007acc" : "transparent"
                                        visible: modelData === LogoService.currentBarLogo
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "✓"
                                            color: "white"
                                            font.pixelSize: 8
                                            font.bold: true
                                        }
                                    }
                                    
                                    // Loading indicator
                                    BusyIndicator {
                                        anchors.centerIn: parent
                                        running: parent.Image.status === Image.Loading
                                        visible: running
                                        width: 16
                                        height: 16
                                    }
                                    
                                    // Error placeholder
                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        color: "#1a1a1a"
                                        radius: 4
                                        visible: parent.Image.status === Image.Error
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "?"
                                            color: "#606060"
                                            font.pixelSize: 16
                                            font.bold: true
                                        }
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            logoSelectionDialog.open()
                                            logoSelectionDialog.selectedLogo = modelData
                                        }
                                    }
                                    
                                    Rectangle {
                                        anchors.fill: parent
                                        color: "#40000000"
                                        opacity: parent.containsMouse ? 1 : 0
                                        radius: 6
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "Select"
                                            color: "white"
                                            font.pixelSize: 10
                                            font.bold: true
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
    
    // Logo Selection Dialog
    Dialog {
        id: logoSelectionDialog
        title: "Set Logo"
        modal: true
        anchors.centerIn: parent
        width: 300
        height: 120
        
        property string selectedLogo: ""
        
        background: Rectangle {
            color: "#2a2a2a"
            radius: 8
            border.color: "#404040"
            border.width: 1
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16
            
            Label {
                text: "Set this logo for both bar and dock?"
                color: "white"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Button {
                    text: "Set Logo"
                    Layout.fillWidth: true
                    background: Rectangle {
                        color: parent.pressed ? "#404040" : "#505050"
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        // Load current settings
                        var currentSettings = settingsWindow.loadSettings()
                        
                        // Update logo settings
                        currentSettings.barLogo = logoSelectionDialog.selectedLogo
                        currentSettings.dockLogo = logoSelectionDialog.selectedLogo
                        
                        // Save updated settings
                        settingsWindow.saveSettings(currentSettings)
                        
                        // Also update LogoService properties
                        LogoService.currentBarLogo = logoSelectionDialog.selectedLogo
                        LogoService.currentDockLogo = logoSelectionDialog.selectedLogo
                        
                        logoSelectionDialog.close()
                    }
                }
                
                Button {
                    text: "Cancel"
                    Layout.fillWidth: true
                    background: Rectangle {
                        color: parent.pressed ? "#404040" : "#505050"
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        logoSelectionDialog.close()
                    }
                }
            }
        }
    }
} 