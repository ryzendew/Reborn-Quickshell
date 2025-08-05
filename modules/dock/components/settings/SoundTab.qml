import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Services
import qs.Settings

Rectangle {
    color: "transparent"
    
    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: soundColumn.height + 40
        
        ColumnLayout {
            id: soundColumn
            width: parent.width
            spacing: 20
            
            // Output Devices Section
            Rectangle {
                Layout.fillWidth: true
                height: 200
                color: "#2a2a2a"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Label {
                            text: "Output Devices"
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: "Refresh"
                            background: Rectangle {
                                color: parent.pressed ? "#404040" : "#505050"
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                // Refresh audio devices
                                console.log("Refreshing output devices")
                            }
                        }
                    }
                    
                    // Default Output Device
                    Rectangle {
                        Layout.fillWidth: true
                        height: 60
                        color: "#1a1a1a"
                        radius: 6
                        border.color: "#404040"
                        border.width: 1
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12
                            
                            Image {
                                source: "file:///usr/share/icons/Adwaita/scalable/audio/audio-speakers-symbolic.svg"
                                width: 24
                                height: 24
                                fillMode: Image.PreserveAspectFit
                            }
                            
                            ColumnLayout {
                                spacing: 2
                                
                                Label {
                                    text: "Default Output"
                                    font.pixelSize: 12
                                    color: "#b0b0b0"
                                }
                                
                                ComboBox {
                                    id: defaultOutputCombo
                                    model: ["Built-in Audio Analog Stereo", "HDMI Audio Output", "USB Audio Device"]
                                    currentIndex: 0
                                    
                                    background: Rectangle {
                                        color: "#2a2a2a"
                                        radius: 4
                                        border.color: "#404040"
                                        border.width: 1
                                    }
                                    
                                    contentItem: Text {
                                        text: parent.displayText
                                        color: "white"
                                        font: parent.font
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: 8
                                        rightPadding: parent.indicator.width + parent.spacing
                                    }
                                    
                                    indicator: Rectangle {
                                        x: parent.width - width - parent.rightPadding
                                        y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                        width: 12
                                        height: 8
                                        color: "transparent"
                                        border.color: "#808080"
                                        border.width: 1
                                        radius: 2
                                    }
                                }
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            // Volume Slider
                            Slider {
                                id: defaultOutputVolume
                                from: 0
                                to: 100
                                value: 75
                                stepSize: 1
                                
                                background: Rectangle {
                                    x: defaultOutputVolume.leftPadding
                                    y: defaultOutputVolume.topPadding + defaultOutputVolume.availableHeight / 2 - height / 2
                                    width: defaultOutputVolume.availableWidth
                                    height: 4
                                    radius: 2
                                    color: "#404040"
                                    
                                    Rectangle {
                                        width: defaultOutputVolume.visualPosition * parent.width
                                        height: parent.height
                                        color: "#007acc"
                                        radius: 2
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: defaultOutputVolume.leftPadding + defaultOutputVolume.visualPosition * (defaultOutputVolume.availableWidth - width)
                                    y: defaultOutputVolume.topPadding + defaultOutputVolume.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: defaultOutputVolume.pressed ? "#ffffff" : "#f3f3f3"
                                    border.color: "#bdbdbd"
                                }
                            }
                            
                            Label {
                                text: defaultOutputVolume.value.toFixed(0) + "%"
                                font.pixelSize: 12
                                color: "white"
                                Layout.preferredWidth: 40
                            }
                            
                            Button {
                                text: defaultOutputMuted ? "🔇" : "🔊"
                                background: Rectangle {
                                    color: parent.pressed ? "#404040" : "#505050"
                                    radius: 4
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    defaultOutputMuted = !defaultOutputMuted
                                }
                            }
                        }
                        
                        property bool defaultOutputMuted: false
                    }
                    
                    // Available Output Devices List
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: ListModel {
                            ListElement { name: "Built-in Audio Analog Stereo"; port: "Speakers"; active: true }
                            ListElement { name: "HDMI Audio Output"; port: "HDMI"; active: false }
                            ListElement { name: "USB Audio Device"; port: "USB"; active: false }
                        }
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 50
                            color: model.active ? "#1a1a1a" : "transparent"
                            border.color: model.active ? "#007acc" : "transparent"
                            border.width: model.active ? 1 : 0
                            radius: 4
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 12
                                
                                Image {
                                    source: "file:///usr/share/icons/Adwaita/scalable/audio/audio-speakers-symbolic.svg"
                                    width: 20
                                    height: 20
                                    fillMode: Image.PreserveAspectFit
                                }
                                
                                ColumnLayout {
                                    spacing: 2
                                    
                                    Label {
                                        text: model.name
                                        font.pixelSize: 12
                                        color: "white"
                                    }
                                    
                                    Label {
                                        text: model.port
                                        font.pixelSize: 10
                                        color: "#b0b0b0"
                                    }
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Button {
                                    text: "Set Default"
                                    visible: !model.active
                                    background: Rectangle {
                                        color: parent.pressed ? "#404040" : "#505050"
                                        radius: 4
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "white"
                                        font.pixelSize: 10
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: {
                                        // Set as default output
                                        console.log("Setting", model.name, "as default output")
                                    }
                                }
                                
                                Label {
                                    text: "Default"
                                    font.pixelSize: 10
                                    color: "#007acc"
                                    visible: model.active
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    // Select this device
                                }
                            }
                        }
                    }
                }
            }
            
            // Input Devices Section
            Rectangle {
                Layout.fillWidth: true
                height: 200
                color: "#2a2a2a"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Label {
                            text: "Input Devices"
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: "Refresh"
                            background: Rectangle {
                                color: parent.pressed ? "#404040" : "#505050"
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                // Refresh audio devices
                                console.log("Refreshing input devices")
                            }
                        }
                    }
                    
                    // Default Input Device
                    Rectangle {
                        Layout.fillWidth: true
                        height: 60
                        color: "#1a1a1a"
                        radius: 6
                        border.color: "#404040"
                        border.width: 1
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12
                            
                            Image {
                                source: "file:///usr/share/icons/Adwaita/scalable/audio/audio-input-microphone-symbolic.svg"
                                width: 24
                                height: 24
                                fillMode: Image.PreserveAspectFit
                            }
                            
                            ColumnLayout {
                                spacing: 2
                                
                                Label {
                                    text: "Default Input"
                                    font.pixelSize: 12
                                    color: "#b0b0b0"
                                }
                                
                                ComboBox {
                                    id: defaultInputCombo
                                    model: ["Built-in Audio Analog Stereo", "USB Microphone", "Bluetooth Headset"]
                                    currentIndex: 0
                                    
                                    background: Rectangle {
                                        color: "#2a2a2a"
                                        radius: 4
                                        border.color: "#404040"
                                        border.width: 1
                                    }
                                    
                                    contentItem: Text {
                                        text: parent.displayText
                                        color: "white"
                                        font: parent.font
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: 8
                                        rightPadding: parent.indicator.width + parent.spacing
                                    }
                                    
                                    indicator: Rectangle {
                                        x: parent.width - width - parent.rightPadding
                                        y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                        width: 12
                                        height: 8
                                        color: "transparent"
                                        border.color: "#808080"
                                        border.width: 1
                                        radius: 2
                                    }
                                }
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            // Volume Slider
                            Slider {
                                id: defaultInputVolume
                                from: 0
                                to: 100
                                value: 50
                                stepSize: 1
                                
                                background: Rectangle {
                                    x: defaultInputVolume.leftPadding
                                    y: defaultInputVolume.topPadding + defaultInputVolume.availableHeight / 2 - height / 2
                                    width: defaultInputVolume.availableWidth
                                    height: 4
                                    radius: 2
                                    color: "#404040"
                                    
                                    Rectangle {
                                        width: defaultInputVolume.visualPosition * parent.width
                                        height: parent.height
                                        color: "#007acc"
                                        radius: 2
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: defaultInputVolume.leftPadding + defaultInputVolume.visualPosition * (defaultInputVolume.availableWidth - width)
                                    y: defaultInputVolume.topPadding + defaultInputVolume.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: defaultInputVolume.pressed ? "#ffffff" : "#f3f3f3"
                                    border.color: "#bdbdbd"
                                }
                            }
                            
                            Label {
                                text: defaultInputVolume.value.toFixed(0) + "%"
                                font.pixelSize: 12
                                color: "white"
                                Layout.preferredWidth: 40
                            }
                            
                            Button {
                                text: defaultInputMuted ? "🔇" : "🎤"
                                background: Rectangle {
                                    color: parent.pressed ? "#404040" : "#505050"
                                    radius: 4
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    defaultInputMuted = !defaultInputMuted
                                }
                            }
                        }
                        
                        property bool defaultInputMuted: false
                    }
                    
                    // Available Input Devices List
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: ListModel {
                            ListElement { name: "Built-in Audio Analog Stereo"; port: "Microphone"; active: true }
                            ListElement { name: "USB Microphone"; port: "USB"; active: false }
                            ListElement { name: "Bluetooth Headset"; port: "Bluetooth"; active: false }
                        }
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 50
                            color: model.active ? "#1a1a1a" : "transparent"
                            border.color: model.active ? "#007acc" : "transparent"
                            border.width: model.active ? 1 : 0
                            radius: 4
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 12
                                
                                Image {
                                    source: "file:///usr/share/icons/Adwaita/scalable/audio/audio-input-microphone-symbolic.svg"
                                    width: 20
                                    height: 20
                                    fillMode: Image.PreserveAspectFit
                                }
                                
                                ColumnLayout {
                                    spacing: 2
                                    
                                    Label {
                                        text: model.name
                                        font.pixelSize: 12
                                        color: "white"
                                    }
                                    
                                    Label {
                                        text: model.port
                                        font.pixelSize: 10
                                        color: "#b0b0b0"
                                    }
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Button {
                                    text: "Set Default"
                                    visible: !model.active
                                    background: Rectangle {
                                        color: parent.pressed ? "#404040" : "#505050"
                                        radius: 4
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "white"
                                        font.pixelSize: 10
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: {
                                        // Set as default input
                                        console.log("Setting", model.name, "as default input")
                                    }
                                }
                                
                                Label {
                                    text: "Default"
                                    font.pixelSize: 10
                                    color: "#007acc"
                                    visible: model.active
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    // Select this device
                                }
                            }
                        }
                    }
                }
            }
            
            // Volume Mixer Section
            Rectangle {
                Layout.fillWidth: true
                height: 300
                color: "#2a2a2a"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Label {
                            text: "Volume Mixer"
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        ComboBox {
                            id: mixerFilterCombo
                            model: ["All Applications", "Playing Audio", "System Sounds"]
                            currentIndex: 0
                            
                            background: Rectangle {
                                color: "#1a1a1a"
                                radius: 4
                                border.color: "#404040"
                                border.width: 1
                            }
                            
                            contentItem: Text {
                                text: parent.displayText
                                color: "white"
                                font: parent.font
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 8
                                rightPadding: parent.indicator.width + parent.spacing
                            }
                            
                            indicator: Rectangle {
                                x: parent.width - width - parent.rightPadding
                                y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                width: 12
                                height: 8
                                color: "transparent"
                                border.color: "#808080"
                                border.width: 1
                                radius: 2
                            }
                        }
                    }
                    
                    // Application Streams
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: ListModel {
                            ListElement { 
                                name: "Firefox"; 
                                icon: "🌐"; 
                                volume: 80; 
                                muted: false; 
                                output: "Built-in Audio";
                                playing: true 
                            }
                            ListElement { 
                                name: "Spotify"; 
                                icon: "🎵"; 
                                volume: 65; 
                                muted: false; 
                                output: "Built-in Audio";
                                playing: true 
                            }
                            ListElement { 
                                name: "System Sounds"; 
                                icon: "🔔"; 
                                volume: 45; 
                                muted: false; 
                                output: "Built-in Audio";
                                playing: false 
                            }
                            ListElement { 
                                name: "Discord"; 
                                icon: "💬"; 
                                volume: 90; 
                                muted: false; 
                                output: "Built-in Audio";
                                playing: true 
                            }
                        }
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 70
                            color: "transparent"
                            border.color: "#404040"
                            border.width: 1
                            radius: 6
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 12
                                
                                Text {
                                    text: model.icon
                                    font.pixelSize: 20
                                }
                                
                                ColumnLayout {
                                    spacing: 4
                                    
                                    Label {
                                        text: model.name
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: "white"
                                    }
                                    
                                    ComboBox {
                                        id: appOutputCombo
                                        model: ["Built-in Audio", "HDMI Audio", "USB Audio"]
                                        currentIndex: 0
                                        
                                        background: Rectangle {
                                            color: "#1a1a1a"
                                            radius: 4
                                            border.color: "#404040"
                                            border.width: 1
                                        }
                                        
                                        contentItem: Text {
                                            text: parent.displayText
                                            color: "white"
                                            font.pixelSize: 10
                                            verticalAlignment: Text.AlignVCenter
                                            leftPadding: 6
                                            rightPadding: parent.indicator.width + parent.spacing
                                        }
                                        
                                        indicator: Rectangle {
                                            x: parent.width - width - parent.rightPadding
                                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                            width: 8
                                            height: 6
                                            color: "transparent"
                                            border.color: "#808080"
                                            border.width: 1
                                            radius: 1
                                        }
                                    }
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                // Volume Slider
                                Slider {
                                    id: appVolumeSlider
                                    from: 0
                                    to: 100
                                    value: model.volume
                                    stepSize: 1
                                    
                                    background: Rectangle {
                                        x: appVolumeSlider.leftPadding
                                        y: appVolumeSlider.topPadding + appVolumeSlider.availableHeight / 2 - height / 2
                                        width: appVolumeSlider.availableWidth
                                        height: 4
                                        radius: 2
                                        color: "#404040"
                                        
                                        Rectangle {
                                            width: appVolumeSlider.visualPosition * parent.width
                                            height: parent.height
                                            color: model.playing ? "#007acc" : "#666666"
                                            radius: 2
                                        }
                                    }
                                    
                                    handle: Rectangle {
                                        x: appVolumeSlider.leftPadding + appVolumeSlider.visualPosition * (appVolumeSlider.availableWidth - width)
                                        y: appVolumeSlider.topPadding + appVolumeSlider.availableHeight / 2 - height / 2
                                        width: 14
                                        height: 14
                                        radius: 7
                                        color: appVolumeSlider.pressed ? "#ffffff" : "#f3f3f3"
                                        border.color: "#bdbdbd"
                                    }
                                }
                                
                                Label {
                                    text: appVolumeSlider.value.toFixed(0) + "%"
                                    font.pixelSize: 10
                                    color: "white"
                                    Layout.preferredWidth: 35
                                }
                                
                                Button {
                                    text: model.muted ? "🔇" : "🔊"
                                    background: Rectangle {
                                        color: parent.pressed ? "#404040" : "#505050"
                                        radius: 4
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: {
                                        // Toggle mute for this app
                                        console.log("Toggling mute for", model.name)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
} 