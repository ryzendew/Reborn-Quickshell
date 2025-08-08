import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
// import Quickshell.Services.Pipewire  // Temporarily disabled to avoid route device errors
import qs.Services
import qs.Settings
import "."
import "./Components"

// Create a proper panel window
PanelWindow {
    id: panel
    
    // Set the specific screen (DP-1)
    screen: Quickshell.screens.find(screen => screen.name === "DP-1")
    
    // Set layer name for Hyprland blur effects
    WlrLayershell.namespace: "quickshell:bar:blur"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    
    // Make the panel window itself transparent
    color: "transparent"
    
    // Accept volume properties from parent
    property int volume: 0
    property bool volumeMuted: false
    
    // Panel configuration - span full width
    anchors {
        top: true
        left: true
        right: true
    }
    
    implicitHeight: Settings.settings.barHeight || 40
    margins {
        top: 0
        left: 0
        right: 0
    }
    
    // The actual bar content - dark mode
    Rectangle {
        id: bar
        anchors.fill: parent
        color: "#1a1a1a"  // Dark background
        opacity: Settings.settings.dimPanels ? 0.8 : 1.0  // Make bar transparent based on dim panels setting
        radius: 0  // Full width bar without rounded corners
        border.color: "#333333"
        border.width: 0
        visible: Settings.settings.showTaskbar !== false
        
        // Bottom border only
        BottomBorder {}

        // Arch Linux button in the top left
        ArchButton {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: 4
            }
        }

        // Workspaces in the center
        Loader {
            anchors {
                centerIn: parent
            }
            source: "Workspaces.qml"
        }

        // Custom tray menu for system tray
        CustomTrayMenu {
            id: trayMenu
        }
        
        // System tray widget positioned to the left of time
        SystemTray {
            id: systemTrayWidget
            bar: panel  // Pass the panel window reference
            shell: panel  // Pass the panel as shell reference
            trayMenu: trayMenu  // Pass the tray menu reference
            anchors {
                right: timeDisplay.left
                verticalCenter: parent.verticalCenter
                rightMargin: 16
            }
        }

        // Time display - stacked vertically
        TimeDisplay {
            id: timeDisplay
            anchors {
                right: indicatorsModule.left
                verticalCenter: parent.verticalCenter
                rightMargin: 24
            }
        }
        
        // Indicators module (audio, network, bluetooth status) on the far right
        Loader {
            id: indicatorsModule
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: -9
            
            }
            source: "IndicatorsModule.qml"
            
            // Pass shell properties to the indicators
            property var shell: QtObject {
                property int volume: panel.volume
                property bool volumeMuted: panel.volumeMuted
            }
            
            // Pass shell to the loaded component
            onLoaded: {
                indicatorsModule.item.shell = shell
            }
        }
    }
} 