import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Services

Rectangle {
    id: wifiTab
    color: "transparent"
    
    // WiFi connection properties
    property bool showPasswordDialog: false
    property string selectedNetwork: ""
    property string passwordInput: ""
    property bool isConnecting: false
    
    // Auto-scan timer
    Timer {
        interval: 30000 // 30 seconds
        running: Network.wifiEnabled
        repeat: true
        onTriggered: {
            if (Network.wifiEnabled) {
                Network.scanNetworks();
            }
        }
    }
    
    // Initial scan
    Component.onCompleted: {
        if (Network.wifiEnabled) {
            Network.scanNetworks();
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
        
        // WiFi toggle section
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            color: "#2a2a2a"
            radius: 8
            border.color: "#33ffffff"
            border.width: 1
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16
                
                ColumnLayout {
                    spacing: 4
                    
                    Text {
                        text: "Wi-Fi"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: "#ffffff"
                    }
                    
                    Text {
                        text: Network.wifiEnabled ? "Wi-Fi is on" : "Wi-Fi is off"
                        font.pixelSize: 11
                        color: Network.wifiEnabled ? "#00ff00" : "#ff4444"
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // Toggle switch
                Rectangle {
                    width: 36
                    height: 18
                    radius: 9
                    color: Network.wifiEnabled ? "#4CAF50" : "#555555"
                    border.color: Network.wifiEnabled ? "#4CAF50" : "#777777"
                    border.width: 1
                    
                    Rectangle {
                        width: 14
                        height: 14
                        radius: 7
                        color: "#ffffff"
                        anchors {
                            verticalCenter: parent.verticalCenter
                            right: Network.wifiEnabled ? parent.right : parent.left
                            rightMargin: Network.wifiEnabled ? 2 : undefined
                            leftMargin: Network.wifiEnabled ? undefined : 2
                        }
                        
                        Behavior on anchors.rightMargin {
                            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                        }
                        Behavior on anchors.leftMargin {
                            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log("WiFi toggle clicked, current state:", Network.wifiEnabled)
                            Network.toggleWifi();
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
        
        // Available networks list
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#2a2a2a"
            radius: 8
            border.color: "#33ffffff"
            border.width: 1
            
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
                            enabled: !Network.isScanning
                            onClicked: {
                                Network.scanNetworks();
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
                        visible: !Network.wifiEnabled || (networksList.count === 0 && !Network.isScanning)
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            
                            Text {
                                text: Network.isScanning ? "refresh" : "wifi_off"
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 32
                                color: "#666666"
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: Network.isScanning ? "Scanning for networks..." : (Network.wifiEnabled ? "No networks found" : "Wi-Fi is turned off")
                                font.pixelSize: 14
                                color: "#666666"
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: Network.wifiEnabled ? "Try refreshing" : "Turn on Wi-Fi to see available networks"
                                font.pixelSize: 12
                                color: "#444444"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                    
                    ListView {
                        id: networksList
                        width: parent.width
                        spacing: 8
                        model: Network.networks || []
                        visible: Network.wifiEnabled && networksList.count > 0
                        
                        // Debug info
                        Component.onCompleted: {
                            console.log("WifiTab: Network.networks length:", Network.networks ? Network.networks.length : 0);
                            console.log("WifiTab: Network.wifiEnabled:", Network.wifiEnabled);
                            console.log("WifiTab: Network.isScanning:", Network.isScanning);
                        }
                        
                        delegate: Rectangle {
                            width: parent.width
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
                                    text: {
                                        const signal = modelData.signal || 0;
                                        return signal > 80 ? "signal_wifi_4_bar" :
                                               signal > 60 ? "network_wifi_3_bar" :
                                               signal > 40 ? "network_wifi_2_bar" :
                                               signal > 20 ? "network_wifi_1_bar" : "signal_wifi_0_bar";
                                    }
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
                                    if (!modelData.connected && !Network.isConnecting) {
                                        selectedNetwork = modelData.ssid || "";
                                        if (modelData.security === "Open") {
                                            Network.connectToNetwork(modelData.ssid || "");
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
            color: "#1a1a1a"
            radius: 12
            border.color: "#33ffffff"
            border.width: 1
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
                    color: "#2a2a2a"
                    radius: 8
                    border.color: "#33ffffff"
                    border.width: 1
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
                        color: "#2a2a2a"
                        radius: 8
                        border.color: "#33ffffff"
                        border.width: 1
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
                        Network.connectToNetwork(selectedNetwork, passwordInput);
                        showPasswordDialog = false;
                        selectedNetwork = "";
                    }
                    
                    background: Rectangle {
                        color: enabled ? "#5700eeff" : "#2a2a2a"
                        radius: 8
                        border.color: enabled ? "#7700eeff" : "#33ffffff"
                        border.width: 1
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