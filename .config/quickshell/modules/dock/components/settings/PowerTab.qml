import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Services
import Quickshell.Services.UPower

Rectangle {
    id: powerTab
    color: "transparent"
    
    // Main background behind everything
    Rectangle {
        anchors.fill: parent
        color: "#00747474"
        opacity: 0.8
        radius: 8
    }
    
    property bool showAdvancedSettings: false
    
    // UPower properties
    property bool hasBattery: false
    property bool isCharging: false
    property int batteryPercentage: 0
    property int timeToEmpty: 0
    property int timeToFull: 0
    property string batteryState: "Unknown"
    property string powerSource: "AC"
    
    // Power profile properties - use Quickshell's PowerProfiles service
    property int currentProfile: PowerProfiles.profile
    
    Component.onCompleted: {
        console.log("PowerTab component completed, initializing...")
        updatePowerInfo()
        // Refresh power info every 30 seconds
        powerRefreshTimer.start()
    }
    
    Timer {
        id: powerRefreshTimer
        interval: 30000 // 30 seconds
        repeat: true
        running: false
        onTriggered: {
            updatePowerInfo()
        }
    }
    
    function updatePowerInfo() {
        // First, get all available UPower devices
        Quickshell.Io.Process.exec("upower -e", function(exitCode, stdout, stderr) {
            if (exitCode === 0) {
                const devices = stdout.trim().split('\n')
                console.log("Available UPower devices:", devices)
                
                // Check if we have battery devices
                const batteryDevices = devices.filter(device => device.includes('battery'))
                const acDevices = devices.filter(device => device.includes('line_power'))
                
                if (batteryDevices.length > 0) {
                    // We have battery devices, get battery info
                    Quickshell.Io.Process.exec("upower -i " + batteryDevices[0], function(exitCode, stdout, stderr) {
                        if (exitCode === 0) {
                            const lines = stdout.split('\n')
                            lines.forEach(line => {
                                if (line.includes('power supply:')) {
                                    powerTab.hasBattery = line.includes('yes')
                                } else if (line.includes('state:')) {
                                    const state = line.split(':')[1].trim()
                                    powerTab.batteryState = state
                                    powerTab.isCharging = state === 'charging'
                                } else if (line.includes('percentage:')) {
                                    const percentage = line.split(':')[1].trim()
                                    powerTab.batteryPercentage = parseInt(percentage)
                                } else if (line.includes('time to empty:')) {
                                    const time = line.split(':')[1].trim()
                                    powerTab.timeToEmpty = parseInt(time) || 0
                                } else if (line.includes('time to full:')) {
                                    const time = line.split(':')[1].trim()
                                    powerTab.timeToFull = parseInt(time) || 0
                                }
                            })
                        }
                    })
                    
                    // Get AC power status
                    if (acDevices.length > 0) {
                        Quickshell.Io.Process.exec("upower -i " + acDevices[0], function(exitCode, stdout, stderr) {
                            if (exitCode === 0) {
                                if (stdout.includes('online: yes')) {
                                    powerTab.powerSource = "AC"
                                } else {
                                    powerTab.powerSource = "Battery"
                                }
                            }
                        })
                    }
                } else {
                    // No battery devices found, this is likely a desktop
                    powerTab.hasBattery = false
                    powerTab.powerSource = "AC"
                    
                    // Get general power status from daemon
                    Quickshell.Io.Process.exec("upower -d", function(exitCode, stdout, stderr) {
                        if (exitCode === 0) {
                            const lines = stdout.split('\n')
                            lines.forEach(line => {
                                if (line.includes('on-battery:')) {
                                    const onBattery = line.includes('yes')
                                    powerTab.powerSource = onBattery ? "Battery" : "AC"
                                }
                            })
                        }
                    })
                }
            }
        })
    }
    
    function setPowerProfile(profile) {
        console.log("Setting power profile to:", profile)
        PowerProfiles.profile = profile
        console.log("Power profile set via PowerProfiles service")
    }
    
    function getProfileDisplayInfo(profileId) {
        const profileMap = {
            [PowerProfile.PowerSaver]: {name: "Power Saver", icon: "battery_saver", color: "#00ff00"},
            [PowerProfile.Balanced]: {name: "Balanced", icon: "tune", color: "#ffaa00"},
            [PowerProfile.Performance]: {name: "Performance", icon: "speed", color: "#ff6666"}
        }
        return profileMap[profileId] || {name: "Unknown", icon: "settings", color: "#cccccc"}
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 24
        
        // Header
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
                        showAdvancedSettings = false
                    }
                }
            }
            
            // Page title
            Text {
                text: showAdvancedSettings ? "Advanced Power Settings" : "Power"
                font.pixelSize: 20
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
                                    color: refreshMouseArea.containsMouse ? "#ffffff" : "#cccccc"
                                }
                                
                                MouseArea {
                                    id: refreshMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        console.log("Manual refresh triggered")
                                        updatePowerInfo()
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
                spacing: 24
                
                // Battery status card
                Rectangle {
                    visible: hasBattery
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    color: "transparent"
                    radius: 12
                    border.color: "#33ffffff"
                    border.width: 1
                    
                    // macOS Tahoe-style transparency effect
                    Rectangle {
                        anchors.fill: parent
                        color: "#2a2a2a"
                        opacity: 0.8
                        radius: 12
                    }
                    
                    // Dark mode backdrop
                    Rectangle {
                        anchors.fill: parent
                        color: "#1a1a1a"
                        opacity: 0.3
                        radius: 12
                    }
                    
                    // Semi-transparent white border overlay
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        radius: 12
                        border.color: "#40ffffff"
                        border.width: 1
                    }
                    
                    // Semi-transparent white overlay for macOS-like shine
                    Rectangle {
                        anchors.fill: parent
                        color: "#15ffffff"
                        radius: 12
                    }
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 20
                        
                        // Battery icon
                        Text {
                            text: isCharging ? "battery_charging_full" :
                                  batteryPercentage > 80 ? "battery_full" :
                                  batteryPercentage > 60 ? "battery_6_bar" :
                                  batteryPercentage > 40 ? "battery_4_bar" :
                                  batteryPercentage > 20 ? "battery_2_bar" :
                                  "battery_alert"
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: 36
                            color: isCharging ? "#00ff00" : 
                                   batteryPercentage > 20 ? "#00ff00" : "#ffaa00"
                        }
                        
                        // Battery info
                        ColumnLayout {
                            spacing: 8
                            
                            Text {
                                text: batteryPercentage + "%"
                                font.pixelSize: 28
                                font.weight: Font.Bold
                                color: "#ffffff"
                            }
                            
                            Text {
                                text: isCharging ? "Charging" : batteryState
                                font.pixelSize: 14
                                color: isCharging ? "#00ff00" : "#cccccc"
                            }
                            
                            Text {
                                text: isCharging ? 
                                      (timeToFull > 0 ? "Time to full: " + Math.floor(timeToFull / 60) + "h " + (timeToFull % 60) + "m" : "") :
                                      (timeToEmpty > 0 ? "Time remaining: " + Math.floor(timeToEmpty / 60) + "h " + (timeToEmpty % 60) + "m" : "")
                                font.pixelSize: 12
                                color: "#888888"
                                visible: text.length > 0
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Power source indicator
                        ColumnLayout {
                            spacing: 8
                            
                            Text {
                                text: powerSource === "AC" ? "power" : "battery_saver"
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 24
                                color: powerSource === "AC" ? "#00ff00" : "#ffaa00"
                            }
                            
                            Text {
                                text: powerSource === "AC" ? "Plugged In" : "On Battery"
                                font.pixelSize: 12
                                color: "#cccccc"
                            }
                        }
                    }
                }
                
                // Desktop mode indicator
                Rectangle {
                    visible: !hasBattery
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    color: "transparent"
                    radius: 12
                    border.color: "#33ffffff"
                    
                    // macOS Tahoe-style transparency effect
                    Rectangle {
                        anchors.fill: parent
                        color: "#2a2a2a"
                        opacity: 0.8
                        radius: 12
                    }
                    
                    // Dark mode backdrop
                    Rectangle {
                        anchors.fill: parent
                        color: "#1a1a1a"
                        opacity: 0.3
                        radius: 12
                    }
                    
                    // Semi-transparent white border overlay
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        radius: 12
                        border.color: "#40ffffff"
                        border.width: 1
                    }
                    
                    // Semi-transparent white overlay for macOS-like shine
                    Rectangle {
                        anchors.fill: parent
                        color: "#15ffffff"
                        radius: 12
                    }
                    border.width: 1
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 16
                        
                        Text {
                            text: "power"
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: 28
                            color: "#00ff00"
                        }
                        
                        ColumnLayout {
                            spacing: 4
                            
                            Text {
                                text: "Desktop Mode"
                                font.pixelSize: 18
                                font.weight: Font.Bold
                                color: "#ffffff"
                            }
                            
                            Text {
                                text: "Connected to AC power"
                                font.pixelSize: 12
                                color: "#cccccc"
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }
                
                // Power profiles section
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    color: "#2a2a2a"
                    radius: 12
                    border.color: "#33ffffff"
                    border.width: 1
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 16
                        
                        // Section header
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Text {
                                text: "tune"
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 20
                                color: "#cccccc"
                            }
                            
                            Text {
                                text: "Power Profile"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: "#ffffff"
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Text {
                                text: getProfileDisplayInfo(currentProfile).name
                                font.pixelSize: 14
                                color: "#00ff00"
                                font.weight: Font.Medium
                            }
                        }
                        
                        // Profile selection
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            
                            Repeater {
                                model: [
                                    {profile: PowerProfile.PowerSaver, name: "Power Saver", icon: "battery_saver", color: "#00ff00"},
                                    {profile: PowerProfile.Balanced, name: "Balanced", icon: "tune", color: "#ffaa00"},
                                    {profile: PowerProfile.Performance, name: "Performance", icon: "speed", color: "#ff6666"}
                                ]
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 100
                                    color: modelData.profile === currentProfile ? "#333333" : "transparent"
                                    radius: 8
                                    border.color: modelData.profile === currentProfile ? "#5700eeff" : "transparent"
                                    border.width: 2
                                    
                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 8
                                        
                                        Text {
                                            text: modelData.icon
                                            font.family: "Material Symbols Outlined"
                                            font.pixelSize: 24
                                            color: modelData.color
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                        
                                        Text {
                                            text: modelData.name
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                            color: "#ffffff"
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                        
                                        Text {
                                            text: modelData.profile === currentProfile ? "Active" : ""
                                            font.pixelSize: 10
                                            color: "#00ff00"
                                            Layout.alignment: Qt.AlignHCenter
                                            visible: modelData.profile === currentProfile
                                        }
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            setPowerProfile(modelData.profile)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Power settings section
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 160
                    color: "#2a2a2a"
                    radius: 12
                    border.color: "#33ffffff"
                    border.width: 1
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 16
                        
                        // Section header
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Text {
                                text: "settings"
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 20
                                color: "#cccccc"
                            }
                            
                            Text {
                                text: "Power Settings"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: "#ffffff"
                            }
                            
                            Item { Layout.fillWidth: true }
                        }
                        
                        // Settings controls
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: 20
                            rowSpacing: 12
                            
                            Text {
                                text: "Screen Timeout"
                                font.pixelSize: 12
                                color: "#cccccc"
                            }
                            
                            ComboBox {
                                id: screenTimeoutCombo
                                model: ["Never", "1 minute", "5 minutes", "10 minutes", "15 minutes", "30 minutes"]
                                currentIndex: 2
                                background: Rectangle {
                                    color: "#333333"
                                    radius: 6
                                    border.color: "#555555"
                                    border.width: 1
                                }
                                contentItem: Text {
                                    text: screenTimeoutCombo.displayText
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: "Sleep Timeout"
                                font.pixelSize: 12
                                color: "#cccccc"
                            }
                            
                            ComboBox {
                                id: sleepTimeoutCombo
                                model: ["Never", "5 minutes", "10 minutes", "15 minutes", "30 minutes", "1 hour"]
                                currentIndex: 3
                                background: Rectangle {
                                    color: "#333333"
                                    radius: 6
                                    border.color: "#555555"
                                    border.width: 1
                                }
                                contentItem: Text {
                                    text: sleepTimeoutCombo.displayText
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                Layout.fillWidth: true
                            }
                        }
                        
                        // Advanced settings button
                        Button {
                            text: "Advanced Settings"
                            background: Rectangle {
                                color: parent.pressed ? "#404040" : "#505050"
                                radius: 6
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 12
                            }
                            onClicked: {
                                showAdvancedSettings = true
                            }
                            Layout.fillWidth: true
                        }
                    }
                }
                
                // Advanced Power Settings (shown when showAdvancedSettings is true)
                Rectangle {
                    visible: showAdvancedSettings
                    Layout.fillWidth: true
                    Layout.preferredHeight: 330
                    color: "#2a2a2a"
                    radius: 12
                    border.color: "#33ffffff"
                    border.width: 1
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 20
                        
                        // Section header
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Text {
                                text: "tune"
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 20
                                color: "#cccccc"
                            }
                            
                            Text {
                                text: "Advanced Power Settings"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: "#ffffff"
                            }
                            
                            Item { Layout.fillWidth: true }
                        }
                        
                        // CPU frequency scaling
                        ColumnLayout {
                            spacing: 12
                            
                            Text {
                                text: "CPU Frequency Scaling"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#ffffff"
                            }
                            
                            RowLayout {
                                spacing: 20
                                
                                RadioButton {
                                    id: powersaveRadio
                                    text: "Powersave"
                                    spacing: 16
                                    indicator: Rectangle {
                                        width: 16
                                        height: 16
                                        radius: 8
                                        border.color: powersaveRadio.checked ? "#5700eeff" : "#555555"
                                        border.width: 2
                                        anchors.verticalCenter: parent.verticalCenter
                                        
                                        Rectangle {
                                            width: 8
                                            height: 8
                                            radius: 4
                                            color: powersaveRadio.checked ? "#5700eeff" : "transparent"
                                            anchors.centerIn: parent
                                        }
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "#ffffff"
                                        font.pixelSize: 12
                                        leftPadding: 20
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                                
                                RadioButton {
                                    id: ondemandRadio
                                    text: "On Demand"
                                    checked: true
                                    spacing: 16
                                    indicator: Rectangle {
                                        width: 16
                                        height: 16
                                        radius: 8
                                        border.color: ondemandRadio.checked ? "#5700eeff" : "#555555"
                                        border.width: 2
                                        anchors.verticalCenter: parent.verticalCenter
                                        
                                        Rectangle {
                                            width: 8
                                            height: 8
                                            radius: 4
                                            color: ondemandRadio.checked ? "#5700eeff" : "transparent"
                                            anchors.centerIn: parent
                                        }
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "#ffffff"
                                        font.pixelSize: 12
                                        leftPadding: 20
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                                
                                RadioButton {
                                    id: performanceRadio
                                    text: "Performance"
                                    spacing: 16
                                    indicator: Rectangle {
                                        width: 16
                                        height: 16
                                        radius: 8
                                        border.color: performanceRadio.checked ? "#5700eeff" : "#555555"
                                        border.width: 2
                                        anchors.verticalCenter: parent.verticalCenter
                                        
                                        Rectangle {
                                            width: 8
                                            height: 8
                                            radius: 4
                                            color: performanceRadio.checked ? "#5700eeff" : "transparent"
                                            anchors.centerIn: parent
                                        }
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "#ffffff"
                                        font.pixelSize: 12
                                        leftPadding: 20
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }
                        
                        // Battery optimization
                        ColumnLayout {
                            spacing: 12
                            
                            Text {
                                text: "Battery Optimization"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#ffffff"
                            }
                            
                            CheckBox {
                                id: lowPowerModeCheck
                                text: "Low Power Mode"
                                checked: false
                                spacing: 16
                                indicator: Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 2
                                    border.color: lowPowerModeCheck.checked ? "#5700eeff" : "#555555"
                                    border.width: 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    
                                    Text {
                                        text: "✓"
                                        color: "#5700eeff"
                                        font.pixelSize: 12
                                        anchors.centerIn: parent
                                        visible: lowPowerModeCheck.checked
                                    }
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    leftPadding: 20
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            
                            CheckBox {
                                id: dimScreenCheck
                                text: "Dim screen when on battery"
                                checked: true
                                spacing: 16
                                indicator: Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 2
                                    border.color: dimScreenCheck.checked ? "#5700eeff" : "#555555"
                                    border.width: 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    
                                    Text {
                                        text: "✓"
                                        color: "#5700eeff"
                                        font.pixelSize: 12
                                        anchors.centerIn: parent
                                        visible: dimScreenCheck.checked
                                    }
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    leftPadding: 20
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                        
                        // Power actions
                        ColumnLayout {
                            spacing: 12
                            
                            Text {
                                text: "Power Actions"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#ffffff"
                            }
                            
                            RowLayout {
                                spacing: 12
                                
                                Button {
                                    text: "Suspend"
                                    Layout.fillWidth: true
                                    background: Rectangle {
                                        color: parent.pressed ? "#404040" : "#505050"
                                        radius: 6
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: 12
                                    }
                                    onClicked: {
                                        Quickshell.Io.Process.exec("systemctl suspend", function(exitCode, stdout, stderr) {
                                            console.log("System suspended")
                                        })
                                    }
                                }
                                
                                Button {
                                    text: "Hibernate"
                                    Layout.fillWidth: true
                                    background: Rectangle {
                                        color: parent.pressed ? "#404040" : "#505050"
                                        radius: 6
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: 12
                                    }
                                    onClicked: {
                                        Quickshell.Io.Process.exec("systemctl hibernate", function(exitCode, stdout, stderr) {
                                            console.log("System hibernated")
                                        })
                                    }
                                }
                                
                                Button {
                                    text: "Restart"
                                    Layout.fillWidth: true
                                    background: Rectangle {
                                        color: parent.pressed ? "#ff4444" : "#ff6666"
                                        radius: 6
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: 12
                                    }
                                    onClicked: {
                                        Quickshell.Io.Process.exec("systemctl reboot", function(exitCode, stdout, stderr) {
                                            console.log("System restarting")
                                        })
                                    }
                                }
                                
                                Button {
                                    text: "Shutdown"
                                    Layout.fillWidth: true
                                    background: Rectangle {
                                        color: parent.pressed ? "#ff4444" : "#ff6666"
                                        radius: 6
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: 12
                                    }
                                    onClicked: {
                                        Quickshell.Io.Process.exec("systemctl poweroff", function(exitCode, stdout, stderr) {
                                            console.log("System shutting down")
                                        })
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