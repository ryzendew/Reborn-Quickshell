import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Services

Rectangle {
    id: bluetoothTab
    color: "transparent"
    
    property var connectedDeviceHistory: []
    property var deviceList: []
    property bool loadingDevices: false
    property string pairingDevice: ""
    
    function updateConnectedDeviceHistory() {
        // Add new connected devices to history
        for (let i = 0; i < Bluetooth.connectedDevices.length; ++i) {
            let addr = Bluetooth.connectedDevices[i].address;
            if (!connectedDeviceHistory.some(d => d.address === addr)) {
                connectedDeviceHistory.push(Bluetooth.connectedDevices[i]);
            }
        }
        // Update connection status for all in history
        for (let i = 0; i < connectedDeviceHistory.length; ++i) {
            let addr = connectedDeviceHistory[i].address;
            connectedDeviceHistory[i].connected = Bluetooth.connectedDevices.some(d => d.address === addr);
        }
    }
    
    function refreshDevices() {
        loadingDevices = true;
        Bluetooth.update();
        // Simulate loading delay
        loadingTimer.start();
    }
    
    Timer {
        id: loadingTimer
        interval: 2000
        onTriggered: {
            loadingDevices = false;
            updateConnectedDeviceHistory();
        }
    }
    
    Component.onCompleted: {
        refreshDevices();
    }
    
    Connections {
        target: Bluetooth
        function onConnectedDevicesChanged() {
            updateConnectedDeviceHistory()
        }
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
                text: "Bluetooth"
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
                    text: "info"
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
        
        // Main content area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#2a2a2a"
            radius: 12
            border.color: "#33ffffff"
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16
                
                // Header with toggle
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    radius: 8
                    color: "#333333"
                    border.color: "#44ffffff"
                    border.width: 1
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12
                        
                        // Bluetooth toggle button
                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: bluetoothToggleMouseArea.containsMouse ? "#5700eeff" : (Bluetooth.bluetoothEnabled ? "#2196F3" : "#666666")
                            border.color: bluetoothToggleMouseArea.containsMouse ? "#7700eeff" : "#44ffffff"
                            border.width: 1
                            
                            Text {
                                anchors.centerIn: parent
                                text: Bluetooth.bluetoothConnected ? "bluetooth_connected" : Bluetooth.bluetoothEnabled ? "bluetooth" : "bluetooth_disabled"
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 20
                                color: "#ffffff"
                            }
                            
                            MouseArea {
                                id: bluetoothToggleMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    if (Bluetooth.bluetoothEnabled) {
                                        Bluetooth.powerOff()
                                    } else {
                                        Bluetooth.powerOn()
                                    }
                                }
                            }
                        }
                        
                        ColumnLayout {
                            spacing: 2
                            
                            Text {
                                text: "Bluetooth"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#ffffff"
                            }
                            
                            Text {
                                text: Bluetooth.bluetoothEnabled ? (Bluetooth.bluetoothConnected ? "Connected" : "On") : "Off"
                                font.pixelSize: 12
                                color: Bluetooth.bluetoothEnabled ? "#4CAF50" : "#888888"
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Status indicator
                        Text {
                            text: Bluetooth.scanning ? "Scanning..." : ""
                            font.pixelSize: 12
                            color: "#888888"
                            visible: Bluetooth.bluetoothEnabled && Bluetooth.scanning
                        }
                    }
                }
                
                // Device list container
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 8
                    color: "#333333"
                    border.color: "#44ffffff"
                    border.width: 1
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12
                        
                        // Connected Devices Section
                        Column {
                            spacing: 8
                            visible: Bluetooth.connectedDevices.length > 0
                            
                            Text {
                                text: "Connected Devices"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#ffffff"
                            }
                            
                            Repeater {
                                model: Bluetooth.connectedDevices
                                delegate: Rectangle {
                                    width: parent.width
                                    height: 60
                                    radius: 6
                                    color: "#444444"
                                    border.color: "#2196F3"
                                    border.width: 1
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 12
                                        
                                        Text {
                                            text: "bluetooth_connected"
                                            font.family: "Material Symbols Outlined"
                                            font.pixelSize: 20
                                            color: "#2196F3"
                                        }
                                        
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2
                                            
                                            Text {
                                                text: modelData ? (modelData.name || "Unknown Device") : "Unknown Device"
                                                font.pixelSize: 14
                                                font.weight: Font.Medium
                                                color: "#ffffff"
                                            }
                                            
                                            Text {
                                                text: (modelData ? modelData.address : "") + 
                                                      (modelData && modelData.type ? " • " + modelData.type : "") + 
                                                      " • Connected"
                                                font.pixelSize: 12
                                                color: "#2196F3"
                                            }
                                        }
                                        
                                        Item { Layout.fillWidth: true }
                                        
                                        // Action buttons
                                        RowLayout {
                                            spacing: 8
                                            
                                            Rectangle {
                                                width: 80
                                                height: 32
                                                radius: 16
                                                color: disconnectMouseArea.containsMouse ? "#ff4444" : "#444444"
                                                border.color: disconnectMouseArea.containsMouse ? "#ff6666" : "#666666"
                                                border.width: 1
                                                
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "Disconnect"
                                                    font.pixelSize: 12
                                                    font.weight: Font.Medium
                                                    color: "#ffffff"
                                                }
                                                
                                                MouseArea {
                                                    id: disconnectMouseArea
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    onClicked: {
                                                        Bluetooth.disconnectDevice(modelData.address)
                                                    }
                                                }
                                            }
                                            
                                            Rectangle {
                                                width: 60
                                                height: 32
                                                radius: 16
                                                color: removeMouseArea.containsMouse ? "#ff4444" : "#444444"
                                                border.color: removeMouseArea.containsMouse ? "#ff6666" : "#666666"
                                                border.width: 1
                                                
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "Forget"
                                                    font.pixelSize: 12
                                                    font.weight: Font.Medium
                                                    color: "#ffffff"
                                                }
                                                
                                                MouseArea {
                                                    id: removeMouseArea
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    onClicked: {
                                                        Bluetooth.removeDevice(modelData.address)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Device list header
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Text {
                                text: "All Devices"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#ffffff"
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            // Scan button
                            Rectangle {
                                width: 80
                                height: 32
                                radius: 16
                                color: scanMouseArea.containsMouse ? "#5700eeff" : "#444444"
                                border.color: scanMouseArea.containsMouse ? "#7700eeff" : "#666666"
                                border.width: 1
                                enabled: Bluetooth.bluetoothEnabled && !Bluetooth.scanning
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: Bluetooth.scanning ? "Scanning..." : "Scan"
                                    font.pixelSize: 12
                                    color: "#ffffff"
                                }
                                
                                MouseArea {
                                    id: scanMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        if (Bluetooth.bluetoothEnabled && !Bluetooth.scanning) {
                                            Bluetooth.startScan()
                                        }
                                    }
                                }
                            }
                            
                            // Discoverable toggle
                            Rectangle {
                                width: 32
                                height: 32
                                radius: 16
                                color: discoverableMouseArea.containsMouse ? "#5700eeff" : (Bluetooth.discoverable ? "#4CAF50" : "#444444")
                                border.color: discoverableMouseArea.containsMouse ? "#7700eeff" : "#666666"
                                border.width: 1
                                enabled: Bluetooth.bluetoothEnabled
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: Bluetooth.discoverable ? "visibility" : "visibility_off"
                                    font.family: "Material Symbols Outlined"
                                    font.pixelSize: 16
                                    color: "#ffffff"
                                }
                                
                                MouseArea {
                                    id: discoverableMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        if (Bluetooth.bluetoothEnabled) {
                                            Bluetooth.setDiscoverable(!Bluetooth.discoverable)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Device list
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            
                            ListView {
                                id: deviceListView
                                spacing: 8
                                boundsBehavior: Flickable.StopAtBounds
                                
                                // Combine all device lists
                                model: (function() {
                                    let seen = {};
                                    let out = [];
                                    
                                    // Process connected devices first
                                    for (let i = 0; i < Bluetooth.connectedDevices.length; ++i) {
                                        let d = Bluetooth.connectedDevices[i];
                                        if (!seen[d.address]) {
                                            seen[d.address] = true;
                                            d.paired = true;
                                            d.connected = true;
                                            out.push(d);
                                        }
                                    }
                                    
                                    // Process paired devices (but not connected)
                                    for (let i = 0; i < Bluetooth.pairedDevices.length; ++i) {
                                        let d = Bluetooth.pairedDevices[i];
                                        if (!seen[d.address]) {
                                            seen[d.address] = true;
                                            d.paired = true;
                                            d.connected = false;
                                            out.push(d);
                                        }
                                    }
                                    
                                    // Process available devices (not paired)
                                    for (let i = 0; i < Bluetooth.availableDevices.length; ++i) {
                                        let d = Bluetooth.availableDevices[i];
                                        if (!seen[d.address]) {
                                            seen[d.address] = true;
                                            d.paired = false;
                                            d.connected = false;
                                            out.push(d);
                                        }
                                    }
                                    
                                    return out;
                                })()
                                
                                // Show message when no devices
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: parent.width - 16
                                    height: 60
                                    color: "transparent"
                                    visible: !deviceListView.count || deviceListView.count === 0
                                    
                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 8
                                        
                                        Text {
                                            text: Bluetooth.scanning ? "Scanning for devices..." : "No devices found"
                                            font.pixelSize: 14
                                            color: "#888888"
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                        
                                        Text {
                                            text: Bluetooth.scanning ? "" : "Click Scan to search for devices"
                                            font.pixelSize: 12
                                            color: "#666666"
                                            horizontalAlignment: Text.AlignHCenter
                                            visible: !Bluetooth.scanning
                                        }
                                    }
                                }
                                
                                delegate: Rectangle {
                                    width: parent.width
                                    height: 60
                                    radius: 6
                                    color: modelData && modelData.connected ? "#444444" : (deviceMouseArea.containsMouse ? "#3a3a3a" : "#333333")
                                    border.color: modelData && modelData.connected ? "#2196F3" : "#44ffffff"
                                    border.width: 1
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 12
                                        
                                        Text {
                                            text: modelData && modelData.connected ? "bluetooth_connected" : "bluetooth"
                                            font.family: "Material Symbols Outlined"
                                            font.pixelSize: 20
                                            color: modelData && modelData.connected ? "#2196F3" : "#888888"
                                        }
                                        
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2
                                            
                                            Text {
                                                text: modelData ? (modelData.name || "Unknown Device") : "Unknown Device"
                                                font.pixelSize: 14
                                                font.weight: modelData && modelData.connected ? Font.Medium : Font.Normal
                                                color: modelData && modelData.connected ? "#2196F3" : "#ffffff"
                                            }
                                            
                                            Text {
                                                text: (modelData ? modelData.address : "") + 
                                                      (modelData && modelData.type ? " • " + modelData.type : "") + 
                                                      (modelData && modelData.connected ? " • Connected" : 
                                                       modelData && modelData.paired ? " • Paired" : " • Available")
                                                font.pixelSize: 12
                                                color: modelData && modelData.connected ? "#2196F3" : "#888888"
                                            }
                                        }
                                        
                                        Item { Layout.fillWidth: true }
                                        
                                        // Action buttons
                                        RowLayout {
                                            spacing: 8
                                            
                                            // Connect/Disconnect button
                                            Rectangle {
                                                id: connectButton
                                                width: 80
                                                height: 32
                                                radius: 16
                                                color: connectMouseArea.containsMouse ? "#5700eeff" : "#444444"
                                                border.color: connectMouseArea.containsMouse ? "#7700eeff" : "#666666"
                                                border.width: 1
                                                
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: pairingDevice === modelData.address ? "Pairing..." : 
                                                          (modelData && modelData.connected ? "Disconnect" : "Connect")
                                                    font.pixelSize: 12
                                                    font.weight: Font.Medium
                                                    color: "#ffffff"
                                                }
                                                
                                                MouseArea {
                                                    id: connectMouseArea
                                                    width: 80
                                                    height: 32
                                                    anchors.centerIn: connectButton
                                                    hoverEnabled: true
                                                    onPressed: {
                                                        console.log("Bluetooth: Connect button pressed")
                                                    }
                                                    onClicked: {
                                                        if (!modelData || !modelData.address) {
                                                            console.log("Bluetooth: No device data or address")
                                                            return;
                                                        }
                                                        
                                                        console.log("Bluetooth: Button clicked for device:", modelData.address, "connected:", modelData.connected, "paired:", modelData.paired)
                                                        
                                                        if (modelData.connected) {
                                                            // Disconnect
                                                            console.log("Bluetooth: Disconnecting device:", modelData.address)
                                                            Bluetooth.disconnectDevice(modelData.address)
                                                        } else {
                                                            // Try to connect (this will pair if needed)
                                                            console.log("Bluetooth: Connecting device:", modelData.address)
                                                            pairingDevice = modelData.address;
                                                            Bluetooth.connectDevice(modelData.address)
                                                            // Reset pairing status after delay
                                                            pairingTimer.start()
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            // Forget button
                                            Rectangle {
                                                id: forgetButton
                                                width: 60
                                                height: 32
                                                radius: 16
                                                color: forgetMouseArea.containsMouse ? "#ff4444" : "#444444"
                                                border.color: forgetMouseArea.containsMouse ? "#ff6666" : "#666666"
                                                border.width: 1
                                                
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "Forget"
                                                    font.pixelSize: 12
                                                    font.weight: Font.Medium
                                                    color: "#ffffff"
                                                }
                                                
                                                MouseArea {
                                                    id: forgetMouseArea
                                                    width: 60
                                                    height: 32
                                                    anchors.centerIn: forgetButton
                                                    hoverEnabled: true
                                                    onClicked: {
                                                        if (!modelData || !modelData.address) return;
                                                        Bluetooth.removeDevice(modelData.address)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    MouseArea {
                                        id: deviceMouseArea
                                        anchors.fill: parent
                                        anchors.rightMargin: 160
                                        hoverEnabled: true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    Timer {
        id: pairingTimer
        interval: 5000
        onTriggered: {
            pairingDevice = "";
        }
    }
} 