import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Settings
import qs.Services
import Quickshell.Services.Pipewire

PanelWindow {
    id: settingsWindow

    WlrLayershell.namespace: "quickshell:settings:blur"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    
    // Floating behavior - don't push other windows out of the way
    exclusiveZone: 0
    
    // Position the window in the center of the screen
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    
    implicitWidth: 1920
    implicitHeight: 1440
    
    // Make the panel window transparent
    color: "transparent"
    
    // Ensure window gets focus when it becomes visible
    onVisibleChanged: {
        console.log("Settings window visibility changed to:", visible)
        if (visible) {
            settingsContent.forceActiveFocus()
            openAnimation.start()
        } else {
            closeAnimation.start()
            // Save current settings when settings window closes
            console.log("Settings window closing, saving current settings")
            saveCurrentSettings()
        }
    }
    
    // Window open/close animations
    property real windowScale: visible ? 1.0 : 0.9
    property real windowOpacity: visible ? 1.0 : 0.0
    
    NumberAnimation {
        id: openAnimation
        target: settingsWindow
        property: "windowScale"
        from: 0.9
        to: 1.0
        duration: 300
        easing.type: Easing.OutCubic
    }
    
    NumberAnimation {
        id: closeAnimation
        target: settingsWindow
        property: "windowOpacity"
        from: 1.0
        to: 0.0
        duration: 200
        easing.type: Easing.InCubic
    }
    
    // Current selected tab
    property int currentTab: 0
    

    
    function createSettingsConf() {
        console.log("createSettingsConf() called")
        try {
            // Only create the file if it doesn't exist
            var settingsFile = Quickshell.env("HOME") + "/.local/state/Quickshell/Settings.conf"
            var settingsData = Quickshell.Io.readFile(settingsFile)
            
            if (!settingsData || settingsData.length === 0) {
                // File doesn't exist, create empty settings object
                var settings = {}
                saveSettings(settings)
                console.log("Created empty Settings.conf file")
            } else {
                console.log("Settings.conf already exists, preserving existing settings")
            }
        } catch (e) {
            console.log("Error in createSettingsConf:", e)
        }
    }
    
    function saveSettings(settings) {
        try {
            console.log("=== saveSettings ===")
            console.log("Settings to save:", settings)
            
            // Create the directory if it doesn't exist
            var settingsDir = Quickshell.env("HOME") + "/.local/state/Quickshell"
            var settingsFile = settingsDir + "/Settings.conf"
            console.log("Creating directory:", settingsDir)
            Hyprland.dispatch(`exec mkdir -p '${settingsDir}'`);
            
            // Write the JSON content to the file using a more reliable method
            var jsonContent = JSON.stringify(settings, null, 2);
            console.log("JSON content to write:", jsonContent)
            
            // Use a temporary file approach to avoid shell escaping issues
            var tempFile = settingsDir + '/Settings.tmp'
            var finalFile = settingsFile
            
            // Write to temp file first
            var writeCommand = `echo '${jsonContent.replace(/'/g, "'\"'\"'")}' > '${tempFile}'`
            console.log("Write command:", writeCommand)
            Hyprland.dispatch(`exec ${writeCommand}`)
            
            // Move temp file to final location
            Hyprland.dispatch(`exec mv '${tempFile}' '${finalFile}'`)
            
            console.log("✓ Settings file saved successfully to:", finalFile)
        } catch (e) {
            console.log("✗ Error saving settings:", e)
            console.log("Error details:", e.message || e)
        }
    }
    
    function loadSettings() {
        try {
            var settingsFile = Quickshell.env("HOME") + "/.local/state/Quickshell/Settings.conf"
            var settingsData = Quickshell.Io.readFile(settingsFile)
            if (settingsData && settingsData.length > 0) {
                var settings = JSON.parse(settingsData)
                console.log("Loaded settings:", settings)
                return settings
            } else {
                // If file doesn't exist or is empty, return empty object
                console.log("Settings file doesn't exist or is empty")
                return {}
            }
        } catch (e) {
            console.log("Error loading settings:", e)
            return {}
        }
    }
    

    
            // Main settings content
        Rectangle {
            id: settingsContent
            anchors.centerIn: parent
            width: parent.width * 0.9
            height: parent.height * 0.9
            color: "transparent"
            radius: 20
            border.color: "#5700eeff"
            border.width: 1
            focus: true
            
            // macOS Tahoe-style transparency effect
            Rectangle {
                anchors.fill: parent
                color: "#1a1a1a"
                opacity: 0.8
                radius: 20
            }
            
            // Dark mode backdrop
            Rectangle {
                anchors.fill: parent
                color: "#0a0a0a"
                opacity: 0.3
                radius: 20
            }
            
            // Semi-transparent white border overlay
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                radius: 20
                border.color: "#40ffffff"
                border.width: 1
            }
            
            // Semi-transparent white overlay for macOS-like shine
            Rectangle {
                anchors.fill: parent
                color: "#15ffffff"
                radius: 20
            }
            
            // Scale and opacity animations
            scale: settingsWindow.windowScale
            
            Behavior on scale {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
            
            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

        
        // Close on escape key
        Keys.onEscapePressed: {
            settingsWindow.visible = false
        }
        
        // Window controls (close, minimize, maximize) at top left
        Row {
            id: windowControls
            anchors {
                top: parent.top
                left: parent.left
                topMargin: 15
                leftMargin: 20
            }
            spacing: 12
            
            // Close button (red)
            Rectangle {
                width: 14
                height: 14
                radius: 7
                color: closeMouseArea.containsMouse ? "#ff5f56" : "#ff5f56"
                border.color: closeMouseArea.containsMouse ? "#ff7f76" : "#ff5f56"
                border.width: 1
                
                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        settingsWindow.visible = false
                    }
                }
            }
            
            // Minimize button (yellow)
            Rectangle {
                width: 14
                height: 14
                radius: 7
                color: minimizeMouseArea.containsMouse ? "#ffbd2e" : "#ffbd2e"
                border.color: minimizeMouseArea.containsMouse ? "#ffd54f" : "#ffbd2e"
                border.width: 1
                
                MouseArea {
                    id: minimizeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        // Minimize functionality (placeholder)
                        console.log("Minimize clicked")
                    }
                }
            }
            
            // Maximize button (green)
            Rectangle {
                width: 14
                height: 14
                radius: 7
                color: maximizeMouseArea.containsMouse ? "#28ca42" : "#28ca42"
                border.color: maximizeMouseArea.containsMouse ? "#4caf50" : "#28ca42"
                border.width: 1
                
                MouseArea {
                    id: maximizeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        // Maximize functionality (placeholder)
                        console.log("Maximize clicked")
                    }
                }
            }
        }
        
        // Main content layout with sidebar and content area
        RowLayout {
            anchors {
                fill: parent
                margins: 16
                topMargin: 50
            }
            spacing: 16
            
            // Left sidebar navigation
            Rectangle {
                id: sidebar
                Layout.preferredWidth: 240
                Layout.fillHeight: true
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
                
                // Sidebar animation
                property real slideOffset: 0
                
                Component.onCompleted: {
                    slideOffset = -20
                    sidebarSlideAnimation.start()
                }
                
                NumberAnimation {
                    id: sidebarSlideAnimation
                    target: sidebar
                    property: "slideOffset"
                    from: -20
                    to: 0
                    duration: 400
                    easing.type: Easing.OutCubic
                }
                
                transform: Translate {
                    x: sidebar.slideOffset
                }
                
                opacity: 1 - (Math.abs(sidebar.slideOffset) / 20)
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16
                    
                    // Search bar at top
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        color: "transparent"
                        radius: 8
                        border.color: "#44ffffff"
                        border.width: 1
                        
                        // macOS Tahoe-style transparency effect
                        Rectangle {
                            anchors.fill: parent
                            color: "#333333"
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
                        
                        // Semi-transparent white border overlay
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            radius: 8
                            border.color: "#40ffffff"
                            border.width: 1
                        }
                        
                        // Semi-transparent white overlay for macOS-like shine
                        Rectangle {
                            anchors.fill: parent
                            color: "#15ffffff"
                            radius: 8
                        }
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8
                            
                            Text {
                                text: "search"
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 16
                                color: "#888888"
                                Layout.alignment: Qt.AlignVCenter
                            }
                            
                            Text {
                                text: "Search settings..."
                                font.pixelSize: 12
                                color: "#888888"
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }
                    }
                    
                    // User profile section
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 90
                        color: "transparent"
                        radius: 8
                        border.color: "#44ffffff"
                        border.width: 1
                        
                        // macOS Tahoe-style transparency effect
                        Rectangle {
                            anchors.fill: parent
                            color: "#333333"
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
                        
                        // Semi-transparent white border overlay
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            radius: 8
                            border.color: "#40ffffff"
                            border.width: 1
                        }
                        
                        // Semi-transparent white overlay for macOS-like shine
                        Rectangle {
                            anchors.fill: parent
                            color: "#15ffffff"
                            radius: 8
                        }
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12
                            
                            // User avatar
                            Rectangle {
                                width: 64
                                height: 64
                                radius: 16
                                color: "#5700eeff"
                                border.color: "#7700eeff"
                                border.width: 1
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "QS"
                                    font.pixelSize: 20
                                    font.weight: Font.Bold
                                    color: "#ffffff"
                                }
                            }
                            
                            ColumnLayout {
                                spacing: 2
                                
                                Text {
                                    text: Quickshell.env("USER") || "User"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                    color: "#ffffff"
                                }
                                
                                Text {
                                    text: "System Account"
                                    font.pixelSize: 10
                                    color: "#cccccc"
                                }
                            }
                            
                            Item { Layout.fillWidth: true }
                        }
                    }
                    
                    // Navigation items
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        
                        ColumnLayout {
                            width: parent.width
                            spacing: 16
                            
                            // Settings categories
                            Repeater {
                                model: [
                                    {icon: "wifi", text: "Wi-Fi", selected: false},
                                    {icon: "bluetooth", text: "Bluetooth", selected: false},
                                    {icon: "language", text: "Network", selected: false},
                                    {icon: "battery_full", text: "Power", selected: false},
                                    {icon: "settings", text: "Calendar", selected: true},
                                    {icon: "palette", text: "Appearance", selected: false},
                                    {icon: "desktop_windows", text: "Desktop & Dock", selected: false},
                                    {icon: "wallpaper", text: "Wallpaper", selected: false},
                                    {icon: "notifications", text: "Notifications", selected: false},
                                    {icon: "volume_up", text: "Sound", selected: false},
                                    {icon: "wb_sunny", text: "Weather", selected: false},
                                    {icon: "computer", text: "System", selected: false}
                                ]
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    color: currentTab === index ? "#5700eeff" : "transparent"
                                    radius: 6
                                    border.color: currentTab === index ? "#7700eeff" : "transparent"
                                    border.width: 1
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 12
                                        
                                        Text {
                                            text: modelData.icon
                                            font.family: "Material Symbols Outlined"
                                            font.pixelSize: 18
                                            color: currentTab === index ? "#ffffff" : "#cccccc"
                                            Layout.alignment: Qt.AlignVCenter
                                        }
                                        
                                        Text {
                                            text: modelData.text
                                            font.pixelSize: 18
                                            font.weight: currentTab === index ? Font.Medium : Font.Normal
                                            color: currentTab === index ? "#ffffff" : "#cccccc"
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignVCenter
                                        }
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            // Handle tab selection
                                            currentTab = index
                                            console.log("Selected tab:", modelData.text)
                                        }
                                    }
                                    
                                    Behavior on color {
                                        ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                                    }
                                    
                                    Behavior on border.color {
                                        ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                                    }
                                    
                                    // Hover effect
                                    property bool isHovered: false
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: parent.isHovered = true
                                        onExited: parent.isHovered = false
                                        onClicked: {
                                            // Handle tab selection with animation
                                            currentTab = index
                                            console.log("Selected tab:", modelData.text)
                                        }
                                    }
                                    
                                    // Hover animation
                                    Rectangle {
                                        anchors.fill: parent
                                        color: parent.isHovered ? "#2200eeff" : "transparent"
                                        radius: 6
                                        opacity: parent.isHovered ? 1 : 0
                                        
                                        Behavior on opacity {
                                            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Right content area
            Rectangle {
                id: contentArea
                Layout.fillWidth: true
                Layout.fillHeight: true
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
                
                // Content area animation
                property real slideOffset: 0
                
                Component.onCompleted: {
                    slideOffset = 20
                    contentSlideAnimation.start()
                }
                
                NumberAnimation {
                    id: contentSlideAnimation
                    target: contentArea
                    property: "slideOffset"
                    from: 20
                    to: 0
                    duration: 400
                    easing.type: Easing.OutCubic
                }
                
                transform: Translate {
                    x: contentArea.slideOffset
                }
                
                opacity: 1 - (Math.abs(contentArea.slideOffset) / 20)
                
                
                // Load different tab content based on currentTab
                Loader {
                    id: tabLoader
                    anchors.fill: parent
                    source: {
                        switch(currentTab) {
                            case 0: return "settings/WifiTab.qml"
                            case 1: return "settings/BluetoothTab.qml" // Bluetooth tab
                            case 2: return "settings/NetworkTab.qml" // Network will use NetworkTab
                            case 3: return "settings/PowerTab.qml" // Power tab
                            case 4: return "settings/CalendarTab.qml" // Calendar tab
                            case 5: return "settings/GeneralTab.qml" // Appearance tab
                            case 6: return "settings/DesktopDockTab.qml" // Desktop & Dock tab
                            case 7: return "settings/WallpaperTab.qml" // Wallpaper tab
                            case 8: return "settings/GeneralTab.qml" // Notifications tab
                            case 9: return "settings/SoundTab.qml" // Sound tab
                            case 10: return "settings/WeatherTab.qml" // Weather tab
                            case 11: return "settings/SystemTab.qml" // System tab
                            default: return "settings/GeneralTab.qml"
                        }
                    }
                    
                    // Tab transition animation
                    property real slideOffset: 0
                    
                    onSourceChanged: {
                        // Slide animation for tab changes
                        slideOffset = 20
                        slideAnimation.start()
                    }
                    
                    NumberAnimation {
                        id: slideAnimation
                        target: tabLoader
                        property: "slideOffset"
                        from: 20
                        to: 0
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                    
                    transform: Translate {
                        x: tabLoader.slideOffset
                    }
                    
                    opacity: 1 - (Math.abs(tabLoader.slideOffset) / 20)
                }
            }
        }
    }
} 