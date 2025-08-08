import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Services
import qs.Settings

Rectangle {
    id: barTab
    color: "transparent"
    
    // Current sub-tab
    property int currentSubTab: 0
    
    // Function to save settings
    function saveBarSettings() {
        // Settings are automatically saved when properties change
    }
    
    // Function to load settings
    function loadBarSettings() {
        // Settings are automatically loaded by the Settings service
    }
    
    Component.onCompleted: {
        loadBarSettings()
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 20
        
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
                        {icon: "settings", text: "General", index: 0},
                        {icon: "palette", text: "Colors", index: 1},
                        {icon: "straighten", text: "Sizing", index: 2}
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
                                console.log("Selected bar sub-tab:", modelData.text)
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
                        case 0: return "BarGeneralTab.qml"
                        case 1: return "BarColorsTab.qml"
                        case 2: return "BarSizingTab.qml"
                        default: return "BarGeneralTab.qml"
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