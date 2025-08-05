import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

PanelWindow {
    id: settingsWindow

    WlrLayershell.namespace: "quickshell:settings:blur"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    
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
    implicitHeight: 1080
    
    // Make the panel window transparent
    color: "transparent"
    
    // Ensure window gets focus when it becomes visible
    onVisibleChanged: {
        if (visible) {
            settingsContent.forceActiveFocus()
            openAnimation.start()
        } else {
            closeAnimation.start()
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
    
            // Main settings content
        Rectangle {
            id: settingsContent
            anchors.centerIn: parent
            width: parent.width * 0.9
            height: parent.height * 0.9
            color: "#1a1a1a"
            opacity: 0.95
            radius: 20
            border.color: "#5700eeff"
            border.width: 1
            focus: true
            
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
                color: "#2a2a2a"
                radius: 12
                border.color: "#33ffffff"
                border.width: 1
                
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
                        color: "#333333"
                        radius: 8
                        border.color: "#44ffffff"
                        border.width: 1
                        
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
                        Layout.preferredHeight: 64
                        color: "#333333"
                        radius: 8
                        border.color: "#44ffffff"
                        border.width: 1
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12
                            
                            // User avatar
                            Rectangle {
                                width: 32
                                height: 32
                                radius: 16
                                color: "#5700eeff"
                                border.color: "#7700eeff"
                                border.width: 1
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "QS"
                                    font.pixelSize: 12
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
                            spacing: 2
                            
                            // Settings categories
                            Repeater {
                                model: [
                                    {icon: "wifi", text: "Wi-Fi", selected: false},
                                    {icon: "bluetooth", text: "Bluetooth", selected: false},
                                    {icon: "language", text: "Network", selected: false},
                                    {icon: "battery_full", text: "Power", selected: false},
                                    {icon: "settings", text: "General", selected: true},
                                    {icon: "accessibility", text: "Accessibility", selected: false},
                                    {icon: "palette", text: "Appearance", selected: false},
                                    {icon: "desktop_windows", text: "Desktop & Dock", selected: false},
                                    {icon: "monitor", text: "Displays", selected: false},
                                    {icon: "wallpaper", text: "Wallpaper", selected: false},
                                    {icon: "notifications", text: "Notifications", selected: false},
                                    {icon: "volume_up", text: "Sound", selected: false},
                                    {icon: "focus_mode", text: "Focus", selected: false},
                                    {icon: "schedule", text: "Screen Time", selected: false}
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
                                            font.pixelSize: 12
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
                color: "#1a1a1a"
                radius: 12
                border.color: "#33ffffff"
                border.width: 1
                
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
                            case 3: return "settings/NetworkTab.qml" // Power will use NetworkTab for now
                            case 4: return "settings/GeneralTab.qml"
                            case 9: return "settings/WallpaperTab.qml" // Wallpaper tab
                            case 12: return "settings/SoundTab.qml" // Sound tab
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