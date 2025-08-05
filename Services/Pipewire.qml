pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Pipewire service that provides audio sink and source controls using pactl
 */
QtObject {
    id: root
    
    // Update interval
    property int updateInterval: 500
    property bool needVolumeCheck: false
    
    // Default audio sink properties
    property real sinkVolume: 1.0
    property bool sinkMuted: false
    property string sinkName: ""
    property string sinkDescription: ""
    property string sinkId: "@DEFAULT_SINK@"  // Default fallback
    
    // Default audio source properties
    property real sourceVolume: 0.0
    property bool sourceMuted: false
    property string sourceName: ""
    property string sourceDescription: ""
    property string sourceId: "@DEFAULT_SOURCE@"  // Default fallback
    
    // Process to set sink volume
    property Process setVolumeProcess: Process {
        running: false
    }
    
    // Process to set sink mute
    property Process setMuteProcess: Process {
        running: false
    }
    
    // Process to set source volume
    property Process setSourceVolumeProcess: Process {
        running: false
    }
    
    // Process to set source mute
    property Process setSourceMuteProcess: Process {
        running: false
    }
    
    // Update sink info
    property Process updateSinkInfo: Process {
        command: ["pactl", "info"]
        running: true
        
        Component.onCompleted: {
            // Process creation log disabled for quiet operation
        }
        

        
        property SplitParser stdout: SplitParser {
            onRead: data => {
                console.log("PipeWire sink info received:", data)
                console.log("Data length:", data.length)
                console.log("Raw data:", JSON.stringify(data))
                
                const lines = data.split('\n')
                console.log("Parsing lines:", lines.length, "lines")
                for (let line of lines) {
                    console.log("Checking line:", JSON.stringify(line))
                    if (line.includes('Default Sink:')) {
                        const sinkName = line.split(':')[1].trim()
                        root.sinkName = sinkName
                        root.sinkId = sinkName
                        console.log("Found default sink:", sinkName)
                        updateSinkDetails.running = true
                        break
                    }
                }
                if (!root.sinkId) {
                    console.warn("No default sink found in data")
                    console.log("Available lines:", lines.map(l => JSON.stringify(l)))
                }
            }
        }
    }
    
    // Update source info
    property Process updateSourceInfo: Process {
        command: ["pactl", "info"]
        running: true
        property SplitParser stdout: SplitParser {
            onRead: data => {
                console.log("PipeWire source info received:", data)
                const lines = data.split('\n')
                for (let line of lines) {
                    if (line.includes('Default Source:')) {
                        const sourceName = line.split(':')[1].trim()
                        root.sourceName = sourceName
                        root.sourceId = sourceName
                        console.log("Found default source:", sourceName)
                        updateSourceDetails.running = true
                        break
                    }
                }
                if (!root.sourceId) {
                    console.warn("No default source found in data")
                }
            }
        }
    }
    
    // Get sink details (volume, mute, description)
    property Process updateSinkDetails: Process {
        command: ["pactl", "list", "sinks"]
        running: false
        property SplitParser stdout: SplitParser {
            onRead: data => {
                console.log("Sink details received, data length:", data.length)
                console.log("Sink details data:", data.substring(0, 200) + "...")
                const blocks = data.split(/\n(?=Sink #)/);
                for (let block of blocks) {
                    // Find the Name: line in this block
                    const nameLine = block.split('\n').find(function(l) {
                        return l.trim().startsWith('Name:');
                    });
                    if (nameLine) {
                        var blockName = nameLine.split(':')[1].trim();
                        console.log("Checking sink block:", blockName, "against:", root.sinkName)
                        // QML: use toLowerCase() and trim() for robust comparison
                        if (blockName.toLowerCase() === root.sinkName.trim().toLowerCase()) {
                            console.log("Found matching sink block!")
                            // Find the 'Volume:' line (first channel)
                            const volumeLine = block.split('\n').find(function(l) {
                                return l.trim().startsWith('Volume:');
                            });
                            if (volumeLine) {
                                // Example: 'Volume: front-left: 65536 / 100% / 0.00 dB, ...'
                                console.log("Volume line found:", volumeLine)
                                const match = volumeLine.match(/\b(\d+)%/);
                                if (match) {
                                    var newVolume = parseInt(match[1]) / 100.0
                                    console.log("Parsed volume:", match[1] + "%", "->", newVolume)
                                    root.sinkVolume = newVolume
                                } else {
                                    console.warn("Could not parse volume from line:", volumeLine)
                                }
                            }
                            // Find the 'Mute:' line
                            const muteLine = block.split('\n').find(function(l) {
                                return l.trim().startsWith('Mute:');
                            });
                            if (muteLine) {
                                root.sinkMuted = muteLine.indexOf('yes') !== -1;
                            }
                            break;
                        }
                    }
                }
            }
        }
    }
    
    // Get source details (volume, mute, description)
    property Process updateSourceDetails: Process {
        command: ["pactl", "list", "sources"]
        running: false
        property SplitParser stdout: SplitParser {
            onRead: data => {
                const blocks = data.split(/\n(?=Source #)/);
                for (let block of blocks) {
                    const nameLine = block.split('\n').find(function(l) {
                        return l.trim().startsWith('Name:');
                    });
                    if (nameLine) {
                        var blockName = nameLine.split(':')[1].trim();
                        if (blockName.toLowerCase() === root.sourceName.trim().toLowerCase()) {
                            // Find the 'Volume:' line (first channel)
                            const volumeLine = block.split('\n').find(function(l) {
                                return l.trim().startsWith('Volume:');
                            });
                            if (volumeLine) {
                                // Example: 'Volume: front-left: 65536 / 100% / 0.00 dB, ...'
                                const match = volumeLine.match(/\b(\d+)%/);
                                if (match) {
                                    root.sourceVolume = parseInt(match[1]) / 100.0;
                                }
                            }
                            // Find the 'Mute:' line
                            const muteLine = block.split('\n').find(function(l) {
                                return l.trim().startsWith('Mute:');
                            });
                            if (muteLine) {
                                root.sourceMuted = muteLine.indexOf('yes') !== -1;
                            }
                            break;
                        }
                    }
                }
            }
        }
    }
    
    // Timer to periodically update audio state
    property Timer updateTimer: Timer {
        interval: root.updateInterval
        running: true
        repeat: true
        onTriggered: {
            if (root.sinkId) {
                updateSinkDetails.running = true
            }
            if (root.sourceId) {
                updateSourceDetails.running = true
            }
            
            // If we need to check volume after setting it
            if (root.needVolumeCheck) {
                root.needVolumeCheck = false
                root.checkCurrentVolume()
            }
        }
    }
    
    // Initialize on component creation
    Component.onCompleted: {
        updateSinkInfo.running = true
        updateSourceInfo.running = true
        
        // Check status after a delay
        initCheckTimer.start()
        
        // Test pactl command after a short delay
        testPactlTimer.start()
    }
    
    // Timer for initial status check
    property Timer initCheckTimer: Timer {
        interval: 2000
        running: false
        repeat: false
        onTriggered: {
            root.checkStatus()
        }
    }
    
    // Timer for testing pactl command
    property Timer testPactlTimer: Timer {
        interval: 1000
        running: false
        repeat: false
        onTriggered: {
            root.testPactl()
        }
    }
    
    // Timer for testing volume set
    property Timer testVolumeTimer: Timer {
        interval: 3000
        running: false
        repeat: false
        onTriggered: {
            console.log("Testing volume set to 50%...")
            root.testSetVolume(0.5)
        }
    }
    
    // Functions to set sink volume and mute
    function setSinkVolume(volume) {
        var sinkToUse = root.sinkId === "@DEFAULT_SINK@" ? "@DEFAULT_SINK@" : root.sinkId
        if (sinkToUse && sinkToUse !== "") {
            setVolumeProcess.command = ["pactl", "set-sink-volume", sinkToUse, Math.round(volume * 100) + "%"]
            setVolumeProcess.running = true
            
            // Mark that we need to check volume after setting it
            root.needVolumeCheck = true
        }
    }
    
    function setSinkMuted(muted) {
        var sinkToUse = root.sinkId === "@DEFAULT_SINK@" ? "@DEFAULT_SINK@" : root.sinkId
        if (sinkToUse && sinkToUse !== "") {
            setMuteProcess.command = ["pactl", "set-sink-mute", sinkToUse, muted ? "1" : "0"]
            setMuteProcess.running = true
        }
    }
    
    // Functions to set source volume and mute
    function setSourceVolume(volume) {
        var sourceToUse = root.sourceId === "@DEFAULT_SOURCE@" ? "@DEFAULT_SOURCE@" : root.sourceId
        if (sourceToUse && sourceToUse !== "") {
            setSourceVolumeProcess.command = ["pactl", "set-source-volume", sourceToUse, Math.round(volume * 100) + "%"]
            setSourceVolumeProcess.running = true
        }
    }
    
    function setSourceMuted(muted) {
        var sourceToUse = root.sourceId === "@DEFAULT_SOURCE@" ? "@DEFAULT_SOURCE@" : root.sourceId
        if (sourceToUse && sourceToUse !== "") {
            setSourceMuteProcess.command = ["pactl", "set-source-mute", sourceToUse, muted ? "1" : "0"]
            setSourceMuteProcess.running = true
        }
    }
    
    // Functions to manually refresh
    function refreshSink() {
        updateSinkInfo.running = true
    }
    
    function refreshSource() {
        updateSourceInfo.running = true
    }
    
    // Function to check current status
    function checkStatus() {
        // Status check disabled for quiet operation
    }
    
    // Function to manually test pactl command
    function testPactl() {
        testPactlProcess.running = true
    }
    
    // Function to check current volume manually
    function checkCurrentVolume() {
        checkVolumeProcess.running = true
    }
    
    // Function to test setting a specific volume
    function testSetVolume(volume) {
        var sinkToUse = root.sinkId === "@DEFAULT_SINK@" ? "@DEFAULT_SINK@" : root.sinkId
        if (sinkToUse && sinkToUse !== "") {
            setVolumeProcess.command = ["pactl", "set-sink-volume", sinkToUse, Math.round(volume * 100) + "%"]
            setVolumeProcess.running = true
        }
    }
    
    // Test process for manual pactl testing
    property Process testPactlProcess: Process {
        command: ["pactl", "info"]
        running: false
        
        property SplitParser stdout: SplitParser {
            onRead: data => {
                // Test output disabled for quiet operation
            }
        }
        
    }
    
    // Process to check current volume
    property Process checkVolumeProcess: Process {
        command: ["pactl", "list", "sinks"]
        running: false
        
        property SplitParser stdout: SplitParser {
            onRead: data => {
                // Volume check output disabled for quiet operation
            }
        }
    }
} 