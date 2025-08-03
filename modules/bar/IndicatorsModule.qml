import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.services

Rectangle {
    id: indicatorsContainer
    
    // Accept shell properties from parent
    property var shell
    
    Layout.margins: 4
    Layout.rightMargin: 2
    Layout.fillHeight: true
    implicitWidth: indicatorsRowLayout.implicitWidth + 20
    radius: 8
    color: indicatorsMouseArea.hovered ? Qt.rgba(0.15, 0.15, 0.15, 0.8) : "transparent"
    
    // Mouse area for hover effects
    MouseArea {
        id: indicatorsMouseArea
        anchors.fill: parent
        hoverEnabled: true
    }
    
    RowLayout {
        id: indicatorsRowLayout
        anchors.centerIn: parent
        property real realSpacing: 8
        spacing: 0
        

        
        // Volume indicator (single component that changes icon)
        Rectangle {
            id: volumeIndicator
            Layout.fillHeight: true
            Layout.rightMargin: indicatorsRowLayout.realSpacing
            width: 24
            height: 24
            color: "transparent"
            visible: shell
            
            // Local volume tracking since Pipewire.sinkVolume might not update properly
            property real currentVolume: 0
            property bool currentMuted: false
            
            Component.onCompleted: {
                // Initialize current volume from shell
                if (shell && shell.volume) {
                    volumeIndicator.currentVolume = shell.volume / 100
                }
                // Initialize current mute state from shell
                if (shell) {
                    volumeIndicator.currentMuted = shell.volumeMuted
                }
            }
            
            Text {
                anchors.centerIn: parent
                font.family: "Material Symbols Outlined"
                font.pixelSize: 24
                color: "#ffffff"
                
                // Direct property binding for reactive updates
                text: {
                    var muted = volumeIndicator.currentMuted
                    var volume = shell ? shell.volume : 0
                    var icon = ""
                    
                    if (muted) {
                        icon = "volume_off"
                    } else if (volume === 0) {
                        icon = "volume_off"
                    } else if (volume < 30) {
                        icon = "volume_down"
                    } else {
                        icon = "volume_up"
                    }
                    
                    return icon
                }
            }
            
            // Mouse area for volume control
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                
                onClicked: function(mouse) {
                    if (mouse.button === Qt.LeftButton) {
                        // Left click: toggle mute using custom PipeWire service
                        if (Pipewire.sinkId) {
                            volumeIndicator.currentMuted = !volumeIndicator.currentMuted
                            Pipewire.setSinkMuted(volumeIndicator.currentMuted)
                            // Update shell mute state for icon and OSD
                            if (shell) {
                                shell.volumeMuted = volumeIndicator.currentMuted
                            }
                        } else {
                            Pipewire.refreshSink()
                            Pipewire.checkStatus()
                        }
                    } else if (mouse.button === Qt.RightButton) {
                        // Right click: open system volume control
                        Quickshell.execDetached(["pavucontrol"])
                    }
                }
                
                onWheel: function(wheel) {
                    // Scroll wheel: adjust volume using custom PipeWire service
                    if (Pipewire.sinkId) {
                        var step = 0.05  // 5% steps
                        // Use a local variable to track volume since Pipewire.sinkVolume might not update
                        if (!volumeIndicator.currentVolume) {
                            volumeIndicator.currentVolume = Pipewire.sinkVolume || 0
                        }
                        
                        if (wheel.angleDelta.y > 0) {
                            volumeIndicator.currentVolume = Math.min(1, volumeIndicator.currentVolume + step)
                            Pipewire.setSinkVolume(volumeIndicator.currentVolume)
                            // Update shell volume for icon and OSD
                            if (shell) {
                                shell.volume = Math.round(volumeIndicator.currentVolume * 100)
                            }
                        } else if (wheel.angleDelta.y < 0) {
                            volumeIndicator.currentVolume = Math.max(0, volumeIndicator.currentVolume - step)
                            Pipewire.setSinkVolume(volumeIndicator.currentVolume)
                            // Update shell volume for icon and OSD
                            if (shell) {
                                shell.volume = Math.round(volumeIndicator.currentVolume * 100)
                            }
                        }
                    }
                }
            }
        }
        
        // Microphone indicator (single component that changes icon)
        Rectangle {
            id: micIndicator
            Layout.fillHeight: true
            Layout.rightMargin: indicatorsRowLayout.realSpacing
            width: 20
            height: 20
            color: "transparent"
            visible: shell
            
            // Local microphone tracking since Pipewire.sourceVolume might not update properly
            property real currentVolume: 0
            property bool currentMuted: false
            
            // Signal to force icon update
            signal muteStateChanged()
            
            Component.onCompleted: {
                // Initialize current volume and mute state
                micIndicator.currentVolume = Pipewire.sourceVolume || 0
                micIndicator.currentMuted = Pipewire.sourceMuted || false
            }
            
            Text {
                anchors.centerIn: parent
                font.family: "Material Symbols Outlined"
                font.pixelSize: 24
                color: "#ffffff"
                
                // Direct property binding for reactive updates
                text: {
                    var muted = micIndicator.currentMuted
                    var icon = muted ? "mic_off" : "mic"
                    return icon
                }
                
                // Listen to mute state changes to force update
                Connections {
                    target: micIndicator
                    function onMuteStateChanged() {
                        // Force text update
                        text = text
                    }
                }
            }
            
            // Mouse area for microphone control
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                
                onClicked: function(mouse) {
                    if (mouse.button === Qt.LeftButton) {
                        // Left click: toggle mute using custom PipeWire service
                        if (Pipewire.sourceId) {
                            micIndicator.currentMuted = !micIndicator.currentMuted
                            Pipewire.setSourceMuted(micIndicator.currentMuted)
                            // Force icon update
                            micIndicator.muteStateChanged()
                        } else {
                            Pipewire.refreshSource()
                            Pipewire.checkStatus()
                        }
                    } else if (mouse.button === Qt.RightButton) {
                        // Right click: open system volume control
                        Quickshell.execDetached(["pavucontrol"])
                    }
                }
                
                onWheel: function(wheel) {
                    // Scroll wheel: adjust microphone volume
                    if (Pipewire.sourceId) {
                        var step = 0.05  // 5% steps
                        if (wheel.angleDelta.y > 0) {
                            micIndicator.currentVolume = Math.min(1, micIndicator.currentVolume + step)
                            Pipewire.setSourceVolume(micIndicator.currentVolume)
                        } else if (wheel.angleDelta.y < 0) {
                            micIndicator.currentVolume = Math.max(0, micIndicator.currentVolume - step)
                            Pipewire.setSourceVolume(micIndicator.currentVolume)
                        }
                    }
                }
            }
        }
        

        
        // Network icons
        Item {
            width: 20
            height: 20
            Layout.rightMargin: indicatorsRowLayout.realSpacing - 1.5
            
            RowLayout {
                anchors.fill: parent
                spacing: 4
                
                // Ethernet icon
                Rectangle {
                    Layout.preferredWidth: 17
                    Layout.preferredHeight: 17
                    color: "transparent"
                    visible: Network.ethernet
                    
                    Component.onCompleted: {
                        // Network indicator log disabled for quiet operation
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "lan"
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 24
                        color: "#ffffff"
                    }
                }
                
                // WiFi icon
                Rectangle {
                    id: wifiIconRect
                    Layout.preferredWidth: 17
                    Layout.preferredHeight: 17
                    color: "transparent"
                    visible: Network.wifi && !Network.ethernet
                    
                    Text {
                        id: wifiIcon
                        anchors.centerIn: parent
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 24
                        color: "#ffffff"
                        opacity: Network.wifiEnabled ? 1.0 : 0.5
                        
                        text: Network.materialSymbol
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: false
                    }
                }
            }
        }
        
        // Bluetooth indicator
        Text {
            text: {
                if (Bluetooth.bluetoothConnected) return "bluetooth_connected"
                if (Bluetooth.bluetoothEnabled) return "bluetooth"
                return "bluetooth_disabled"
            }
            font.family: "Material Symbols Outlined"
            font.pixelSize: 24
            color: "#ffffff"
        }
    }
} 