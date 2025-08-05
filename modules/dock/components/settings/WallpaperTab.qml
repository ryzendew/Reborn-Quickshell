import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Quickshell
import Quickshell.Io
import qs.Services
import qs.Settings

Rectangle {
    color: "transparent"
    
    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: wallpaperColumn.height + 40
        
        ColumnLayout {
            id: wallpaperColumn
            width: parent.width
            spacing: 20
            
            // Current Wallpaper Section
            Rectangle {
                Layout.fillWidth: true
                height: 200
                color: "#2a2a2a"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    Label {
                        text: "Current Wallpaper"
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#1a1a1a"
                        radius: 6
                        
                        Image {
                            id: currentWallpaperImage
                            anchors.fill: parent
                            anchors.margins: 8
                            source: Settings.settings.currentWallpaper || "file:///usr/share/backgrounds/default.jpg"
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: false
                        }
                        
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.color: "#404040"
                            border.width: 1
                            radius: 6
                        }
                        
                        // Loading indicator
                        BusyIndicator {
                            anchors.centerIn: parent
                            running: currentWallpaperImage.status === Image.Loading
                            visible: running
                        }
                        
                        // Error placeholder
                        Rectangle {
                            anchors.fill: parent
                            color: "#1a1a1a"
                            visible: currentWallpaperImage.status === Image.Error
                            
                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 8
                                
                                Label {
                                    text: "No wallpaper set"
                                    color: "#808080"
                                    font.pixelSize: 14
                                }
                                
                                Label {
                                    text: "Select a wallpaper folder to get started"
                                    color: "#606060"
                                    font.pixelSize: 12
                                }
                            }
                        }
                    }
                }
            }
            
            // Wallpaper Folder Section
            Rectangle {
                Layout.fillWidth: true
                height: 120
                color: "#2a2a2a"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    Label {
                        text: "Wallpaper Folder"
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        TextField {
                            id: folderPathField
                            Layout.fillWidth: true
                            text: Settings.settings.wallpaperFolder || "~/Pictures/Wallpapers"
                            color: "white"
                            background: Rectangle {
                                color: "#1a1a1a"
                                radius: 4
                                border.color: "#404040"
                                border.width: 1
                            }
                            onTextChanged: {
                                if (text !== Settings.settings.wallpaperFolder) {
                                    Settings.settings.wallpaperFolder = text
                                }
                            }
                        }
                        
                        Button {
                            text: "Browse"
                            background: Rectangle {
                                color: parent.pressed ? "#404040" : "#505050"
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: folderDialog.open()
                        }
                        
                        Button {
                            text: "Refresh"
                            background: Rectangle {
                                color: parent.pressed ? "#404040" : "#505050"
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                Wallpaper.loadWallpapers()
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        Label {
                            text: "Found wallpapers:"
                            color: "#b0b0b0"
                            font.pixelSize: 12
                        }
                        
                        Label {
                            text: Wallpaper.scanning ? "Scanning..." : Wallpaper.wallpaperList.length + " images"
                            color: Wallpaper.scanning ? "#ffaa00" : "#90ee90"
                            font.pixelSize: 12
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        BusyIndicator {
                            running: Wallpaper.scanning
                            visible: running
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                        }
                    }
                }
            }
            
            // Wallpaper Grid Section
            Rectangle {
                Layout.fillWidth: true
                height: 300
                color: "#2a2a2a"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Label {
                            text: "Available Wallpapers"
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Label {
                            text: Wallpaper.scanning ? "Scanning..." : Wallpaper.wallpaperList.length + " images"
                            color: Wallpaper.scanning ? "#ffaa00" : "#90ee90"
                            font.pixelSize: 12
                        }
                        
                        BusyIndicator {
                            running: Wallpaper.scanning
                            visible: running
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                        }
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        
                        GridView {
                            id: wallpaperGrid
                            width: parent.width
                            height: parent.height
                            cellWidth: 120
                            cellHeight: 90
                            model: Wallpaper.wallpaperList
                            
                            delegate: Rectangle {
                                width: 120
                                height: 90
                                color: "transparent"
                                
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    color: "#1a1a1a"
                                    radius: 6
                                    border.color: modelData === Settings.settings.currentWallpaper ? "#007acc" : "#404040"
                                    border.width: modelData === Settings.settings.currentWallpaper ? 2 : 1
                                    
                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        source: "file://" + modelData
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: false
                                        
                                        Rectangle {
                                            anchors.fill: parent
                                            color: "transparent"
                                            border.color: "#202020"
                                            border.width: 1
                                            radius: 4
                                        }
                                    }
                                    
                                    // Current wallpaper indicator
                                    Rectangle {
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.margins: 4
                                        width: 16
                                        height: 16
                                        radius: 8
                                        color: "#007acc"
                                        visible: modelData === Settings.settings.currentWallpaper
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "✓"
                                            color: "white"
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                    }
                                    
                                    // Loading indicator
                                    BusyIndicator {
                                        anchors.centerIn: parent
                                        running: parent.Image.status === Image.Loading
                                        visible: running
                                        width: 20
                                        height: 20
                                    }
                                    
                                    // Error placeholder
                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        color: "#1a1a1a"
                                        radius: 4
                                        visible: parent.Image.status === Image.Error
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "?"
                                            color: "#606060"
                                            font.pixelSize: 20
                                            font.bold: true
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        Wallpaper.setCurrentWallpaper(modelData, false)
                                    }
                                    
                                    Rectangle {
                                        anchors.fill: parent
                                        color: "#40000000"
                                        opacity: parent.containsMouse ? 1 : 0
                                        radius: 6
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "Set"
                                            color: "white"
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Random Wallpaper Section
            Rectangle {
                Layout.fillWidth: true
                height: 140
                color: "#2a2a2a"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    Label {
                        text: "Random Wallpaper"
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                    }
                    
                    CheckBox {
                        id: randomWallpaperCheck
                        text: "Enable random wallpaper"
                        checked: Settings.settings.randomWallpaper || false
                        onCheckedChanged: {
                            Settings.settings.randomWallpaper = checked
                            Wallpaper.toggleRandomWallpaper()
                        }
                        
                        indicator: Rectangle {
                            width: 18
                            height: 18
                            radius: 3
                            border.color: "#404040"
                            border.width: 1
                            color: parent.checked ? "#007acc" : "transparent"
                            
                            Rectangle {
                                anchors.centerIn: parent
                                width: 10
                                height: 10
                                radius: 2
                                color: "white"
                                visible: parent.checked
                            }
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 14
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: parent.indicator.width + parent.spacing
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        Label {
                            text: "Change interval:"
                            color: "#b0b0b0"
                            font.pixelSize: 12
                        }
                        
                        SpinBox {
                            id: intervalSpinBox
                            from: 30
                            to: 3600
                            value: Settings.settings.wallpaperInterval
                            onValueChanged: {
                                Settings.settings.wallpaperInterval = value
                                Wallpaper.restartRandomWallpaperTimer()
                            }
                            
                            background: Rectangle {
                                color: "#1a1a1a"
                                radius: 4
                                border.color: "#404040"
                                border.width: 1
                            }
                            
                            contentItem: TextInput {
                                text: parent.textFromValue(parent.value, parent.locale)
                                color: "white"
                                font: parent.font
                                horizontalAlignment: Qt.AlignHCenter
                                verticalAlignment: Qt.AlignVCenter
                                readOnly: true
                                validator: parent.validator
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                            }
                        }
                        
                        Label {
                            text: "seconds"
                            color: "#b0b0b0"
                            font.pixelSize: 12
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: "Change Now"
                            enabled: Settings.settings.randomWallpaper
                            background: Rectangle {
                                color: parent.pressed ? "#404040" : (parent.enabled ? "#505050" : "#303030")
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                color: parent.enabled ? "white" : "#606060"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                Wallpaper.setRandomWallpaper()
                            }
                        }
                    }
                }
            }
            
            // SWWW Integration Section
            Rectangle {
                Layout.fillWidth: true
                height: 200
                color: "#2a2a2a"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    Label {
                        text: "SWWW Integration"
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                    }
                    
                    CheckBox {
                        id: useSWWWCheck
                        text: "Use SWWW for wallpaper management"
                        checked: Settings.settings.useSWWW || false
                        onCheckedChanged: {
                            Settings.settings.useSWWW = checked
                        }
                        
                        indicator: Rectangle {
                            width: 18
                            height: 18
                            radius: 3
                            border.color: "#404040"
                            border.width: 1
                            color: parent.checked ? "#007acc" : "transparent"
                            
                            Rectangle {
                                anchors.centerIn: parent
                                width: 10
                                height: 10
                                radius: 2
                                color: "white"
                                visible: parent.checked
                            }
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 14
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: parent.indicator.width + parent.spacing
                        }
                    }
                    
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 12
                        columnSpacing: 16
                        enabled: Settings.settings.useSWWW
                        
                        Label {
                            text: "Transition Type:"
                            color: "#b0b0b0"
                            font.pixelSize: 12
                        }
                        
                        Rectangle {
                            width: 200
                            height: 30
                            color: "#1a1a1a"
                            radius: 4
                            border.color: "#404040"
                            border.width: 1
                            
                            Text {
                                id: transitionTypeText
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                text: Settings.settings.transitionType || "random"
                                color: "white"
                                font.pixelSize: 12
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var options = ["random", "fade", "left", "right", "top", "bottom", "wipe", "wave", "grow", "center", "any", "outer"]
                                    var currentIndex = options.indexOf(Settings.settings.transitionType || "random")
                                    var nextIndex = (currentIndex + 1) % options.length
                                    Settings.settings.transitionType = options[nextIndex]
                                    transitionTypeText.text = options[nextIndex]
                                }
                            }
                        }
                        
                        Label {
                            text: "Resize Mode:"
                            color: "#b0b0b0"
                            font.pixelSize: 12
                        }
                        
                        Rectangle {
                            width: 200
                            height: 30
                            color: "#1a1a1a"
                            radius: 4
                            border.color: "#404040"
                            border.width: 1
                            
                            Text {
                                id: resizeModeText
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                text: Settings.settings.wallpaperResize || "crop"
                                color: "white"
                                font.pixelSize: 12
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var options = ["crop", "fit", "no", "scale-down"]
                                    var currentIndex = options.indexOf(Settings.settings.wallpaperResize || "crop")
                                    var nextIndex = (currentIndex + 1) % options.length
                                    Settings.settings.wallpaperResize = options[nextIndex]
                                    resizeModeText.text = options[nextIndex]
                                }
                            }
                        }
                        
                        Label {
                            text: "Transition FPS:"
                            color: "#b0b0b0"
                            font.pixelSize: 12
                        }
                        
                        SpinBox {
                            id: fpsSpinBox
                            from: 30
                            to: 120
                            value: Settings.settings.transitionFps
                            onValueChanged: {
                                Settings.settings.transitionFps = value
                            }
                            
                            background: Rectangle {
                                color: "#1a1a1a"
                                radius: 4
                                border.color: "#404040"
                                border.width: 1
                            }
                            
                            contentItem: TextInput {
                                text: parent.textFromValue(parent.value, parent.locale)
                                color: "white"
                                font: parent.font
                                horizontalAlignment: Qt.AlignHCenter
                                verticalAlignment: Qt.AlignVCenter
                                readOnly: true
                                validator: parent.validator
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                            }
                        }
                        
                        Label {
                            text: "Duration:"
                            color: "#b0b0b0"
                            font.pixelSize: 12
                        }
                        
                        TextField {
                            id: durationTextField
                            text: Settings.settings.transitionDuration.toString()
                            validator: DoubleValidator {
                                bottom: 0.1
                                top: 5.0
                                decimals: 1
                                notation: DoubleValidator.StandardNotation
                            }
                            onTextChanged: {
                                var value = parseFloat(text)
                                if (!isNaN(value) && value >= 0.1 && value <= 5.0) {
                                    Settings.settings.transitionDuration = value
                                }
                            }
                            
                            background: Rectangle {
                                color: "#1a1a1a"
                                radius: 4
                                border.color: "#404040"
                                border.width: 1
                            }
                            
                            color: "white"
                            font.pixelSize: 12
                            horizontalAlignment: TextInput.AlignHCenter
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                        }
                    }
                }
            }
            
            // Theme Integration Section
            Rectangle {
                Layout.fillWidth: true
                height: 80
                color: "#2a2a2a"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    Label {
                        text: "Theme Integration"
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                    }
                    
                    CheckBox {
                        id: useThemeCheck
                        text: "Generate theme colors from wallpaper (requires wallust)"
                        checked: Settings.settings.useWallpaperTheme || false
                        onCheckedChanged: {
                            Settings.settings.useWallpaperTheme = checked
                        }
                        
                        indicator: Rectangle {
                            width: 18
                            height: 18
                            radius: 3
                            border.color: "#404040"
                            border.width: 1
                            color: parent.checked ? "#007acc" : "transparent"
                            
                            Rectangle {
                                anchors.centerIn: parent
                                width: 10
                                height: 10
                                radius: 2
                                color: "white"
                                visible: parent.checked
                            }
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 14
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: parent.indicator.width + parent.spacing
                        }
                    }
                }
            }
        }
    }
    
    // Folder Dialog
    FolderDialog {
        id: folderDialog
        title: "Select Wallpaper Folder"
        onAccepted: {
            var path = selectedFolder.toString().replace("file://", "")
            folderPathField.text = path
            Settings.settings.wallpaperFolder = path
            Wallpaper.loadWallpapers()
        }
    }
} 