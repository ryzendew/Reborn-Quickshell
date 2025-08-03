pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

PopupWindow {
    id: dockMenu
    
    implicitWidth: 180
    implicitHeight: Math.max(40, listView.contentHeight + 12)
    visible: false
    color: "transparent"
    
    property QsMenuHandle menu
    property var anchorItem: null
    property real anchorX
    property real anchorY
    
    anchor.item: anchorItem ? anchorItem : null
    anchor.rect.x: anchorX
    anchor.rect.y: anchorY
    
    // Properties for context
    property var dock: null
    property var contextAppInfo: null
    property bool contextIsPinned: false
    property var contextDockItem: null
    
    function showAt(item, x, y) {
        if (!item) {
            console.warn("CustomDockMenu: anchorItem is undefined, not showing menu.")
            return
        }
        anchorItem = item
        anchorX = x
        anchorY = y
        visible = true
        Qt.callLater(() => dockMenu.anchor.updateAnchor())
    }
    
    function hideMenu() {
        visible = false
    }
    
    Item {
        anchors.fill: parent
        Keys.onEscapePressed: dockMenu.hideMenu()
    }
    
    // Global mouse area to close menu when clicking outside
    MouseArea {
        anchors.fill: parent
        enabled: dockMenu.visible
        z: 9998
        onClicked: function() {
            dockMenu.hideMenu()
        }
        
        // Prevent clicks on menu items from closing the menu
        onPressed: function(mouse) {
            mouse.accepted = false
        }
    }
    
    QsMenuOpener {
        id: opener
        menu: dockMenu.menu
    }
    
    Rectangle {
        id: bg
        anchors.fill: parent
        color: "#1a1a1a"
        border.color: "#333333"
        border.width: 1
        radius: 8
        z: 0
    }
    
    ListView {
        id: listView
        anchors.fill: parent
        anchors.margins: 6
        spacing: 2
        interactive: false
        enabled: dockMenu.visible
        clip: true
        
        model: ScriptModel {
            values: [
                {
                    text: dockMenu.contextIsPinned ? "Unpin from dock" : "Pin to dock",
                    enabled: dockMenu.contextAppInfo,
                    triggered: () => {
                        if (dockMenu.contextIsPinned) {
                            if (dockMenu.dock && dockMenu.dock.pinnedAppsManager) {
                                dockMenu.dock.pinnedAppsManager.unpinApp(dockMenu.contextAppInfo.class || dockMenu.contextAppInfo.id)
                            }
                        } else {
                            if (dockMenu.dock && dockMenu.dock.pinnedAppsManager) {
                                dockMenu.dock.pinnedAppsManager.pinApp(dockMenu.contextAppInfo)
                            }
                        }
                        dockMenu.hideMenu()
                    }
                },
                {
                    text: "Launch new instance",
                    enabled: dockMenu.contextAppInfo,
                    triggered: () => {
                        if (dockMenu.contextAppInfo && dockMenu.contextAppInfo.execString) {
                            Quickshell.execDetached(["sh", "-c", dockMenu.contextAppInfo.execString])
                        }
                        dockMenu.hideMenu()
                    }
                },
                {
                    isSeparator: true
                },
                {
                    text: "Move to workspace",
                    enabled: dockMenu.contextAppInfo && dockMenu.contextAppInfo.class,
                    triggered: () => {
                        if (dockMenu.contextAppInfo && dockMenu.contextAppInfo.class) {
                            console.log("Moving window to workspace 1 for class:", dockMenu.contextAppInfo.class)
                            // Use the app's class directly - let Hyprland handle it
                            Hyprland.dispatch(`movetoworkspace 1 class:${dockMenu.contextAppInfo.class}`)
                        }
                        dockMenu.hideMenu()
                    }
                },
                {
                    text: "Toggle floating",
                    enabled: dockMenu.contextAppInfo && dockMenu.contextAppInfo.class,
                    triggered: () => {
                        if (dockMenu.contextAppInfo && dockMenu.contextAppInfo.class) {
                            console.log("Toggling floating for class:", dockMenu.contextAppInfo.class)
                            // Use the app's class directly - let Hyprland handle it
                            Hyprland.dispatch(`togglefloating class:${dockMenu.contextAppInfo.class}`)
                        }
                        dockMenu.hideMenu()
                    }
                },
                {
                    isSeparator: true
                },
                {
                    text: "Close",
                    enabled: dockMenu.contextAppInfo && dockMenu.contextAppInfo.class,
                    triggered: () => {
                        if (dockMenu.contextAppInfo && dockMenu.contextAppInfo.class) {
                            console.log("Closing window for class:", dockMenu.contextAppInfo.class)
                            // Use the app's class directly - let Hyprland handle it
                            Hyprland.dispatch(`closewindow class:${dockMenu.contextAppInfo.class}`)
                        }
                        dockMenu.hideMenu()
                    }
                },
                {
                    text: "Close All",
                    enabled: dockMenu.contextAppInfo && dockMenu.contextAppInfo.class,
                    triggered: () => {
                        if (dockMenu.contextAppInfo && dockMenu.contextAppInfo.class) {
                            console.log("Closing all windows for class:", dockMenu.contextAppInfo.class)
                            // Use the app's class directly - let Hyprland handle it
                            Hyprland.dispatch(`closewindow class:${dockMenu.contextAppInfo.class}`)
                        }
                        dockMenu.hideMenu()
                    }
                }
            ]
        }
        
        delegate: Rectangle {
            id: entry
            required property var modelData
            width: listView.width
            height: (modelData?.isSeparator) ? 8 : 32
            color: "transparent"
            radius: 8
            
            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 20
                height: 1
                color: "#333333"
                visible: modelData?.isSeparator ?? false
            }
            
            Rectangle {
                id: bg
                anchors.fill: parent
                color: mouseArea.containsMouse ? "#333333" : "transparent"
                radius: 8
                visible: !(modelData?.isSeparator ?? false)
                
                property color hoverTextColor: mouseArea.containsMouse ? "#ffffff" : "#ffffff"
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8
                    
                    Text {
                        Layout.fillWidth: true
                        color: (modelData?.enabled ?? true) ? bg.hoverTextColor : "#666666"
                        text: modelData?.text ?? ""
                        font.pixelSize: 12
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }
                
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: (modelData?.enabled ?? true) && !(modelData?.isSeparator ?? false) && dockMenu.visible
                    
                    onClicked: function() {
                        if (modelData && !modelData.isSeparator) {
                            modelData.triggered()
                        }
                    }
                }
            }
        }
    }
    
    // Menu content for QsMenuOpener (placeholder)
    Menu {
        id: menuContent
    }
    
    // Function to show menu with context (wrapper)
    function showMenu(dockItem, mouseX, mouseY) {
        console.log("CustomDockMenu.showMenu called with:", dockItem, mouseX, mouseY)
        contextDockItem = dockItem
        showAt(dockItem, mouseX, mouseY)
    }
    
    // Function to close menu
    function close() {
        hideMenu()
    }
} 