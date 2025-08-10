import Quickshell.Services.Pipewire
import Quickshell
import QtQuick

pragma Singleton

QtObject {
    id: root
    
    // Native PipeWire service
    property var nativePipewire: Pipewire
    property bool nativeAvailable: !!nativePipewire
    
    // Device lists
    property var availableSinks: []
    property var availableSources: []
    property var applicationStreams: []
    property var audioCards: []
    
    // Note: Qt automatically generates property change signals for availableSinks, availableSources, etc.
    
    // Default device IDs
    readonly property string sinkId: nativePipewire && nativePipewire.defaultAudioSink ? nativePipewire.defaultAudioSink.id : ""
    readonly property string sourceId: nativePipewire && nativePipewire.defaultAudioSource ? nativePipewire.defaultAudioSource.id : ""
    
    // Device descriptions
    readonly property string sinkDescription: nativePipewire && nativePipewire.defaultAudioSink ? nativePipewire.defaultAudioSink.name : ""
    readonly property string sourceDescription: nativePipewire && nativePipewire.defaultAudioSource ? nativePipewire.defaultAudioSource.name : ""
    
    // Local state tracking for volume and mute (to avoid accessing problematic native properties)
    property real sinkVolume: 1.0
    property real sourceVolume: 1.0
    property bool sinkMuted: false
    property bool sourceMuted: false
    
    // Monitoring state
    property bool monitoringEnabled: false
    
    // Timer for real-time volume monitoring
    property Timer volumeMonitorTimer: Timer {
        interval: 1000 // Check every second
        running: monitoringEnabled
        repeat: true
        onTriggered: {
            if (monitoringEnabled) {
                updateVolumeStates()
            }
        }
    }
    
    // Initialize when native service is ready
    Component.onCompleted: {
        console.log("Pipewire service: Component.onCompleted")
        if (nativePipewire) {
            console.log("Pipewire service: Native service found")
            initializeNativePipewire()
        } else {
            console.log("Pipewire service: No native service available")
        }
    }
    
    // Initialize native PipeWire integration
    function initializeNativePipewire() {
        console.log("Pipewire service: Initializing native integration")
        
        // Debug: Check what properties are available
        console.log("Pipewire service: Native service properties:", Object.keys(nativePipewire))
        console.log("Pipewire service: Native service ready:", nativePipewire.ready)
        console.log("Pipewire service: Native service nodes:", nativePipewire.nodes)
        console.log("Pipewire service: Native service defaultAudioSink:", nativePipewire.defaultAudioSink)
        console.log("Pipewire service: Native service defaultAudioSource:", nativePipewire.defaultAudioSource)
        
        // Connect to native service signals
        if (nativePipewire.readyChanged) {
            nativePipewire.readyChanged.connect(() => {
                console.log("Pipewire service: Ready state changed:", nativePipewire.ready)
                if (nativePipewire.ready) {
                    console.log("Pipewire service: Service is now ready, populating devices")
                    populateFromNative()
                    startEnhancedMonitoring()
                }
            })
        }
        
        // Connect to default device changes
        if (nativePipewire.defaultAudioSinkChanged) {
            nativePipewire.defaultAudioSinkChanged.connect(() => {
                console.log("Pipewire service: Default sink changed")
                populateFromNative()
            })
        }
        
        if (nativePipewire.defaultAudioSourceChanged) {
            nativePipewire.defaultAudioSourceChanged.connect(() => {
                console.log("Pipewire service: Default source changed")
                populateFromNative()
            })
        }
        
        // Connect to node changes
        if (nativePipewire.nodeAdded) {
            nativePipewire.nodeAdded.connect(handleNodeAdded)
        }
        
        if (nativePipewire.nodeRemoved) {
            nativePipewire.nodeRemoved.connect(handleNodeRemoved)
        }
        
        // Connect to valuesChanged signal if available
        if (nativePipewire.nodes && nativePipewire.nodes.valuesChanged) {
            nativePipewire.nodes.valuesChanged.connect(() => {
                console.log("Pipewire service: valuesChanged signal received")
                // Populate immediately after valuesChanged
                if (nativePipewire.ready) {
                    console.log("Pipewire service: Population after valuesChanged")
                    populateFromNative()
                }
            })
        }
        
        // Initial population if already ready
        if (nativePipewire.ready) {
            console.log("Pipewire service: Service already ready, populating")
            populateFromNative()
            startEnhancedMonitoring()
        } else {
            console.log("Pipewire service: Service not ready yet, waiting for readyChanged signal")
        }
    }
    
    // Populate device lists from native PipeWire
    function populateFromNative() {
        if (!nativePipewire || !nativePipewire.ready) {
            console.log("Pipewire service: Cannot populate - service not ready")
            return
        }
        
        console.log("Pipewire service: Populating from native service")
        console.log("Pipewire service: Nodes object:", nativePipewire.nodes)
        
        // Clear existing arrays
        availableSinks = []
        availableSources = []
        applicationStreams = []
        audioCards = []
        
        if (!nativePipewire.nodes) {
            console.log("Pipewire service: No nodes available")
            return
        }
        
        console.log("Pipewire service: Nodes object type:", typeof nativePipewire.nodes)
        console.log("Pipewire service: Nodes object properties:", Object.keys(nativePipewire.nodes))
        
        // Try to access nodes using ObjectModel methods
        try {
            // Based on Noctalia's working implementation, nodes.values is an array
            console.log("Pipewire service: Checking nodes.values:", nativePipewire.nodes.values)
            console.log("Pipewire service: nodes.values type:", typeof nativePipewire.nodes.values)
            console.log("Pipewire service: nodes.values isArray:", Array.isArray(nativePipewire.nodes.values))
            console.log("Pipewire service: nodes.values length:", nativePipewire.nodes.values ? nativePipewire.nodes.values.length : "undefined")
            
            // nodes.values is an object with length, not an array, so we can access by index
            if (nativePipewire.nodes.values && nativePipewire.nodes.values.length > 0) {
                console.log("Pipewire service: Using nodes.values object with index access, length:", nativePipewire.nodes.values.length)
                for (let i = 0; i < nativePipewire.nodes.values.length; i++) {
                    try {
                        const node = nativePipewire.nodes.values[i]
                        if (node) {
                            console.log("Pipewire service: Processing node at index", i, ":", node.name)
                            processNode(node)
                        }
        } catch (e) {
                        console.log("Pipewire service: Error accessing node at index", i, ":", e.message)
                    }
                }
            } else if (nativePipewire.nodes.model) {
                console.log("Pipewire service: Found model property, using it")
                const model = nativePipewire.nodes.model
                console.log("Pipewire service: Model properties:", Object.keys(model))
                
                // Try to iterate over the model
                if (model.count !== undefined) {
                    console.log("Pipewire service: Model has count:", model.count)
                    for (let i = 0; i < model.count; i++) {
                        try {
                            const node = model.get(i)
                            if (node) {
                                processNode(node)
                            }
        } catch (e) {
                            console.log("Pipewire service: Error accessing model node at index", i, ":", e.message)
                        }
                    }
                }
            } else if (nativePipewire.nodes.count !== undefined) {
                console.log("Pipewire service: Using direct count property:", nativePipewire.nodes.count)
                for (let i = 0; i < nativePipewire.nodes.count; i++) {
                    try {
                        const node = nativePipewire.nodes.get(i)
                        if (node) {
                            processNode(node)
                        }
                    } catch (e) {
                        console.log("Pipewire service: Error accessing node at index", i, ":", e.message)
                    }
                }
            } else if (nativePipewire.nodes.rowCount !== undefined) {
                console.log("Pipewire service: Using rowCount property:", nativePipewire.nodes.rowCount)
                try {
                    const count = nativePipewire.nodes.rowCount()
                    console.log("Pipewire service: rowCount() returned:", count)
                    for (let i = 0; i < count; i++) {
                        try {
                            console.log("Pipewire service: Trying to access node at index", i)
                            const indexObj = nativePipewire.nodes.index(i, 0)
                            console.log("Pipewire service: index() returned:", indexObj)
                            if (indexObj) {
                                const node = nativePipewire.nodes.data(indexObj)
                                console.log("Pipewire service: data() returned:", node)
                                if (node) {
                                    console.log("Pipewire service: Successfully got node:", node)
                                    processNode(node)
                                } else {
                                    console.log("Pipewire service: data() returned null/undefined")
                                }
                            } else {
                                console.log("Pipewire service: index() returned null/undefined")
                            }
                        } catch (e) {
                            console.log("Pipewire service: Error accessing node at row", i, ":", e.message)
                        }
                    }
                } catch (e) {
                    console.log("Pipewire service: Error calling rowCount():", e.message)
                }
            } else {
                console.log("Pipewire service: Cannot determine how to access nodes, trying alternative methods")
                
                // Try to access as a list
                if (nativePipewire.nodes.toArray) {
                    console.log("Pipewire service: Trying toArray method")
                    const nodeArray = nativePipewire.nodes.toArray()
                    console.log("Pipewire service: toArray result:", nodeArray)
                    if (Array.isArray(nodeArray)) {
                        nodeArray.forEach(node => {
                            if (node) processNode(node)
                        })
                    }
                } else if (nativePipewire.nodes.values && typeof nativePipewire.nodes.values === 'function') {
                    console.log("Pipewire service: Trying values function")
                    const values = nativePipewire.nodes.values()
                    console.log("Pipewire service: values result:", values)
                    if (Array.isArray(values)) {
                        values.forEach(node => {
                            if (node) processNode(node)
                        })
                    }
                }
            }
        } catch (e) {
            console.log("Pipewire service: Error during node population:", e.message)
        }
        
        console.log("Pipewire service: Populated - Sinks:", availableSinks.length, "Sources:", availableSources.length, "Streams:", applicationStreams.length, "Cards:", audioCards.length)
        console.log("Pipewire service: Available sinks:", availableSinks.map(s => s.name))
        console.log("Pipewire service: Available sources:", availableSources.map(s => s.name))
        console.log("Pipewire service: Application streams:", applicationStreams.map(s => s.name))
        
        // Note: Qt automatically emits property change signals when properties change
        
        // Initialize local state from the populated devices
        initializeLocalState()
    }
    
    // Helper function to process individual nodes
    function processNode(node) {
        console.log("Pipewire service: Processing node:", node.name, "type:", node.type, "isStream:", node.isStream, "isSink:", node.isSink)
        console.log("Pipewire service: Node properties:", Object.keys(node))
        
        // Categorize nodes based on isSink, isStream and other properties
        if (node.isStream && (node.name && (node.name.includes("speech-dispatcher") || node.name.includes("Chromium")))) {
            console.log("Pipewire service: Adding application stream:", node.name)
            
            // Extract application information
            let appName = node.name
            let appIcon = "audio"
            let appDescription = node.description || node.name
            
            // Try to get better application name from metadata
            if (node.metadata) {
                // Look for common metadata keys that contain app names
                const appNameKeys = ["application.name", "app.name", "application.process.name", "process.name"]
                for (const key of appNameKeys) {
                    if (node.metadata[key]) {
                        appName = node.metadata[key]
                        break
                    }
                }
                
                // Look for icon metadata
                const iconKeys = ["application.icon_name", "app.icon_name", "icon.name"]
                for (const key of iconKeys) {
                    if (node.metadata[key]) {
                        appIcon = node.metadata[key]
                        break
                    }
                }
            }
            
            // If no metadata found, try to extract from the name
            if (appName === node.name && node.name.includes(".")) {
                // Try to extract app name from process names like "firefox.1234"
                const parts = node.name.split(".")
                if (parts.length > 0) {
                    appName = parts[0]
                    // Try to map common app names to icons
                    const iconMap = {
                        "firefox": "firefox",
                        "chrome": "google-chrome",
                        "discord": "discord",
                        "spotify": "spotify",
                        "vlc": "vlc",
                        "mpv": "mpv",
                        "pulseaudio": "audio",
                        "pipewire": "audio",
                        "system": "audio",
                        "chromium": "google-chrome",
                        "speech-dispatcher": "audio"
                    }
                    if (iconMap[appName.toLowerCase()]) {
                        appIcon = iconMap[appName.toLowerCase()]
                    }
                }
            }
            
            applicationStreams.push({
                id: node.id,
                name: appName,
                originalName: node.name,
                description: appDescription,
                icon: appIcon,
                volume: node.audio ? node.audio.volume : 1.0,
                muted: node.audio ? node.audio.muted : false,
                sinkId: node.sinkId || "",
                mediaClass: node.type || "Audio/Stream",
                metadata: node.metadata || {},
                isStream: true
            })
        } else if (node.isSink) {
            console.log("Pipewire service: Adding sink:", node.name)
            availableSinks.push({
            id: node.id,
            name: node.name,
                description: node.description || node.name,
            volume: node.audio ? node.audio.volume : 1.0,
            muted: node.audio ? node.audio.muted : false,
                isDefault: node.id === sinkId,
                card: node.card || 0,
                ports: node.ports || []
            })
        } else if (node.name && node.name.includes("alsa_input")) {
            console.log("Pipewire service: Adding source:", node.name)
            availableSources.push({
            id: node.id,
            name: node.name,
                description: node.description || node.name,
            volume: node.audio ? node.audio.volume : 1.0,
            muted: node.audio ? node.audio.muted : false,
                isDefault: node.id === sourceId,
                card: node.card || 0,
                ports: node.ports || []
            })
        } else if (node.name && node.name.includes("alsa_card")) {
            console.log("Pipewire service: Adding audio card:", node.name)
            audioCards.push({
                id: node.id,
                name: node.name,
                description: node.description || node.name,
                profiles: node.profiles || [],
                activeProfile: node.activeProfile || ""
            })
        } else {
            console.log("Pipewire service: Skipping node:", node.name, "mediaClass:", node.mediaClass, "isStream:", node.isStream, "isSink:", node.isSink)
        }
    }
    
    // Initialize local state from available devices
    function initializeLocalState() {
        console.log("Pipewire service: Initializing local state from available devices")
        
        // Find default sink and source to initialize local state
        const defaultSink = availableSinks.find(s => s.isDefault)
        if (defaultSink) {
            root.sinkVolume = defaultSink.volume
            root.sinkMuted = defaultSink.muted
            console.log("Pipewire service: Initialized sink state - volume:", root.sinkVolume, "muted:", root.sinkMuted)
        }
        
        const defaultSource = availableSources.find(s => s.isDefault)
        if (defaultSource) {
            root.sourceVolume = defaultSource.volume
            root.sourceMuted = defaultSource.muted
            console.log("Pipewire service: Initialized source state - volume:", root.sourceVolume, "muted:", root.sourceMuted)
        }
    }
    
    // Handle new nodes being added
    function handleNodeAdded(node) {
        console.log("Pipewire service: Node added:", node.name, "type:", node.mediaClass)
        populateFromNative()
    }
    
    // Handle nodes being removed
    function handleNodeRemoved(node) {
        console.log("Pipewire service: Node removed:", node.name)
        populateFromNative()
    }
    
    // Refresh all devices
    function refreshAll() {
        console.log("Pipewire service: refreshAll called")
        if (nativeAvailable) {
            populateFromNative()
        }
    }
    
    // Set default sink
    function setDefaultSink(sinkId) {
        console.log("Pipewire service: Setting default sink:", sinkId)
        if (nativePipewire && nativePipewire.preferredDefaultAudioSink) {
            // Find the sink node
            const sink = availableSinks.find(s => s.id === sinkId)
            if (sink) {
                // This would need to be implemented based on how to set preferred default
                // For now, just refresh to update the UI
                refreshAll()
            }
        }
    }
    
    // Set default source
    function setDefaultSource(sourceId) {
        console.log("Pipewire service: Setting default source:", sourceId)
        if (nativePipewire && nativePipewire.preferredDefaultAudioSource) {
            // Find the source node
            const source = availableSources.find(s => s.id === sourceId)
            if (source) {
                // This would need to be implemented based on how to set preferred default
                // For now, just refresh to update the UI
                refreshAll()
            }
        }
    }
    
    // Set sink volume
    function setSinkVolumeById(sinkId, volume) {
        console.log("Pipewire service: Setting sink volume:", sinkId, volume)
        if (nativePipewire && nativePipewire.nodes) {
            try {
                // Try different ways to access nodes
                let node = null
                
                // Method 1: Try nodes.values if it's an object with length
                if (nativePipewire.nodes.values && nativePipewire.nodes.values.length > 0) {
                    for (let i = 0; i < nativePipewire.nodes.values.length; i++) {
                        const potentialNode = nativePipewire.nodes.values[i]
                        if (potentialNode && potentialNode.id === sinkId && potentialNode.isSink && potentialNode.audio) {
                            node = potentialNode
                            break
                        }
                    }
                }
                
                // Method 2: Try direct count property
                if (!node && nativePipewire.nodes.count !== undefined) {
                    for (let i = 0; i < nativePipewire.nodes.count; i++) {
                        const potentialNode = nativePipewire.nodes.get(i)
                        if (potentialNode && potentialNode.id === sinkId && potentialNode.isSink && potentialNode.audio) {
                            node = potentialNode
                            break
                        }
                    }
                }
                
                // Method 3: Try rowCount method
                if (!node && nativePipewire.nodes.rowCount !== undefined) {
                    const count = nativePipewire.nodes.rowCount()
                    for (let i = 0; i < count; i++) {
                        const indexObj = nativePipewire.nodes.index(i, 0)
                        if (indexObj) {
                            const potentialNode = nativePipewire.nodes.data(indexObj)
                            if (potentialNode && potentialNode.id === sinkId && potentialNode.isSink && potentialNode.audio) {
                                node = potentialNode
                                break
                            }
                        }
                    }
                }
                
                if (node) {
                    console.log("Pipewire service: Found sink node for volume control:", node.name)
                    
                    // Try to set volume using native PipeWire API
                    let volumeSet = false
                    
                    if (node.audio.setVolume && typeof node.audio.setVolume === 'function') {
                        try {
                            node.audio.setVolume(volume)
                            volumeSet = true
                            console.log("Pipewire service: Used setVolume method")
                        } catch (e) {
                            console.log("Pipewire service: setVolume method failed:", e.message)
                        }
                    }
                    
                    if (!volumeSet && node.audio.volume !== undefined) {
                        try {
                            node.audio.volume = volume
                            volumeSet = true
                            console.log("Pipewire service: Used direct volume property")
                        } catch (e) {
                            console.log("Pipewire service: Direct volume property failed:", e.message)
                        }
                    }
                    
                    if (volumeSet) {
                        // Update our local copy
                        const sinkIndex = availableSinks.findIndex(s => s.id === sinkId)
                        if (sinkIndex !== -1) {
                            availableSinks[sinkIndex].volume = volume
                        }
                        
                        // Update local state if this is the default sink
                        if (sinkId === root.sinkId) {
                            root.sinkVolume = volume
                        }
                        
                        console.log("Pipewire service: Successfully set sink volume:", sinkId, volume)
                        return
                    }
                }
                
                console.log("Pipewire service: Could not find sink node or set volume")
            } catch (e) {
                console.log("Pipewire service: Error setting sink volume:", e.message)
            }
        }
        // Fallback to refresh if native API fails
        refreshAll()
    }
    
    // Set sink mute - DEBUGGING ADDED HERE
    function setSinkMuteById(sinkId, muted) {
        console.log("Pipewire service: Setting sink mute:", sinkId, muted)
        console.log("Pipewire service: Available sinks:", availableSinks.map(s => ({ id: s.id, name: s.name })))
        if (nativePipewire && nativePipewire.nodes) {
            try {
                // Try different ways to access nodes
                let node = null
                
                // Method 1: Try nodes.values if it's an object with length
                if (nativePipewire.nodes.values && nativePipewire.nodes.values.length > 0) {
                    console.log("Pipewire service: Trying nodes.values method, length:", nativePipewire.nodes.values.length)
                    for (let i = 0; i < nativePipewire.nodes.values.length; i++) {
                        const potentialNode = nativePipewire.nodes.values[i]
                        console.log("Pipewire service: Checking node:", potentialNode.id, "isSink:", potentialNode.isSink, "has audio:", !!potentialNode.audio)
                        if (potentialNode && potentialNode.id === sinkId && potentialNode.isSink && potentialNode.audio) {
                            node = potentialNode
                            console.log("Pipewire service: Found matching node via nodes.values")
                            break
                        }
                    }
                }
                
                // Method 2: Try direct count property
                if (!node && nativePipewire.nodes.count !== undefined) {
                    console.log("Pipewire service: Trying count method, count:", nativePipewire.nodes.count)
                    for (let i = 0; i < nativePipewire.nodes.count; i++) {
                        const potentialNode = nativePipewire.nodes.get(i)
                        console.log("Pipewire service: Checking node:", potentialNode.id, "isSink:", potentialNode.isSink, "has audio:", !!potentialNode.audio)
                        if (potentialNode && potentialNode.id === sinkId && potentialNode.isSink && potentialNode.audio) {
                            node = potentialNode
                            console.log("Pipewire service: Found matching node via count method")
                            break
                        }
                    }
                }
                
                // Method 3: Try rowCount method
                if (!node && nativePipewire.nodes.rowCount !== undefined) {
                    const count = nativePipewire.nodes.rowCount()
                    for (let i = 0; i < count; i++) {
                        const indexObj = nativePipewire.nodes.index(i, 0)
                        if (indexObj) {
                            const potentialNode = nativePipewire.nodes.data(indexObj)
                            if (potentialNode && potentialNode.id === sinkId && potentialNode.isSink && potentialNode.audio) {
                                node = potentialNode
                                break
                            }
                        }
                    }
                }
                
                if (node) {
                    console.log("Pipewire service: Found sink node for mute control:", node.name)
                    
                    // Try to set mute using native PipeWire API
                    let muteSet = false
                    
                    if (node.audio.setMuted && typeof node.audio.setMuted === 'function') {
                        try {
                            node.audio.setMuted(muted)
                            muteSet = true
                            console.log("Pipewire service: Used setMuted method")
                        } catch (e) {
                            console.log("Pipewire service: setMuted method failed:", e.message)
                        }
                    }
                    
                    if (!muteSet && node.audio.muted !== undefined) {
                        try {
                            node.audio.muted = muted
                            muteSet = true
                            console.log("Pipewire service: Used direct muted property")
                        } catch (e) {
                            console.log("Pipewire service: Direct muted property failed:", e.message)
                        }
                    }
                    
                    if (muteSet) {
                        // Update our local copy
                        const sinkIndex = availableSinks.findIndex(s => s.id === sinkId)
                        if (sinkIndex !== -1) {
                            availableSinks[sinkIndex].muted = muted
                        }
                        
                        // Update local state if this is the default sink
                        if (sinkId === root.sinkId) {
                            root.sinkMuted = muted
                        }
                        
                        console.log("Pipewire service: Successfully set sink mute:", sinkId, muted)
                        return
                    }
                }
                
                console.log("Pipewire service: Could not find sink node or set mute")
            } catch (e) {
                console.log("Pipewire service: Error setting sink mute:", e.message)
            }
        }
        // Fallback to refresh if native API fails
        refreshAll()
    }
    
    // Set source volume
    function setSourceVolumeById(sourceId, volume) {
        console.log("Pipewire service: Setting source volume:", sourceId, volume)
        if (nativePipewire && nativePipewire.nodes) {
            try {
                // Try different ways to access nodes
                let node = null
                
                // Method 1: Try nodes.values if it's an object with length
                if (nativePipewire.nodes.values && nativePipewire.nodes.values.length > 0) {
                    for (let i = 0; i < nativePipewire.nodes.values.length; i++) {
                        const potentialNode = nativePipewire.nodes.values[i]
                        if (potentialNode && potentialNode.id === sourceId && potentialNode.name && potentialNode.name.includes("alsa_input") && potentialNode.audio) {
                            node = potentialNode
                            break
                        }
                    }
                }
                
                // Method 2: Try direct count property
                if (!node && nativePipewire.nodes.count !== undefined) {
                    for (let i = 0; i < nativePipewire.nodes.count; i++) {
                        const potentialNode = nativePipewire.nodes.get(i)
                        if (potentialNode && potentialNode.id === sourceId && potentialNode.name && potentialNode.name.includes("alsa_input") && potentialNode.audio) {
                            node = potentialNode
                            break
                        }
                    }
                }
                
                // Method 3: Try rowCount method
                if (!node && nativePipewire.nodes.rowCount !== undefined) {
                    const count = nativePipewire.nodes.rowCount()
                    for (let i = 0; i < count; i++) {
                        const indexObj = nativePipewire.nodes.index(i, 0)
                        if (indexObj) {
                            const potentialNode = nativePipewire.nodes.data(indexObj)
                            if (potentialNode && potentialNode.id === sourceId && potentialNode.name && potentialNode.name.includes("alsa_input") && potentialNode.audio) {
                                node = potentialNode
                                break
                            }
                        }
                    }
                }
                
                if (node) {
                    console.log("Pipewire service: Found source node for volume control:", node.name)
                    
                    // Try to set volume using native PipeWire API
                    let volumeSet = false
                    
                    if (node.audio.setVolume && typeof node.audio.setVolume === 'function') {
                        try {
                            node.audio.setVolume(volume)
                            volumeSet = true
                            console.log("Pipewire service: Used setVolume method")
                        } catch (e) {
                            console.log("Pipewire service: setVolume method failed:", e.message)
                        }
                    }
                    
                    if (!volumeSet && node.audio.volume !== undefined) {
                        try {
                            node.audio.volume = volume
                            volumeSet = true
                            console.log("Pipewire service: Used direct volume property")
                        } catch (e) {
                            console.log("Pipewire service: Direct volume property failed:", e.message)
                        }
                    }
                    
                    if (volumeSet) {
                        // Update our local copy
                        const sourceIndex = availableSources.findIndex(s => s.id === sourceId)
                        if (sourceIndex !== -1) {
                            availableSources[sourceIndex].volume = volume
                        }
                        
                        // Update local state if this is the default source
                        if (sourceId === root.sourceId) {
                            root.sourceVolume = volume
                        }
                        
                        console.log("Pipewire service: Successfully set source volume:", sourceId, volume)
                        return
                    }
                }
                
                console.log("Pipewire service: Could not find source node or set volume")
            } catch (e) {
                console.log("Pipewire service: Error setting source volume:", e.message)
            }
        }
        // Fallback to refresh if native API fails
        refreshAll()
    }
    
    // Set source mute
    function setSourceMuteById(sourceId, muted) {
        console.log("Pipewire service: Setting source mute:", sourceId, muted)
        if (nativePipewire && nativePipewire.nodes) {
            try {
                // Try different ways to access nodes
                let node = null
                
                // Method 1: Try nodes.values if it's an object with length
                if (nativePipewire.nodes.values && nativePipewire.nodes.values.length > 0) {
                    for (let i = 0; i < nativePipewire.nodes.values.length; i++) {
                        const potentialNode = nativePipewire.nodes.values[i]
                        if (potentialNode && potentialNode.id === sourceId && potentialNode.name && potentialNode.name.includes("alsa_input") && potentialNode.audio) {
                            node = potentialNode
                            break
                        }
                    }
                }
                
                // Method 2: Try direct count property
                if (!node && nativePipewire.nodes.count !== undefined) {
                    for (let i = 0; i < nativePipewire.nodes.count; i++) {
                        const potentialNode = nativePipewire.nodes.get(i)
                        if (potentialNode && potentialNode.id === sourceId && potentialNode.name && potentialNode.name.includes("alsa_input") && potentialNode.audio) {
                            node = potentialNode
                            break
                        }
                    }
                }
                
                // Method 3: Try rowCount method
                if (!node && nativePipewire.nodes.rowCount !== undefined) {
                    const count = nativePipewire.nodes.rowCount()
                    for (let i = 0; i < count; i++) {
                        const indexObj = nativePipewire.nodes.index(i, 0)
                        if (indexObj) {
                            const potentialNode = nativePipewire.nodes.data(indexObj)
                            if (potentialNode && potentialNode.id === sourceId && potentialNode.name && potentialNode.name.includes("alsa_input") && potentialNode.audio) {
                                node = potentialNode
                                break
                            }
                        }
                    }
                }
                
                if (node) {
                    console.log("Pipewire service: Found source node for mute control:", node.name)
                    
                    // Try to set mute using native PipeWire API
                    let muteSet = false
                    
                    if (node.audio.setMuted && typeof node.audio.setMuted === 'function') {
                        try {
                            node.audio.setMuted(muted)
                            muteSet = true
                            console.log("Pipewire service: Used setMuted method")
                        } catch (e) {
                            console.log("Pipewire service: setMuted method failed:", e.message)
                        }
                    }
                    
                    if (!muteSet && node.audio.muted !== undefined) {
                        try {
                            node.audio.muted = muted
                            muteSet = true
                            console.log("Pipewire service: Used direct muted property")
                        } catch (e) {
                            console.log("Pipewire service: Direct muted property failed:", e.message)
                        }
                    }
                    
                    if (muteSet) {
                        // Update our local copy
                        const sourceIndex = availableSources.findIndex(s => s.id === sourceId)
                        if (sourceIndex !== -1) {
                            availableSources[sourceIndex].muted = muted
                        }
                        
                        // Update local state if this is the default source
                        if (sourceId === root.sourceId) {
                            root.sourceMuted = muted
                        }
                        
                        console.log("Pipewire service: Successfully set source mute:", sourceId, muted)
                        return
                    }
                }
                
                console.log("Pipewire service: Could not find source node or set mute")
            } catch (e) {
                console.log("Pipewire service: Error setting source mute:", e.message)
            }
        }
        // Fallback to refresh if native API fails
        refreshAll()
    }
    
    // Enhanced application control methods
    function setApplicationVolume(streamId, volume) {
        console.log("Pipewire service: Setting application volume:", streamId, volume)
        if (nativePipewire && nativePipewire.nodes) {
            try {
                // Try different ways to access nodes
                let node = null
                
                // Method 1: Try nodes.values if it's an object with length
                if (nativePipewire.nodes.values && nativePipewire.nodes.values.length > 0) {
                    for (let i = 0; i < nativePipewire.nodes.values.length; i++) {
                        const potentialNode = nativePipewire.nodes.values[i]
                        if (potentialNode && potentialNode.id === streamId && potentialNode.isStream && potentialNode.audio) {
                            node = potentialNode
                            break
                        }
                    }
                }
                
                // Method 2: Try direct count property
                if (!node && nativePipewire.nodes.count !== undefined) {
                    for (let i = 0; i < nativePipewire.nodes.count; i++) {
                        const potentialNode = nativePipewire.nodes.get(i)
                        if (potentialNode && potentialNode.id === streamId && potentialNode.isStream && potentialNode.audio) {
                            node = potentialNode
                            break
                        }
                    }
                }
                
                // Method 3: Try rowCount method
                if (!node && nativePipewire.nodes.rowCount !== undefined) {
                    const count = nativePipewire.nodes.rowCount()
                    for (let i = 0; i < count; i++) {
                        const indexObj = nativePipewire.nodes.index(i, 0)
                        if (indexObj) {
                            const potentialNode = nativePipewire.nodes.data(indexObj)
                            if (potentialNode && potentialNode.id === streamId && potentialNode.isStream && potentialNode.audio) {
                                node = potentialNode
                                break
                            }
                        }
                    }
                }
                
                if (node) {
                    console.log("Pipewire service: Found stream node for volume control:", node.name)
                    
                    // Try to set volume using native PipeWire API
                    let volumeSet = false
                    
                    if (node.audio.setVolume && typeof node.audio.setVolume === 'function') {
                        try {
                            node.audio.setVolume(volume)
                            volumeSet = true
                            console.log("Pipewire service: Used setVolume method")
                        } catch (e) {
                            console.log("Pipewire service: setVolume method failed:", e.message)
                        }
                    }
                    
                    if (!volumeSet && node.audio.volume !== undefined) {
                        try {
                            node.audio.volume = volume
                            volumeSet = true
                            console.log("Pipewire service: Used direct volume property")
                        } catch (e) {
                            console.log("Pipewire service: Direct volume property failed:", e.message)
                        }
                    }
                    
                    if (volumeSet) {
                        // Update our local copy
                        const streamIndex = applicationStreams.findIndex(s => s.id === streamId)
                        if (streamIndex !== -1) {
                            applicationStreams[streamIndex].volume = volume
                        }
                        
                        console.log("Pipewire service: Successfully set application volume:", streamId, volume)
                        return
                    }
                }
                
                console.log("Pipewire service: Could not find stream node or set volume")
            } catch (e) {
                console.log("Pipewire service: Error setting application volume:", e.message)
            }
        }
        // Fallback to refresh if native API fails
        refreshAll()
    }
    
    function setApplicationMute(streamId, muted) {
        console.log("Pipewire service: Setting application mute:", streamId, muted)
        if (nativePipewire && nativePipewire.nodes) {
            try {
                // Try different ways to access nodes
                let node = null
                
                // Method 1: Try nodes.values if it's an object with length
                if (nativePipewire.nodes.values && nativePipewire.nodes.values.length > 0) {
                    for (let i = 0; i < nativePipewire.nodes.values.length; i++) {
                        const potentialNode = nativePipewire.nodes.values[i]
                        if (potentialNode && potentialNode.id === streamId && potentialNode.isStream && potentialNode.audio) {
                            node = potentialNode
                            break
                        }
                    }
                }
                
                // Method 2: Try direct count property
                if (!node && nativePipewire.nodes.count !== undefined) {
                    for (let i = 0; i < nativePipewire.nodes.count; i++) {
                        const potentialNode = nativePipewire.nodes.get(i)
                        if (potentialNode && potentialNode.id === streamId && potentialNode.isStream && potentialNode.audio) {
                            node = potentialNode
                            break
                        }
                    }
                }
                
                // Method 3: Try rowCount method
                if (!node && nativePipewire.nodes.rowCount !== undefined) {
                    const count = nativePipewire.nodes.rowCount()
                    for (let i = 0; i < count; i++) {
                        const indexObj = nativePipewire.nodes.index(i, 0)
                        if (indexObj) {
                            const potentialNode = nativePipewire.nodes.data(indexObj)
                            if (potentialNode && potentialNode.id === streamId && potentialNode.isStream && potentialNode.audio) {
                                node = potentialNode
                                break
                            }
                        }
                    }
                }
                
                if (node) {
                    console.log("Pipewire service: Found stream node for mute control:", node.name)
                    
                    // Try to set mute using native PipeWire API
                    let muteSet = false
                    
                    if (node.audio.setMuted && typeof node.audio.setMuted === 'function') {
                        try {
                            node.audio.setMuted(muted)
                            muteSet = true
                            console.log("Pipewire service: Used setMuted method")
                        } catch (e) {
                            console.log("Pipewire service: setMuted method failed:", e.message)
                        }
                    }
                    
                    if (!muteSet && node.audio.muted !== undefined) {
                        try {
                            node.audio.muted = muted
                            muteSet = true
                            console.log("Pipewire service: Used direct muted property")
                        } catch (e) {
                            console.log("Pipewire service: Direct muted property failed:", e.message)
                        }
                    }
                    
                    if (muteSet) {
                        // Update our local copy
                        const streamIndex = applicationStreams.findIndex(s => s.id === streamId)
                        if (streamIndex !== -1) {
                            applicationStreams[streamIndex].muted = muted
                        }
                        
                        console.log("Pipewire service: Successfully set application mute:", streamId, muted)
                        return
                    }
                }
                
                console.log("Pipewire service: Could not find stream node or set mute")
            } catch (e) {
                console.log("Pipewire service: Error setting application mute:", e.message)
            }
        }
        // Fallback to refresh if native API fails
        refreshAll()
    }
    
    function moveApplicationToSink(streamId, sinkId) {
        console.log("Pipewire service: Moving application to sink:", streamId, sinkId)
        if (nativePipewire && nativePipewire.nodes) {
            // Find the stream node and sink node
            let streamNode = null
            let sinkNode = null
            
            for (let i = 0; i < nativePipewire.nodes.count; i++) {
                const node = nativePipewire.nodes.get(i)
                if (node) {
                    if (node.id === streamId && node.isStream) {
                        streamNode = node
                    } else if (node.id === sinkId && node.mediaClass && node.mediaClass.includes("Audio/Sink")) {
                        sinkNode = node
                    }
                }
            }
            
            if (streamNode && sinkNode) {
                // This would need to be implemented using native PipeWire API
                // For now, just refresh to update the UI
                console.log("Pipewire service: Found nodes for move operation:", streamNode.name, "->", sinkNode.name)
                refreshAll()
            }
        }
    }
    
    // Set card profile
    function setCardProfile(cardId, profile) {
        console.log("Pipewire service: Setting card profile:", cardId, profile)
        // This would need to be implemented using native PipeWire API
        // For now, just refresh to update the UI
        refreshAll()
    }
    
    // Methods needed by the volume indicator
    function setSinkVolume(volume) {
        console.log("Pipewire service: Setting sink volume:", volume)
        
        // Update local state immediately
        root.sinkVolume = volume
        
        // Try to set volume on the default sink using the by-id function
        if (sinkId) {
            setSinkVolumeById(sinkId, volume)
        } else if (availableSinks.length > 0) {
            // Fallback: use the first available sink if no default is set
            console.log("Pipewire service: No default sink, using first available sink:", availableSinks[0].id)
            setSinkVolumeById(availableSinks[0].id, volume)
        } else {
            console.log("Pipewire service: No sinks available")
            refreshAll()
        }
    }

    function setSinkMuted(muted) {
        console.log("Pipewire service: Setting sink muted:", muted)
        
        // Update local state immediately
        root.sinkMuted = muted
        
        // Try to set mute on the default sink using the by-id function
        if (sinkId) {
            setSinkMuteById(sinkId, muted)
        } else if (availableSinks.length > 0) {
            // Fallback: use the first available sink if no default is set
            console.log("Pipewire service: No default sink, using first available sink:", availableSinks[0].id)
            setSinkMuteById(availableSinks[0].id, muted)
        } else {
            console.log("Pipewire service: No sinks available")
            refreshAll()
        }
    }

    function setSourceVolume(volume) {
        console.log("Pipewire service: Setting source volume:", volume)
        
        // Update local state immediately
        root.sourceVolume = volume
        
        // Try to set volume on the default source using the by-id function
        if (sourceId) {
            setSourceVolumeById(sourceId, volume)
        } else if (availableSources.length > 0) {
            // Fallback: use the first available source if no default is set
            console.log("Pipewire service: No default source, using first available source:", availableSources[0].id)
            setSourceVolumeById(availableSources[0].id, volume)
        } else {
            console.log("Pipewire service: No sources available")
            refreshAll()
        }
    }

    function setSourceMuted(muted) {
        console.log("Pipewire service: Setting source muted:", muted)
        
        // Update local state immediately
        root.sourceMuted = muted
        
        // Try to set mute on the default source using the by-id function
        if (sourceId) {
            setSourceMuteById(sourceId, muted)
        } else if (availableSources.length > 0) {
            // Fallback: use the first available source if no default is set
            console.log("Pipewire service: No default source, using first available source:", availableSources[0].id)
            setSourceMuteById(availableSources[0].id, muted)
        } else {
            console.log("Pipewire service: No sources available")
            refreshAll()
        }
    }
    
    function refreshSink() {
        console.log("Pipewire service: Refreshing sink")
        refreshAll()
    }
    
    function refreshSource() {
        console.log("Pipewire service: Refreshing source")
        refreshAll()
    }
    
    function checkStatus() {
        console.log("Pipewire service: Checking status")
        refreshAll()
    }
    
    // Helper methods for the UI
    function getActiveApplicationStreams() {
        // Return only active (non-muted, volume > 0) application streams
        return applicationStreams.filter(stream => !stream.muted && stream.volume > 0)
    }
    
    function getApplicationStreamsBySink(sinkId) {
        // Return application streams that are connected to a specific sink
        return applicationStreams.filter(stream => stream.sinkId === sinkId)
    }
    
    function getSinkByName(name) {
        // Find a sink by name
        return availableSinks.find(sink => sink.name === name || sink.description === name)
    }
    
    function getSourceByName(name) {
        // Find a source by name
        return availableSources.find(source => source.name === name || source.description === name)
    }
    
    function getApplicationStreamByName(name) {
        // Find an application stream by name
        return applicationStreams.find(stream => stream.name === name || stream.originalName === name)
    }
    
    // Start enhanced monitoring
    function startEnhancedMonitoring() {
        console.log("Pipewire service: Starting enhanced monitoring")
        monitoringEnabled = true
        monitoringEnabledChanged()
    }
    
    // Stop enhanced monitoring
    function stopEnhancedMonitoring() {
        console.log("Pipewire service: Stopping enhanced monitoring")
        monitoringEnabled = false
        monitoringEnabledChanged()
    }
    
    // Update volume states from native service
    function updateVolumeStates() {
        if (!nativePipewire || !nativePipewire.ready) {
            return
        }
        
        try {
            // Update sink volumes
            for (let i = 0; i < availableSinks.length; i++) {
                const sink = availableSinks[i]
                if (nativePipewire.nodes) {
                    let node = null
                    
                    // Try different ways to access nodes
                    if (nativePipewire.nodes.values && nativePipewire.nodes.values.length > 0) {
                        for (let j = 0; j < nativePipewire.nodes.values.length; j++) {
                            const potentialNode = nativePipewire.nodes.values[j]
                            if (potentialNode && potentialNode.id === sink.id && potentialNode.isSink && potentialNode.audio) {
                                node = potentialNode
                                break
                            }
                        }
                    }
                    
                    if (!node && nativePipewire.nodes.count !== undefined) {
                        for (let j = 0; j < nativePipewire.nodes.count; j++) {
                            const potentialNode = nativePipewire.nodes.get(j)
                            if (potentialNode && potentialNode.id === sink.id && potentialNode.isSink && potentialNode.audio) {
                                node = potentialNode
                                break
                            }
                        }
                    }
                    
                    if (!node && nativePipewire.nodes.rowCount !== undefined) {
                        const count = nativePipewire.nodes.rowCount()
                        for (let j = 0; j < count; j++) {
                            const indexObj = nativePipewire.nodes.index(j, 0)
                            if (indexObj) {
                                const potentialNode = nativePipewire.nodes.data(indexObj)
                                if (potentialNode && potentialNode.id === sink.id && potentialNode.isSink && potentialNode.audio) {
                                    node = potentialNode
                                    break
                                }
                            }
                        }
                    }
                    
                    if (node) {
                        const newVolume = node.audio.volume || 1.0
                        const newMuted = node.audio.muted || false
                        
                        if (sink.volume !== newVolume || sink.muted !== newMuted) {
                            availableSinks[i].volume = newVolume
                            availableSinks[i].muted = newMuted
                            console.log("Pipewire service: Updated sink volume:", sink.name, newVolume, "muted:", newMuted)
                        }
                    }
                }
            }
            
            // Update source volumes
            for (let i = 0; i < availableSources.length; i++) {
                const source = availableSources[i]
                if (nativePipewire.nodes) {
                    let node = null
                    
                    // Try different ways to access nodes
                    if (nativePipewire.nodes.values && nativePipewire.nodes.values.length > 0) {
                        for (let j = 0; j < nativePipewire.nodes.values.length; j++) {
                            const potentialNode = nativePipewire.nodes.values[j]
                            if (potentialNode && potentialNode.id === source.id && potentialNode.name && potentialNode.name.includes("alsa_input") && potentialNode.audio) {
                                node = potentialNode
                                break
                            }
                        }
                    }
                    
                    if (!node && nativePipewire.nodes.count !== undefined) {
                        for (let j = 0; j < nativePipewire.nodes.count; j++) {
                            const potentialNode = nativePipewire.nodes.get(j)
                            if (potentialNode && potentialNode.id === source.id && potentialNode.name && potentialNode.name.includes("alsa_input") && potentialNode.audio) {
                                node = potentialNode
                                break
                            }
                        }
                    }
                    
                    if (!node && nativePipewire.nodes.rowCount !== undefined) {
                        const count = nativePipewire.nodes.rowCount()
                        for (let j = 0; j < count; j++) {
                            const indexObj = nativePipewire.nodes.index(j, 0)
                            if (indexObj) {
                                const potentialNode = nativePipewire.nodes.data(indexObj)
                                if (potentialNode && potentialNode.id === source.id && potentialNode.name && potentialNode.name.includes("alsa_input") && potentialNode.audio) {
                                    node = potentialNode
                                    break
                                }
                            }
                        }
                    }
                    
                    if (node) {
                        const newVolume = node.audio.volume || 1.0
                        const newMuted = node.audio.muted || false
                        
                        if (source.volume !== newVolume || source.muted !== newMuted) {
                            availableSources[i].volume = newVolume
                            availableSources[i].muted = newMuted
                            console.log("Pipewire service: Updated source volume:", source.name, newVolume, "muted:", newMuted)
                        }
                    }
                }
            }
            
            // Update application stream volumes
            for (let i = 0; i < applicationStreams.length; i++) {
                const stream = applicationStreams[i]
                if (nativePipewire.nodes) {
                    let node = null
                    
                    // Try different ways to access nodes
                    if (nativePipewire.nodes.values && nativePipewire.nodes.values.length > 0) {
                        for (let j = 0; j < nativePipewire.nodes.values.length; j++) {
                            const potentialNode = nativePipewire.nodes.values[j]
                            if (potentialNode && potentialNode.id === stream.id && potentialNode.isStream && potentialNode.audio) {
                                node = potentialNode
                                break
                            }
                        }
                    }
                    
                    if (!node && nativePipewire.nodes.count !== undefined) {
                        for (let j = 0; j < nativePipewire.nodes.count; j++) {
                            const potentialNode = nativePipewire.nodes.get(j)
                            if (potentialNode && potentialNode.id === stream.id && potentialNode.isStream && potentialNode.audio) {
                                node = potentialNode
                                break
                            }
                        }
                    }
                    
                    if (!node && nativePipewire.nodes.rowCount !== undefined) {
                        const count = nativePipewire.nodes.rowCount()
                        for (let j = 0; j < count; j++) {
                            const indexObj = nativePipewire.nodes.index(j, 0)
                            if (indexObj) {
                                const potentialNode = nativePipewire.nodes.data(indexObj)
                                if (potentialNode && potentialNode.id === stream.id && potentialNode.isStream && potentialNode.audio) {
                                    node = potentialNode
                                    break
                                }
                            }
                        }
                    }
                    
                    if (node) {
                        const newVolume = node.audio.volume || 1.0
                        const newMuted = node.audio.muted || false
                        
                        if (stream.volume !== newVolume || stream.muted !== newMuted) {
                            applicationStreams[i].volume = newVolume
                            applicationStreams[i].muted = newMuted
                            console.log("Pipewire service: Updated stream volume:", stream.name, newVolume, "muted:", newMuted)
                        }
                    }
                }
            }
            
            // Note: Qt automatically emits property change signals when properties change
            
        } catch (e) {
            console.log("Pipewire service: Error updating volume states:", e.message)
        }
    }
} 