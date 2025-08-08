pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * System Information Service
 * Provides detailed system information like OS, kernel, uptime, etc.
 */
Singleton {
    id: root

    // System Information Properties
    property string osName: "Unknown"
    property string osVersion: "Unknown"
    property string kernelVersion: "Unknown"
    property string hostname: "Unknown"
    property string architecture: "Unknown"
    property string uptime: "Unknown"
    property string bootTime: "Unknown"
    property string cpuModel: "Unknown"
    property int cpuCores: 0
    property int cpuThreads: 0
    property string gpuModel: "Unknown"
    property string totalMemory: "Unknown"
    property string availableMemory: "Unknown"
    property string diskUsage: "Unknown"
    property string networkInterface: "Unknown"
    property string ipAddress: "Unknown"

    // Update interval
    property int updateInterval: 10000 // 10 seconds

    // Main update timer
    Timer {
        interval: root.updateInterval
        running: true
        repeat: true
        onTriggered: {
            updateSystemInfo()
        }
    }

    // Update all system information
    function updateSystemInfo() {
        updateOSInfo()
        updateKernelInfo()
        updateHostnameInfo()
        updateUptimeInfo()
        updateCPUInfo()
        updateMemoryInfo()
        updateDiskInfo()
        updateNetworkInfo()
    }



    // OS Information
    function updateOSInfo() {
        console.log("SystemInfo: Updating OS info...")
        var process = Qt.createQmlObject('import QtQuick; import Quickshell.Io; Process {}', root)
        process.exec("cat /etc/os-release | grep -E '^(NAME|VERSION)=' | sed 's/NAME=//' | sed 's/VERSION=//' | tr '\\n' ' '")
        process.onExited.connect(function(exitCode, stdout, stderr) {
            console.log("SystemInfo: OS info result - exitCode:", exitCode, "stdout:", stdout, "stderr:", stderr)
            if (stdout) {
                const parts = stdout.trim().split(/\s+/)
                if (parts.length >= 2) {
                    osName = parts[0].replace(/"/g, '')
                    osVersion = parts[1].replace(/"/g, '')
                    console.log("SystemInfo: Set osName to", osName, "osVersion to", osVersion)
                }
            }
        })
    }

    // Kernel Information
    function updateKernelInfo() {
        var process = Qt.createQmlObject('import QtQuick; import Quickshell.Io; Process {}', root)
        process.exec("uname -r && uname -m")
        process.onExited.connect(function(exitCode, stdout, stderr) {
            if (stdout) {
                const lines = stdout.trim().split('\n')
                if (lines.length >= 2) {
                    kernelVersion = lines[0]
                    architecture = lines[1]
                }
            }
        })
    }

    // Hostname Information
    function updateHostnameInfo() {
        var process = Qt.createQmlObject('import QtQuick; import Quickshell.Io; Process {}', root)
        process.exec("hostname")
        process.onExited.connect(function(exitCode, stdout, stderr) {
            if (stdout) {
                hostname = stdout.trim()
            }
        })
    }

    // Uptime Information
    function updateUptimeInfo() {
        var process = Qt.createQmlObject('import QtQuick; import Quickshell.Io; Process {}', root)
        process.exec("uptime -p | sed 's/up //' && echo '---' && date -d @$(cat /proc/uptime | cut -d' ' -f1 | cut -d'.' -f1) | date '+%Y-%m-%d %H:%M:%S'")
        process.onExited.connect(function(exitCode, stdout, stderr) {
            if (stdout) {
                const parts = stdout.trim().split('---')
                if (parts.length >= 2) {
                    uptime = parts[0].trim()
                    bootTime = parts[1].trim()
                }
            }
        })
    }

    // CPU Information
    function updateCPUInfo() {
        var process = Qt.createQmlObject('import QtQuick; import Quickshell.Io; Process {}', root)
        process.exec("cat /proc/cpuinfo | grep 'model name' | head -1 | sed 's/.*: //' && echo '---' && nproc && echo '---' && cat /proc/cpuinfo | grep 'processor' | wc -l")
        process.onExited.connect(function(exitCode, stdout, stderr) {
            if (stdout) {
                const parts = stdout.trim().split('---')
                if (parts.length >= 3) {
                    cpuModel = parts[0].trim()
                    cpuCores = parseInt(parts[1].trim())
                    cpuThreads = parseInt(parts[2].trim())
                }
            }
        })
    }

    // Memory Information
    function updateMemoryInfo() {
        var process = Qt.createQmlObject('import QtQuick; import Quickshell.Io; Process {}', root)
        process.exec("free -h | grep '^Mem:' | awk '{print $2}' && echo '---' && free -h | grep '^Mem:' | awk '{print $7}'")
        process.onExited.connect(function(exitCode, stdout, stderr) {
            if (stdout) {
                const parts = stdout.trim().split('---')
                if (parts.length >= 2) {
                    totalMemory = parts[0].trim()
                    availableMemory = parts[1].trim()
                }
            }
        })
    }

    // Disk Information
    function updateDiskInfo() {
        var process = Qt.createQmlObject('import QtQuick; import Quickshell.Io; Process {}', root)
        process.exec("df -h / | tail -1 | awk '{print $5}'")
        process.onExited.connect(function(exitCode, stdout, stderr) {
            if (stdout) {
                diskUsage = stdout.trim()
            }
        })
    }

    // Network Information
    function updateNetworkInfo() {
        var process = Qt.createQmlObject('import QtQuick; import Quickshell.Io; Process {}', root)
        process.exec("ip route | grep default | awk '{print $5}' | head -1 && echo '---' && ip addr show | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}' | cut -d'/' -f1")
        process.onExited.connect(function(exitCode, stdout, stderr) {
            if (stdout) {
                const parts = stdout.trim().split('---')
                if (parts.length >= 2) {
                    networkInterface = parts[0].trim()
                    ipAddress = parts[1].trim()
                }
            }
        })
    }

    // Initialize on component creation
    Component.onCompleted: {
        console.log("SystemInfo: Component completed, calling updateSystemInfo()")
        updateSystemInfo()
    }
} 