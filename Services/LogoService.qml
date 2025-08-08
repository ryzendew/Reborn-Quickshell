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
            loadSavedLogos();
            settingsFileView.path = `${StandardPaths.writableLocation(StandardPaths.HomeLocation)}/.local/state/Quickshell/Settings.conf`
        }
    }


    property var logoList: []
    property string currentBarLogo: "arch-white-symbolic.svg"
    property string currentDockLogo: "arch-symbolic.svg"
    property string logoColor: "#ffffff"
    property bool scanning: false

    function loadSavedLogos() {
        try {
            // Load settings from Settings.conf
            var settingsFile = Quickshell.env("HOME") + "/.local/state/Quickshell/Settings.conf"
            var settingsData = Quickshell.Io.readFile(settingsFile)
            
            if (settingsData && settingsData.length > 0) {
                var settings = JSON.parse(settingsData)
                
                // Apply saved settings
                if (settings.barLogo) {
                    currentBarLogo = settings.barLogo
                }
                if (settings.dockLogo) {
                    currentDockLogo = settings.dockLogo
                }
                if (settings.logoColor) {
                    logoColor = settings.logoColor
                }
            } else {
                // Set defaults if no saved settings
                currentBarLogo = "arch-symbolic.svg"
                currentDockLogo = "arch-symbolic.svg"
                logoColor = "#ffffff"
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
        var settings = {
            barLogo: currentBarLogo,
            dockLogo: currentDockLogo,
            logoColor: logoColor
        }
        writeSettingsFile(settings)
    }
    
        function writeSettingsFile(settings) {
        try {
            var settingsJson = JSON.stringify(settings, null, 2)
            var settingsFile = `${StandardPaths.writableLocation(StandardPaths.HomeLocation)}/.local/state/Quickshell/Settings.conf`
            
            // Create the directory if it doesn't exist
            var dirPath = settingsFile.replace('/Settings.conf', '');
            Hyprland.dispatch(`exec mkdir -p '${dirPath}'`);
            
            // Use a temporary file approach to avoid shell escaping issues
            var tempFile = dirPath + '/Settings.tmp'
            var finalFile = settingsFile
            
            // Write to temp file first
            var writeCommand = `echo '${settingsJson.replace(/'/g, "'\"'\"'")}' > '${tempFile}'`
            Hyprland.dispatch(`exec ${writeCommand}`)
            
            // Move temp file to final location
            Hyprland.dispatch(`exec mv '${tempFile}' '${finalFile}'`)
            
            // Reload the FileView to reflect changes
            if (settingsFileView && settingsFileView.reload) {
                settingsFileView.reload();
            }
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
    
    function createSettingsConf() {
        var settings = {
            barLogo: "arch-symbolic.svg",
            dockLogo: "arch-symbolic.svg",
            logoColor: "#ffffff"
        }
        writeSettingsFile(settings)
    }
    
    function ensureSettingsFileExists() {
        createSettingsConf()
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
    
    // FileView to monitor Settings.conf file (like the reference implementation)
    FileView {
        id: settingsFileView
        // Path will be set after file creation to avoid "file does not exist" warnings
        
        onLoaded: {
            try {
                var content = text();
                if (content && content.trim() !== '') {
                    var settings = JSON.parse(content);
                    
                    // Update logo settings from file
                    if (settings.barLogo && settings.barLogo !== currentBarLogo) {
                        currentBarLogo = settings.barLogo;
                    }
                    if (settings.dockLogo && settings.dockLogo !== currentDockLogo) {
                        currentDockLogo = settings.dockLogo;
                    }
                    if (settings.logoColor && settings.logoColor !== logoColor) {
                        logoColor = settings.logoColor;
                    }
                }
            } catch (e) {
                // Error loading Settings.conf
            }
        }
        
        onLoadFailed: {
            createSettingsConf();
        }
    }
} 