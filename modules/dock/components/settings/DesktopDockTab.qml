import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

Rectangle {
    id: desktopDockTab
    color: "transparent"
    
    // Current sub-tab
    property int currentSubTab: 0
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20
        
        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "transparent"
            
            RowLayout {
                anchors.fill: parent
                spacing: 16
                
                Text {
                    text: "desktop_windows"
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 32
                    color: "#5700eeff"
                    Layout.alignment: Qt.AlignVCenter
                }
                
                ColumnLayout {
                    spacing: 4
                    
                    Text {
                        text: "Desktop & Dock"
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    Text {
                        text: "Customize your desktop appearance and dock behavior"
                        font.pixelSize: 14
                        color: "#888888"
                    }
                }
                
                Item { Layout.fillWidth: true }
            }
        }
        
        // Sub-tab navigation
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "#2a2a2a"
            radius: 8
            border.color: "#33ffffff"
            border.width: 1
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8
                
                // Sub-tab buttons
                Repeater {
                    model: [
                        {icon: "dock_to_bottom", text: "Dock", index: 0},
                        {icon: "space_dashboard", text: "Bar", index: 1},
                        {icon: "apps", text: "Logo", index: 2}
                    ]
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: currentSubTab === modelData.index ? "#5700eeff" : "transparent"
                        radius: 6
                        border.color: currentSubTab === modelData.index ? "#7700eeff" : "transparent"
                        border.width: 1
                        
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            
                            Text {
                                text: modelData.icon
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 18
                                color: currentSubTab === modelData.index ? "#ffffff" : "#cccccc"
                            }
                            
                            Text {
                                text: modelData.text
                                font.pixelSize: 14
                                font.weight: currentSubTab === modelData.index ? Font.Medium : Font.Normal
                                color: currentSubTab === modelData.index ? "#ffffff" : "#cccccc"
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                currentSubTab = modelData.index
                                console.log("Selected sub-tab:", modelData.text)
                            }
                        }
                        
                        Behavior on color {
                            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }
                        
                        Behavior on border.color {
                            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }
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
            
            // Load different sub-tab content
            Loader {
                id: subTabLoader
                anchors.fill: parent
                anchors.margins: 16
                source: {
                    switch(currentSubTab) {
                        case 0: return "DesktopDockSubTabs/DockTab.qml"
                        case 1: return "DesktopDockSubTabs/BarTab.qml"
                        case 2: return "DesktopDockSubTabs/LogoTab.qml"
                        default: return "DesktopDockSubTabs/DockTab.qml"
                    }
                }
                
                // Sub-tab transition animation
                property real slideOffset: 0
                
                onSourceChanged: {
                    // Slide animation for sub-tab changes
                    slideOffset = 20
                    subTabSlideAnimation.start()
                }
                
                NumberAnimation {
                    id: subTabSlideAnimation
                    target: subTabLoader
                    property: "slideOffset"
                    from: 20
                    to: 0
                    duration: 300
                    easing.type: Easing.OutCubic
                }
                
                transform: Translate {
                    x: subTabLoader.slideOffset
                }
                
                opacity: 1 - (Math.abs(subTabLoader.slideOffset) / 20)
            }
        }
    }
} 