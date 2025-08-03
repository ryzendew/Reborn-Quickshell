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
    property var focusedScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name)
    
    Component.onCompleted: {
        console.log("Microphone OSD component loaded!")
    }
    
    function triggerOsd() {
        console.log("Microphone OSD triggered!")
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
        }
    }
    

    
    Connections {
        // Listen to volume changes to hide microphone OSD
        target: shell
        function onVolumeChanged() {
            root.showOsdValues = false
        }
    }
    
    Connections {
        // Listen to microphone changes from PipeWire service
        target: Pipewire
        function onSourceVolumeChanged() {
            console.log("Microphone OSD received sourceVolumeChanged signal:", Pipewire.sourceVolume)
            root.triggerOsd()
        }
        function onSourceMutedChanged() {
            console.log("Microphone OSD received sourceMutedChanged signal:", Pipewire.sourceMuted)
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
            WlrLayershell.namespace: "quickshell:onScreenDisplayMicrophone"
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
                        
                        // Modern microphone OSD indicator
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
                                    text: Pipewire.sourceMuted ? "mic_off" : "mic"
                                    font.family: "Material Symbols Outlined"
                                    font.pixelSize: 26
                                    color: Pipewire.sourceMuted ? "#ff6b6b" : "#4ecdc4"
                                }
                                
                                Text {
                                    text: Math.round(Pipewire.sourceVolume * 100) + "%"
                                    font.pixelSize: 21
                                    font.weight: Font.Medium
                                    color: "#ffffff"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    IpcHandler {
        target: "osdMicrophone"
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
        name: "osdMicrophoneTrigger"
        description: qsTr("Triggers microphone OSD on press")
        onPressed: {
            root.triggerOsd()
        }
    }
    
    GlobalShortcut {
        name: "osdMicrophoneHide"
        description: qsTr("Hides microphone OSD on press")
        onPressed: {
            root.showOsdValues = false
        }
    }
} 