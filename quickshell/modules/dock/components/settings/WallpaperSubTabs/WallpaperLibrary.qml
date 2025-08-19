import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Quickshell
import qs.Services
import qs.Settings

Rectangle {
    id: wallpaperLibraryTab
    color: "transparent"
    
    ScrollView {
        anchors.fill: parent
        clip: true
        
        ColumnLayout {
            width: parent.width
            spacing: 20
            

            
            // Wallpaper Grid
            Rectangle {
                Layout.fillWidth: true
                height: 700
                color: "#1a1a1a"
                radius: 12
                border.color: "#33ffffff"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 16
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Label {
                            text: "Available Wallpapers"
                            font.pixelSize: 18
                            font.weight: Font.Medium
                            color: "white"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Label {
                            text: Wallpaper.scanning ? "Scanning..." : Wallpaper.wallpaperList.length + " images"
                            color: Wallpaper.scanning ? "#ffaa00" : "#90ee90"
                            font.pixelSize: 14
                        }
                        
                        BusyIndicator {
                            running: Wallpaper.scanning
                            visible: running
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                        }
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        
                        GridView {
                            id: wallpaperGrid
                            width: parent.width
                            height: parent.height
                            cellWidth: 160
                            cellHeight: 120
                            model: Wallpaper.wallpaperList
                            
                            delegate: Rectangle {
                                width: 160
                                height: 120
                                color: "transparent"
                                
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    color: "#0a0a0a"
                                    radius: 8
                                    border.color: modelData === Settings.settings.currentWallpaper ? "#007acc" : "#404040"
                                    border.width: modelData === Settings.settings.currentWallpaper ? 2 : 1
                                    
                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        source: modelData
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: false
                                        
                                        Rectangle {
                                            anchors.fill: parent
                                            color: "transparent"
                                            border.color: "#202020"
                                            border.width: 1
                                            radius: 4
                                        }
                                    }
                                    
                                    // Current wallpaper indicator
                                    Rectangle {
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.margins: 4
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: "#007acc"
                                        visible: modelData === Settings.settings.currentWallpaper
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "✓"
                                            color: "white"
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                    }
                                    
                                    // Loading indicator
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 32
                                        height: 32
                                        radius: 16
                                        color: "#80000000"
                                        visible: parent.Image.status === Image.Loading
                                        
                                        BusyIndicator {
                                            anchors.centerIn: parent
                                            running: parent.visible
                                            width: 20
                                            height: 20
                                        }
                                    }
                                    
                                    // Error placeholder
                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        color: "#1a1a1a"
                                        radius: 4
                                        visible: parent.Image.status === Image.Error
                                        
                                        ColumnLayout {
                                            anchors.centerIn: parent
                                            spacing: 4
                                            
                                            Text {
                                                text: "wallpaper"
                                                font.family: "Material Symbols Outlined"
                                                font.pixelSize: 24
                                                color: "#404040"
                                            }
                                            
                                            Text {
                                                text: "?"
                                                color: "#606060"
                                                font.pixelSize: 16
                                                font.bold: true
                                            }
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        wallpaperSelectionDialog.open()
                                        wallpaperSelectionDialog.selectedWallpaper = modelData
                                    }
                                    
                                    Rectangle {
                                        anchors.fill: parent
                                        color: "#40000000"
                                        opacity: parent.containsMouse ? 1 : 0
                                        radius: 8
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "Set Wallpaper"
                                            color: "white"
                                            font.pixelSize: 14
                                            font.weight: Font.Medium
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
    

    
    // Wallpaper Selection Dialog
    Dialog {
        id: wallpaperSelectionDialog
        title: "Set Wallpaper"
        modal: true
        anchors.centerIn: parent
        width: 320
        height: 140
        
        property string selectedWallpaper: ""
        
        background: Rectangle {
            color: "#1a1a1a"
            radius: 12
            border.color: "#404040"
            border.width: 1
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16
            
            Label {
                text: "Set this wallpaper using SWWW?"
                color: "white"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Button {
                    text: "Set Wallpaper"
                    Layout.fillWidth: true
                    background: Rectangle {
                        color: parent.pressed ? "#404040" : "#505050"
                        radius: 6
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        // Ensure SWWW is enabled for proper wallpaper setting
                        if (!Settings.settings.useSWWW) {
                            Settings.settings.useSWWW = true
                        }
                        Wallpaper.setCurrentWallpaper(wallpaperSelectionDialog.selectedWallpaper)
                        wallpaperSelectionDialog.close()
                    }
                }
                
                Button {
                    text: "Cancel"
                    Layout.fillWidth: true
                    background: Rectangle {
                        color: parent.pressed ? "#404040" : "#505050"
                        radius: 6
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        wallpaperSelectionDialog.close()
                    }
                }
            }
        }
    }
} 