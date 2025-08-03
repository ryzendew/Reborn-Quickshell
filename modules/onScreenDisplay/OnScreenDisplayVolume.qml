import qs.services
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root
    
    property var shell
    property bool showOsdValues: false
    property string protectionMessage: ""
    property var focusedScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name)
    
    Component.onCompleted: {
        console.log("Volume OSD component loaded!")
    }
    
    function triggerOsd() {
        console.log("Volume OSD triggered!")
        showOsdValues = true
        osdTimeout.restart()
    }
    
    Timer {
        id: osdTimeout
        interval: ConfigOptions.osd.timeout
        repeat: false
        running: false
        onTriggered: {
            root.showOsdValues = false
            root.protectionMessage = ""
        }
    }
    

    
    Connections {
        // Listen to volume changes from shell
        target: shell
        function onVolumeChanged() {
            console.log("Volume OSD received volumeChanged signal:", shell.volume)
            root.triggerOsd()
        }
        function onVolumeMutedChanged() {
            console.log("Volume OSD received volumeMutedChanged signal:", shell.volumeMuted)
            root.triggerOsd()
        }
    }
    
    Loader {
        id: osdLoader
        active: showOsdValues
        sourceComponent: PanelWindow {
            id: osdRoot
            
            Connections {
                target: root
                function onFocusedScreenChanged() {
                    osdRoot.screen = root.focusedScreen
                }
            }
            
            exclusionMode: ExclusionMode.Normal
            WlrLayershell.namespace: "quickshell:onScreenDisplay"
            WlrLayershell.layer: WlrLayer.Overlay
            color: "transparent"
            anchors {
                top: ConfigOptions.bar.bottom
                bottom: !ConfigOptions.bar.bottom
            }
            implicitWidth: columnLayout.implicitWidth + 40
            implicitHeight: columnLayout.implicitHeight + 40
            visible: osdLoader.active
            
            ColumnLayout {
                id: columnLayout
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: 20
                
                Item {
                    id: osdValuesWrapper
                    // Extra space for shadow
                    implicitHeight: contentColumnLayout.implicitHeight + 16
                    implicitWidth: contentColumnLayout.implicitWidth
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: root.showOsdValues = false
                    }
                    
                    ColumnLayout {
                        id: contentColumnLayout
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            leftMargin: 8
                            rightMargin: 8
                        }
                        spacing: 0
                        
                                                // Modern volume OSD indicator
                        Rectangle {
                            Layout.preferredWidth: 182
                            Layout.preferredHeight: 65
                            color: Qt.rgba(0.1, 0.1, 0.1, 0.9)
                            radius: 16
                            border.color: Qt.rgba(0.3, 0.3, 0.3, 0.3)
                            border.width: 1
                            
                            // Subtle shadow effect
                            layer.enabled: true
                            layer.smooth: true
                            layer.samples: 4
                            
                            RowLayout {
                                anchors.centerIn: parent
                                anchors.margins: 16
                                spacing: 16
                                
                                Text {
                                    text: shell.volumeMuted ? "volume_off" : "volume_up"
                                    font.family: "Material Symbols Outlined"
                                    font.pixelSize: 26
                                    color: shell.volumeMuted ? "#ff6b6b" : "#4ecdc4"
                                }
                                
                                Text {
                                    text: shell.volume + "%"
                                    font.pixelSize: 21
                                    font.weight: Font.Medium
                                    color: "#ffffff"
                                }
                            }
                        }
                        
                        // Protection message
                        Rectangle {
                            id: protectionMessageBackground
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 8
                            opacity: root.protectionMessage !== "" ? 1 : 0
                            color: "#ff4444"
                            radius: 6
                            implicitHeight: protectionMessageRowLayout.implicitHeight + 20
                            implicitWidth: protectionMessageRowLayout.implicitWidth + 20
                            
                            RowLayout {
                                id: protectionMessageRowLayout
                                anchors.centerIn: parent
                                spacing: 8
                                
                                Text {
                                    text: "dangerous"
                                    font.family: "Material Symbols Outlined"
                                    font.pixelSize: 16
                                    color: "#ffffff"
                                }
                                
                                Text {
                                    text: root.protectionMessage
                                    font.pixelSize: 12
                                    color: "#ffffff"
                                    wrapMode: Text.Wrap
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    IpcHandler {
        target: "osdVolume"
        function trigger() {
            root.triggerOsd()
        }
        function hide() {
            showOsdValues = false
        }
        function toggle() {
            showOsdValues = !showOsdValues
        }
    }
    
    GlobalShortcut {
        name: "osdVolumeTrigger"
        description: qsTr("Triggers volume OSD on press")
        onPressed: {
            root.triggerOsd()
        }
    }
    
    GlobalShortcut {
        name: "osdVolumeHide"
        description: qsTr("Hides volume OSD on press")
        onPressed: {
            root.showOsdValues = false
        }
    }
} 