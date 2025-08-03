pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: root
    
    property var audio: QtObject {
        property var protection: QtObject {
            property bool enable: false
            property real maxAllowedIncrease: 20
            property real maxAllowed: 100
        }
    }
    
    property var osd: QtObject {
        property int timeout: 2000
    }
    
    property var bar: QtObject {
        property bool bottom: true
    }
} 