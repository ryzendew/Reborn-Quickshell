import QtQuick
import Quickshell
import Quickshell.Hyprland

Rectangle {
    id: workspacesContainer
    color: "transparent"
    border.color: "#00ccff"
    border.width: 2
    radius: 20
    implicitWidth: workspacesRow.implicitWidth + 4
    implicitHeight: workspacesRow.implicitHeight + 4
    
    // Get current workspace
    property int currentWorkspace: 1
    
    // Connect to Hyprland events for workspace changes
    Connections {
        target: Hyprland
        
        function onRawEvent(event) {
            if (event.name.includes("workspace")) {
                Qt.callLater(updateCurrentWorkspace)
            }
        }
    }
    
    // Connect to workspace values changes
    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() {
            Qt.callLater(updateCurrentWorkspace)
        }
    }
    
    // Update current workspace function
    function updateCurrentWorkspace() {
        try {
            const workspaces = Hyprland.workspaces.values
            
            for (let i = 0; i < workspaces.length; i++) {
                const ws = workspaces[i]
                if (ws.focused === true) {
                    if (ws.id !== currentWorkspace) {
                        currentWorkspace = ws.id
                    }
                    break
                }
            }
        } catch (error) {
            // Error handling without logging
        }
    }
    
    // Initial workspace detection
    Component.onCompleted: {
        updateCurrentWorkspace()
    }
    
    Row {
        id: workspacesRow
        spacing: 4
        anchors.centerIn: parent
        padding: 4
        
        // 10 static workspaces
        Repeater {
            model: 10
            
            Rectangle {
                width: 28
                height: 22
                radius: 14
                color: isActive ? "#00ffff" : "#1a1a1a"
                border.color: isActive ? "#ffffff" : "#333333"
                border.width: isActive ? 2 : 1
                
                property bool isActive: (index + 1) === currentWorkspace
                
                // Bright cyan glow for active workspace only
                Rectangle {
                    visible: isActive
                    anchors.fill: parent
                    radius: 14
                    color: "#00ffff"
                    opacity: 0.6
                    
                    // Animated glow
                    SequentialAnimation on opacity {
                        running: isActive
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.3; duration: 500 }
                        NumberAnimation { to: 0.9; duration: 500 }
                    }
                }
                
                // Outer cyan glow ring for active workspace only
                Rectangle {
                    visible: isActive
                    anchors.centerIn: parent
                    width: parent.width + 8
                    height: parent.height + 8
                    radius: 16
                    color: "transparent"
                    border.color: "#00ffff"
                    border.width: 2
                    opacity: 1.0
                    
                    // Animated outer glow
                    SequentialAnimation on opacity {
                        running: isActive
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.4; duration: 700 }
                        NumberAnimation { to: 1.0; duration: 700 }
                    }
                }
                
                // Additional bright cyan halo for active workspace only
                Rectangle {
                    visible: isActive
                    anchors.centerIn: parent
                    width: parent.width + 12
                    height: parent.height + 12
                    radius: 18
                    color: "#00ffff"
                    opacity: 0.2
                    
                    // Animated halo
                    SequentialAnimation on opacity {
                        running: isActive
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.1; duration: 1000 }
                        NumberAnimation { to: 0.4; duration: 1000 }
                    }
                }
                
                // Make workspaces clickable
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Hyprland.dispatch("workspace " + (index + 1))
                    onEntered: parent.scale = 1.1
                    onExited: parent.scale = 1.0
                }
                
                // Hover effect
                Behavior on scale {
                    NumberAnimation { duration: 150 }
                }
                
                Text {
                    text: (index + 1).toString()
                    anchors.centerIn: parent
                    color: isActive ? "#000000" : "#00ffff"
                    font.pixelSize: 11
                    font.family: "Inter, sans-serif"
                    font.bold: isActive
                }
            }
        }
    }
} 