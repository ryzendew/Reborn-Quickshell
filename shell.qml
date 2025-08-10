//@ pragma UseQApplication
import QtQuick
import Quickshell
// import Quickshell.Services.Pipewire  // Temporarily disabled to avoid route device errors
import Quickshell.Services.SystemTray
import qs.Services
import qs.modules.bar
import qs.modules.dock
import qs.modules.dock.components
import qs.modules.onScreenDisplay
import qs.modules.Notifications

ShellRoot {
    id: root

    Component.onCompleted: {
        // Wait a bit for PipeWire to initialize
        initTimer.start()
        
        // Initialize weather service
        WeatherService.initialize()
    }

    // Global states for UI components
    property var globalStates: QtObject {
        property bool sidebarRightOpen: false
    }

    // Volume properties for audio integration (using custom PipeWire service)
    property int volume: 100
    property bool volumeMuted: false
    
    // Use the custom Pipewire service that's actually working
    property var pipewireService: Pipewire
    
    function updateVolumeProperties() {
        try {
            // Use the custom PipeWire service that's working
            if (pipewireService && pipewireService.sinkVolume !== undefined) {
                var newVolume = Math.round(pipewireService.sinkVolume * 100)
                var newMuted = pipewireService.sinkMuted
                if (volume !== newVolume || volumeMuted !== newMuted) {
                    volume = newVolume
                    volumeMuted = newMuted
                }
            }
        } catch (error) {
            console.warn("Error updating volume properties:", error)
        }
    }
    
    // Method to update volume using the working custom service
    function updateVolume(newVolume) {
        try {
            if (pipewireService && typeof pipewireService.setSinkVolume === 'function') {
                // Convert percentage to 0-1 range and call the service
                const volumeNormalized = Math.max(0, Math.min(1, newVolume / 100))
                pipewireService.setSinkVolume(volumeNormalized)
                volume = newVolume
            }
        } catch (error) {
            console.warn("Error updating volume:", error)
        }
    }
    
    // Method to toggle mute (like Noctalia's approach)
    function toggleMute() {
        try {
                    if (pipewireService && typeof pipewireService.setSinkMuted === 'function') {
            const newMutedState = !volumeMuted
            pipewireService.setSinkMuted(newMutedState)
            volumeMuted = newMutedState
        }
        } catch (error) {
            console.warn("Error toggling mute:", error)
        }
    }
    
    // Timer to update volume properties periodically
    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            updateVolumeProperties()
        }
    }
    
    // Connections to custom PipeWire service for real-time updates
    Connections {
        target: pipewireService
        
        function onSinkVolumeChanged() {
            updateVolumeProperties()
        }
        
        function onSinkMutedChanged() {
            updateVolumeProperties()
        }
    }
    
    // Initialize volume properties
    // Component.onCompleted: {
    //     // Shell component log disabled for quiet operation
        
    //     // Wait a bit for PipeWire to initialize
    //     initTimer.start()
    // }
    
    // Timer for delayed initialization
    Timer {
        id: initTimer
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            // Volume properties initialization log disabled for quiet operation
            updateVolumeProperties()
        }
    }



    // Top bar
    Loader {
        active: true
        sourceComponent: Bar {
            volume: root.volume
            volumeMuted: root.volumeMuted
        }
    }
    
    // Dock
    Loader {
        active: true
        sourceComponent: Dock {
        }
    }
    
    // OnScreenDisplay components
    Loader {
        active: true
        sourceComponent: OnScreenDisplayVolume {
            shell: root
        }
    }
    
    Loader {
        active: true
        sourceComponent: OnScreenDisplayMicrophone {
            shell: root
        }
    }
    
    // Notifications
    Loader {
        active: true
        sourceComponent: Notifications {
        }
    }
}
