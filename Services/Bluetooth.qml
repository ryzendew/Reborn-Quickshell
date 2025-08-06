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
            // On other distributions, use a simpler approach
            return "export DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS"
        }
    }
    
    // Device lists
    property var connectedDevices: []
    property var availableDevices: []
    property var pairedDevices: []
    
    // Signal to notify when devices change
    signal devicesChanged()
    
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
        // Filter out RSSI and other noise entries
        if (name.startsWith("RSSI:") || name.startsWith("Discovering:") || name.includes("RSSI:") || 
            name.startsWith("TxPower:") || name.includes("TxPower:") || name.startsWith("ManufacturerData:") ||
            name.startsWith("ServiceData:") || name.startsWith("UUID:") || name.startsWith("Alias:")) {

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
        // Filter out names that are just numbers or hex values
        if (/^[0-9A-Fa-f\s\-:]+$/.test(name) && name.length < 20) {

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
                    let deviceName = permissiveMatch[2].trim()
                    // Only process if it looks like a real device name
                    if (deviceName && 
                        !deviceName.startsWith("RSSI:") && 
                        !deviceName.startsWith("Discovering:") && 
                        !deviceName.startsWith("TxPower:") &&
                        !deviceName.startsWith("ManufacturerData:") &&
                        !deviceName.startsWith("ServiceData:") &&
                        !deviceName.startsWith("UUID:") &&
                        !deviceName.startsWith("Alias:") &&
                        deviceName.length > 2) {
                        if (currentDevice && isRealDevice(currentDevice.address, currentDevice.name)) {
                            devices.push(currentDevice)
                        }
                        currentDevice = {
                            address: permissiveMatch[1],
                            name: deviceName,
                            type: "Unknown",
                            connected: false,
                            paired: false,
                            battery: null
                        }
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
                let enabled = (parseInt(data) === 1)

                root.bluetoothEnabled = enabled
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
    
                
                // Update paired and connected devices
                root.pairedDevices = devices.filter(d => d.paired && !d.connected)
                root.connectedDevices = devices.filter(d => d.connected)
                
                
                // Update available devices - include all devices that aren't connected
                let allAvailable = uniqueDevices.filter(d => !d.connected)
                root.availableDevices = allAvailable
                
                
                // Notify UI that devices have changed
                root.devicesChanged()
                
                // Update connected device info
                if (root.connectedDevices.length > 0) {
                    let device = root.connectedDevices[0]
                    // Try to get a better device name
                    let deviceName = device.name
                    if (!deviceName || deviceName === "Unknown" || deviceName.length === 0) {
                        // Try to find the device in available devices to get the name
                        let availableDevice = root.availableDevices.find(d => d.address === device.address)
                        if (availableDevice && availableDevice.name) {
                            deviceName = availableDevice.name
                        }
                    }
                    root.bluetoothDeviceName = deviceName || "Connected Device"
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
    
    // Process to capture discovered devices during scanning
    property Process scanCapture: Process {
        command: ["bash", "-c", root.getEnvironmentSetup() + " && bluetoothctl --timeout=30 scan on"]
        stdout: SplitParser {
            property string collectedOutput: ""
            onRead: data => {
                collectedOutput += data + "\n"

                
                // Parse discovered devices in real-time
                let lines = data.split('\n')
                for (let line of lines) {
                    line = line.trim()
                    if (!line) continue
                    
                    // Look for [NEW] Device lines
                    let newDeviceMatch = line.match(/\[NEW\]\s+Device\s+([A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2})\s+(.+)/)
                    if (newDeviceMatch) {
                        let address = newDeviceMatch[1]
                        let name = newDeviceMatch[2].trim()
                        
                        // Check if this is a real device
                        if (root.isRealDevice(address, name)) {
                            // Check if device already exists
                            let existingIndex = root.availableDevices.findIndex(d => d.address === address)
                            if (existingIndex === -1) {
                                let newDevice = {
                                    address: address,
                                    name: name,
                                    type: "Unknown",
                                    connected: false,
                                    paired: false,
                                    battery: null
                                }
                                root.availableDevices.push(newDevice)
        
                                root.devicesChanged()
                            }
                        }
                    }
                }
            }
        }
        onRunningChanged: {
            if (!running) {
    
                root.scanning = false
                // Stop scanning
                stopScanProcess.running = true
            }
        }
    }
    
    // Power on Bluetooth
    function powerOn() {
        powerOnProcess.running = true
    }
    
    // Power off Bluetooth
    function powerOff() {
        powerOffProcess.running = true
    }
    
    // Start scanning for devices
    function startScan() {
        scanning = true
        // Clear existing available devices
        availableDevices = []
        // Start the scan capture process
        scanCapture.running = true
    }
    
    // Stop scanning
    function stopScan() {
        scanning = false
        scanCapture.running = false
        stopScanProcess.running = true
    }
    
    // Set discoverable mode
    function setDiscoverable(enabled) {
        discoverable = enabled
        setDiscoverableProcess.enabled = enabled
        setDiscoverableProcess.running = true
    }
    
    // Connect to a device
    function connectDevice(address) {

        // For DualSense controllers, try pairing first
        if (address && address.length > 0) {
            // Check if it's a DualSense controller by looking at the device name
            let device = root.availableDevices.find(d => d.address === address)
            if (device && (device.name.includes("DualSense") || device.name.includes("Wireless Controller"))) {

                pairDeviceProcess.address = address
                pairDeviceProcess.running = true
            } else {
                connectDeviceProcess.address = address
                connectDeviceProcess.running = true
            }
        }
    }
    
    // Disconnect from a device
    function disconnectDevice(address) {
        disconnectDeviceProcess.address = address
        disconnectDeviceProcess.running = true
    }
    
    // Remove/forget a device
    function removeDevice(address) {
        removeDeviceProcess.address = address
        removeDeviceProcess.running = true
    }
    
    // Pair with a device
    function pairDevice(address) {
        
        pairDeviceProcess.address = address
        pairDeviceProcess.running = true
    }
    
    // Power on Bluetooth process
    property Process powerOnProcess: Process {
        command: ["bash", "-c", root.getEnvironmentSetup() + " && bluetoothctl power on"]
        running: false
        onExited: (exitCode, exitStatus) => {

            update()
        }
    }
    
    // Power off Bluetooth process
    property Process powerOffProcess: Process {
        command: ["bash", "-c", root.getEnvironmentSetup() + " && bluetoothctl power off"]
        running: false
        onExited: (exitCode, exitStatus) => {

            update()
        }
    }
    
    // Stop scanning process
    property Process stopScanProcess: Process {
        command: ["bash", "-c", root.getEnvironmentSetup() + " && bluetoothctl scan off"]
        running: false
        onExited: (exitCode, exitStatus) => {

        }
    }
    
    // Set discoverable process
    property Process setDiscoverableProcess: Process {
        property bool enabled: false
        command: ["bash", "-c", root.getEnvironmentSetup() + " && bluetoothctl discoverable " + (enabled ? "on" : "off")]
        running: false
        onExited: (exitCode, exitStatus) => {

        }
    }
    
    // Connect device process
    property Process connectDeviceProcess: Process {
        property string address: ""
        command: ["bash", "-c", root.getEnvironmentSetup() + " && bluetoothctl --timeout=30 connect " + address]
        running: false
        onStarted: {

        }
        onExited: (exitCode, exitStatus) => {

            // For DualSense controllers, try pairing first if connect fails
            if (exitCode !== 0) {

                pairDeviceProcess.address = address
                pairDeviceProcess.running = true
            } else {
                // Get better device info after successful connection
                setTimeout(() => {
                    updateDeviceInfoProcess.address = address
                    updateDeviceInfoProcess.running = true
                }, 1000)
                update()
            }
        }
    }
    
    // Disconnect device process
    property Process disconnectDeviceProcess: Process {
        property string address: ""
        command: ["bash", "-c", root.getEnvironmentSetup() + " && bluetoothctl disconnect " + address]
        running: false
        onExited: (exitCode, exitStatus) => {

            update()
        }
    }
    
    // Remove device process
    property Process removeDeviceProcess: Process {
        property string address: ""
        command: ["bash", "-c", root.getEnvironmentSetup() + " && bluetoothctl remove " + address]
        running: false
        onExited: (exitCode, exitStatus) => {

            update()
        }
    }
    
    // Pair device process
    property Process pairDeviceProcess: Process {
        property string address: ""
        command: ["bash", "-c", root.getEnvironmentSetup() + " && bluetoothctl --timeout=20 pair " + address]
        running: false
        onStarted: {

        }
        onExited: (exitCode, exitStatus) => {

            // After pairing, try to connect
            if (exitCode === 0) {

                setTimeout(() => {
                    connectDeviceProcess.address = address
                    connectDeviceProcess.running = true
                }, 2000)
            } else {
                update()
            }
        }
    }
    
    // Update device info process
    property Process updateDeviceInfoProcess: Process {
        property string address: ""
        command: ["bash", "-c", root.getEnvironmentSetup() + " && bluetoothctl info " + address]
        running: false
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                update()
            }
        }
    }
} 