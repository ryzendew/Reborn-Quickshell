import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Hyprland
import qs.modules.dock.components
import qs.Settings
import qs.Services

Row {
    id: pinnedAppsContainer
    spacing: Settings.settings.dockIconSpacing || 8
    
    // Property to receive the pinned apps from parent
    property var pinnedApps: []
    property var hyprlandManager: null
    property var dockWindow: null
    
    // Application menu
    ApplicationMenu {
        id: applicationMenu
        visible: false
    }
    
    // Arch Linux logo button at the beginning
    Rectangle {
        id: archButton
        width: Settings.settings.dockIconSize || 48
        height: Settings.settings.dockIconSize || 48
        radius: (Settings.settings.dockIconSize || 48) / 2
        color: archMouseArea.containsMouse ? "#333333" : "transparent"
        border.color: archMouseArea.containsMouse ? "#555555" : "transparent"
        border.width: archMouseArea.containsMouse ? 1 : 0
        
        // Dynamic logo from LogoService
        Image {
            id: dockLogoImage
            anchors.centerIn: parent
            width: (Settings.settings.dockIconSize || 48) * 0.67
            height: (Settings.settings.dockIconSize || 48) * 0.67
            source: LogoService.getLogoPath(LogoService.currentDockLogo)
            fillMode: Image.PreserveAspectFit
            smooth: false
            mipmap: true
            cache: true
            sourceSize.width: 64
            sourceSize.height: 64
            
            // Fallback to a generic system icon if logo not found
            onStatusChanged: {
                if (status === Image.Error) {
                    source = IconService ? IconService.getIconPath("system-linux") : "image://icon/system-linux"
                }
            }
        }
        
        // Dynamic color overlay for the dock logo
        ColorOverlay {
            anchors.fill: dockLogoImage
            source: dockLogoImage
            color: LogoService.logoColor
        }
        
        MouseArea {
            id: archMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                archButton.isHovered = true
            }
            onExited: {
                archButton.isHovered = false
            }
            onClicked: {
                // Toggle application menu
                applicationMenu.visible = !applicationMenu.visible
            }
        }
        
        // Smooth scale animation like other dock icons
        property bool isHovered: false
        
        onIsHoveredChanged: {
            if (isHovered) {
                scale = 1.1
            } else {
                scale = 1.0
            }
        }
        
        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }
        
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
    
    // Repeater for pinned apps
    Repeater {
        model: pinnedApps
        
        DockIcon {
            appId: typeof modelData === 'string' ? modelData : (modelData.class || modelData.id || modelData.execString)
            isPinned: true
            isRunning: hyprlandManager ? hyprlandManager.isAppRunning(typeof modelData === 'string' ? modelData : (modelData.class || modelData.id || modelData.execString)) : false
            workspace: hyprlandManager ? hyprlandManager.getAppWorkspace(typeof modelData === 'string' ? modelData : (modelData.class || modelData.id || modelData.execString)) : 1
            dockWindow: pinnedAppsContainer.dockWindow
            
            // Debug logging for running state
            onIsRunningChanged: {
                const appId = typeof modelData === 'string' ? modelData : (modelData.class || modelData.id || modelData.execString)
                if (appId === 'AffinityPhoto.desktop' || appId === 'AffinityDesigner.desktop' || appId === 'net.lutris.davinci-resolve-studio-1.desktop') {
                    // console.log(`PinnedApps: isRunning changed for "${appId}": ${isRunning}`)
                }
            }
            
            Component.onCompleted: {
                const appId = typeof modelData === 'string' ? modelData : (modelData.class || modelData.id || modelData.execString)
                // console.log(`PinnedApps: ALL Component completed for "${appId}"`)
                if (appId === 'AffinityPhoto.desktop' || appId === 'AffinityDesigner.desktop') {
                    // console.log(`PinnedApps: Component completed for "${appId}"`)
                    // console.log(`PinnedApps: hyprlandManager available: ${hyprlandManager !== null}`)
                    if (hyprlandManager) {
                        // console.log(`PinnedApps: Current running apps:`, hyprlandManager.runningApps)
                        // console.log(`PinnedApps: isAppRunning result:`, hyprlandManager.isAppRunning(appId))
                    }
                }
                if (appId === 'AffinityDesigner.desktop') {
                    // console.log(`PinnedApps: AffinityDesigner.desktop component created!`)
                    // console.log(`PinnedApps: isRunning binding should be evaluated for "${appId}"`)
                }
            }

            onAppClicked: {
                if (hyprlandManager) {
                    const appId = typeof modelData === 'string' ? modelData : (modelData.class || modelData.id || modelData.execString)
                    const isRunning = hyprlandManager.isAppRunning(appId)
                    hyprlandManager.handleAppClick(appId, isRunning)
                }
            }
        }
    }
    
    // Debug info
    Component.onCompleted: {
        // Component loaded
    }
    
    onPinnedAppsChanged: {
        // Pinned apps changed
    }
} 