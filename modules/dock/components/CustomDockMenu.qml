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
        // Debug logging disabled
        
        if (!item) {
            console.warn("CustomDockMenu: anchorItem is undefined, not showing menu.")
            return
        }
        anchorItem = item
        anchorX = x
        anchorY = y
        populateMenu()
        visible = true
        Qt.callLater(() => dockMenu.anchor.updateAnchor())
    }
    
    function populateMenu() {
        menuModel.clear()
        
        // Debug logging
        // Debug logging disabled
        // Debug logging disabled
        
        // Pin/Unpin item
        menuModel.append({
            text: contextIsPinned ? "Unpin from dock" : "Pin to dock",
            enabled: Boolean(true),
            isSeparator: Boolean(false),
            action: "pin"
        })
        
        // Launch new instance
        menuModel.append({
            text: "Launch new instance",
            enabled: Boolean(true),
            isSeparator: Boolean(false),
            action: "launch"
        })
        
        // Separator
        menuModel.append({
            text: "",
            enabled: Boolean(false),
            isSeparator: Boolean(true),
            action: ""
        })
        
        // Move to workspace
        menuModel.append({
            text: "Move to workspace",
            enabled: Boolean(contextAppInfo && contextAppInfo.class),
            isSeparator: Boolean(false),
            action: "move_workspace"
        })
        
        // Toggle floating
        menuModel.append({
            text: "Toggle floating",
            enabled: Boolean(contextAppInfo && contextAppInfo.class),
            isSeparator: Boolean(false),
            action: "toggle_floating"
        })
        
        // Separator
        menuModel.append({
            text: "",
            enabled: Boolean(false),
            isSeparator: Boolean(true),
            action: ""
        })
        
        // Close
        menuModel.append({
            text: "Close",
            enabled: Boolean(contextAppInfo && contextAppInfo.class),
            isSeparator: Boolean(false),
            action: "close"
        })
        
        // Close All
        if (contextAppInfo && contextAppInfo.class) {
            menuModel.append({
                text: "Close All",
                enabled: Boolean(true),
                isSeparator: Boolean(false),
                action: "close_all"
            })
        }
    }
    
    function handleMenuAction(action) {
        // Debug logging disabled
        
        switch (action) {
            case "pin":
                // Debug logging disabled
                
                if (contextIsPinned) {
                    // Debug logging disabled
                    if (dock && dock.pinnedAppsManager) {
                        const appId = contextAppInfo.class || contextAppInfo.id || contextAppInfo.execString
                        dock.pinnedAppsManager.unpinApp(appId)
                    }
                } else {
                    // Debug logging disabled
                    if (dock && dock.pinnedAppsManager) {
                        
                        // Find the best app identifier to use for pinning
                        let bestAppId = null
                        let appInfoToPin = null
                        
                        if (contextAppInfo) {
                            // Try to get the best identifier from the app info
                            bestAppId = contextAppInfo.class || contextAppInfo.id || contextAppInfo.execString
                            
                            // For complex app IDs like org.gnome.ptyxis, try to get a simpler name
                            if (bestAppId && bestAppId.includes(".")) {
                                const parts = bestAppId.split(".")
                                const lastPart = parts[parts.length - 1]
                                
                                // Use the last part as the primary identifier (e.g., "ptyxis" instead of "org.gnome.ptyxis")
                                appInfoToPin = {
                                    class: lastPart,
                                    id: lastPart,
                                    name: contextAppInfo.name || lastPart,
                                    execString: contextAppInfo.execString || lastPart
                                }
                                // Debug logging disabled
                            } else {
                                // Use the original app info
                                appInfoToPin = contextAppInfo
                            }
                        }
                        
                        if (appInfoToPin) {
                            // Debug logging disabled
                            dock.pinnedAppsManager.pinApp(appInfoToPin)
                            
                            // Force update the dock to show the pinned app
                            if (dock.pinnedAppsManager.pinnedAppsChanged) {
                                dock.pinnedAppsManager.pinnedAppsChanged()
                            }
                        }
                    }
                }
                break
                
            case "launch":
                // Debug logging disabled
                
                // Try multiple ways to identify the app
                let appId = null
                let execString = null
                
                if (contextAppInfo) {
                    appId = contextAppInfo.class || contextAppInfo.id || contextAppInfo.execString
                    execString = contextAppInfo.execString
                }
                
                // If no app info available, try to get it from the dock item
                if (!appId && dock && dock.hyprlandManager) {
                    // This might be a pinned app that's not running
                    // Try to get the app ID from the dock context
                }
                
                if (appId) {
                    
                    // Try HyprlandManager first (most reliable)
                    if (dock && dock.hyprlandManager) {
                        try {
                            dock.hyprlandManager.launchApp(appId)
                        } catch (error) {
                            
                            // Fallback to --new-window approach
                            try {
                                const command = appId + " --new-window"
                                Hyprland.dispatch("exec " + command)
                            } catch (newWindowError) {
                                
                                                                // Final fallback to direct Hyprland dispatch
                                try {
                                    Hyprland.dispatch("exec " + appId)
                                } catch (dispatchError) {
                                    // Final fallback to direct execution
                                    try {
                                        Quickshell.execDetached(["sh", "-c", appId])
                                    } catch (finalError) {
                                    }
                                }
                            }
                        }
                    }
                } else {
                    // Even if we don't have app info, we can still try to launch
                    // This might happen with pinned apps that aren't running
                    if (dock && dock.hyprlandManager) {
                        // The HyprlandManager might have additional ways to launch apps
                        // This is a fallback for when context info is missing
                    }
                }
                break
                
            case "move_workspace":
                if (contextAppInfo && contextAppInfo.class) {
                    Hyprland.dispatch(`movetoworkspace 1 class:${contextAppInfo.class}`)
                }
                break
                
            case "toggle_floating":
                if (contextAppInfo && contextAppInfo.class) {
                    Hyprland.dispatch(`togglefloating class:${contextAppInfo.class}`)
                }
                break
                
            case "close":
                if (contextAppInfo && contextAppInfo.class) {
                    Hyprland.dispatch(`closewindow class:${contextAppInfo.class}`)
                }
                break
                
            case "close_all":
                if (contextAppInfo && contextAppInfo.class) {
                    Hyprland.dispatch(`closewindow class:${contextAppInfo.class}`)
                }
                break
        }
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
        
        model: ListModel {
            id: menuModel
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
                        if (modelData && !modelData.isSeparator && modelData.enabled) {
                            handleMenuAction(modelData.action)
                            dockMenu.hideMenu()
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