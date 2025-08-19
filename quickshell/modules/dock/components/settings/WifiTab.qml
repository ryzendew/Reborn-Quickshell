import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Services

Rectangle {
    id: wifiTab
    color: "transparent"
    
    // Main background behind everything
    Rectangle {
        anchors.fill: parent
        color: "#00747474"
        opacity: 0.6
        radius: 8
    }
    
    // WiFi connection properties
    property bool showPasswordDialog: false
    property string selectedNetwork: ""
    property string passwordInput: ""
    property bool isConnecting: false
    
    // Computed property to get the currently connected WiFi network
    property var connectedWifiNetwork: {
        for (const net in Network.networks) {
            if (Network.networks[net].connected && Network.networks[net].type === "wifi") {
                return Network.networks[net];
            }
        }
        return null;
    }
    
    // Auto-scan timer
    Timer {
        interval: 30000 // 30 seconds
        running: true
        repeat: true
        onTriggered: {
            Network.refreshNetworks();
        }
    }
    
    // Initial scan
    Component.onCompleted: {
        Network.refreshNetworks();
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
                implicitHeight: 32
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
                text: "Wi-Fi"
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
        
        // WiFi status section
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            color: "transparent"
            radius: 8
            border.color: "#33ffffff"
            border.width: 1
            
            // macOS Tahoe-style transparency effect
            Rectangle {
                anchors.fill: parent
                color: "#2a2a2a"
                opacity: 0.6
                radius: 8
            }
            
            // Dark mode backdrop
            Rectangle {
                anchors.fill: parent
                color: "#1a1a1a"
                opacity: 0.3
                radius: 8
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16
                
                ColumnLayout {
                    spacing: 4
                    
                    Text {
                        text: "Wi-Fi Status"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: "#ffffff"
                    }
                    
                    Text {
                        text: Network.hasActiveConnection ? "Connected to a network" : "Not connected"
                        font.pixelSize: 11
                        color: Network.hasActiveConnection ? "#00ff00" : "#ff4444"
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // Connection indicator
                Rectangle {
                    width: 36
                    height: 18
                    radius: 9
                    color: Network.hasActiveConnection ? "#4CAF50" : "#555555"
                    border.color: Network.hasActiveConnection ? "#4CAF50" : "#777777"
                    border.width: 1
                    
                    Rectangle {
                        width: 14
                        height: 14
                        radius: 7
                        color: "#ffffff"
                        anchors {
                            verticalCenter: parent.verticalCenter
                            right: Network.hasActiveConnection ? parent.right : parent.left
                            rightMargin: Network.hasActiveConnection ? 2 : undefined
                            leftMargin: Network.hasActiveConnection ? undefined : 2
                        }
                        
                        Behavior on anchors.rightMargin {
                            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                        }
                        Behavior on anchors.leftMargin {
                            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                        }
                    }
                    
                    Behavior on color {
                        ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
                    }
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
                    }
                }
            }
        }
        
        // Currently connected WiFi network display with blue overlay
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: "transparent"
            radius: 8
            border.color: "#33ffffff"
            border.width: 1
            visible: connectedWifiNetwork !== null
            
            // macOS Tahoe-style transparency effect
            Rectangle {
                anchors.fill: parent
                color: "#2a2a2a"
                opacity: 0.6
                radius: 8
            }
            
            // Dark mode backdrop
            Rectangle {
                anchors.fill: parent
                color: "#481a1a1a"
                opacity: 0.3
                radius: 8
            }
            
            // Blue semi-transparent overlay
            Rectangle {
                anchors.fill: parent
                color: "#330099ff"
                radius: 8
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16
                
                // WiFi icon with signal strength
                Text {
                    text: Network.signalIcon(connectedWifiNetwork ? connectedWifiNetwork.signal || 0 : 0)
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 32
                    color: "#ffffff"
                    Layout.alignment: Qt.AlignVCenter
                }
                
                // Connected network info
                ColumnLayout {
                    spacing: 4
                    
                    Text {
                        text: "Connected to"
                        font.pixelSize: 12
                        color: "#cccccc"
                    }
                    
                    Text {
                        text: connectedWifiNetwork ? connectedWifiNetwork.ssid || "Unknown Network" : ""
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    Text {
                        text: connectedWifiNetwork ? (connectedWifiNetwork.security || "Open") + " • " + (connectedWifiNetwork.signal || 0) + "%" : ""
                        font.pixelSize: 11
                        color: "#cccccc"
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // Connection status indicator
                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    color: "#4CAF50"
                    border.color: "#ffffff"
                    border.width: 2
                    
                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: "#ffffff"
                        anchors.centerIn: parent
                    }
                }
            }
        }
        
        // Available networks list
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            radius: 8
            border.color: "#33ffffff"
            border.width: 1
            
            // macOS Tahoe-style transparency effect
            Rectangle {
                anchors.fill: parent
                color: "#2a2a2a"
                opacity: 0.6
                radius: 8
            }
            
            // Dark mode backdrop
            Rectangle {
                anchors.fill: parent
                color: "#1a1a1a"
                opacity: 0.3
                radius: 8
            }
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12
                
                // Networks header
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: "Networks"
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
                        color: refreshArea.containsMouse ? "#333333" : "transparent"
                        border.color: refreshArea.containsMouse ? "#555555" : "transparent"
                        border.width: 1
                        
                        Text {
                            anchors.centerIn: parent
                            text: "refresh"
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: 18
                            color: "#cccccc"
                        }
                        
                        MouseArea {
                            id: refreshArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                Network.refreshNetworks();
                            }
                        }
                    }
                }
                
                // Networks list
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    // Show loading or no networks message when no networks
                    Rectangle {
                        anchors.fill: parent
                        color: "#1a1a1a"
                        radius: 8
                        visible: Object.keys(Network.networks).length === 0
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            
                            Text {
                                text: "wifi_off"
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 32
                                color: "#666666"
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "No networks found"
                                font.pixelSize: 14
                                color: "#666666"
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "Try refreshing to scan for networks"
                                font.pixelSize: 12
                                color: "#444444"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                    
                    ListView {
                        id: networksList
                        width: parent.width
                        height: parent.height
                        spacing: 8
                        model: Object.keys(Network.networks).map(key => Network.networks[key])
                        visible: Object.keys(Network.networks).length > 0
                        
                        delegate: Rectangle {
                            width: networksList ? networksList.width : 400
                            height: 64
                            color: networkArea.containsMouse ? "#333333" : "transparent"
                            radius: 8
                            border.color: networkArea.containsMouse ? "#555555" : "transparent"
                            border.width: 1
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 12
                                
                                // Signal strength icon
                                Text {
                                    text: Network.signalIcon(modelData.signal || 0)
                                    font.family: "Material Symbols Outlined"
                                    font.pixelSize: 24
                                    color: modelData.connected ? "#4CAF50" : "#cccccc"
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                
                                // Network info
                                ColumnLayout {
                                    spacing: 2
                                    
                                    Text {
                                        text: modelData.ssid || "Unknown Network"
                                        font.pixelSize: 14
                                        font.weight: modelData.connected ? Font.Medium : Font.Normal
                                        color: "#ffffff"
                                    }
                                    
                                    Text {
                                        text: modelData.security || "Open"
                                        font.pixelSize: 11
                                        color: "#cccccc"
                                    }
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                // Connection status
                                Text {
                                    text: modelData.connected ? "check_circle" : "radio_button_unchecked"
                                    font.family: "Material Symbols Outlined"
                                    font.pixelSize: 18
                                    color: modelData.connected ? "#4CAF50" : "#cccccc"
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }
                            
                            MouseArea {
                                id: networkArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    if (!modelData.connected && !Network.connectingSsid) {
                                        selectedNetwork = modelData.ssid || "";
                                        if (modelData.security === "--" || !Network.isSecured(modelData.security)) {
                                            Network.connectNetwork(modelData.ssid || "", modelData.security || "");
                                        } else {
                                            showPasswordDialog = true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Connection status display
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            color: "transparent"
            radius: 8
            border.color: "#33ffffff"
            border.width: 1
            visible: Network.connectingSsid || Network.connectStatus
            
            // macOS Tahoe-style transparency effect
            Rectangle {
                anchors.fill: parent
                color: "#2a2a2a"
                opacity: 0.6
                radius: 8
            }
            
            // Dark mode backdrop
            Rectangle {
                anchors.fill: parent
                color: "#1a1a1a"
                opacity: 0.3
                radius: 8
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12
                
                Text {
                    text: Network.connectingSsid ? "refresh" : (Network.connectStatus === "success" ? "check_circle" : "error")
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 20
                    color: Network.connectingSsid ? "#ffaa00" : (Network.connectStatus === "success" ? "#4CAF50" : "#ff4444")
                }
                
                Text {
                    text: Network.connectingSsid ? "Connecting to " + Network.connectingSsid + "..." : 
                          (Network.connectStatus === "success" ? "Successfully connected to " + Network.connectStatusSsid : 
                           "Connection failed: " + Network.connectError)
                    font.pixelSize: 14
                    color: "#ffffff"
                    Layout.fillWidth: true
                }
            }
        }
    }
    
    // Password dialog
    Dialog {
        id: passwordDialog
        title: ""
        modal: true
        visible: showPasswordDialog
        anchors.centerIn: parent
        width: 340
        height: 220
        
        background: Rectangle {
            color: "transparent"
            radius: 12
            border.color: "#33ffffff"
            border.width: 1
            
            // macOS Tahoe-style transparency effect
            Rectangle {
                anchors.fill: parent
                color: "#1a1a1a"
                opacity: 0.6
                radius: 12
            }
            
            // Dark mode backdrop
            Rectangle {
                anchors.fill: parent
                color: "#0a0a0a"
                opacity: 0.3
                radius: 12
            }
        }
        
        onVisibleChanged: {
            if (visible) {
                passwordInput = "";
                passwordField.forceActiveFocus();
            }
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16
            
            // Dialog title
            Text {
                text: "Connect to " + selectedNetwork
                font.pixelSize: 16
                font.weight: Font.Bold
                color: "#ffffff"
                Layout.alignment: Qt.AlignHCenter
            }
            
            // Password input
            TextField {
                id: passwordField
                Layout.fillWidth: true
                placeholderText: "Password"
                echoMode: TextInput.Password
                text: passwordInput
                onTextChanged: passwordInput = text
                onAccepted: connectButton.clicked()
                focus: true
                
                color: "#ffffff"
                selectionColor: "#5700eeff"
                selectedTextColor: "#ffffff"
                
                background: Rectangle {
                    color: "transparent"
                    radius: 8
                    border.color: "#33ffffff"
                    border.width: 1
                    
                    // macOS Tahoe-style transparency effect
                    Rectangle {
                        anchors.fill: parent
                        color: "#2a2a2a"
                        opacity: 0.8
                        radius: 8
                    }
                    
                    // Dark mode backdrop
                    Rectangle {
                        anchors.fill: parent
                        color: "#1a1a1a"
                        opacity: 0.3
                        radius: 8
                    }
                }
            }
            
            // Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "Cancel"
                    onClicked: {
                        showPasswordDialog = false;
                        selectedNetwork = "";
                    }
                    
                    background: Rectangle {
                        color: "transparent"
                        radius: 8
                        border.color: "#33ffffff"
                        border.width: 1
                        
                        // macOS Tahoe-style transparency effect
                        Rectangle {
                            anchors.fill: parent
                            color: "#2a2a2a"
                            opacity: 0.6
                            radius: 8
                        }
                        
                        // Dark mode backdrop
                        Rectangle {
                            anchors.fill: parent
                            color: "#1a1a1a"
                            opacity: 0.3
                            radius: 8
                        }
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    id: connectButton
                    text: "Connect"
                    enabled: passwordInput.length > 0
                    onClicked: {
                        Network.submitPassword(selectedNetwork, passwordInput);
                        showPasswordDialog = false;
                        selectedNetwork = "";
                    }
                    
                    background: Rectangle {
                        color: "transparent"
                        radius: 8
                        border.color: enabled ? "#7700eeff" : "#33ffffff"
                        border.width: 1
                        
                        // macOS Tahoe-style transparency effect
                        Rectangle {
                            anchors.fill: parent
                            color: enabled ? "#5700eeff" : "#2a2a2a"
                            opacity: 0.8
                            radius: 8
                        }
                        
                        // Dark mode backdrop
                        Rectangle {
                            anchors.fill: parent
                            color: enabled ? "#3300eeff" : "#1a1a1a"
                            opacity: 0.3
                            radius: 8
                        }
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: enabled ? "#ffffff" : "#888888"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
} 