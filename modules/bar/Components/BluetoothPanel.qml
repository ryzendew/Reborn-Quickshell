import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Bluetooth
import qs.Services
import qs.Settings

Item {
    id: root
    
    property alias panel: bluetoothPanelModal
    property string statusMessage: ""
    property bool statusPopupVisible: false
    
    function showStatus(msg) {
        statusMessage = msg
        statusPopupVisible = true
    }
    
    function hideStatus() {
        statusPopupVisible = false
    }
    
    function showAt() {
        bluetoothLogic.showAt()
    }
    
    // Bluetooth logic
    QtObject {
        id: bluetoothLogic
        
        function showAt() {
            if (Bluetooth.defaultAdapter) {
                if (!Bluetooth.defaultAdapter.enabled) {
                    Bluetooth.defaultAdapter.enabled = true
                }
                if (!Bluetooth.defaultAdapter.discovering) {
                    Bluetooth.defaultAdapter.discovering = true
                }
            }
            bluetoothPanelModal.visible = true
        }
    }
    
    // Main panel window
    PanelWindow {
        id: bluetoothPanelModal
        implicitWidth: 480
        implicitHeight: 780
        visible: false
        color: "transparent"
        anchors.top: true
        anchors.right: true
        margins.right: 0
        margins.top: 0
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        
        onVisibleChanged: {
            if (!visible && Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.discovering) {
                Bluetooth.defaultAdapter.discovering = false
            }
        }
        
        Rectangle {
            anchors.fill: parent
            color: "#1a1a1a"  // Dark theme matching our bar
            radius: 20
            border.color: "#333333"
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 32
                spacing: 0
                
                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20
                    Layout.preferredHeight: 48
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    
                    Text {
                        text: "bluetooth"
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 32
                        color: "#2196F3"  // Blue accent
                    }
                    
                    Text {
                        text: "Bluetooth"
                        font.family: "Segoe UI"
                        font.pixelSize: 26
                        font.bold: true
                        color: "#ffffff"
                        Layout.fillWidth: true
                    }
                    
                    // Close button
                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: closeButtonArea.containsMouse ? "#2196F3" : "transparent"
                        border.color: "#2196F3"
                        border.width: 1
                        
                        Text {
                            anchors.centerIn: parent
                            text: "close"
                            font.family: closeButtonArea.containsMouse ? "Material Symbols Rounded" : "Material Symbols Outlined"
                            font.pixelSize: 20
                            color: closeButtonArea.containsMouse ? "#ffffff" : "#2196F3"
                        }
                        
                        MouseArea {
                            id: closeButtonArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: bluetoothPanelModal.visible = false
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }
                
                // Divider
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#333333"
                    opacity: 0.5
                }
                
                // Main content area
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 640
                    Layout.alignment: Qt.AlignHCenter
                    Layout.margins: 0
                    color: "#2a2a2a"
                    radius: 18
                    border.color: "#333333"
                    border.width: 1
                    anchors.topMargin: 32
                    
                    Rectangle {
                        id: bg
                        anchors.fill: parent
                        color: "#1a1a1a"
                        radius: 12
                        border.width: 1
                        border.color: "#2a2a2a"
                        z: 0
                    }
                    
                    Rectangle {
                        id: header
                        color: "transparent"
                    }
                    
                    Rectangle {
                        id: listContainer
                        anchors.top: header.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 24
                        color: "transparent"
                        clip: true
                        
                        ListView {
                            id: deviceListView
                            anchors.fill: parent
                            spacing: 4
                            boundsBehavior: Flickable.StopAtBounds
                            model: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.devices : []
                            
                            delegate: Rectangle {
                                width: parent.width
                                height: 60
                                color: "transparent"
                                radius: 8
                                property bool userInitiatedDisconnect: false
                                
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 8
                                    color: modelData.connected ? 
                                           Qt.rgba(0.33, 0.58, 0.95, 0.18) : // Blue with transparency
                                           (deviceMouseArea.containsMouse ? "#333333" : "transparent")
                                }
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 12
                                    
                                    // Fixed-width icon for alignment
                                    Text {
                                        width: 28
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        text: modelData.connected ? "bluetooth" : "bluetooth_disabled"
                                        font.family: "Material Symbols Outlined"
                                        font.pixelSize: 20
                                        color: modelData.connected ? "#2196F3" : "#888888"
                                    }
                                    
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        
                                        // Device name always fills width for alignment
                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.name || "Unknown Device"
                                            font.family: "Segoe UI"
                                            color: modelData.connected ? "#2196F3" : "#ffffff"
                                            font.pixelSize: 14
                                            elide: Text.ElideRight
                                        }
                                        
                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.address
                                            font.family: "Segoe UI"
                                            color: modelData.connected ? "#2196F3" : "#888888"
                                            font.pixelSize: 11
                                            elide: Text.ElideRight
                                        }
                                        
                                        Text {
                                            text: "Paired: " + modelData.paired + " | Trusted: " + modelData.trusted
                                            font.family: "Segoe UI"
                                            font.pixelSize: 10
                                            color: "#888888"
                                            visible: true
                                        }
                                    }
                                    
                                    // Loading spinner for pairing/connecting states
                                    Item {
                                        Layout.preferredWidth: 16
                                        Layout.preferredHeight: 16
                                        visible: modelData.pairing || 
                                                modelData.state === BluetoothDeviceState.Connecting || 
                                                modelData.state === BluetoothDeviceState.Disconnecting
                                        
                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: 16
                                            height: 16
                                            radius: 8
                                            color: "transparent"
                                            border.color: "#2196F3"
                                            border.width: 2
                                            
                                            RotationAnimation on rotation {
                                                from: 0
                                                to: 360
                                                duration: 1000
                                                loops: Animation.Infinite
                                                running: parent.visible
                                            }
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    id: deviceMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    
                                    onClicked: {
                                        if (modelData.connected) {
                                            userInitiatedDisconnect = true
                                            modelData.disconnect()
                                        } else if (!modelData.paired) {
                                            modelData.pair()
                                            root.showStatus("Pairing... Please check your phone or system for a PIN dialog.")
                                        } else {
                                            modelData.connect()
                                        }
                                    }
                                }
                                
                                Connections {
                                    target: modelData
                                    
                                    function onPairedChanged() {
                                        if (modelData.paired) {
                                            root.showStatus("Paired! Now connecting...")
                                            modelData.connect()
                                        }
                                    }
                                    
                                    function onPairingChanged() {
                                        if (!modelData.pairing && !modelData.paired) {
                                            root.showStatus("Pairing failed or was cancelled.")
                                        }
                                    }
                                    
                                    function onConnectedChanged() {
                                        userInitiatedDisconnect = false
                                    }
                                    
                                    function onStateChanged() {
                                        // Optionally handle more granular feedback here
                                    }
                                }
                            }
                        }
                        
                        // Scrollbar
                        Rectangle {
                            anchors.right: parent.right
                            anchors.rightMargin: 2
                            anchors.top: listContainer.top
                            anchors.bottom: listContainer.bottom
                            width: 4
                            radius: 2
                            color: "#888888"
                            opacity: deviceListView.contentHeight > deviceListView.height ? 0.3 : 0
                            visible: opacity > 0
                        }
                    }
                }
            }
        }
    }
    
    // Status/Info popup
    Popup {
        id: statusPopup
        x: (parent.width - width) / 2
        y: 40
        width: Math.min(360, parent.width - 40)
        visible: root.statusPopupVisible
        modal: false
        focus: false
        
        background: Rectangle {
            color: "#2196F3"  // Blue accent
            radius: 8
        }
        
        contentItem: Text {
            text: root.statusMessage
            color: "white"
            wrapMode: Text.WordWrap
            padding: 12
            font.pixelSize: 14
        }
        
        onVisibleChanged: {
            if (visible) {
                // Auto-hide after 3 seconds
                statusPopupTimer.restart()
            }
        }
    }
    
    Timer {
        id: statusPopupTimer
        interval: 3000
        onTriggered: {
            root.hideStatus()
        }
    }
} 