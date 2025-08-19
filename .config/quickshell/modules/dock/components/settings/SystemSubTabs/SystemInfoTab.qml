import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Settings
import qs.Services

Rectangle {
    id: systemInfoTab
    color: "transparent"
    
    Component.onCompleted: {
        console.log("SystemInfoTab: Component completed")
        console.log("SystemInfoTab: SystemInfo.osName =", SystemInfo.osName)
        console.log("SystemInfoTab: SystemInfo.hostname =", SystemInfo.hostname)
    }
    
    function getMemoryUsagePercent() {
        // Calculate memory usage percentage from SystemInfo service
        if (SystemInfo.totalMemory && SystemInfo.availableMemory) {
            var total = parseFloat(SystemInfo.totalMemory.replace(/[^\d.]/g, ''))
            var available = parseFloat(SystemInfo.availableMemory.replace(/[^\d.]/g, ''))
            var used = total - available
            if (total > 0) {
                return used / total
            }
        }
        return 0.5 // Fallback
    }
    
    function getDiskUsagePercent() {
        // Parse disk usage percentage from SystemInfo service
        if (SystemInfo.diskUsage && SystemInfo.diskUsage.includes('%')) {
            var match = SystemInfo.diskUsage.match(/(\d+)%/)
            if (match) {
                return parseInt(match[1]) / 100
            }
        }
        return 0.3 // Fallback
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 24
        
        // System Overview
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            color: "#333333"
            radius: 12
            border.color: "#44ffffff"
            border.width: 1
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16
                
                // System icon
                Rectangle {
                    width: 80
                    height: 80
                    radius: 12
                    color: "#5700eeff"
                    border.color: "#7700eeff"
                    border.width: 2
                    
                    Text {
                        anchors.centerIn: parent
                        text: "QS"
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                }
                
                ColumnLayout {
                    spacing: 8
                    
                    Text {
                        text: SystemInfo.osName + " " + SystemInfo.osVersion
                        font.pixelSize: 20
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    Text {
                        text: "Hostname: " + SystemInfo.hostname
                        font.pixelSize: 14
                        color: "#cccccc"
                    }
                    
                    Text {
                        text: "Kernel: " + SystemInfo.kernelVersion
                        font.pixelSize: 14
                        color: "#cccccc"
                    }
                    
                    Text {
                        text: "Architecture: " + SystemInfo.architecture
                        font.pixelSize: 14
                        color: "#cccccc"
                    }
                    
                    Text {
                        text: "Boot Time: " + SystemInfo.bootTime
                        font.pixelSize: 14
                        color: "#cccccc"
                    }
                }
                
                Item { Layout.fillWidth: true }
            }
        }
        
        // Hardware Information
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 300
            color: "#333333"
            radius: 12
            border.color: "#44ffffff"
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16
                
                Text {
                    text: "Hardware Information"
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    color: "#ffffff"
                }
                
                // CPU Info
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16
                    
                    Text {
                        text: "CPU:"
                        font.pixelSize: 14
                        color: "#cccccc"
                        Layout.preferredWidth: 80
                    }
                    
                    Text {
                        text: SystemInfo.cpuModel + " (" + SystemInfo.cpuCores + " cores, " + SystemInfo.cpuThreads + " threads)"
                        font.pixelSize: 14
                        color: "#ffffff"
                        Layout.fillWidth: true
                    }
                }
                
                // Memory Info
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16
                    
                    Text {
                        text: "Memory:"
                        font.pixelSize: 14
                        color: "#cccccc"
                        Layout.preferredWidth: 80
                    }
                    
                    Text {
                        text: SystemInfo.availableMemory + " / " + SystemInfo.totalMemory
                        font.pixelSize: 14
                        color: "#ffffff"
                        Layout.fillWidth: true
                    }
                    
                    // Memory progress bar
                    Rectangle {
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 8
                        color: "#2a2a2a"
                        radius: 4
                        
                        Rectangle {
                            width: parent.width * getMemoryUsagePercent()
                            height: parent.height
                            color: "#5700eeff"
                            radius: 4
                        }
                    }
                }
                
                // Disk Info
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16
                    
                    Text {
                        text: "Disk:"
                        font.pixelSize: 14
                        color: "#cccccc"
                        Layout.preferredWidth: 80
                    }
                    
                    Text {
                        text: SystemInfo.diskUsage
                        font.pixelSize: 14
                        color: "#ffffff"
                        Layout.fillWidth: true
                    }
                    
                    // Disk progress bar
                    Rectangle {
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 8
                        color: "#2a2a2a"
                        radius: 4
                        
                        Rectangle {
                            width: parent.width * getDiskUsagePercent()
                            height: parent.height
                            color: "#00ff00"
                            radius: 4
                        }
                    }
                }
                
                // GPU Info
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16
                    
                    Text {
                        text: "GPU:"
                        font.pixelSize: 14
                        color: "#cccccc"
                        Layout.preferredWidth: 80
                    }
                    
                    Text {
                        text: SystemInfo.gpuModel
                        font.pixelSize: 14
                        color: "#ffffff"
                        Layout.fillWidth: true
                    }
                }
                
                // Network Info
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16
                    
                    Text {
                        text: "Network:"
                        font.pixelSize: 14
                        color: "#cccccc"
                        Layout.preferredWidth: 80
                    }
                    
                    Text {
                        text: SystemInfo.networkInterface + " (" + SystemInfo.ipAddress + ")"
                        font.pixelSize: 14
                        color: "#ffffff"
                        Layout.fillWidth: true
                    }
                }
                
                // Uptime
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16
                    
                    Text {
                        text: "Uptime:"
                        font.pixelSize: 14
                        color: "#cccccc"
                        Layout.preferredWidth: 80
                    }
                    
                    Text {
                        text: SystemInfo.uptime
                        font.pixelSize: 14
                        color: "#ffffff"
                        Layout.fillWidth: true
                    }
                }
            }
        }
        

        
        // System Actions
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: "#333333"
            radius: 12
            border.color: "#44ffffff"
            border.width: 1
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16
                
                Button {
                    text: "Refresh Info"
                    Layout.fillWidth: true
                    
                    background: Rectangle {
                        color: parent.pressed ? "#404040" : "#5700eeff"
                        radius: 6
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        getSystemInfo()
                        updateSystemInfo()
                    }
                }
                
                Button {
                    text: "System Monitor"
                    Layout.fillWidth: true
                    
                    background: Rectangle {
                        color: parent.pressed ? "#404040" : "#555555"
                        radius: 6
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        Hyprland.dispatch("exec flatpak run io.missioncenter.MissionCenter")
                    }
                }
                
                Button {
                    text: "Terminal"
                    Layout.fillWidth: true
                    
                    background: Rectangle {
                        color: parent.pressed ? "#404040" : "#555555"
                        radius: 6
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        Hyprland.dispatch("exec kitty")
                    }
                }
            }
        }
    }
    

    

} 