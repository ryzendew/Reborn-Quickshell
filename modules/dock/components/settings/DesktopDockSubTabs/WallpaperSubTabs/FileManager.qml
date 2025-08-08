import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Io

Window {
    id: fileManagerWindow
    width: 800
    height: 600
    visible: false
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    modality: Qt.ApplicationModal
    focus: true
    
    property var parentWindow: null
    property string selectedFilePath: ""
    signal fileSelected(string filePath)
    
    // Handle Escape key to close
    Keys.onEscapePressed: {
        fileManagerWindow.visible = false
    }
    
    // Position the file manager over the parent window
    onVisibleChanged: {
        if (visible && parentWindow) {
            x = parentWindow.x + (parentWindow.width - width) / 2
            y = parentWindow.y + (parentWindow.height - height) / 2
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.1, 0.1, 0.1, 0.95)
        border.color: "#00ffff"
        border.width: 2
        radius: 10
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            // Header with title bar
            Rectangle {
                Layout.fillWidth: true
                height: 50
                color: "#222222"
                radius: 8
                border.color: "#00ffff"
                border.width: 1
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15
                    
                    Text {
                        text: "File Manager"
                        color: "#ffffff"
                        font.pixelSize: 20
                        font.family: "Inter, sans-serif"
                        font.bold: true
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    // Close button
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: closeMouseArea.containsMouse ? "#ff4444" : "#333333"
                        border.color: "#00ffff"
                        border.width: 1
                        
                        Text {
                            anchors.centerIn: parent
                            text: "×"
                            color: "#ffffff"
                            font.pixelSize: 24
                            font.bold: true
                        }
                        
                        MouseArea {
                            id: closeMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: fileManagerWindow.visible = false
                        }
                    }
                }
            }
            
            // Path bar
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "#222222"
                border.color: "#444444"
                border.width: 1
                radius: 5
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    
                    Text {
                        text: "Path:"
                        color: "#ffffff"
                        font.pixelSize: 14
                    }
                    
                    Text {
                        text: currentPath
                        color: "#cccccc"
                        font.pixelSize: 14
                        Layout.fillWidth: true
                        elide: Text.ElideLeft
                    }
                    
                    // Refresh button
                    Rectangle {
                        width: 30
                        height: 30
                        radius: 15
                        color: refreshMouseArea.containsMouse ? "#00ffff" : "#333333"
                        border.color: "#00ffff"
                        border.width: 1
                        
                        Text {
                            anchors.centerIn: parent
                            text: "↻"
                            color: "#ffffff"
                            font.pixelSize: 16
                        }
                        
                        MouseArea {
                            id: refreshMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: loadDirectory(currentPath)
                        }
                    }
                }
            }
            
            // Navigation buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Button {
                    text: "Home"
                    enabled: currentPath !== homePath
                    onClicked: loadDirectory(homePath)
                    
                    background: Rectangle {
                        color: parent.enabled ? (parent.pressed ? "#00ffff" : "#333333") : "#222222"
                        border.color: "#00ffff"
                        border.width: 1
                        radius: 5
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: parent.enabled ? "#ffffff" : "#666666"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    text: "Up"
                    enabled: currentPath !== "/"
                    onClicked: {
                        let parentPath = currentPath.substring(0, currentPath.lastIndexOf('/'))
                        if (parentPath === "") parentPath = "/"
                        loadDirectory(parentPath)
                    }
                    
                    background: Rectangle {
                        color: parent.enabled ? (parent.pressed ? "#00ffff" : "#333333") : "#222222"
                        border.color: "#00ffff"
                        border.width: 1
                        radius: 5
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: parent.enabled ? "#ffffff" : "#666666"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // File type filter
                ComboBox {
                    id: fileTypeFilter
                    model: ["All Files", "Images", "Videos"]
                    currentIndex: 0
                    onCurrentTextChanged: loadDirectory(currentPath)
                    
                    background: Rectangle {
                        color: "#333333"
                        border.color: "#00ffff"
                        border.width: 1
                        radius: 5
                    }
                    
                    contentItem: Text {
                        text: parent.currentText
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
            
            // File list
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#222222"
                border.color: "#444444"
                border.width: 1
                radius: 5
                
                ListView {
                    id: fileListView
                    anchors.fill: parent
                    anchors.margins: 10
                    model: fileModel
                    spacing: 5
                    clip: true
                    
                    delegate: Rectangle {
                        width: fileListView.width
                        height: 50
                        color: mouseArea.containsMouse ? "#333333" : "transparent"
                        radius: 5
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 15
                            
                            // File icon
                            Rectangle {
                                width: 30
                                height: 30
                                radius: 5
                                color: modelData.isDirectory ? "#00ffff" : "#ff8800"
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.isDirectory ? "📁" : "📄"
                                    font.pixelSize: 16
                                }
                            }
                            
                            // File name
                            Text {
                                text: modelData.name
                                color: "#ffffff"
                                font.pixelSize: 14
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            
                            // File size (for files only)
                            Text {
                                text: modelData.isDirectory ? "" : formatFileSize(modelData.size)
                                color: "#cccccc"
                                font.pixelSize: 12
                                visible: !modelData.isDirectory
                            }
                        }
                        
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (modelData.isDirectory) {
                                    loadDirectory(modelData.path)
                                } else {
                                    selectedFilePath = modelData.path
                                    fileSelected(modelData.path)
                                    fileManagerWindow.visible = false
                                }
                            }
                            onDoubleClicked: {
                                if (modelData.isDirectory) {
                                    loadDirectory(modelData.path)
                                }
                            }
                        }
                    }
                    
                    ScrollBar.vertical: ScrollBar {
                        active: true
                        policy: ScrollBar.AsNeeded
                    }
                }
            }
            
            // Bottom buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Button {
                    text: "Close"
                    onClicked: fileManagerWindow.visible = false
                    
                    background: Rectangle {
                        color: parent.pressed ? "#ff4444" : "#333333"
                        border.color: "#ff4444"
                        border.width: 1
                        radius: 5
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "Cancel"
                    onClicked: fileManagerWindow.visible = false
                    
                    background: Rectangle {
                        color: parent.pressed ? "#ff4444" : "#333333"
                        border.color: "#ff4444"
                        border.width: 1
                        radius: 5
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    text: "Select"
                    enabled: selectedFilePath !== ""
                    onClicked: {
                        if (selectedFilePath !== "") {
                            fileSelected(selectedFilePath)
                            fileManagerWindow.visible = false
                        }
                    }
                    
                    background: Rectangle {
                        color: parent.enabled ? (parent.pressed ? "#00ffff" : "#333333") : "#222222"
                        border.color: "#00ffff"
                        border.width: 1
                        radius: 5
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: parent.enabled ? "#ffffff" : "#666666"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
    
    // Properties
    property string currentPath: homePath
    property string homePath: Quickshell.Io.Process.exec("echo $HOME").trim()
    property var fileModel: []
    
    // Functions
    function loadDirectory(path) {
        currentPath = path
        fileModel = []
        
        try {
            let entries = Quickshell.Io.readDir(path)
            
            // Filter and sort entries
            let filteredEntries = []
            for (let entry of entries) {
                if (entry.name.startsWith('.')) continue // Skip hidden files
                
                let isImage = /\.(jpg|jpeg|png|gif|bmp|svg|webp)$/i.test(entry.name)
                let isVideo = /\.(mp4|avi|mov|mkv|webm)$/i.test(entry.name)
                
                if (fileTypeFilter.currentText === "Images" && !isImage && !entry.isDirectory) continue
                if (fileTypeFilter.currentText === "Videos" && !isVideo && !entry.isDirectory) continue
                
                filteredEntries.push({
                    name: entry.name,
                    path: entry.path,
                    isDirectory: entry.isDirectory,
                    size: entry.size || 0
                })
            }
            
            // Sort: directories first, then files alphabetically
            filteredEntries.sort((a, b) => {
                if (a.isDirectory && !b.isDirectory) return -1
                if (!a.isDirectory && b.isDirectory) return 1
                return a.name.localeCompare(b.name)
            })
            
            fileModel = filteredEntries
        } catch (error) {
            console.log("Error loading directory:", error)
        }
    }
    
    function formatFileSize(bytes) {
        if (bytes === 0) return "0 B"
        const k = 1024
        const sizes = ['B', 'KB', 'MB', 'GB']
        const i = Math.floor(Math.log(bytes) / Math.log(k))
        return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i]
    }
    
    // Initialize
    Component.onCompleted: {
        loadDirectory(homePath)
    }
} 