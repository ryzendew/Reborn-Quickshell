import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Services
import qs.Settings

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
            width: Settings.settings.indicatorsSize || 24
            height: Settings.settings.indicatorsSize || 24
            color: "transparent"
            visible: shell
            
            // Hover effects - simple magnification
            property bool isHovered: false
            scale: isHovered ? 1.1 : 1.0
            Behavior on scale {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
            
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
                
                // Also try to get initial state from Pipewire service
                if (Pipewire && Pipewire.sinkMuted !== undefined) {
                    volumeIndicator.currentMuted = Pipewire.sinkMuted
                }
                if (Pipewire && Pipewire.sinkVolume !== undefined) {
                    volumeIndicator.currentVolume = Pipewire.sinkVolume
                }
            }
            
            // Update local state when Pipewire service changes
            Connections {
                target: Pipewire
                function onSinkMutedChanged() {
                    if (Pipewire.sinkMuted !== undefined) {
                        volumeIndicator.currentMuted = Pipewire.sinkMuted
                        // Update shell mute state for icon and OSD
                        if (shell) {
                            shell.volumeMuted = volumeIndicator.currentMuted
                        }
                    }
                }
                
                function onSinkVolumeChanged() {
                    if (Pipewire.sinkVolume !== undefined) {
                        volumeIndicator.currentVolume = Pipewire.sinkVolume
                        // Update shell volume for icon and OSD
                        if (shell) {
                            shell.volume = Math.round(volumeIndicator.currentVolume * 100)
                        }
                    }
                }
            }
            
            Text {
                anchors.centerIn: parent
                font.family: "Material Symbols Outlined"
                font.pixelSize: Settings.settings.indicatorsSize || 24
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
                hoverEnabled: true
                
                onEntered: {
                    volumeIndicator.isHovered = true
                }
                
                onExited: {
                    volumeIndicator.isHovered = false
                }
                
                onClicked: function(mouse) {
                    if (mouse.button === Qt.LeftButton) {
                        // Left click: toggle mute using shell's toggleMute method
                        if (shell && typeof shell.toggleMute === 'function') {
                            shell.toggleMute()
                            console.log("Volume indicator: Toggled mute via shell")
                        } else if (Pipewire && Pipewire.sinkId) {
                            // Fallback: toggle mute using custom PipeWire service
                            const newMutedState = !volumeIndicator.currentMuted
                            volumeIndicator.currentMuted = newMutedState
                            
                            // Call the Pipewire service to actually mute/unmute
                            try {
                                Pipewire.setSinkMuted(newMutedState)
                                console.log("Volume indicator: Toggled mute to:", newMutedState)
                            } catch (e) {
                                console.log("Volume indicator: Error setting mute:", e.message)
                                // Revert local state if the call failed
                                volumeIndicator.currentMuted = !newMutedState
                            }
                            
                            // Update shell mute state for icon and OSD
                            if (shell) {
                                shell.volumeMuted = volumeIndicator.currentMuted
                            }
                        } else {
                            console.log("Volume indicator: No default sink available, refreshing...")
                            if (Pipewire && typeof Pipewire.refreshSink === 'function') {
                                Pipewire.refreshSink()
                            }
                            if (Pipewire && typeof Pipewire.checkStatus === 'function') {
                                Pipewire.checkStatus()
                            }
                        }
                    } else if (mouse.button === Qt.RightButton) {
                        // Right click: open system volume control
                        Quickshell.execDetached(["pavucontrol"])
                    }
                }
                
                onWheel: function(wheel) {
                    // Scroll wheel: adjust volume using shell's updateVolume method (similar to Noctalia)
                    if (shell && typeof shell.updateVolume === 'function') {
                        var step = 5  // 5% steps in percentage
                        // Convert current volume to percentage for easier calculation
                        let currentVolumePercent = Math.round(volumeIndicator.currentVolume * 100)
                        
                        let newVolumePercent = currentVolumePercent
                        
                        if (wheel.angleDelta.y > 0) {
                            newVolumePercent = Math.min(100, currentVolumePercent + step)
                        } else if (wheel.angleDelta.y < 0) {
                            newVolumePercent = Math.max(0, currentVolumePercent - step)
                        }
                        
                        // Only update if volume actually changed
                        if (newVolumePercent !== currentVolumePercent) {
                            // Update local state immediately
                            volumeIndicator.currentVolume = newVolumePercent / 100
                            
                            // Call shell's updateVolume method
                            try {
                                shell.updateVolume(newVolumePercent)
                                console.log("Volume indicator: Changed volume to:", newVolumePercent, "% via shell")
                            } catch (e) {
                                console.log("Volume indicator: Error setting volume:", e.message)
                                // Revert local state if the call failed
                                volumeIndicator.currentVolume = currentVolumePercent / 100
                            }
                            
                            // Update shell volume for icon and OSD
                            if (shell) {
                                shell.volume = newVolumePercent
                            }
                        }
                    } else if (Pipewire && Pipewire.sinkId) {
                        // Fallback: use custom PipeWire service
                        var step = 0.05  // 5% steps
                        // Use a local variable to track volume since Pipewire.sinkVolume might not update
                        if (!volumeIndicator.currentVolume) {
                            volumeIndicator.currentVolume = Pipewire.sinkVolume || 0
                        }
                        
                        let newVolume = volumeIndicator.currentVolume
                        
                        if (wheel.angleDelta.y > 0) {
                            newVolume = Math.min(1, volumeIndicator.currentVolume + step)
                        } else if (wheel.angleDelta.y < 0) {
                            newVolume = Math.max(0, volumeIndicator.currentVolume - step)
                        }
                        
                        // Only update if volume actually changed
                        if (newVolume !== volumeIndicator.currentVolume) {
                            volumeIndicator.currentVolume = newVolume
                            
                            // Call the Pipewire service to actually change volume
                            try {
                                Pipewire.setSinkVolume(newVolume)
                                console.log("Volume indicator: Changed volume to:", newVolume)
                            } catch (e) {
                                console.log("Volume indicator: Error setting volume:", e.message)
                                // Revert local state if the call failed
                                volumeIndicator.currentVolume = volumeIndicator.currentVolume
                            }
                            
                            // Update shell volume for icon and OSD
                            if (shell) {
                                shell.volume = Math.round(volumeIndicator.currentVolume * 100)
                            }
                        }
                    } else {
                        console.log("Volume indicator: No default sink available for volume control")
                    }
                }
            }
        }
        
        // Microphone indicator (single component that changes icon)
        Rectangle {
            id: micIndicator
            Layout.fillHeight: true
            Layout.rightMargin: indicatorsRowLayout.realSpacing
            width: Settings.settings.indicatorsSize || 24
            height: Settings.settings.indicatorsSize || 24
            color: "transparent"
            visible: shell
            
            // Hover effects - simple magnification
            property bool isHovered: false
            scale: isHovered ? 1.1 : 1.0
            Behavior on scale {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
            
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
                font.pixelSize: Settings.settings.indicatorsSize || 24
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
                hoverEnabled: true
                
                onEntered: {
                    micIndicator.isHovered = true
                }
                
                onExited: {
                    micIndicator.isHovered = false
                }
                
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
        

        
        // Network indicator
        Rectangle {
            id: networkIndicator
            width: Settings.settings.indicatorsSize || 24
            height: Settings.settings.indicatorsSize || 24
            Layout.rightMargin: indicatorsRowLayout.realSpacing - 1.5
            color: "transparent"
            visible: Network.hasActiveConnection
            
            // Debug logging for network indicator
            Component.onCompleted: {
                console.log("Network indicator: hasActiveConnection =", Network.hasActiveConnection);
                console.log("Network indicator: hasEthernetConnection =", Network.hasEthernetConnection);
                console.log("Network indicator: hasWifiConnection =", Network.hasWifiConnection);
                console.log("Network indicator: networks =", JSON.stringify(Network.networks));
            }
            
            // Hover effects - simple magnification
            property bool isHovered: false
            scale: isHovered ? 1.1 : 1.0
            Behavior on scale {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
            
            Text {
                anchors.centerIn: parent
                font.family: "Material Symbols Outlined"
                font.pixelSize: Settings.settings.indicatorsSize || 24
                color: "#ffffff"
                
                text: {
                    if (Network.hasEthernetConnection) return "lan"
                    if (Network.hasWifiConnection) {
                        // Find the connected WiFi network to get signal strength
                        for (const net in Network.networks) {
                            const network = Network.networks[net]
                            if (network.connected && network.type === "wifi") {
                                return Network.signalIcon(network.signal || 0)
                            }
                        }
                        return "wifi"
                    }
                    return "wifi_off"
                }
            }
            
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onEntered: {
                    networkIndicator.isHovered = true
                }
                
                onExited: {
                    networkIndicator.isHovered = false
                }
                
                onClicked: {
                    // Open WiFi settings tab
                    SettingsManager.openSettingsTab(0)  // WiFi tab index
                }
            }
        }
        
        // Bluetooth indicator
        Rectangle {
            id: bluetoothIndicatorRect
            width: Settings.settings.indicatorsSize || 24
            height: Settings.settings.indicatorsSize || 24
            color: "transparent"
            
            // Hover effects - simple magnification
            property bool isHovered: false
            scale: isHovered ? 1.1 : 1.0
            Behavior on scale {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
            
            Text {
                anchors.centerIn: parent
                text: {
                    if (Bluetooth.connectedDevices.length > 0) return "bluetooth_connected"
                    if (Bluetooth.bluetoothEnabled) return "bluetooth"
                    return "bluetooth_disabled"
                }
                font.family: "Material Symbols Outlined"
                font.pixelSize: Settings.settings.indicatorsSize || 24
                color: "#ffffff"
            }
            
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onEntered: {
                    bluetoothIndicatorRect.isHovered = true
                }
                
                onExited: {
                    bluetoothIndicatorRect.isHovered = false
                }
                
                onClicked: {
                    // Open Bluetooth settings tab
                    SettingsManager.openSettingsTab(1)  // Bluetooth tab index
                }
            }
        }
    }
} 