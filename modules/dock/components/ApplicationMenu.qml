import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "root:/services"

PanelWindow {
    id: applicationMenu
    
    // Floating behavior - don't push other windows out of the way
    exclusiveZone: 0
    
    // Set keyboard focus mode to allow input when visible
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    
    // Timer to delay focus activation
    Timer {
        id: focusGrabTimer
        interval: 100
        onTriggered: {
            if (applicationMenu.visible) {
                searchField.forceActiveFocus()
            }
        }
    }
    
    // Ensure search field gets focus when menu becomes visible
    onVisibleChanged: {
        if (visible) {
            // Clear search and focus with delay to prevent interference
            searchField.text = ""
            focusGrabTimer.start()
        } else {
            focusGrabTimer.stop()
        }
    }
    
    // Menu configuration - position relative to screen
    anchors {
        bottom: parent.bottom
    }
    
    implicitWidth: 800
    implicitHeight: 600
    
    // Make the panel window transparent
    color: "transparent"
    
    // Main menu content
    Rectangle {
        id: menuContent
        anchors.fill: parent
        color: "#1a1a1a"
        radius: 15
        border.color: "#5700eeff"
        border.width: 1
        

        
        property var appModel: AppSearch.list
        property var filteredApps: []
        property int selectedIndex: 0
        
        // Search debounce timer
        Timer {
            id: searchTimer
            interval: 150
            onTriggered: menuContent.updateFilter()
        }
        
        function updateFilter() {
            var query = searchField.text ? searchField.text.toLowerCase() : "";
            var apps = appModel.slice();
            var results = [];
            
            if (!query) {
                results = results.concat(apps.sort(function (a, b) {
                    return a.name.toLowerCase().localeCompare(b.name.toLowerCase());
                }));
            } else {
                // Simple search: check if name, comment, or genericName contains the search term
                for (var i = 0; i < apps.length; i++) {
                    var app = apps[i];
                    if (app.name && app.name.toLowerCase().includes(query)) {
                        results.push(app);
                    } else if (app.comment && app.comment.toLowerCase().includes(query)) {
                        results.push(app);
                    } else if (app.genericName && app.genericName.toLowerCase().includes(query)) {
                        results.push(app);
                    }
                }
            }
            
            filteredApps = results;
            selectedIndex = 0;
        }
        
        function activateSelected() {
            if (filteredApps.length === 0) return;
            var modelData = filteredApps[selectedIndex];
            
            // Debug: log what we have
            console.log("Launching app:", modelData.name);
            console.log("exec:", modelData.exec);
            console.log("execString:", modelData.execString);
            console.log("execute function:", modelData.execute);
            
            const termEmu = Quickshell.env("TERMINAL") || Quickshell.env("TERM_PROGRAM") || "";
            
            if (modelData.runInTerminal && termEmu) {
                console.log("Launching in terminal:", modelData.execString);
                Quickshell.execDetached([termEmu, "-e", modelData.execString.trim()]);
            } else if (modelData.execute) {
                console.log("Using execute function");
                modelData.execute();
            } else {
                var execCmd = modelData.execString || modelData.exec || "";
                if (execCmd) {
                    execCmd = execCmd.replace(/\s?%[fFuUdDnNiCkvm]/g, '');
                    console.log("Launching with exec:", execCmd);
                    Quickshell.execDetached(["sh", "-c", execCmd.trim()]);
                } else {
                    console.log("No exec command found!");
                }
            }
            applicationMenu.visible = false;
            searchField.text = "";
        }
        
        Component.onCompleted: {
            menuContent.updateFilter();
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            // Header with search
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: "#2a2a2a"
                radius: 10
                border.color: "#33ffffff"
                border.width: 1
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    
                    // Search icon
                    Text {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        Layout.alignment: Qt.AlignVCenter
                        text: "search"
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 20
                        color: "#ffffff"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                                            // Search input
                        TextField {
                            id: searchField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            Layout.alignment: Qt.AlignVCenter
                            color: "#ffffff"
                            font.pixelSize: 14
                            text: ""
                            placeholderText: "Search applications..."
                            placeholderTextColor: "#888888"
                            background: null
                            focus: applicationMenu.visible
                            
                            onTextChanged: {
                                searchTimer.restart()
                            }
                            
                            Keys.onDownPressed: menuContent.selectNext()
                            Keys.onUpPressed: menuContent.selectPrev()
                            Keys.onEnterPressed: menuContent.activateSelected()
                            Keys.onReturnPressed: menuContent.activateSelected()
                            Keys.onEscapePressed: applicationMenu.visible = false
                            
                            // Ensure focus when menu becomes visible
                            Component.onCompleted: {
                                if (applicationMenu.visible) {
                                    forceActiveFocus()
                                }
                            }
                    }
                }
            }
            
            // Applications grid
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                GridView {
                    id: applicationsGrid
                    anchors.fill: parent
                    cellWidth: Math.floor(parent.width / Math.floor(parent.width / 120))
                    cellHeight: 100
                    
                    model: menuContent.filteredApps
                    
                    Component.onCompleted: {
                    }
                    
                    delegate: Rectangle {
                        id: appDelegate
                        width: applicationsGrid.cellWidth - 10
                        height: applicationsGrid.cellHeight - 10
                        color: appMouseArea.containsMouse ? "#333333" : "transparent"
                        radius: 10
                        border.color: appMouseArea.containsMouse ? "#555555" : "transparent"
                        border.width: appMouseArea.containsMouse ? 1 : 0
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 5
                            
                            // App icon
                            Image {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 48
                                Layout.preferredHeight: 48
                                source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                
                                // Fallback icon
                                onStatusChanged: {
                                    if (status === Image.Error) {
                                        source = "image://icon/application-x-executable"
                                    }
                                }
                            }
                            
                            // App name
                            Text {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.name
                                color: "#ffffff"
                                font.pixelSize: 11
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                            }
                        }
                        
                        MouseArea {
                            id: appMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            
                            onPressed: {
                                console.log("App pressed:", index, modelData.name);
                                appDelegate.color = "#444444";
                            }
                            
                            onReleased: {
                                console.log("App released:", index, modelData.name);
                                appDelegate.color = appMouseArea.containsMouse ? "#333333" : "transparent";
                            }
                            
                            onClicked: {
                                console.log("App clicked:", index, modelData.name);
                                menuContent.selectedIndex = index;
                                menuContent.activateSelected();
                            }
                        }
                        
                        // Smooth hover animation
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                                easing.type: Easing.OutQuad
                            }
                        }
                        
                        Behavior on border.color {
                            ColorAnimation {
                                duration: 150
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                }
            }
            
            // Power buttons section
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                color: "#2a2a2a"
                radius: 8
                border.color: "#33ffffff"
                border.width: 1
                
                RowLayout {
                    anchors.centerIn: parent
                    spacing: 16
                    
                    // System buttons using MaterialSymbol like HyprMenu
                    Repeater {
                        model: [
                            {icon: "lock", tooltip: "Lock", command: ["loginctl", "lock-session"]},
                            {icon: "logout", tooltip: "Logout", command: ["loginctl", "terminate-session", Quickshell.env("XDG_SESSION_ID")]},
                            {icon: "restart_alt", tooltip: "Restart", command: ["systemctl", "reboot"]},
                            {icon: "power_settings_new", tooltip: "Shutdown", command: ["systemctl", "poweroff"]}
                        ]
                        
                        Rectangle {
                            width: 36
                            height: 36
                            radius: 6
                            color: sysArea.containsMouse ? "#444444" : "transparent"
                            
                            // Material Design icons using proper font
                            Text {
                                anchors.centerIn: parent
                                text: {
                                    switch(modelData.icon) {
                                        case "lock": return "lock"
                                        case "logout": return "logout"
                                        case "restart_alt": return "restart_alt"
                                        case "power_settings_new": return "power_settings_new"
                                        default: return "settings"
                                    }
                                }
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 20
                                color: "#ffffff"
                            }
                            
                            MouseArea {
                                id: sysArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    Quickshell.execDetached(modelData.command)
                                    applicationMenu.visible = false
                                }
                            }
                            
                            // Tooltip
                            Rectangle {
                                anchors.bottom: parent.top
                                anchors.bottomMargin: 8
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: tooltipText.width + 12
                                height: tooltipText.height + 8
                                color: "#000000"
                                opacity: 0.8
                                radius: 4
                                visible: sysArea.containsMouse
                                
                                Text {
                                    id: tooltipText
                                    anchors.centerIn: parent
                                    text: modelData.tooltip
                                    color: "#ffffff"
                                    font.pixelSize: 10
                                }
                            }
                            
                            Behavior on color {
                                ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
                            }
                        }
                    }
                }
            }
        }
        
        function selectNext() {
            if (filteredApps.length > 0) {
                selectedIndex = Math.min(selectedIndex + 1, filteredApps.length - 1);
            }
        }
        
        function selectPrev() {
            if (filteredApps.length > 0) {
                selectedIndex = Math.max(selectedIndex - 1, 0);
            }
        }
    }
    

} 