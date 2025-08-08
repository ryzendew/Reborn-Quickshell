import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Settings
import qs.Services

Rectangle {
    id: userTab
    color: "transparent"
    
    // User properties
    property string currentUser: Quickshell.env("USER") || "user"
    property string userHome: Quickshell.env("HOME") || "/home/user"
    property string userShell: Quickshell.env("SHELL") || "/bin/bash"
    property bool autoLogin: false
    property bool sudoAccess: true
    property string userImage: ""
    property var allUsers: []
    property var userGroups: []
    
    // Timer to update user list
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            getAllUsers()
            getUserGroups()
            checkSudoAccess()
        }
    }
    
    Component.onCompleted: {
        getAllUsers()
        getUserGroups()
        checkSudoAccess()
        loadUserImage()
    }
    
    function getAllUsers() {
        // For now, use a simple approach
        allUsers = [currentUser, "root"]
    }
    
    function getUserGroups() {
        // For now, use common groups
        userGroups = [currentUser, "wheel", "users", "audio", "video", "storage"]
    }
    
    function checkSudoAccess() {
        // For now, assume true if user is not root
        sudoAccess = currentUser !== "root"
    }
    
    function loadUserImage() {
        try {
            if (Settings.settings.userImage) {
                userImage = Settings.settings.userImage
            }
        } catch (e) {
            // Error loading user image
        }
    }
    
    function saveUserImage() {
        try {
            Settings.settings.userImage = userImage
        } catch (e) {
            // Error saving user image
        }
    }
    
    function createUser(username, password, isAdmin) {
        var commands = []
        commands.push(`sudo useradd -m -s /bin/bash ${username}`)
        commands.push(`echo '${username}:${password}' | sudo chpasswd`)
        
        if (isAdmin) {
            commands.push(`sudo usermod -aG wheel ${username}`)
        }
        
        // Execute commands
        for (var i = 0; i < commands.length; i++) {
            Hyprland.dispatch(`exec ${commands[i]}`)
        }
        
        // Refresh user list
        getAllUsers()
    }
    
    function deleteUser(username) {
        Hyprland.dispatch(`exec sudo userdel -r ${username}`)
        getAllUsers()
    }
    
    function changePassword(newPassword) {
        Hyprland.dispatch(`exec echo '${currentUser}:${newPassword}' | sudo chpasswd`)
    }
    
    function toggleAutoLogin() {
        autoLogin = !autoLogin
        if (autoLogin) {
            Hyprland.dispatch("exec sudo systemctl enable lightdm")
        } else {
            Hyprland.dispatch("exec sudo systemctl disable lightdm")
        }
    }
    
    function toggleSudoAccess() {
        sudoAccess = !sudoAccess
        if (sudoAccess) {
            Hyprland.dispatch(`exec sudo usermod -aG wheel ${currentUser}`)
        } else {
            Hyprland.dispatch(`exec sudo gpasswd -d ${currentUser} wheel`)
        }
        checkSudoAccess()
    }
    
    // Password change dialog
    Dialog {
        id: passwordDialog
        title: "Change Password"
        modal: true
        anchors.centerIn: parent
        width: 400
        height: 300
        
        background: Rectangle {
            color: "#2a2a2a"
            radius: 12
            border.color: "#44ffffff"
            border.width: 1
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16
            
            Text {
                text: "Change Password for " + currentUser
                font.pixelSize: 16
                font.weight: Font.Bold
                color: "#ffffff"
            }
            
            TextField {
                id: currentPasswordField
                placeholderText: "Current Password"
                echoMode: TextInput.Password
                Layout.fillWidth: true
                
                background: Rectangle {
                    color: "#333333"
                    radius: 6
                    border.color: "#555555"
                    border.width: 1
                }
                
                color: "#ffffff"
                placeholderTextColor: "#888888"
                font.pixelSize: 14
            }
            
            TextField {
                id: newPasswordField
                placeholderText: "New Password"
                echoMode: TextInput.Password
                Layout.fillWidth: true
                
                background: Rectangle {
                    color: "#333333"
                    radius: 6
                    border.color: "#555555"
                    border.width: 1
                }
                
                color: "#ffffff"
                placeholderTextColor: "#888888"
                font.pixelSize: 14
            }
            
            TextField {
                id: confirmPasswordField
                placeholderText: "Confirm New Password"
                echoMode: TextInput.Password
                Layout.fillWidth: true
                
                background: Rectangle {
                    color: "#333333"
                    radius: 6
                    border.color: "#555555"
                    border.width: 1
                }
                
                color: "#ffffff"
                placeholderTextColor: "#888888"
                font.pixelSize: 14
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Button {
                    text: "Change Password"
                    Layout.fillWidth: true
                    
                    background: Rectangle {
                        color: parent.pressed ? "#404040" : "#5700eeff"
                        radius: 6
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        if (newPasswordField.text === confirmPasswordField.text && newPasswordField.text.length > 0) {
                            changePassword(newPasswordField.text)
                            passwordDialog.close()
                            currentPasswordField.text = ""
                            newPasswordField.text = ""
                            confirmPasswordField.text = ""
                        }
                    }
                }
                
                Button {
                    text: "Cancel"
                    Layout.fillWidth: true
                    
                    background: Rectangle {
                        color: parent.pressed ? "#404040" : "#555555"
                        radius: 6
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        passwordDialog.close()
                        currentPasswordField.text = ""
                        newPasswordField.text = ""
                        confirmPasswordField.text = ""
                    }
                }
            }
        }
    }
    
    // Create user dialog
    Dialog {
        id: createUserDialog
        title: "Create New User"
        modal: true
        anchors.centerIn: parent
        width: 400
        height: 350
        
        background: Rectangle {
            color: "#2a2a2a"
            radius: 12
            border.color: "#44ffffff"
            border.width: 1
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16
            
            Text {
                text: "Create New User"
                font.pixelSize: 16
                font.weight: Font.Bold
                color: "#ffffff"
            }
            
            TextField {
                id: newUsernameField
                placeholderText: "Username"
                Layout.fillWidth: true
                
                background: Rectangle {
                    color: "#333333"
                    radius: 6
                    border.color: "#555555"
                    border.width: 1
                }
                
                color: "#ffffff"
                placeholderTextColor: "#888888"
                font.pixelSize: 14
            }
            
            TextField {
                id: newUserPasswordField
                placeholderText: "Password"
                echoMode: TextInput.Password
                Layout.fillWidth: true
                
                background: Rectangle {
                    color: "#333333"
                    radius: 6
                    border.color: "#555555"
                    border.width: 1
                }
                
                color: "#ffffff"
                placeholderTextColor: "#888888"
                font.pixelSize: 14
            }
            
            TextField {
                id: newUserConfirmPasswordField
                placeholderText: "Confirm Password"
                echoMode: TextInput.Password
                Layout.fillWidth: true
                
                background: Rectangle {
                    color: "#333333"
                    radius: 6
                    border.color: "#555555"
                    border.width: 1
                }
                
                color: "#ffffff"
                placeholderTextColor: "#888888"
                font.pixelSize: 14
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                
                Text {
                    text: "Admin Access:"
                    font.pixelSize: 14
                    color: "#cccccc"
                }
                
                Switch {
                    id: newUserAdminSwitch
                    checked: false
                }
                
                Text {
                    text: newUserAdminSwitch.checked ? "Yes" : "No"
                    font.pixelSize: 14
                    color: newUserAdminSwitch.checked ? "#00ff00" : "#ff0000"
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Button {
                    text: "Create User"
                    Layout.fillWidth: true
                    
                    background: Rectangle {
                        color: parent.pressed ? "#404040" : "#5700eeff"
                        radius: 6
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        if (newUserPasswordField.text === newUserConfirmPasswordField.text && 
                            newUserPasswordField.text.length > 0 && 
                            newUsernameField.text.length > 0) {
                            createUser(newUsernameField.text, newUserPasswordField.text, newUserAdminSwitch.checked)
                            createUserDialog.close()
                            newUsernameField.text = ""
                            newUserPasswordField.text = ""
                            newUserConfirmPasswordField.text = ""
                            newUserAdminSwitch.checked = false
                        }
                    }
                }
                
                Button {
                    text: "Cancel"
                    Layout.fillWidth: true
                    
                    background: Rectangle {
                        color: parent.pressed ? "#404040" : "#555555"
                        radius: 6
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        createUserDialog.close()
                        newUsernameField.text = ""
                        newUserPasswordField.text = ""
                        newUserConfirmPasswordField.text = ""
                        newUserAdminSwitch.checked = false
                    }
                }
            }
        }
    }
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: 24
        
        ColumnLayout {
            width: parent.width - 48
            spacing: 16
            
            // Current User Profile
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                color: "#333333"
                radius: 12
                border.color: "#44ffffff"
                border.width: 1
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 16
                    
                    // User avatar
                    Rectangle {
                        width: 80
                        height: 80
                        radius: 40
                        color: "#5700eeff"
                        border.color: "#7700eeff"
                        border.width: 2
                        
                        Image {
                            anchors.fill: parent
                            anchors.margins: 4
                            source: userImage || ""
                            fillMode: Image.PreserveAspectCrop
                            visible: userImage !== ""
                            
                            layer.enabled: true
                            layer.smooth: true
                            layer.samples: 4
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: parent.width
                                    height: parent.height
                                    radius: width / 2
                                }
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: currentUser.charAt(0).toUpperCase()
                            font.pixelSize: 24
                            font.bold: true
                            color: "#ffffff"
                            visible: userImage === ""
                        }
                    }
                    
                    ColumnLayout {
                        spacing: 8
                        
                        Text {
                            text: currentUser
                            font.pixelSize: 20
                            font.weight: Font.Bold
                            color: "#ffffff"
                        }
                        
                        Text {
                            text: sudoAccess ? "Admin" : "User"
                            font.pixelSize: 14
                            color: sudoAccess ? "#00ff00" : "#cccccc"
                        }
                        
                        Text {
                            text: "Home: " + userHome
                            font.pixelSize: 12
                            color: "#888888"
                        }
                        
                        Text {
                            text: "Shell: " + userShell
                            font.pixelSize: 12
                            color: "#888888"
                        }
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    ColumnLayout {
                        spacing: 8
                        
                        Button {
                            text: "Set Image"
                            Layout.preferredWidth: 100
                            
                            background: Rectangle {
                                color: parent.pressed ? "#404040" : "#5700eeff"
                                radius: 6
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 12
                            }
                            
                            onClicked: {
                                imagePathDialog.open()
                            }
                        }
                        
                        Button {
                            text: "Change Password"
                            Layout.preferredWidth: 100
                            
                            background: Rectangle {
                                color: parent.pressed ? "#404040" : "#5700eeff"
                                radius: 6
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 12
                            }
                            
                            onClicked: {
                                passwordDialog.open()
                            }
                        }
                    }
                }
            }
            
            // User Settings
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: "#333333"
                radius: 12
                border.color: "#44ffffff"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12
                    
                    Text {
                        text: "User Settings"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        Text {
                            text: "Auto Login:"
                            font.pixelSize: 14
                            color: "#cccccc"
                            Layout.preferredWidth: 100
                        }
                        
                        Switch {
                            id: autoLoginSwitch
                            checked: autoLogin
                            onCheckedChanged: {
                                if (checked !== autoLogin) {
                                    toggleAutoLogin()
                                }
                            }
                        }
                        
                        Text {
                            text: autoLogin ? "Enabled" : "Disabled"
                            font.pixelSize: 14
                            color: autoLogin ? "#00ff00" : "#ff0000"
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        Text {
                            text: "Sudo Access:"
                            font.pixelSize: 14
                            color: "#cccccc"
                            Layout.preferredWidth: 100
                        }
                        
                        Switch {
                            id: sudoSwitch
                            checked: sudoAccess
                            onCheckedChanged: {
                                if (checked !== sudoAccess) {
                                    toggleSudoAccess()
                                }
                            }
                        }
                        
                        Text {
                            text: sudoAccess ? "Enabled" : "Disabled"
                            font.pixelSize: 14
                            color: sudoAccess ? "#00ff00" : "#ff0000"
                        }
                    }
                }
            }
            
            // All Users
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                color: "#333333"
                radius: 12
                border.color: "#44ffffff"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "All Users"
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            color: "#ffffff"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: "Create User"
                            Layout.preferredWidth: 100
                            
                            background: Rectangle {
                                color: parent.pressed ? "#404040" : "#5700eeff"
                                radius: 6
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 12
                            }
                            
                            onClicked: {
                                createUserDialog.open()
                            }
                        }
                    }
                    
                    ListView {
                        id: usersList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: allUsers
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 50
                            color: usersList.currentIndex === index ? "#5700eeff" : "transparent"
                            radius: 6
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 12
                                
                                Rectangle {
                                    width: 32
                                    height: 32
                                    radius: 16
                                    color: "#5700eeff"
                                    border.color: "#7700eeff"
                                    border.width: 1
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.charAt(0).toUpperCase()
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: "#ffffff"
                                    }
                                }
                                
                                ColumnLayout {
                                    spacing: 2
                                    
                                    Text {
                                        text: modelData
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                        color: "#ffffff"
                                    }
                                    
                                    Text {
                                        text: modelData === currentUser ? "Current User" : "User"
                                        font.pixelSize: 10
                                        color: "#888888"
                                    }
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Button {
                                    text: "Delete"
                                    visible: modelData !== currentUser
                                    Layout.preferredWidth: 60
                                    
                                    background: Rectangle {
                                        color: parent.pressed ? "#404040" : "#ff4444"
                                        radius: 4
                                    }
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        color: "#ffffff"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: 10
                                    }
                                    
                                    onClicked: {
                                        deleteUser(modelData)
                                    }
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    usersList.currentIndex = index
                                }
                            }
                        }
                        
                        ScrollBar.vertical: ScrollBar {
                            active: true
                            policy: ScrollBar.AsNeeded
                        }
                    }
                }
            }
            
            // User Groups
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                color: "#333333"
                radius: 12
                border.color: "#44ffffff"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12
                    
                    Text {
                        text: "User Groups"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    ListView {
                        id: groupsList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: userGroups
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 30
                            color: "transparent"
                            radius: 4
                            
                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData
                                font.pixelSize: 12
                                color: "#cccccc"
                            }
                        }
                        
                        ScrollBar.vertical: ScrollBar {
                            active: true
                            policy: ScrollBar.AsNeeded
                        }
                    }
                }
            }
        }
    }
    
    // Image path dialog
    Dialog {
        id: imagePathDialog
        title: "Set User Image"
        modal: true
        anchors.centerIn: parent
        width: 400
        height: 200
        
        background: Rectangle {
            color: "#2a2a2a"
            radius: 12
            border.color: "#44ffffff"
            border.width: 1
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16
            
            Text {
                text: "Enter image path:"
                font.pixelSize: 14
                color: "#ffffff"
            }
            
            TextField {
                id: imagePathField
                placeholderText: "/path/to/image.jpg"
                Layout.fillWidth: true
                
                background: Rectangle {
                    color: "#333333"
                    radius: 6
                    border.color: "#555555"
                    border.width: 1
                }
                
                color: "#ffffff"
                placeholderTextColor: "#888888"
                font.pixelSize: 14
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Button {
                    text: "Set Image"
                    Layout.fillWidth: true
                    
                    background: Rectangle {
                        color: parent.pressed ? "#404040" : "#5700eeff"
                        radius: 6
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        if (imagePathField.text.length > 0) {
                            userImage = imagePathField.text
                            saveUserImage()
                            imagePathDialog.close()
                            imagePathField.text = ""
                        }
                    }
                }
                
                Button {
                    text: "Cancel"
                    Layout.fillWidth: true
                    
                    background: Rectangle {
                        color: parent.pressed ? "#404040" : "#555555"
                        radius: 6
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        imagePathDialog.close()
                        imagePathField.text = ""
                    }
                }
            }
        }
    }
} 