//@ pragma UseQApplication
import QtQuick
import Quickshell
// import Quickshell.Services.Pipewire  // Temporarily disabled to avoid route device errors
import Quickshell.Services.SystemTray
import qs.services
import qs.modules.bar
import qs.modules.dock
import qs.modules.dock.components
import qs.modules.onScreenDisplay

ShellRoot {
    id: root

    // Global states for UI components
    property var globalStates: QtObject {
        property bool sidebarRightOpen: false
    }

    // Volume properties for audio integration (using custom PipeWire service)
    property int volume: 100
    property bool volumeMuted: false
    
    function updateVolumeProperties() {
        try {
            // Use the custom PipeWire service instead of native one
            var newVolume = Math.round(Pipewire.sinkVolume * 100)
            var newMuted = Pipewire.sinkMuted
            if (volume !== newVolume || volumeMuted !== newMuted) {
                volume = newVolume
                volumeMuted = newMuted
            }
        } catch (error) {
            console.warn("Error updating volume properties:", error)
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
    
    // Connections to PipeWire service for real-time updates
    Connections {
        target: Pipewire
        
        function onSinkVolumeChanged() {
            updateVolumeProperties()
        }
        
        function onSinkMutedChanged() {
            updateVolumeProperties()
        }
    }
    
    // Initialize volume properties
    Component.onCompleted: {
        // Shell component log disabled for quiet operation
        
        // Wait a bit for PipeWire to initialize
        initTimer.start()
    }
    
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
    
    // Custom dock menu for right-click actions
    CustomDockMenu {
        id: dockMenu
    }
    
    // Dock
    Loader {
        active: true
        sourceComponent: Dock {
            contextMenu: dockMenu
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
}
