import QtQuick
import Quickshell
// import Quickshell.Services.Pipewire  // Temporarily disabled to avoid route device errors
import "."

pragma Singleton
pragma ComponentBehavior: Bound

/**
 * A nice wrapper for default Pipewire audio sink and source.
 */
QtObject {
    id: root
    
    property bool ready: false
    property var sink: sinkWrapper
    property var source: sourceWrapper
    signal sinkProtectionTriggered(string reason);
    
    // Initialize when Pipewire is available
    Component.onCompleted: {
        // Wait for Pipewire to be available
        Timer {
            interval: 1000
            running: true
            repeat: false
            onTriggered: {
                if (typeof Pipewire !== 'undefined') {
                    root.ready = Pipewire.sinkId !== ""
                    console.log("Audio service initialized, ready:", root.ready)
                }
            }
        }
    }
    
    // Wrapper objects to maintain compatibility with existing code
    property var sinkWrapper: QtObject {
        property var audio: sinkAudio
        property bool ready: Pipewire.sinkId !== ""
        property string name: Pipewire.sinkName ?? ""
        property string description: Pipewire.sinkDescription ?? ""
        property string id: Pipewire.sinkId ?? ""
        
        property var sinkAudio: QtObject {
            property real volume: Pipewire.sinkVolume ?? 0
            property bool muted: Pipewire.sinkMuted ?? false
            
            onVolumeChanged: {
                if (Pipewire.sinkId) {
                    Pipewire.setSinkVolume(volume)
                }
            }
            
            onMutedChanged: {
                if (Pipewire.sinkId) {
                    Pipewire.setSinkMuted(muted)
                }
            }
        }
    }
    
    property var sourceWrapper: QtObject {
        property var audio: sourceAudio
        property bool ready: Pipewire.sourceId !== ""
        property string name: Pipewire.sourceName ?? ""
        property string description: Pipewire.sourceDescription ?? ""
        property string id: Pipewire.sourceId ?? ""
        
        property var sourceAudio: QtObject {
            property real volume: Pipewire.sourceVolume ?? 0
            property bool muted: Pipewire.sourceMuted ?? false
            
            onVolumeChanged: {
                if (Pipewire.sourceId) {
                    Pipewire.setSourceVolume(volume)
                }
            }
            
            onMutedChanged: {
                if (Pipewire.sourceId) {
                    Pipewire.setSourceMuted(muted)
                }
            }
        }
    }
    
    property Connections volumeProtection: Connections {
        // Protection against sudden volume changes
        target: sink?.audio ?? null
        property bool lastReady: false
        property real lastVolume: 0
        
        function onVolumeChanged() {
            if (!ConfigOptions.audio.protection.enable) return;
            
            if (!lastReady) {
                lastVolume = sink.audio.volume;
                lastReady = true;
                return;
            }
            
            const newVolume = sink.audio.volume;
            const maxAllowedIncrease = ConfigOptions.audio.protection.maxAllowedIncrease / 100;
            const maxAllowed = ConfigOptions.audio.protection.maxAllowed / 100;
            
            if (newVolume - lastVolume > maxAllowedIncrease) {
                sink.audio.volume = lastVolume;
                root.sinkProtectionTriggered("Illegal increment");
            } else if (newVolume > maxAllowed) {
                sink.audio.volume = lastVolume;
                root.sinkProtectionTriggered("Exceeded max allowed");
            }
            
            lastVolume = sink.audio.volume;
        }
    }
} 