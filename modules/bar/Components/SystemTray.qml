import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Qt5Compat.GraphicalEffects
import Quickshell.Services.SystemTray

Row {
    property var bar
    property var shell
    property var trayMenu
    spacing: 8
    Layout.alignment: Qt.AlignVCenter
    property bool containsMouse: false
    property var systemTray: SystemTray
    
    // Error handling and connection management
    property bool trayAvailable: systemTray && systemTray.items
    property int connectionRetries: 0
    property int maxRetries: 3
    
    // Retry connection if tray fails to load
    Timer {
        id: retryTimer
        interval: 2000
        repeat: false
        onTriggered: {
            if (!trayAvailable && connectionRetries < maxRetries) {
                connectionRetries++
                console.log("SystemTray: Retrying connection, attempt", connectionRetries)
                // Force refresh of system tray
                if (systemTray && typeof systemTray.refresh === 'function') {
                    systemTray.refresh()
                }
            }
        }
    }
    
    Component.onCompleted: {
        if (!trayAvailable) {
            console.log("SystemTray: Initial connection failed, scheduling retry")
            retryTimer.start()
        }
    }
    
    Repeater {
        model: trayAvailable ? systemTray.items : []
        
        delegate: Item {
            width: 32
            height: 32
            
            // Better visibility check with error handling
            visible: modelData && modelData.id && modelData.id !== "spotify" && modelData.icon
            
            property bool isHovered: trayMouseArea.containsMouse
            
            // Hover scale animation
            scale: isHovered ? 1.15 : 1.0
            Behavior on scale {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }
            
            // Subtle rotation on hover
            rotation: isHovered ? 5 : 0
            Behavior on rotation {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
            
            Rectangle {
                anchors.centerIn: parent
                width: 40
                height: 40
                radius: 6
                color: "transparent"
                clip: true
                
                Image {
                    id: trayIcon
                    anchors.centerIn: parent
                    width: 24
                    height: 24
                    smooth: true
                    asynchronous: true
                    fillMode: Image.PreserveAspectFit
                    source: {
                        if (!modelData || !modelData.icon) return ""
                        // Handle different icon formats
                        const icon = modelData.icon
                        if (icon.startsWith("file://")) return icon
                        if (icon.startsWith("/")) return "file://" + icon
                        return icon
                    }
                    
                    opacity: status === Image.Ready ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                    
                    // Error handling for failed icon loads
                    onStatusChanged: {
                        if (status === Image.Error) {
                            console.log("SystemTray: Failed to load icon for", modelData?.id || "unknown")
                        }
                    }
                }
            }
            
            MouseArea {
                id: trayMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                
                onClicked: (mouse) => {
                    if (!modelData || !modelData.id) {
                        console.log("SystemTray: Invalid tray item clicked")
                        return
                    }
                    
                    try {
                        if (mouse.button === Qt.LeftButton) {
                            // Close any open menu first
                            if (trayMenu && trayMenu.visible) {
                                trayMenu.hideMenu()
                            }
                            
                            if (!modelData.onlyMenu && typeof modelData.activate === 'function') {
                                modelData.activate()
                            }
                        } else if (mouse.button === Qt.MiddleButton) {
                            // Close any open menu first
                            if (trayMenu && trayMenu.visible) {
                                trayMenu.hideMenu()
                            }
                            
                            if (typeof modelData.secondaryActivate === 'function') {
                                modelData.secondaryActivate()
                            }
                        } else if (mouse.button === Qt.RightButton) {
                            trayTooltip.tooltipVisible = false
                            
                            // If menu is already visible, close it
                            if (trayMenu && trayMenu.visible) {
                                trayMenu.hideMenu()
                                return
                            }
                            
                            if (modelData.hasMenu && modelData.menu && trayMenu) {
                                // Anchor the menu to the tray icon item (parent) and position it below the icon
                                const menuX = (width / 2) - (trayMenu.width / 2)
                                const menuY = height + 20
                                trayMenu.menu = modelData.menu
                                trayMenu.showAt(parent, menuX, menuY)
                            }
                        }
                    } catch (error) {
                        console.log("SystemTray: Error handling click for", modelData.id, ":", error)
                    }
                }
                
                onEntered: trayTooltip.tooltipVisible = true
                onExited: trayTooltip.tooltipVisible = false
            }
            
            // Simple tooltip
            Rectangle {
                id: trayTooltip
                visible: tooltipVisible
                color: "#1a1a1a"
                border.color: "#333333"
                border.width: 1
                radius: 4
                width: tooltipText.width + 12
                height: tooltipText.height + 8
                
                property bool tooltipVisible: false
                
                // Position tooltip above the icon
                anchors.bottom: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 8
                
                Text {
                    id: tooltipText
                    anchors.centerIn: parent
                    text: modelData.tooltipTitle || modelData.name || modelData.id || "Tray Item"
                    color: "#ffffff"
                    font.pixelSize: 11
                }
                
                // Fade in/out animation
                opacity: tooltipVisible ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
            }
            
            Component.onDestruction: {
                // No cache cleanup needed
            }
        }
    }
} 