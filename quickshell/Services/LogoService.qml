pragma Singleton
import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import qs.Settings
import Quickshell.Io
import Quickshell.Wayland
import Qt.labs.platform

Singleton {
    id: manager

    Item {
        Component.onCompleted: {
            loadLogos();
            // Wait a bit for ConfigService to be ready, then load saved logos
            Qt.callLater(function() {
                loadSavedLogos();
            });
        }
    }


    property var logoList: []
    property string currentBarLogo: "arch-white-symbolic.svg"
    property string currentDockLogo: "arch-symbolic.svg"
    property string logoColor: "#ffffff"
    property bool scanning: false

    function loadSavedLogos() {
        try {
            // Load from Settings service
            if (Settings.settings.barLogo) {
                currentBarLogo = Settings.settings.barLogo
            }
            if (Settings.settings.dockLogo) {
                currentDockLogo = Settings.settings.dockLogo
            }
            if (Settings.settings.logoColor) {
                logoColor = Settings.settings.logoColor
            }
        } catch (e) {
            // Set defaults if error loading settings
            currentBarLogo = "arch-symbolic.svg"
            currentDockLogo = "arch-symbolic.svg"
            logoColor = "#ffffff"
        }
    }

    function loadLogos() {
        scanning = true;
        logoList = [];
        folderModel.folder = "";
        folderModel.folder = "file://" + Quickshell.shellDir + "/assets/icons";
    }

    function setBarLogo(logoName) {
        currentBarLogo = logoName;
        saveLogoSettings();
    }

    function setDockLogo(logoName) {
        currentDockLogo = logoName;
        saveLogoSettings();
    }
    
    function setLogoColor(color) {
        logoColor = color;
        saveLogoSettings();
    }
    
    function saveLogoSettings() {
        try {
            // Save to Settings service
            Settings.settings.barLogo = currentBarLogo
            Settings.settings.dockLogo = currentDockLogo
            Settings.settings.logoColor = logoColor
        } catch (e) {
            // Error saving settings
        }
    }

    function getLogoPath(logoName) {
        return Quickshell.shellDir + "/assets/icons/" + logoName;
    }
    
    function reloadSavedSettings() {
        loadSavedLogos()
    }
    


    // Update logos when config changes - temporarily disabled
    // Connections {
    //     target: ConfigService
    //     
    //     function onConfigUpdated() {
    //         var settings = ConfigService.loadSettings()
    //         var newBarLogo = settings.barLogo || "arch-symbolic.svg"
    //         var newDockLogo = settings.dockLogo || "arch-symbolic.svg"
    //         var newLogoColor = settings.logoColor || "#ffffff"
    //         
    //         if (currentBarLogo !== newBarLogo) {
    //             currentBarLogo = newBarLogo
    //             console.log("Updated bar logo to:", newBarLogo)
    //         }
    //         if (currentDockLogo !== newDockLogo) {
    //             currentDockLogo = newDockLogo
    //             console.log("Updated dock logo to:", newDockLogo)
    //         }
    //         if (logoColor !== newLogoColor) {
    //             logoColor = newLogoColor
    //             console.log("Updated logo color to:", newLogoColor)
    //         }
    //     }
    // }

    FolderListModel {
        id: folderModel
        nameFilters: ["*.svg", "*.png"]
        showDirs: false
        sortField: FolderListModel.Name
        onStatusChanged: {
            if (status === FolderListModel.Ready) {
                var files = [];
                for (var i = 0; i < count; i++) {
                    var fileName = get(i, "fileName");
                    files.push(fileName);
                }
                logoList = files;
                scanning = false;
            }
        }
    }
    

} 