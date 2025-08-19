import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick.Layouts
import Quickshell.Hyprland
import QtQuick.Controls
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects

PanelWindow {
    id: notificationPanel

     WlrLayershell.namespace: "quickshell:notificationPanel:blur"
    WlrLayershell.layer: WlrLayer.Overlay
    
    // Set the specific screen (use focused monitor or fallback to first available)
    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) || Quickshell.screens[0]
    
    // Position in top left
    anchors {
        top: true
        left: true
    }
    
    // Make panel completely transparent
    color: "transparent"
    
    // Ensure transparency is enabled
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    
    // Add transparent background to ensure no opaque areas
    Rectangle {
        anchors.fill: parent
        color: "transparent"
    }
    
    // Don't take up space in layout
    exclusiveZone: 0
    
    // Don't grab keyboard focus - this is the key for non-blocking
    focusable: false
    
    // Ensure panel can be wide enough
    implicitWidth: 600
    implicitHeight: notificationColumn.implicitHeight + 20
    property var notifications: []
    property int maxVisible: 5
    property int spacing: 10
    
    // Function to add notification - exactly like Noctalia
    function addNotification(notification) {
        var notifObj = {
            id: notification.id,
            appName: notification.appName || "Notification",
            summary: notification.summary || "",
            body: notification.body || "",
            rawNotification: notification
        };
        
        notifications.unshift(notifObj);
        
        if (notifications.length > maxVisible) {
            notifications = notifications.slice(0, maxVisible);
        }
        
        visible = true;
        notificationsChanged();
    }
    
    // Function to dismiss notification - exactly like Noctalia
    function dismissNotification(id) {
        notifications = notifications.filter(n => n.id !== id);
        if (notifications.length === 0) {
            visible = false;
        }
        notificationsChanged();
    }
    
    // Notification stack - positioned from left with proper spacing
    Column {
        id: notificationColumn
        anchors {
            left: parent.left
            leftMargin: 5
            top: parent.top
            topMargin: 5
        }
        spacing: notificationPanel.spacing
        width: 320
        clip: false
        
        // Notification items
        Repeater {
            model: notifications
            
            Rectangle {
                id: notificationDelegate
                width: parent.width
                implicitHeight: contentRow.height + 20
                color: Qt.rgba(0.1, 0.1, 0.1, 0.8)
                radius: 12
                border.color: "#00ffff"
                border.width: 2
                
                RowLayout {
                    id: contentRow
                    anchors.centerIn: parent
                    spacing: 15
                    width: parent.width - 20
                    
                    // App icon with album art support
                    Rectangle {
                        id: iconBackground
                        width: 94
                        implicitHeight: 94
                        radius: 60
                        color: "#333333"
                        border.color: "#555555"
                        border.width: 1
                        
                        // Try to load app icon or album art with circular mask
                        Image {
                            id: appIcon
                            anchors.fill: parent
                            anchors.margins: 4
                            source: {
                                // Priority order: album art > app icon > notification icon
                                if (modelData.rawNotification && modelData.rawNotification.image) {
                                    return modelData.rawNotification.image;
                                } else if (modelData.rawNotification && modelData.rawNotification.appIcon) {
                                    return modelData.rawNotification.appIcon;
                                } else if (modelData.rawNotification && modelData.rawNotification.icon) {
                                    return modelData.rawNotification.icon;
                                }
                                return "";
                            }
                            fillMode: Image.PreserveAspectCrop
                            visible: status === Image.Ready && source.toString() !== ""
                            
                            // Circular mask for album art
                            layer.enabled: true
                            layer.smooth: true
                            layer.samples: 4
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: appIcon.width
                                    implicitHeight: appIcon.height
                                    radius: width / 2
                                }
                            }
                        }
                        
                        // Fallback: show first letter of app name
                        Text {
                            anchors.centerIn: parent
                            text: modelData.appName ? modelData.appName.charAt(0).toUpperCase() : "?"
                            font.pixelSize: 20
                            font.bold: true
                            color: "#ffffff"
                            visible: !appIcon.visible
                        }
                    }
                    
                    // Notification content
                    Column {
                        width: contentRow.width - iconBackground.width - 10
                        spacing: 5
                        
                        Text {
                            text: modelData.appName
                            width: parent.width
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 20
                            font.family: "Inter, sans-serif"
                            elide: Text.ElideRight
                        }
                        
                        Text {
                            text: modelData.summary
                            width: parent.width
                            color: "#ffffff"
                            font.pixelSize: 20
                            font.family: "Inter, sans-serif"
                            wrapMode: Text.WordWrap
                            maximumLineCount: 8
                            elide: Text.ElideRight
                            visible: text !== ""
                        }
                        
                        Text {
                            text: modelData.body
                            width: parent.width
                            color: "#cccccc"
                            font.pixelSize: 20
                            font.family: "Inter, sans-serif"
                            wrapMode: Text.WordWrap
                            maximumLineCount: 8
                            elide: Text.ElideRight
                            visible: text !== ""
                        }
                    }
                }
                
                Timer {
                    interval: 4000
                    running: true
                    onTriggered: {
                        dismissAnimation.start();
                        if (modelData.rawNotification) {
                            modelData.rawNotification.expire();
                        }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        dismissAnimation.start();
                        if (modelData.rawNotification) {
                            modelData.rawNotification.dismiss();
                        }
                    }
                }
                
                ParallelAnimation {
                    id: dismissAnimation
                    NumberAnimation {
                        target: notificationDelegate
                        property: "opacity"
                        to: 0
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: notificationDelegate
                        property: "height"
                        to: 0
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                    onFinished: notificationPanel.dismissNotification(modelData.id)
                }
                
                Component.onCompleted: {
                    opacity = 0;
                    height = 0;
                    appearAnimation.start();
                }
                
                ParallelAnimation {
                    id: appearAnimation
                    NumberAnimation {
                        target: notificationDelegate
                        property: "opacity"
                        to: 1
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: notificationDelegate
                        property: "height"
                        to: contentRow.height + 20
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
    
    onNotificationsChanged: {
        height = notificationColumn.implicitHeight + 20
    }
    
    Connections {
        target: Quickshell
        function onScreensChanged() {
            if (notificationPanel.screen) {
                x = notificationPanel.screen.width - notificationPanel.width - 20
            }
        }
    }
    
    // Hyprland connections for detecting window changes and events
    Connections {
        target: Hyprland
        
        function onRawEvent(event) {
            // Log all window title changes for debugging
            if (event.name === "windowtitle" && event.data) {
                console.log("Window title changed:", event.data)
            }
        }
    }
    
    // Monitor active window changes
    Connections {
        target: Hyprland.toplevels
        
        function onValuesChanged() {
            // Log all active windows for debugging
            const toplevels = Hyprland.toplevels.values
            for (let i = 0; i < toplevels.length; i++) {
                const window = toplevels[i]
                if (window.title) {
                    console.log("Active window:", window.title)
                }
            }
        }
    }
    
    // Notification server - this is what detects notify-send!
    NotificationServer {
        id: notificationServer
        
        onNotification: function(notification) {
            console.log("[Notifications] Received notification:", notification.appName, "-", notification.summary);
            notification.tracked = true;
            
            // Add notification to our popup
            addNotification(notification);
        }
    }
    
    Component.onCompleted: {
        // console.log("Notifications component loaded successfully")
    }
} 