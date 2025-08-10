import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Services

Rectangle {
    id: soundTab
    color: "transparent"
    
    // Main background behind everything
    Rectangle {
        anchors.fill: parent
        color: "#00747474"
        opacity: 0.8
        radius: 8
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16
        
        // Content header with navigation
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            spacing: 16
            
            // Back button
            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: backMouseArea.containsMouse ? "#333333" : "transparent"
                border.color: backMouseArea.containsMouse ? "#555555" : "transparent"
                border.width: 1
                
                Text {
                    anchors.centerIn: parent
                    text: "arrow_back"
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 18
                    color: "#cccccc"
                }
                
                MouseArea {
                    id: backMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
            
            // Forward button
            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: forwardMouseArea.containsMouse ? "#333333" : "transparent"
                border.color: forwardMouseArea.containsMouse ? "#555555" : "transparent"
                border.width: 1
                
                Text {
                    anchors.centerIn: parent
                    text: "arrow_forward"
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 18
                    color: "#cccccc"
                }
                
                MouseArea {
                    id: forwardMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
            
            // Page title
            Text {
                text: "Sound"
                font.pixelSize: 18
                font.weight: Font.Bold
                color: "#ffffff"
                Layout.fillWidth: true
            }
            
            // Help button
            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: helpMouseArea.containsMouse ? "#333333" : "transparent"
                border.color: helpMouseArea.containsMouse ? "#555555" : "transparent"
                border.width: 1
                
                Text {
                    anchors.centerIn: parent
                    text: "help"
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 18
                    color: "#cccccc"
                }
                
                MouseArea {
                    id: helpMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
        }
        
        // Tab bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: "#333333"
            radius: 8
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 0
                
                // Devices tab button
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 120
                    color: tabBar.currentIndex === 0 ? "#555555" : "transparent"
                    radius: 6
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Devices"
                        font.pixelSize: 14
                        font.weight: tabBar.currentIndex === 0 ? Font.Bold : Font.Normal
                        color: "#ffffff"
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: tabBar.currentIndex = 0
                    }
                }
                
                // Applications tab button
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 120
                    color: tabBar.currentIndex === 1 ? "#555555" : "transparent"
                    radius: 6
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Applications"
                        font.pixelSize: 14
                        font.weight: tabBar.currentIndex === 1 ? Font.Bold : Font.Normal
                        color: "#ffffff"
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: tabBar.currentIndex = 1
                    }
                }
            }
        }
        
        // Tab content
        TabBar {
            id: tabBar
            currentIndex: 0
            visible: false // Hide the actual TabBar, we use custom buttons above
        }
        
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex
            
            // Devices tab
            Rectangle {
                color: "transparent"
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 20
                    
                    // Output devices section
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: outputDevicesColumn.height + 80
                        color: "#333333"
                        radius: 8
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 16
                            
                            // Section header
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                
                                Text {
                                    text: "volume_up"
                                    font.family: "Material Symbols Outlined"
                                    font.pixelSize: 24
                                    color: "#4CAF50"
                                }
                                
                                Text {
                                    text: "Output Devices"
                                    font.pixelSize: 18
                                    font.weight: Font.Bold
                                    color: "#ffffff"
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                // Refresh button
                                Rectangle {
                                    width: 32
                                    height: 32
                                    radius: 16
                                    color: refreshMouseArea.containsMouse ? "#555555" : "transparent"
                                    border.color: refreshMouseArea.containsMouse ? "#4CAF50" : "#666666"
                                    border.width: 2
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "refresh"
                                        font.family: "Material Symbols Outlined"
                                        font.pixelSize: 16
                                        color: "#4CAF50"
                                    }
                                    
                                    MouseArea {
                                        id: refreshMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            if (Pipewire && typeof Pipewire.refreshAll === 'function') {
                                                try {
                                                    Pipewire.refreshAll()
                                                } catch (e) {
                                                    console.log("SoundTab: Error refreshing output devices:", e.message)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Output devices list
                            ColumnLayout {
                                id: outputDevicesColumn
                                Layout.fillWidth: true
                                spacing: 16
                                
                                Repeater {
                                    model: Pipewire.availableSinks
                                    
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 100
                                        color: "#444444"
                                        radius: 8
                                        
                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: 16
                                            spacing: 12
                                            
                                            // Device header row
                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 12
                                                
                                                // Device icon
                                                Text {
                                                    text: "speaker"
                                                    font.family: "Material Symbols Outlined"
                                                    font.pixelSize: 24
                                                    color: "#4CAF50"
                                                }
                                                
                                                // Device info
                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 4
                                                    
                                                    Text {
                                                        text: modelData.description || modelData.name
                                                        font.pixelSize: 16
                                                        font.weight: Font.Medium
                                                        color: "#ffffff"
                                                        elide: Text.ElideRight
                                                    }
                                                    
                                                    Text {
                                                        text: modelData.isDefault ? "Default Output Device" : "Available Output Device"
                                                        font.pixelSize: 12
                                                        color: modelData.isDefault ? "#4CAF50" : "#888888"
                                                    }
                                                }
                                                
                                                // Mute button
                                                Rectangle {
                                                    width: 36
                                                    height: 36
                                                    radius: 18
                                                    color: muteMouseArea.containsMouse ? "#555555" : "transparent"
                                                    border.color: modelData.muted ? "#f44336" : "#666666"
                                                    border.width: 2
                                                    
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData.muted ? "volume_off" : "volume_up"
                                                        font.family: "Material Symbols Outlined"
                                                        font.pixelSize: 18
                                                        color: modelData.muted ? "#f44336" : "#cccccc"
                                                    }
                                                    
                                                    MouseArea {
                                                        id: muteMouseArea
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        onClicked: {
                                                            if (Pipewire && typeof Pipewire.setSinkMuteById === 'function') {
                                                                try {
                                                                    Pipewire.setSinkMuteById(modelData.id, !modelData.muted)
                                                                } catch (e) {
                                                                    console.log("SoundTab: Error setting sink mute:", e.message)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                // Set as default button
                                                Rectangle {
                                                    width: 36
                                                    height: 36
                                                    radius: 18
                                                    color: defaultMouseArea.containsMouse ? "#555555" : "transparent"
                                                    border.color: modelData.isDefault ? "#4CAF50" : "#666666"
                                                    border.width: 2
                                                    
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "check_circle"
                                                        font.family: "Material Symbols Outlined"
                                                        font.pixelSize: 18
                                                        color: modelData.isDefault ? "#4CAF50" : "#cccccc"
                                                    }
                                                    
                                                    MouseArea {
                                                        id: defaultMouseArea
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        onClicked: {
                                                            if (Pipewire && typeof Pipewire.setDefaultSink === 'function') {
                                                                try {
                                                                    Pipewire.setDefaultSink(modelData.id)
                                                                } catch (e) {
                                                                    console.log("SoundTab: Error setting default sink:", e.message)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            // Volume control row
                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 16
                                                
                                                // Volume label
                                                Text {
                                                    text: "Volume"
                                                    font.pixelSize: 14
                                                    font.weight: Font.Medium
                                                    color: "#cccccc"
                                                    Layout.preferredWidth: 60
                                                }
                                                
                                                // Volume slider
                                                Slider {
                                                    id: outputVolumeSlider
                                                    Layout.fillWidth: true
                                                    value: modelData.volume || 0
                                                    from: 0
                                                    to: 1
                                                    stepSize: 0.01
                                                    activeFocusOnTab: true
                                                    enabled: true
                                                    focus: true
                                                    hoverEnabled: true
                                                    live: true
                                                    snapMode: Slider.SnapOnRelease
                                                    
                                                    onValueChanged: {
                                                        if (modelData.id && Pipewire && typeof Pipewire.setSinkVolumeById === 'function') {
                                                            try {
                                                                Pipewire.setSinkVolumeById(modelData.id, value)
                                                            } catch (e) {
                                                                console.log("SoundTab: Error setting sink volume:", e.message)
                                                            }
                                                        }
                                                    }
                                                    
                                                    onPressedChanged: {
                                                        console.log("Output slider pressed:", pressed)
                                                    }
                                                    
                                                    onMoved: {
                                                        console.log("Output slider moved to:", value)
                                                    }
                                                    
                                                    background: Rectangle {
                                                        x: outputVolumeSlider.leftPadding
                                                        y: outputVolumeSlider.topPadding + outputVolumeSlider.availableHeight / 2 - height / 2
                                                        width: outputVolumeSlider.availableWidth
                                                        height: 6
                                                        radius: 3
                                                        color: "#555555"
                                                        
                                                        Rectangle {
                                                            width: outputVolumeSlider.visualPosition * parent.width
                                                            height: parent.height
                                                            color: "#4CAF50"
                                                            radius: 3
                                                        }
                                                    }
                                                    
                                                    handle: Rectangle {
                                                        x: outputVolumeSlider.leftPadding + outputVolumeSlider.visualPosition * (outputVolumeSlider.availableWidth - width)
                                                        y: outputVolumeSlider.topPadding + outputVolumeSlider.availableHeight / 2 - height / 2
                                                        width: 20
                                                        height: 20
                                                        radius: 10
                                                        color: outputVolumeSlider.pressed ? "#4CAF50" : "#ffffff"
                                                        border.color: "#4CAF50"
                                                        border.width: 2
                                                    }
                                                }
                                                
                                                // Volume percentage display
                                                Text {
                                                    text: Math.round((modelData.volume || 0) * 100) + "%"
                                                    font.pixelSize: 14
                                                    font.weight: Font.Bold
                                                    color: "#4CAF50"
                                                    Layout.preferredWidth: 50
                                                    horizontalAlignment: Text.AlignRight
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // No devices message
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 80
                                    color: "#444444"
                                    radius: 8
                                    visible: Pipewire.availableSinks.length === 0
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "No output devices found"
                                        font.pixelSize: 16
                                        color: "#888888"
                                    }
                                }
                            }
                        }
                    }
                    
                    // Input devices section
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: inputDevicesColumn.height + 80
                        color: "#333333"
                        radius: 8
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 16
                            
                            // Section header
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                
                                Text {
                                    text: "mic"
                                    font.family: "Material Symbols Outlined"
                                    font.pixelSize: 24
                                    color: "#2196F3"
                                }
                                
                                Text {
                                    text: "Input Devices"
                                    font.pixelSize: 18
                                    font.weight: Font.Bold
                                    color: "#ffffff"
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                // Refresh button
                                Rectangle {
                                    width: 32
                                    height: 32
                                    radius: 16
                                    color: refreshInputMouseArea.containsMouse ? "#555555" : "transparent"
                                    border.color: refreshInputMouseArea.containsMouse ? "#2196F3" : "#666666"
                                    border.width: 2
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "refresh"
                                        font.family: "Material Symbols Outlined"
                                        font.pixelSize: 16
                                        color: "#2196F3"
                                    }
                                    
                                    MouseArea {
                                        id: refreshInputMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            if (Pipewire && typeof Pipewire.refreshAll === 'function') {
                                                try {
                                                    Pipewire.refreshAll()
                                                } catch (e) {
                                                    console.log("SoundTab: Error refreshing input devices:", e.message)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Input devices list
                            ColumnLayout {
                                id: inputDevicesColumn
                                Layout.fillWidth: true
                                spacing: 16
                                
                                Repeater {
                                    model: Pipewire.availableSources
                                    
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 100
                                        color: "#444444"
                                        radius: 8
                                        
                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: 16
                                            spacing: 12
                                            
                                            // Device header row
                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 12
                                                
                                                // Device icon
                                                Text {
                                                    text: "mic"
                                                    font.family: "Material Symbols Outlined"
                                                    font.pixelSize: 24
                                                    color: "#2196F3"
                                                }
                                                
                                                // Device info
                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 4
                                                    
                                                    Text {
                                                        text: modelData.description || modelData.name
                                                        font.pixelSize: 16
                                                        font.weight: Font.Medium
                                                        color: "#ffffff"
                                                        elide: Text.ElideRight
                                                    }
                                                    
                                                    Text {
                                                        text: modelData.isDefault ? "Default Input Device" : "Available Input Device"
                                                        font.pixelSize: 12
                                                        color: modelData.isDefault ? "#2196F3" : "#888888"
                                                    }
                                                }
                                                
                                                // Mute button
                                                Rectangle {
                                                    width: 36
                                                    height: 36
                                                    radius: 18
                                                    color: muteMouseArea.containsMouse ? "#555555" : "transparent"
                                                    border.color: modelData.muted ? "#f44336" : "#666666"
                                                    border.width: 2
                                                    
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData.muted ? "mic_off" : "mic"
                                                        font.family: "Material Symbols Outlined"
                                                        font.pixelSize: 18
                                                        color: modelData.muted ? "#f44336" : "#cccccc"
                                                    }
                                                    
                                                    MouseArea {
                                                        id: muteMouseArea
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        onClicked: {
                                                            if (Pipewire && typeof Pipewire.setSourceMuteById === 'function') {
                                                                try {
                                                                    Pipewire.setSourceMuteById(modelData.id, !modelData.muted)
                                                                } catch (e) {
                                                                    console.log("SoundTab: Error setting source mute:", e.message)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                // Set as default button
                                                Rectangle {
                                                    width: 36
                                                    height: 36
                                                    radius: 18
                                                    color: defaultMouseArea.containsMouse ? "#555555" : "transparent"
                                                    border.color: modelData.isDefault ? "#2196F3" : "#666666"
                                                    border.width: 2
                                                    
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "check_circle"
                                                        font.family: "Material Symbols Outlined"
                                                        font.pixelSize: 18
                                                        color: modelData.isDefault ? "#2196F3" : "#cccccc"
                                                    }
                                                    
                                                    MouseArea {
                                                        id: defaultMouseArea
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        onClicked: {
                                                            if (Pipewire && typeof Pipewire.setDefaultSource === 'function') {
                                                                try {
                                                                    Pipewire.setDefaultSource(modelData.id)
                                                                } catch (e) {
                                                                    console.log("SoundTab: Error setting default source:", e.message)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            // Volume control row
                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 16
                                                
                                                // Volume label
                                                Text {
                                                    text: "Volume"
                                                    font.pixelSize: 14
                                                    font.weight: Font.Medium
                                                    color: "#cccccc"
                                                    Layout.preferredWidth: 60
                                                }
                                                
                                                // Volume slider
                                                Slider {
                                                    id: inputVolumeSlider
                                                    Layout.fillWidth: true
                                                    value: modelData.volume || 0
                                                    from: 0
                                                    to: 1
                                                    stepSize: 0.01
                                                    activeFocusOnTab: true
                                                    enabled: true
                                                    focus: true
                                                    hoverEnabled: true
                                                    live: true
                                                    snapMode: Slider.SnapOnRelease
                                                    
                                                    onValueChanged: {
                                                        if (modelData.id && Pipewire && typeof Pipewire.setSourceVolumeById === 'function') {
                                                            try {
                                                                Pipewire.setSourceVolumeById(modelData.id, value)
                                                            } catch (e) {
                                                                console.log("SoundTab: Error setting source volume:", e.message)
                                                            }
                                                        }
                                                    }
                                                    
                                                    onPressedChanged: {
                                                        console.log("Input slider pressed:", pressed)
                                                    }
                                                    
                                                    onMoved: {
                                                        console.log("Input slider moved to:", value)
                                                    }
                                                    
                                                    background: Rectangle {
                                                        x: inputVolumeSlider.leftPadding
                                                        y: inputVolumeSlider.topPadding + inputVolumeSlider.availableHeight / 2 - height / 2
                                                        width: inputVolumeSlider.availableWidth
                                                        height: 6
                                                        radius: 3
                                                        color: "#555555"
                                                        
                                                        Rectangle {
                                                            width: inputVolumeSlider.visualPosition * parent.width
                                                            height: parent.height
                                                            color: "#2196F3"
                                                            radius: 3
                                                        }
                                                    }
                                                    
                                                    handle: Rectangle {
                                                        x: inputVolumeSlider.leftPadding + inputVolumeSlider.visualPosition * (inputVolumeSlider.availableWidth - width)
                                                        y: inputVolumeSlider.topPadding + inputVolumeSlider.availableHeight / 2 - height / 2
                                                        width: 20
                                                        height: 20
                                                        radius: 10
                                                        color: inputVolumeSlider.pressed ? "#2196F3" : "#ffffff"
                                                        border.color: "#2196F3"
                                                        border.width: 2
                                                    }
                                                }
                                                
                                                // Volume percentage display
                                                Text {
                                                    text: Math.round((modelData.volume || 0) * 100) + "%"
                                                    font.pixelSize: 14
                                                    font.weight: Font.Bold
                                                    color: "#2196F3"
                                                    Layout.preferredWidth: 50
                                                    horizontalAlignment: Text.AlignRight
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // No devices message
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 80
                                    color: "#444444"
                                    radius: 8
                                    visible: Pipewire.availableSources.length === 0
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "No input devices found"
                                        font.pixelSize: 16
                                        color: "#888888"
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Applications tab
            Rectangle {
                color: "transparent"
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 16
                    
                    // Applications header
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        color: "#333333"
                        radius: 8
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 12
                            
                            Text {
                                text: "apps"
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 24
                                color: "#FF9800"
                            }
                            
                            Text {
                                text: "Application Volume Mixer"
                                font.pixelSize: 18
                                font.weight: Font.Bold
                                color: "#ffffff"
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            // Refresh button
                            Rectangle {
                                width: 32
                                height: 32
                                radius: 16
                                color: refreshAppMouseArea.containsMouse ? "#555555" : "transparent"
                                border.color: refreshAppMouseArea.containsMouse ? "#FF9800" : "#666666"
                                border.width: 2
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "refresh"
                                    font.family: "Material Symbols Outlined"
                                    font.pixelSize: 16
                                    color: "#FF9800"
                                }
                                
                                MouseArea {
                                    id: refreshAppMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        if (Pipewire && typeof Pipewire.refreshAll === 'function') {
                                            try {
                                                Pipewire.refreshAll()
                                            } catch (e) {
                                                console.log("SoundTab: Error refreshing applications:", e.message)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Applications list
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#333333"
                        radius: 8
                        
                        ScrollView {
                            anchors.fill: parent
                            anchors.margins: 20
                            
                            ColumnLayout {
                                width: parent.width
                                spacing: 16
                                
                                Repeater {
                                    model: Pipewire.applicationStreams
                                    
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 200
                                        color: "#444444"
                                        radius: 8
                                        
                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: 16
                                            spacing: 12
                                            
                                            // App header row
                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 12
                                                
                                                // App icon using IconService
                                                Image {
                                                    width: 32
                                                    height: 32
                                                    source: IconService.getIconPath(getAppIdentifier(modelData))
                                                    fillMode: Image.PreserveAspectFit
                                                    smooth: true
                                                    mipmap: true
                                                    
                                                    // Fallback to Material Symbol if icon not found
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "audio"
                                                        font.family: "Material Symbols Outlined"
                                                        font.pixelSize: 24
                                                        color: "#FF9800"
                                                        visible: parent.status !== Image.Ready
                                                    }
                                                }
                                                
                                                // App info
                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 4
                                                    
                                                    Text {
                                                        text: getAppDisplayName(modelData)
                                                        font.pixelSize: 16
                                                        font.weight: Font.Medium
                                                        color: "#ffffff"
                                                    }
                                                    
                                                    Text {
                                                        text: modelData.description || modelData.originalName || ""
                                                        font.pixelSize: 12
                                                        color: "#888888"
                                                        elide: Text.ElideRight
                                                    }
                                                }
                                                
                                                // Mute button
                                                Rectangle {
                                                    width: 36
                                                    height: 36
                                                    radius: 18
                                                    color: muteMouseArea.containsMouse ? "#555555" : "transparent"
                                                    border.color: modelData.muted ? "#f44336" : "#666666"
                                                    border.width: 2
                                                    
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData.muted ? "volume_off" : "volume_up"
                                                        font.family: "Material Symbols Outlined"
                                                        font.pixelSize: 18
                                                        color: modelData.muted ? "#f44336" : "#cccccc"
                                                    }
                                                    
                                                    MouseArea {
                                                        id: muteMouseArea
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        onClicked: {
                                                            if (Pipewire && typeof Pipewire.setApplicationMute === 'function') {
                                                                try {
                                                                    Pipewire.setApplicationMute(modelData.id, !modelData.muted)
                                                                } catch (e) {
                                                                    console.log("SoundTab: Error setting application mute:", e.message)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            // Volume control row
                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 16
                                                
                                                // Volume label
                                                Text {
                                                    text: "Volume"
                                                    font.pixelSize: 14
                                                    font.weight: Font.Medium
                                                    color: "#cccccc"
                                                    Layout.preferredWidth: 60
                                                }
                                                
                                                // Volume slider
                                                Slider {
                                                    id: appVolumeSlider
                                                    Layout.fillWidth: true
                                                    value: modelData.volume || 0
                                                    from: 0
                                                    to: 1
                                                    stepSize: 0.01
                                                    activeFocusOnTab: true
                                                    enabled: true
                                                    focus: true
                                                    hoverEnabled: true
                                                    
                                                    onValueChanged: {
                                                        if (modelData.id && Pipewire && typeof Pipewire.setApplicationVolume === 'function') {
                                                            try {
                                                                Pipewire.setApplicationVolume(modelData.id, value)
                                                            } catch (e) {
                                                                console.log("SoundTab: Error setting application volume:", e.message)
                                                            }
                                                        }
                                                    }
                                                    
                                                    onPressedChanged: {
                                                        console.log("App slider pressed:", pressed)
                                                    }
                                                    
                                                    onMoved: {
                                                        console.log("App slider moved to:", value)
                                                    }
                                                    
                                                    background: Rectangle {
                                                        x: appVolumeSlider.leftPadding
                                                        y: appVolumeSlider.topPadding + appVolumeSlider.availableHeight / 2 - height / 2
                                                        width: appVolumeSlider.availableWidth
                                                        height: 6
                                                        radius: 3
                                                        color: "#555555"
                                                        
                                                        Rectangle {
                                                            width: appVolumeSlider.visualPosition * parent.width
                                                            height: parent.height
                                                            color: "#FF9800"
                                                            radius: 3
                                                        }
                                                    }
                                                    
                                                    handle: Rectangle {
                                                        x: appVolumeSlider.leftPadding + appVolumeSlider.visualPosition * (appVolumeSlider.availableWidth - width)
                                                        y: appVolumeSlider.topPadding + appVolumeSlider.availableHeight / 2 - height / 2
                                                        width: 20
                                                        height: 20
                                                        radius: 10
                                                        color: appVolumeSlider.pressed ? "#FF9800" : "#ffffff"
                                                        border.color: "#FF9800"
                                                        border.width: 2
                                                    }
                                                }
                                                
                                                // Volume percentage display
                                                Text {
                                                    text: Math.round((modelData.volume || 0) * 100) + "%"
                                                    font.pixelSize: 14
                                                    font.weight: Font.Bold
                                                    color: "#FF9800"
                                                    Layout.preferredWidth: 50
                                                    horizontalAlignment: Text.AlignRight
                                                }
                                            }
                                            
                                            // Output device selection row
                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 16
                                                
                                                // Device label
                                                Text {
                                                    text: "Output"
                                                    font.pixelSize: 14
                                                    font.weight: Font.Medium
                                                    color: "#cccccc"
                                                    Layout.preferredWidth: 60
                                                }
                                                
                                                // Output device selector
                                                ComboBox {
                                                    Layout.fillWidth: true
                                                    model: ["Default"] + Pipewire.availableSinks.map(sink => sink.description || sink.name)
                                                    currentIndex: 0
                                                    
                                                    onActivated: {
                                                        if (currentText === "Default") {
                                                            // Use system default
                                                            return
                                                        }
                                                        
                                                        if (Pipewire && typeof Pipewire.getSinkByName === 'function' && typeof Pipewire.moveApplicationToSink === 'function') {
                                                            try {
                                                                const sink = Pipewire.getSinkByName(currentText)
                                                                if (sink) {
                                                                    Pipewire.moveApplicationToSink(modelData.id, sink.id)
                                                                }
                                                            } catch (e) {
                                                                console.log("SoundTab: Error moving application to sink:", e.message)
                                                            }
                                                        }
                                                    }
                                                    
                                                    background: Rectangle {
                                                        color: "#555555"
                                                        radius: 4
                                                        border.color: "#666666"
                                                        border.width: 1
                                                    }
                                                    
                                                    contentItem: Text {
                                                        text: parent.displayText
                                                        font.pixelSize: 12
                                                        color: "#ffffff"
                                                        verticalAlignment: Text.AlignVCenter
                                                        horizontalAlignment: Text.AlignLeft
                                                        leftPadding: 8
                                                    }
                                                    
                                                    popup: Popup {
                                                        y: parent.height
                                                        width: parent.width
                                                        implicitHeight: contentItem.implicitHeight
                                                        padding: 1
                                                        
                                                        contentItem: ListView {
                                                            clip: true
                                                            model: parent.parent.model
                                                            delegate: Rectangle {
                                                                width: parent.width
                                                                height: 30
                                                                color: ListView.isCurrentItem ? "#666666" : "transparent"
                                                                
                                                                Text {
                                                                    anchors.centerIn: parent
                                                                    text: modelData
                                                                    font.pixelSize: 12
                                                                    color: "#ffffff"
                                                                }
                                                                
                                                                MouseArea {
                                                                    anchors.fill: parent
                                                                    onClicked: {
                                                                        parent.parent.parent.currentIndex = index
                                                                        parent.parent.parent.popup.close()
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        
                                                        background: Rectangle {
                                                            color: "#444444"
                                                            border.color: "#666666"
                                                            border.width: 1
                                                            radius: 4
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // No applications message
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 80
                                    color: "#444444"
                                    radius: 8
                                    visible: Pipewire.applicationStreams.length === 0
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "No applications found"
                                        font.pixelSize: 16
                                        color: "#888888"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Helper functions for application identification and display
    function getAppIdentifier(appData) {
        // Try to get the best identifier for IconService
        if (appData.metadata && appData.metadata["application.name"]) {
            return appData.metadata["application.name"]
        }
        if (appData.metadata && appData.metadata["app.name"]) {
            return appData.metadata["app.name"]
        }
        if (appData.metadata && appData.metadata["application.process.name"]) {
            return appData.metadata["application.process.name"]
        }
        if (appData.metadata && appData.metadata["process.name"]) {
            return appData.metadata["process.name"]
        }
        
        // Fallback to name or originalName
        let appName = appData.name || appData.originalName || ""
        
        // Clean up the name for better icon matching
        if (appName.includes(".")) {
            // Remove process ID and other suffixes
            appName = appName.split(".")[0]
        }
        
        return appName
    }
    
    function getAppDisplayName(appData) {
        // Try to get a clean display name
        if (appData.metadata && appData.metadata["application.name"]) {
            return appData.metadata["application.name"]
        }
        if (appData.metadata && appData.metadata["app.name"]) {
            return appData.metadata["app.name"]
        }
        
        // Fallback to processed name
        let appName = appData.name || appData.originalName || "Unknown App"
        
        // Clean up the name for display
        if (appName.includes(".")) {
            // Remove process ID and other suffixes
            appName = appName.split(".")[0]
        }
        
        // Capitalize first letter
        if (appName.length > 0) {
            appName = appName.charAt(0).toUpperCase() + appName.slice(1)
        }
        
        return appName
    }
    
    Component.onCompleted: {
        // Wait a bit for the Pipewire service to initialize
        Qt.setTimeout(() => {
            if (Pipewire && typeof Pipewire.refreshAll === 'function') {
                console.log("SoundTab: Pipewire service ready, refreshing devices")
                Pipewire.refreshAll()
            } else {
                console.log("SoundTab: Pipewire service not ready yet")
            }
        }, 500)
    }
}
