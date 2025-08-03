pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

/**
 * Enhanced Bluetooth service with device management
 */
QtObject {
    id: root
    
    property int updateInterval: 2000
    property bool bluetoothEnabled: false
    property bool bluetoothConnected: false
    property bool scanning: false
    property string bluetoothDeviceName: ""
    property string bluetoothDeviceAddress: ""
    property bool discoverable: false
    
    // NixOS detection
    property bool isNixOS: false
    
    // Initialize NixOS detection
    Component.onCompleted: {
        checkNixOS.running = true
    }
    
    property Process checkNixOS: Process {
        command: ["bash", "-c", "test -f /etc/os-release && grep -q 'ID=nixos' /etc/os-release && echo 1 || echo 0"]
        stdout: SplitParser {
            onRead: data => {
                root.isNixOS = (parseInt(data) === 1)
            }
        }
    }
    
    // Helper function to get the correct environment setup command for the current OS
    function getEnvironmentSetup() {
        if (root.isNixOS) {
            // On NixOS, DBUS_SESSION_BUS_ADDRESS is already set correctly
            return "export DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS"
        } else {
            // On other distributions, use the original logic
            return "source /etc/environment && export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u $USER -f dbus-daemon)/environ | tr -d '\\0' | cut -d= -f2-)"
        }
    }
    
    // Device lists
    property var connectedDevices: []
    property var availableDevices: []
    property var pairedDevices: []
    
    // Helper function to check if a device is real
    function isRealDevice(address, name) {
        // Only allow MAC addresses for real devices
        const macPattern = /^([A-Fa-f0-9]{2}:){5}[A-Fa-f0-9]{2}$/;
        
        if (!macPattern.test(address)) {
            return false;
        }
        if (!name || name.trim() === '') {
            return false;
        }
        // Filter out the adapter itself (Media device)
        if (name === "Media") {
            return false;
        }
        // Filter out devices where name is just the address repeated (with various separators)
        const addressWithDashes = address.replace(/:/g, '-');
        const addressWithUnderscores = address.replace(/:/g, '_');
        const addressNoSeparators = address.replace(/:/g, '');
        if (name === addressWithDashes || name === addressWithUnderscores || name === addressNoSeparators) {
            return false;
        }
        // Filter out very short names that are likely not real device names
        if (name.length < 2) {
            return false;
        }
        return true;
    }
    
    // Helper function to parse device info
    function parseDeviceInfo(data) {
        let devices = []
        let lines = data.split('\n')
        let currentDevice = null
        
        for (let line of lines) {
            line = line.trim()
            if (!line) continue
            
            // New device line - handle both formats
            let deviceMatch = line.match(/Device\s+(([A-F0-9]{2}:){5}[A-F0-9]{2})\s+(.+)/)
            if (deviceMatch) {
                if (currentDevice && isRealDevice(currentDevice.address, currentDevice.name)) {
                    devices.push(currentDevice)
                }
                currentDevice = {
                    address: deviceMatch[1],
                    name: deviceMatch[3].trim(),
                    type: "Unknown",
                    connected: false,
                    paired: false,
                    battery: null
                }
            }
            
            // Handle [NEW] format from bluetoothctl - only for real devices, not adapters
            let newDeviceMatch = line.match(/\[NEW\]\s+Device\s+([A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2})\s+(.+)/)
            if (newDeviceMatch) {
                if (currentDevice && isRealDevice(currentDevice.address, currentDevice.name)) {
                    devices.push(currentDevice)
                }
                currentDevice = {
                    address: newDeviceMatch[1],
                    name: newDeviceMatch[2].trim(),
                    type: "Unknown",
                    connected: false,
                    paired: false,
                    battery: null
                }
            }
            
            // More permissive pattern for any line that looks like a device
            if (!deviceMatch && !newDeviceMatch) {
                let permissiveMatch = line.match(/([A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2})\s+(.+)/)
                if (permissiveMatch) {
                    if (currentDevice && isRealDevice(currentDevice.address, currentDevice.name)) {
                        devices.push(currentDevice)
                    }
                    currentDevice = {
                        address: permissiveMatch[1],
                        name: permissiveMatch[2].trim(),
                        type: "Unknown",
                        connected: false,
                        paired: false,
                        battery: null
                    }
                }
            }
            
            // Device properties
            if (currentDevice) {
                if (line.includes("Connected: yes")) {
                    currentDevice.connected = true
                } else if (line.includes("Paired: yes")) {
                    currentDevice.paired = true
                } else if (line.includes("Icon:")) {
                    let iconMatch = line.match(/Icon:\s+(.+)/)
                    if (iconMatch) {
                        let icon = iconMatch[1].trim()
                        if (icon.includes("audio")) currentDevice.type = "Headphones"
                        else if (icon.includes("input")) currentDevice.type = "Mouse"
                        else if (icon.includes("phone")) currentDevice.type = "Phone"
                        else if (icon.includes("computer")) currentDevice.type = "Computer"
                        else if (icon.includes("tv")) currentDevice.type = "TV"
                        else currentDevice.type = "Device"
                    }
                }
            }
        }
        
        // Add last device
        if (currentDevice && isRealDevice(currentDevice.address, currentDevice.name)) {
            devices.push(currentDevice)
        }
        
        return devices
    }
    
    function update() {
        updateBluetoothStatus.running = true
        // Only update devices if not currently scanning
        if (!scanning) {
            updateDevices.running = true
        }
    }
    
    property Timer updateTimer: Timer {
        interval: 10
        running: true
        repeat: true
        onTriggered: {
            update()
            interval = root.updateInterval
        }
    }
    
    // Check Bluetooth status
    property Process updateBluetoothStatus: Process {
        command: ["bash", "-c", root.getEnvironmentSetup() + " && bluetoothctl show | grep -q 'Powered: yes' && echo 1 || echo 0"]
        stdout: SplitParser {
            onRead: data => {
                root.bluetoothEnabled = (parseInt(data) === 1)
            }
        }
    }
    
    // Update device lists
    property Process updateDevices: Process {
        command: ["bash", "-c", root.getEnvironmentSetup() + " && bluetoothctl --timeout=5 devices"]
        stdout: SplitParser {
            property string collectedOutput: ""
            onRead: data => {
                collectedOutput += data + "\n"
            }
        }
        onRunningChanged: {
            if (!running) {
                let devices = root.parseDeviceInfo(updateDevices.stdout.collectedOutput)
                
                // Deduplicate by address
                let uniqueDevices = [];
                let seenAddresses = {};
                for (let i = 0; i < devices.length; ++i) {
                    let addr = devices[i].address;
                    if (!seenAddresses[addr]) {
                        seenAddresses[addr] = true;
                        uniqueDevices.push(devices[i]);
                    }
                }
                
                root.availableDevices = uniqueDevices;
                root.pairedDevices = devices.filter(d => d.paired && !d.connected)
                root.connectedDevices = devices.filter(d => d.connected)
                
                // Update connected device info
                if (root.connectedDevices.length > 0) {
                    let device = root.connectedDevices[0]
                    root.bluetoothDeviceName = device.name
                    root.bluetoothDeviceAddress = device.address
                    root.bluetoothConnected = true
                } else {
                    root.bluetoothDeviceName = ""
                    root.bluetoothDeviceAddress = ""
                    root.bluetoothConnected = false
                }
                
                // Reset for next update
                updateDevices.stdout.collectedOutput = ""
            }
        }
    }
} 