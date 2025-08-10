import QtQuick

pragma Singleton

QtObject {
    id: root
    
    // Signal to open settings window with specific tab
    signal openSettingsTab(int tabIndex)
    
    // Function to open weather tab
    function openWeatherTab() {
        openSettingsTab(10)  // Weather tab index
    }
} 