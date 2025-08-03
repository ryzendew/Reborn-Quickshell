pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

/**
 * Enhanced network state service with WiFi management capabilities.
 */
QtObject {
    id: root
    
    // Basic network state
    property bool wifi: true
    property bool ethernet: false
    property bool wifiEnabled: true
    property bool connected: false
    property string ssid: ""
    property string networkName: ""
    property int networkStrength: 0
    property string connectedSecurity: ""
    
    onNetworkStrengthChanged: {
        // Ensure networkStrength is always a valid integer between 0-100
        if (isNaN(networkStrength) || networkStrength < 0) {
            networkStrength = 0;
        } else if (networkStrength > 100) {
            networkStrength = 100;
        }
    }
    
    property int updateInterval: 1000
    
    // WiFi scanning and management
    property bool isScanning: false
    property var networks: []
    property bool isConnecting: false
    property string connectionError: ""
    
    // Material symbol for display
    property string materialSymbol: ethernet ? "lan" : (Network.networkName.length > 0 && Network.networkName != "lo") ? (
        networkStrength > 80 ? "signal_wifi_4_bar" :
        networkStrength > 60 ? "network_wifi_3_bar" :
        networkStrength > 40 ? "network_wifi_2_bar" :
        networkStrength > 20 ? "network_wifi_1_bar" :
        "signal_wifi_0_bar"
    ) : "signal_wifi_off"
    
    function update() {
        updateConnectionType.startCheck();
        updateNetworkName.running = true;
        updateNetworkStrength.running = true;
        updateWifiState.running = true;
        updateConnectedSecurity.running = true;
    }
    
    function scanNetworks() {
        if (isScanning) return;
        isScanning = true;
        scanProcess.running = true;
    }
    
    function connectToNetwork(ssid, password = "") {
        if (isConnecting) return;
        isConnecting = true;
        connectionError = "";
        if (password) {
            connectWithPasswordProcess.ssid = ssid;
            connectWithPasswordProcess.password = password;
            connectWithPasswordProcess.running = true;
        } else {
            connectOpenProcess.ssid = ssid;
            connectOpenProcess.running = true;
        }
    }
    
    function disconnectFromNetwork() {
        disconnectProcess.running = true;
    }
    
    function toggleWifi() {
        toggleWifiProcess.running = true;
    }
    
    property Timer updateTimer: Timer {
        interval: 10
        running: true
        repeat: true
        onTriggered: {
            root.update();
            interval = root.updateInterval;
        }
    }
    
    // Update connection type (ethernet/wifi)
    property Process updateConnectionType: Process {
        property string buffer
        command: ["sh", "-c", "nmcli -t -f NAME,TYPE,DEVICE c show --active"]
        running: true
        
        function startCheck() {
            buffer = "";
            updateConnectionType.running = true;
        }
        
        stdout: SplitParser {
            onRead: data => {
                updateConnectionType.buffer += data + "\n";
            }
        }
        
        onExited: (exitCode, exitStatus) => {
            const lines = updateConnectionType.buffer.trim().split('\n');
            let hasEthernet = false;
            let hasWifi = false;
            lines.forEach(line => {
                if (line.includes("ethernet")) hasEthernet = true;
                else if (line.includes("wireless")) hasWifi = true;
            });
            root.ethernet = hasEthernet;
            root.wifi = hasWifi;
            root.connected = hasEthernet || hasWifi;
        }
    }
    
    // Update network name
    property Process updateNetworkName: Process {
        command: ["sh", "-c", "nmcli -t -f NAME c show --active | head -1"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                root.networkName = data;
                root.ssid = data;
            }
        }
    }
    
    // Update network strength
    property Process updateNetworkStrength: Process {
        running: true
        command: ["sh", "-c", "nmcli -f IN-USE,SIGNAL,SSID device wifi | awk '/^\\*/{if (NR!=1) {print $2}}'"]
        stdout: SplitParser {
            onRead: data => {
                const strength = parseInt(data);
                root.networkStrength = (!isNaN(strength)) ? strength : 0;
            }
        }
    }
    
    // Update WiFi enabled state
    property Process updateWifiState: Process {
        command: ["sh", "-c", "nmcli radio wifi"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                root.wifiEnabled = data.trim() === "enabled";
            }
        }
    }
    
    // Update connected network security type
    property Process updateConnectedSecurity: Process {
        command: ["sh", "-c", "nmcli -t -f SSID,SECURITY,IN-USE device wifi | awk -F: '/\\*$/{print $2}'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                root.connectedSecurity = data.trim() || "Open";
            }
        }
    }
    
    // Scan for available networks
    property Process scanProcess: Process {
        property string buffer
        command: ["nmcli", "-t", "-f", "SSID,SECURITY,SIGNAL,IN-USE", "device", "wifi", "list"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                scanProcess.buffer += data + "\n";
            }
        }
        onExited: (exitCode, exitStatus) => {
            const lines = scanProcess.buffer.trim().split('\n');
            const nets = [];
            const seen = {};
            for (let i = 0; i < lines.length; ++i) {
                const line = lines[i].trim();
                if (!line) continue;
                const parts = line.split(':');
                const ssid = parts[0];
                const security = parts[1] || "Open";
                const signalRaw = parts[2];
                const signal = (signalRaw && !isNaN(parseInt(signalRaw))) ? parseInt(signalRaw) : 0;
                const inUse = parts[3] === "*";
                if (ssid && !seen[ssid]) {
                    nets.push({
                        ssid: ssid,
                        security: security,
                        signal: signal,
                        connected: inUse
                    });
                    seen[ssid] = true;
                }
            }
            // Defensive: ensure every network has a valid signal property
            for (let i = 0; i < nets.length; ++i) {
                if (typeof nets[i].signal !== 'number' || isNaN(nets[i].signal)) {
                    nets[i].signal = 0;
                }
            }
            root.networks = nets;
            root.isScanning = false;
        }
    }
    
    // Connect to open network
    property Process connectOpenProcess: Process {
        property string ssid
        command: ["sh", "-c", "nmcli device wifi connect \"" + ssid + "\""]
        running: false
        onExited: (exitCode, exitStatus) => {
            root.isConnecting = false;
            if (exitCode !== 0) {
                root.connectionError = "Failed to connect to " + connectOpenProcess.ssid;
            } else {
                root.update();
            }
        }
    }
    
    // Connect to secured network
    property Process connectWithPasswordProcess: Process {
        property string ssid
        property string password
        command: ["sh", "-c", "nmcli device wifi connect '" + ssid + "' password '" + password + "'"]
        running: false
        onExited: (exitCode, exitStatus) => {
            root.isConnecting = false;
            if (exitCode !== 0) {
                root.connectionError = "Failed to connect to " + connectWithPasswordProcess.ssid;
            } else {
                root.update();
            }
        }
    }
    
    // Disconnect from current network
    property Process disconnectProcess: Process {
        command: ["sh", "-c", "nmcli device disconnect $(nmcli -t -f DEVICE,TYPE device status | grep wireless | cut -d: -f1 | head -1)"]
        running: false
        onExited: (exitCode, exitStatus) => {
            root.update();
        }
    }
    
    // Toggle WiFi on/off
    property Process toggleWifiProcess: Process {
        command: ["sh", "-c", "nmcli radio wifi | grep -q enabled && nmcli radio wifi off || nmcli radio wifi on"]
        running: false
        onExited: (exitCode, exitStatus) => {
            root.update();
        }
    }
} 