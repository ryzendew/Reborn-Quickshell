import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Services

Item {
    id: root
    
    Component.onCompleted: {
        console.log("VolumeMixer component loaded")
        console.log("Pipewire service available:", typeof Pipewire !== 'undefined')
        if (typeof Pipewire !== 'undefined') {
            console.log("Pipewire sink volume:", Pipewire.sinkVolume)
            console.log("Pipewire sink name:", Pipewire.sinkName)
            console.log("Pipewire sink description:", Pipewire.sinkDescription)
        }
    }
    
    function wrapAfterWords(str, n) {
        if (!str) return "";
        var words = str.split(/\s+/);
        var lines = [];
        for (var i = 0; i < words.length; i += n) {
            lines.push(words.slice(i, i + n).join(" "));
        }
        return lines.join("\n");
    }
    
    property bool showDeviceSelector: false
    property bool deviceSelectorInput
    property int dialogMargins: 16
    property var selectedDevice
    property var deviceSelectorTargetNode: null // null = system, or a node for per-app
    property string deviceSelectorMode: "system" // "system" or "app"
    
    function showDeviceSelectorDialog(input) {
        root.selectedDevice = null
        root.showDeviceSelector = true
        root.deviceSelectorInput = input
        root.deviceSelectorTargetNode = null;
        root.deviceSelectorMode = "system";
    }
    
    function showAppDeviceSelectorDialog(node) {
        root.selectedDevice = null;
        root.showDeviceSelector = true;
        root.deviceSelectorInput = false;
        root.deviceSelectorTargetNode = node;
        root.deviceSelectorMode = "app";
    }
    
    Keys.onPressed: (event) => {
        // Close dialog on pressing Esc if open
        if (event.key === Qt.Key_Escape && root.showDeviceSelector) {
            root.showDeviceSelector = false
            event.accepted = true;
        }
    }
    
    // Track audio objects - using local Pipewire service
    ColumnLayout {
        anchors.fill: parent
        spacing: 8
        
        // Device Header Section
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 110
            radius: 8
            color: "#2a2a2a"
            border.color: "#33ffffff"
            border.width: 1
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 0
                anchors.leftMargin: 4
                spacing: 0
                
                // Output Section
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    anchors.margins: 0
                    spacing: 4
                    
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 6
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "speaker"
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: 16
                            color: "#ffffff"
                            opacity: 0.85
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Output"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: "#cccccc"
                        }
                    }
                    
                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: Pipewire.sinkDescription || Pipewire.sinkName || "No device"
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        color: "#ffffff"
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                    }
                }
                
                // Divider
                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                    color: "#33ffffff"
                }
                
                // Input Section
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    anchors.margins: 0
                    spacing: 4
                    
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 6
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "mic"
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: 16
                            color: "#ffffff"
                            opacity: 0.85
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Input"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: "#cccccc"
                        }
                    }
                    
                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: Pipewire.sourceDescription || Pipewire.sourceName || "No device"
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        color: "#ffffff"
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                    }
                }
            }
        }
        
        // Main Audio Controls Section
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            radius: 8
            color: "#2a2a2a"
            border.color: "#33ffffff"
            border.width: 1
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12
                
                // Output Control
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        
                        Text {
                            text: "speaker"
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: 16
                            color: "#ffffff"
                        }
                        
                        Text {
                            text: "Output"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: "#ffffff"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Device selector button for output
                        Rectangle {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            radius: 10
                            color: outputCogMouseArea.containsMouse ? "#33ffffff" : "transparent"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "settings"
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 16
                                color: "#ffffff"
                                opacity: 0.7
                            }
                            
                            MouseArea {
                                id: outputCogMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    root.showDeviceSelectorDialog(false) // false = output device
                                }
                            }
                        }
                        
                        Text {
                            text: Math.round((Pipewire.sinkVolume ?? 0) * 100) + "%"
                            font.pixelSize: 12
                            color: "#ffffff"
                            opacity: 0.7
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        
                        Slider {
                            id: outputSlider
                            Layout.fillWidth: true
                            from: 0
                            to: 1.0
                            value: Pipewire.sinkVolume ?? 0
                            enabled: !(Pipewire.sinkMuted ?? false)
                            opacity: (Pipewire.sinkMuted ?? false) ? 0.5 : 1.0
                            
                            onValueChanged: {
                                Pipewire.setSinkVolume(value)
                            }
                            
                            background: Rectangle {
                                x: outputSlider.leftPadding
                                y: outputSlider.topPadding + outputSlider.availableHeight / 2 - height / 2
                                width: outputSlider.availableWidth
                                height: 4
                                radius: 2
                                color: "#404040"
                                
                                Rectangle {
                                    width: outputSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: "#007acc"
                                    radius: 2
                                }
                            }
                            
                            handle: Rectangle {
                                x: outputSlider.leftPadding + outputSlider.visualPosition * (outputSlider.availableWidth - width)
                                y: outputSlider.topPadding + outputSlider.availableHeight / 2 - height / 2
                                width: 16
                                height: 16
                                radius: 8
                                color: outputSlider.pressed ? "#ffffff" : "#f3f3f3"
                                border.color: "#bdbdbd"
                            }
                        }
                        
                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 16
                            color: (Pipewire.sinkMuted ?? false) ? "#e74c3c" : "#33ffffff"
                            border.color: "#33ffffff"
                            border.width: 1
                            
                            Text {
                                anchors.centerIn: parent
                                text: (Pipewire.sinkMuted ?? false) ? "volume_off" : "volume_up"
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 16
                                color: (Pipewire.sinkMuted ?? false) ? "white" : "#ffffff"
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    Pipewire.setSinkMuted(!Pipewire.sinkMuted)
                                }
                            }
                        }
                    }
                }
                
                // Separator
                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                    color: "#33ffffff"
                }
                
                // Input Control
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        
                        Text {
                            text: "mic"
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: 16
                            color: "#ffffff"
                        }
                        
                        Text {
                            text: "Input"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: "#ffffff"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Device selector button for input
                        Rectangle {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            radius: 10
                            color: inputCogMouseArea.containsMouse ? "#33ffffff" : "transparent"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "settings"
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 16
                                color: "#ffffff"
                                opacity: 0.7
                            }
                            
                            MouseArea {
                                id: inputCogMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    root.showDeviceSelectorDialog(true) // true = input device
                                }
                            }
                        }
                        
                        Text {
                            text: Math.round((Pipewire.sourceVolume ?? 0) * 100) + "%"
                            font.pixelSize: 12
                            color: "#ffffff"
                            opacity: 0.7
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        
                        Slider {
                            id: inputSlider
                            Layout.fillWidth: true
                            from: 0
                            to: 1.0
                            value: Pipewire.sourceVolume ?? 0
                            enabled: !(Pipewire.sourceMuted ?? false)
                            opacity: (Pipewire.sourceMuted ?? false) ? 0.5 : 1.0
                            
                            onValueChanged: {
                                Pipewire.setSourceVolume(value)
                            }
                            
                            background: Rectangle {
                                x: inputSlider.leftPadding
                                y: inputSlider.topPadding + inputSlider.availableHeight / 2 - height / 2
                                width: inputSlider.availableWidth
                                height: 4
                                radius: 2
                                color: "#404040"
                                
                                Rectangle {
                                    width: inputSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: "#007acc"
                                    radius: 2
                                }
                            }
                            
                            handle: Rectangle {
                                x: inputSlider.leftPadding + inputSlider.visualPosition * (inputSlider.availableWidth - width)
                                y: inputSlider.topPadding + inputSlider.availableHeight / 2 - height / 2
                                width: 16
                                height: 16
                                radius: 8
                                color: inputSlider.pressed ? "#ffffff" : "#f3f3f3"
                                border.color: "#bdbdbd"
                            }
                        }
                        
                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 16
                            color: (Pipewire.sourceMuted ?? false) ? "#e74c3c" : "#33ffffff"
                            border.color: "#33ffffff"
                            border.width: 1
                            
                            Text {
                                anchors.centerIn: parent
                                text: (Pipewire.sourceMuted ?? false) ? "mic_off" : "mic"
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 16
                                color: (Pipewire.sourceMuted ?? false) ? "white" : "#ffffff"
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    Pipewire.setSourceMuted(!Pipewire.sourceMuted)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Application Streams Section
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: "#2a2a2a"
            border.color: "#33ffffff"
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    Text {
                        text: "Application Streams"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    // Refresh button
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: refreshStreamsArea.containsMouse ? "#33ffffff" : "transparent"
                        border.color: "#33ffffff"
                        border.width: 1
                        
                        Text {
                            anchors.centerIn: parent
                            text: "refresh"
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: 16
                            color: "#ffffff"
                        }
                        
                        MouseArea {
                            id: refreshStreamsArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                console.log("Manual refresh clicked")
                                if (typeof Pipewire !== 'undefined') {
                                    console.log("Calling Pipewire.refreshAll()")
                                    Pipewire.refreshAll()
                                } else {
                                    console.log("Pipewire service not available!")
                                }
                            }
                        }
                    }
                    
                    Text {
                        text: "Audio Controls"
                        font.pixelSize: 12
                        color: "#ffffff"
                        opacity: 0.7
                    }
                    
                    // Test button
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: testButtonArea.containsMouse ? "#33ffffff" : "transparent"
                        border.color: "#33ffffff"
                        border.width: 1
                        
                        Text {
                            anchors.centerIn: parent
                            text: "bug_report"
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: 16
                            color: "#ffffff"
                        }
                        
                        MouseArea {
                            id: testButtonArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                console.log("=== PIPEWIRE DEBUG INFO ===")
                                console.log("Pipewire service available:", typeof Pipewire !== 'undefined')
                                if (typeof Pipewire !== 'undefined') {
                                    console.log("Sink volume:", Pipewire.sinkVolume)
                                    console.log("Sink name:", Pipewire.sinkName)
                                    console.log("Sink description:", Pipewire.sinkDescription)
                                    console.log("Source volume:", Pipewire.sourceVolume)
                                    console.log("Source name:", Pipewire.sourceName)
                                    console.log("Source description:", Pipewire.sourceDescription)
                                }
                                console.log("==========================")
                            }
                        }
                    }
                }
                

                
                // Simple status display
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "transparent"
                    border.color: "#404040"
                    border.width: 1
                    radius: 6
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 4
                        
                        Text {
                            text: "Audio System Status"
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            color: "#ffffff"
                        }
                        
                        Text {
                            text: "Output: " + (Pipewire.sinkDescription || Pipewire.sinkName || "No device")
                            font.pixelSize: 12
                            color: "#cccccc"
                        }
                        
                        Text {
                            text: "Input: " + (Pipewire.sourceDescription || Pipewire.sourceName || "No device")
                            font.pixelSize: 12
                            color: "#cccccc"
                        }
                    }
                }
            }
        }
    }
    
    // Device selector dialog
    Item {
        anchors.fill: parent
        z: 9999
        visible: root.showDeviceSelector
        
        Rectangle {
            // Scrim
            id: scrimOverlay
            anchors.fill: parent
            radius: 8
            color: "#80000000"
            
            MouseArea {
                hoverEnabled: true
                anchors.fill: parent
                preventStealing: true
                propagateComposedEvents: false
                onClicked: {
                    root.showDeviceSelector = false
                }
            }
        }
        
        Rectangle {
            // The dialog
            id: dialog
            color: "#1a1a1a"
            radius: 12
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 30
            implicitHeight: dialogColumnLayout.implicitHeight
            border.color: "#33ffffff"
            border.width: 1
            
            transform: Scale {
                origin.x: dialog.width / 2
                origin.y: dialog.height / 2
                xScale: root.showDeviceSelector ? 1 : 0.9
                yScale: xScale
                
                Behavior on xScale {
                    NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                }
            }
            
            ColumnLayout {
                id: dialogColumnLayout
                anchors.fill: parent
                spacing: 16
                
                Text {
                    id: dialogTitle
                    Layout.topMargin: dialogMargins
                    Layout.leftMargin: dialogMargins
                    Layout.rightMargin: dialogMargins
                    Layout.alignment: Qt.AlignLeft
                    color: "#ffffff"
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    text: `Select ${root.deviceSelectorInput ? "input" : "output"} device`
                }
                
                Rectangle {
                    color: "#33ffffff"
                    implicitHeight: 1
                    Layout.fillWidth: true
                    Layout.leftMargin: dialogMargins
                    Layout.rightMargin: dialogMargins
                }
                
                ScrollView {
                    id: dialogFlickable
                    Layout.fillWidth: true
                    clip: true
                    implicitHeight: Math.min(scrimOverlay.height - dialogMargins * 8 - dialogTitle.height - dialogButtonsRowLayout.height, devicesColumnLayout.implicitHeight)
                    contentHeight: devicesColumnLayout.implicitHeight
                    
                    ColumnLayout {
                        id: devicesColumnLayout
                        anchors.fill: parent
                        Layout.fillWidth: true
                        spacing: 0
                        
                        Repeater {
                            model: root.deviceSelectorInput ? Pipewire.availableSources : Pipewire.availableSinks
                            
                            delegate: Rectangle {
                                Layout.leftMargin: root.dialogMargins
                                Layout.rightMargin: root.dialogMargins
                                Layout.fillWidth: true
                                implicitHeight: 40
                                color: radioButton.checked ? "#33ffffff" : "transparent"
                                radius: 6
                                
                                RadioButton {
                                    id: radioButton
                                    anchors.fill: parent
                                    checked: root.deviceSelectorInput ? 
                                             (modelData.id === Pipewire.sourceId) : 
                                             (modelData.id === Pipewire.sinkId)
                                    
                                    onCheckedChanged: {
                                        if (checked) {
                                            root.selectedDevice = modelData
                                        }
                                    }
                                    
                                    indicator: Rectangle {
                                        x: parent.leftPadding
                                        y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                        width: 20
                                        height: 20
                                        radius: 10
                                        border.color: radioButton.checked ? "#007acc" : "#666666"
                                        border.width: 2
                                        color: "transparent"
                                        
                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: radioButton.checked ? 10 : 4
                                            height: radioButton.checked ? 10 : 4
                                            radius: 5
                                            color: "#007acc"
                                            opacity: radioButton.checked ? 1 : 0
                                            
                                            Behavior on opacity {
                                                NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                                            }
                                            
                                            Behavior on width {
                                                NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                                            }
                                            
                                            Behavior on height {
                                                NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                                            }
                                        }
                                    }
                                    
                                    contentItem: Text {
                                        text: modelData.description
                                        color: "#ffffff"
                                        font.pixelSize: 14
                                        leftPadding: radioButton.indicator.width + radioButton.spacing
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            radioButton.checked = true
                                        }
                                    }
                                }
                            }
                        }
                        
                        Item { implicitHeight: dialogMargins }
                    }
                }
                
                Rectangle {
                    color: "#33ffffff"
                    implicitHeight: 1
                    Layout.fillWidth: true
                    Layout.leftMargin: dialogMargins
                    Layout.rightMargin: dialogMargins
                }
                
                RowLayout {
                    id: dialogButtonsRowLayout
                    Layout.bottomMargin: dialogMargins
                    Layout.leftMargin: dialogMargins
                    Layout.rightMargin: dialogMargins
                    Layout.alignment: Qt.AlignRight
                    spacing: 12
                    
                    Button {
                        text: "Cancel"
                        onClicked: {
                            root.showDeviceSelector = false
                            root.deviceSelectorTargetNode = null;
                            root.deviceSelectorMode = "system";
                        }
                        
                        background: Rectangle {
                            color: parent.pressed ? "#404040" : "#505050"
                            radius: 6
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    Button {
                        text: "OK"
                        onClicked: {
                            root.showDeviceSelector = false
                            if (root.selectedDevice) {
                                if (root.deviceSelectorInput) {
                                    Pipewire.setDefaultSource(root.selectedDevice.id)
                                } else {
                                    Pipewire.setDefaultSink(root.selectedDevice.id)
                                }
                            }
                            root.deviceSelectorTargetNode = null;
                            root.deviceSelectorMode = "system";
                        }
                        
                        background: Rectangle {
                            color: parent.pressed ? "#404040" : "#007acc"
                            radius: 6
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }
} 