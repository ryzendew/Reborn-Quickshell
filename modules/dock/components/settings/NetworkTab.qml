import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Services

Rectangle {
    id: networkTab
    color: "transparent"
    
    property bool showWifiNetworks: false
    property bool showEthernetSettings: false
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16
        
        // Header with navigation
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
                    onClicked: {
                        showWifiNetworks = false
                        showEthernetSettings = false
                    }
                }
            }
            
            // Page title
            Text {
                text: showWifiNetworks ? "WiFi Networks" : 
                      showEthernetSettings ? "Ethernet Settings" : "Network"
                font.pixelSize: 18
                font.weight: Font.Bold
                color: "#ffffff"
                Layout.fillWidth: true
            }
            
            // Refresh button
            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: refreshMouseArea.containsMouse ? "#333333" : "transparent"
                border.color: refreshMouseArea.containsMouse ? "#555555" : "transparent"
                border.width: 1
                
                Text {
                    anchors.centerIn: parent
                    text: "refresh"
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 18
                    color: "#cccccc"
                }
                
                MouseArea {
                    id: refreshMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        Network.scanNetworks()
                    }
                }
            }
        }
        
        // Main content area
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            ColumnLayout {
                width: parent.width
                spacing: 16
                
                // Current connection status
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    color: "#2a2a2a"
                    radius: 8
                    border.color: "#33ffffff"
                    border.width: 1
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 8
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Text {
                                text: Network.ethernet ? "lan" : 
                                      Network.wifi ? "wifi" : "wifi_off"
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 24
                                color: Network.connected ? "#00ff00" : "#ffaa00"
                            }
                            
                            ColumnLayout {
                                spacing: 2
                                
                                Text {
                                    text: Network.connected ? "Connected" : "Not Connected"
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                    color: Network.connected ? "#00ff00" : "#ffaa00"
                                }
                                
                                Text {
                                    text: Network.connected ? 
                                          (Network.ethernet ? "Ethernet" : Network.ssid) : 
                                          "No active connection"
                                    font.pixelSize: 12
                                    color: "#cccccc"
                                }
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            // Disconnect button
                            Button {
                                visible: Network.connected
                                text: "Disconnect"
                                background: Rectangle {
                                    color: parent.pressed ? "#ff4444" : "#ff6666"
                                    radius: 4
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    Network.disconnectFromNetwork()
                                }
                            }
                        }
                        
                        // Connection details
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: 16
                            rowSpacing: 4
                            
                            Text {
                                text: "IP Address:"
                                font.pixelSize: 11
                                color: "#888888"
                            }
                            Text {
                                text: Network.connected ? "192.168.1.100" : "N/A"
                                font.pixelSize: 11
                                color: "#cccccc"
                            }
                            
                            Text {
                                text: "Signal Strength:"
                                font.pixelSize: 11
                                color: "#888888"
                                visible: Network.wifi
                            }
                            Text {
                                text: Network.wifi ? 
                                      (Network.networkStrength > 80 ? "Excellent" : 
                                       Network.networkStrength > 60 ? "Good" :
                                       Network.networkStrength > 40 ? "Fair" :
                                       Network.networkStrength > 20 ? "Poor" : "Very Poor") : ""
                                font.pixelSize: 11
                                color: Network.networkStrength > 60 ? "#00ff00" : "#ffaa00"
                                visible: Network.wifi
                            }
                            
                            Text {
                                text: "Security:"
                                font.pixelSize: 11
                                color: "#888888"
                                visible: Network.wifi
                            }
                            Text {
                                text: Network.wifi ? Network.connectedSecurity : ""
                                font.pixelSize: 11
                                color: "#cccccc"
                                visible: Network.wifi
                            }
                        }
                    }
                }
                
                // WiFi section
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
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
                                text: "WiFi"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#ffffff"
                            }
                            
                            Text {
                                text: Network.wifiEnabled ? "Enabled" : "Disabled"
                                font.pixelSize: 11
                                color: Network.wifiEnabled ? "#00ff00" : "#ffaa00"
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // WiFi toggle
                        Rectangle {
                            width: 44
                            height: 24
                            radius: 12
                            color: Network.wifiEnabled ? "#5700eeff" : "#333333"
                            border.color: Network.wifiEnabled ? "#7700eeff" : "#555555"
                            border.width: 1
                            
                            Rectangle {
                                width: 18
                                height: 18
                                radius: 9
                                color: "#ffffff"
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    right: Network.wifiEnabled ? parent.right : parent.left
                                    rightMargin: Network.wifiEnabled ? 3 : undefined
                                    leftMargin: Network.wifiEnabled ? undefined : 3
                                }
                                
                                Behavior on anchors.rightMargin {
                                    NumberAnimation { duration: 150 }
                                }
                                Behavior on anchors.leftMargin {
                                    NumberAnimation { duration: 150 }
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    Network.toggleWifi()
                                }
                            }
                        }
                        
                        // Scan networks button
                        Button {
                            text: "Scan"
                            enabled: Network.wifiEnabled && !Network.isScanning
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
                                Network.scanNetworks()
                            }
                        }
                        
                        // Show networks button
                        Button {
                            text: "Networks"
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
                                showWifiNetworks = true
                                Network.scanNetworks()
                            }
                        }
                    }
                }
                
                // Ethernet section
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
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
                                text: "Ethernet"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#ffffff"
                            }
                            
                            Text {
                                text: Network.ethernet ? "Connected" : "Not connected"
                                font.pixelSize: 11
                                color: Network.ethernet ? "#00ff00" : "#888888"
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Ethernet settings button
                        Button {
                            text: "Settings"
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
                                showEthernetSettings = true
                            }
                        }
                    }
                }
                
                // WiFi Networks List (shown when showWifiNetworks is true)
                Rectangle {
                    visible: showWifiNetworks
                    Layout.fillWidth: true
                    Layout.preferredHeight: 400
                    color: "#2a2a2a"
                    radius: 8
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
                                text: "Available Networks"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: "#ffffff"
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            BusyIndicator {
                                running: Network.isScanning
                                visible: running
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                            }
                            
                            Text {
                                text: Network.isScanning ? "Scanning..." : Network.networks.length + " networks"
                                font.pixelSize: 12
                                color: "#cccccc"
                            }
                        }
                        
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            
                            ListView {
                                id: networksList
                                width: parent.width
                                model: Network.networks
                                spacing: 4
                                
                                delegate: Rectangle {
                                    width: networksList.width
                                    height: 60
                                    color: mouseArea.containsMouse ? "#333333" : "transparent"
                                    radius: 6
                                    border.color: modelData.connected ? "#00ff00" : "transparent"
                                    border.width: 1
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 12
                                        
                                        // Signal strength icon
                                        Text {
                                            text: modelData.signal > 80 ? "signal_wifi_4_bar" :
                                                  modelData.signal > 60 ? "network_wifi_3_bar" :
                                                  modelData.signal > 40 ? "network_wifi_2_bar" :
                                                  modelData.signal > 20 ? "network_wifi_1_bar" :
                                                  "signal_wifi_0_bar"
                                            font.family: "Material Symbols Outlined"
                                            font.pixelSize: 20
                                            color: modelData.connected ? "#00ff00" : "#cccccc"
                                        }
                                        
                                        ColumnLayout {
                                            spacing: 2
                                            
                                            Text {
                                                text: modelData.ssid
                                                font.pixelSize: 14
                                                font.weight: Font.Medium
                                                color: "#ffffff"
                                            }
                                            
                                            RowLayout {
                                                spacing: 8
                                                
                                                Text {
                                                    text: modelData.security
                                                    font.pixelSize: 11
                                                    color: "#888888"
                                                }
                                                
                                                Text {
                                                    text: modelData.signal + "%"
                                                    font.pixelSize: 11
                                                    color: "#cccccc"
                                                }
                                                
                                                Text {
                                                    text: modelData.connected ? "Connected" : ""
                                                    font.pixelSize: 11
                                                    color: "#00ff00"
                                                    visible: modelData.connected
                                                }
                                            }
                                        }
                                        
                                        Item { Layout.fillWidth: true }
                                        
                                        // Connect button
                                        Button {
                                            text: modelData.connected ? "Connected" : "Connect"
                                            enabled: !modelData.connected && !Network.isConnecting
                                            background: Rectangle {
                                                color: modelData.connected ? "#00ff00" : 
                                                       parent.pressed ? "#404040" : "#505050"
                                                radius: 4
                                            }
                                            contentItem: Text {
                                                text: parent.text
                                                color: "white"
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                            onClicked: {
                                                if (modelData.security === "Open") {
                                                    Network.connectToNetwork(modelData.ssid)
                                                } else {
                                                    // Show password dialog
                                                    passwordDialog.ssid = modelData.ssid
                                                    passwordDialog.open()
                                                }
                                            }
                                        }
                                    }
                                    
                                    MouseArea {
                                        id: mouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Ethernet Settings (shown when showEthernetSettings is true)
                Rectangle {
                    visible: showEthernetSettings
                    Layout.fillWidth: true
                    Layout.preferredHeight: 400
                    color: "#2a2a2a"
                    radius: 8
                    border.color: "#33ffffff"
                    border.width: 1
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16
                        
                        Text {
                            text: "Ethernet Configuration"
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            color: "#ffffff"
                        }
                        
                        // Connection type
                        ColumnLayout {
                            spacing: 8
                            
                            property bool dhcpRadio: true
                            property bool manualRadio: false
                            
                            Text {
                                text: "Connection Type"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#ffffff"
                            }
                            
                            Row {
                                spacing: 2
                                
                                Row {
                                    spacing: 8
                                    
                                    Rectangle {
                                        width: 16
                                        height: 16
                                        radius: 8
                                        border.color: parent.parent.dhcpRadio ? "#5700eeff" : "#555555"
                                        border.width: 2
                                        anchors.verticalCenter: parent.verticalCenter
                                        
                                        Rectangle {
                                            width: 8
                                            height: 8
                                            radius: 4
                                            color: parent.parent.dhcpRadio ? "#5700eeff" : "transparent"
                                            anchors.centerIn: parent
                                        }
                                    }
                                    
                                    Text {
                                        text: "Automatic (DHCP)"
                                        color: "#ffffff"
                                        font.pixelSize: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    
                                    MouseArea {
                                        width: parent.width
                                        height: parent.height
                                        onClicked: {
                                            parent.parent.dhcpRadio = true
                                            parent.parent.manualRadio = false
                                        }
                                    }
                                }
                                
                                Row {
                                    spacing: 8
                                    
                                    Rectangle {
                                        width: 16
                                        height: 16
                                        radius: 8
                                        border.color: parent.parent.manualRadio ? "#5700eeff" : "#555555"
                                        border.width: 2
                                        anchors.verticalCenter: parent.verticalCenter
                                        
                                        Rectangle {
                                            width: 8
                                            height: 8
                                            radius: 4
                                            color: parent.parent.manualRadio ? "#5700eeff" : "transparent"
                                            anchors.centerIn: parent
                                        }
                                    }
                                    
                                    Text {
                                        text: "Manual"
                                        color: "#ffffff"
                                        font.pixelSize: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    
                                    MouseArea {
                                        width: parent.width
                                        height: parent.height
                                        onClicked: {
                                            parent.parent.dhcpRadio = false
                                            parent.parent.manualRadio = true
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Manual IP settings (shown when manual is selected)
                        ColumnLayout {
                            visible: manualRadio
                            spacing: 8
                            
                            Text {
                                text: "IP Address"
                                font.pixelSize: 12
                                color: "#cccccc"
                            }
                            
                            TextField {
                                id: ipAddressField
                                placeholderText: "192.168.1.100"
                                placeholderTextColor: "#888888"
                                background: Rectangle {
                                    color: "#333333"
                                    radius: 4
                                    border.color: "#555555"
                                    border.width: 1
                                }
                                color: "#ffffff"
                                font.pixelSize: 12
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: "Subnet Mask"
                                font.pixelSize: 12
                                color: "#cccccc"
                            }
                            
                            TextField {
                                id: subnetMaskField
                                placeholderText: "255.255.255.0"
                                placeholderTextColor: "#888888"
                                background: Rectangle {
                                    color: "#333333"
                                    radius: 4
                                    border.color: "#555555"
                                    border.width: 1
                                }
                                color: "#ffffff"
                                font.pixelSize: 12
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: "Gateway"
                                font.pixelSize: 12
                                color: "#cccccc"
                            }
                            
                            TextField {
                                id: gatewayField
                                placeholderText: "192.168.1.1"
                                placeholderTextColor: "#888888"
                                background: Rectangle {
                                    color: "#333333"
                                    radius: 4
                                    border.color: "#555555"
                                    border.width: 1
                                }
                                color: "#ffffff"
                                font.pixelSize: 12
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: "DNS Servers"
                                font.pixelSize: 12
                                color: "#cccccc"
                            }
                            
                            TextField {
                                id: dnsField
                                placeholderText: "8.8.8.8, 8.8.4.4"
                                placeholderTextColor: "#888888"
                                background: Rectangle {
                                    color: "#333333"
                                    radius: 4
                                    border.color: "#555555"
                                    border.width: 1
                                }
                                color: "#ffffff"
                                font.pixelSize: 12
                                Layout.fillWidth: true
                            }
                        }
                        
                        // Apply button
                        Button {
                            text: "Apply Settings"
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
                                // Apply ethernet settings (placeholder)
                                console.log("Applying ethernet settings...")
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Password dialog for secured networks
    Dialog {
        id: passwordDialog
        title: "Enter Password"
        modal: true
        anchors.centerIn: parent
        width: 300
        height: 150
        
        property string ssid: ""
        
        background: Rectangle {
            color: "#2a2a2a"
            radius: 8
            border.color: "#404040"
            border.width: 1
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16
            
            Text {
                text: "Enter password for: " + passwordDialog.ssid
                color: "white"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
            }
            
            TextField {
                id: passwordField
                placeholderText: "Password"
                echoMode: TextInput.Password
                background: Rectangle {
                    color: "#333333"
                    radius: 4
                    border.color: "#555555"
                    border.width: 1
                }
                color: "#ffffff"
                font.pixelSize: 12
                Layout.fillWidth: true
                
                Keys.onReturnPressed: {
                    if (passwordField.text.length > 0) {
                        Network.connectToNetwork(passwordDialog.ssid, passwordField.text)
                        passwordDialog.close()
                        passwordField.text = ""
                    }
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Button {
                    text: "Connect"
                    Layout.fillWidth: true
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
                        if (passwordField.text.length > 0) {
                            Network.connectToNetwork(passwordDialog.ssid, passwordField.text)
                            passwordDialog.close()
                            passwordField.text = ""
                        }
                    }
                }
                
                Button {
                    text: "Cancel"
                    Layout.fillWidth: true
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
                        passwordDialog.close()
                        passwordField.text = ""
                    }
                }
            }
        }
    }
} 