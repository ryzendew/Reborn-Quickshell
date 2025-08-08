import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Settings
import qs.Services

Rectangle {
    id: timeTab
    color: "transparent"
    
    // Time properties
    property string currentTimezone: "UTC"
    property bool ntpEnabled: true
    
    // Timer for updating time display
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            timeDisplay.text = TimeService.formatTime(new Date())
            dateDisplay.text = TimeService.formatDate(new Date())
        }
    }
    
    Component.onCompleted: {
        console.log("TimeTab: Component completed")
        // Load settings from TimeService
        currentTimezone = TimeService.timezone
        ntpEnabled = true // Default to true
    }
    
    function setTimeFormat(format) {
        TimeService.timeFormat = format
        TimeService.saveSettings()
    }
    
    function setDateFormat(format) {
        TimeService.dateFormat = format
        TimeService.saveSettings()
    }
    
    function setShowSeconds(show) {
        TimeService.showSeconds = show
        TimeService.saveSettings()
    }
    
    function setShowDate(show) {
        TimeService.showDate = show
        TimeService.saveSettings()
    }
    
    function setTimeBold(bold) {
        TimeService.timeBold = bold
        TimeService.saveSettings()
    }
    
    function setDateBold(bold) {
        TimeService.dateBold = bold
        TimeService.saveSettings()
    }
    
    function setTimeSize(size) {
        TimeService.timeSize = size
        TimeService.saveSettings()
    }
    
    function setDateSize(size) {
        TimeService.dateSize = size
        TimeService.saveSettings()
    }
    
    function setTimeSpacing(spacing) {
        TimeService.timeSpacing = spacing
        TimeService.saveSettings()
    }
    
    function setTimeColor(color) {
        TimeService.timeColor = color
        TimeService.saveSettings()
    }
    
    function setDateColor(color) {
        TimeService.dateColor = color
        TimeService.saveSettings()
    }
    
    function setTimezone(timezone) {
        currentTimezone = timezone
        TimeService.timezone = timezone
        TimeService.saveSettings()
        // Execute timezone change command
        Hyprland.dispatch(`exec timedatectl set-timezone ${timezone}`)
    }
    
    function toggleNTP() {
        ntpEnabled = !ntpEnabled
        if (ntpEnabled) {
            Hyprland.dispatch("exec timedatectl set-ntp true")
        } else {
            Hyprland.dispatch("exec timedatectl set-ntp false")
        }
    }
    
    // Color options
    property var colorOptions: [
        { name: "White", value: "#ffffff" },
        { name: "Light Gray", value: "#cccccc" },
        { name: "Gray", value: "#888888" },
        { name: "Cyan", value: "#00ffff" },
        { name: "Blue", value: "#0088ff" },
        { name: "Green", value: "#00ff00" },
        { name: "Yellow", value: "#ffff00" },
        { name: "Orange", value: "#ff8800" },
        { name: "Red", value: "#ff0000" },
        { name: "Purple", value: "#8800ff" }
    ]
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: 24
        
        ColumnLayout {
            width: parent.width - 48
            spacing: 16
            
            // Current Time Display
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                color: "#333333"
                radius: 12
                border.color: "#44ffffff"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 6
                    
                    Text {
                        text: "Current Time"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: "#cccccc"
                    }
                    
                    Text {
                        id: timeDisplay
                        text: TimeService.formatTime(new Date())
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        font.family: "Monospace"
                        color: "#ffffff"
                    }
                    
                    Text {
                        id: dateDisplay
                        text: TimeService.formatDate(new Date())
                        font.pixelSize: 14
                        color: "#888888"
                    }
                }
            }
            
            // Time Settings
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 220
                color: "#333333"
                radius: 12
                border.color: "#44ffffff"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    Text {
                        text: "Time Settings"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    // Time Format
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        Text {
                            text: "Time Format:"
                            font.pixelSize: 14
                            color: "#cccccc"
                            Layout.preferredWidth: 100
                        }
                        
                        ComboBox {
                            id: timeFormatCombo
                            model: ["24h", "12h"]
                            currentIndex: TimeService.timeFormat === "12h" ? 1 : 0
                            Layout.preferredWidth: 120
                            
                            background: Rectangle {
                                color: "#2a2a2a"
                                radius: 6
                                border.color: "#555555"
                                border.width: 1
                            }
                            
                            contentItem: Text {
                                text: timeFormatCombo.displayText
                                color: "#ffffff"
                                font.pixelSize: 14
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                            }
                            
                            onActivated: {
                                setTimeFormat(model[index])
                            }
                        }
                    }
                    
                    // Show Seconds
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        Text {
                            text: "Show Seconds:"
                            font.pixelSize: 14
                            color: "#cccccc"
                            Layout.preferredWidth: 100
                        }
                        
                        Switch {
                            id: showSecondsSwitch
                            checked: TimeService.showSeconds
                            onCheckedChanged: {
                                if (checked !== TimeService.showSeconds) {
                                    setShowSeconds(checked)
                                }
                            }
                        }
                        
                        Text {
                            text: TimeService.showSeconds ? "Enabled" : "Disabled"
                            font.pixelSize: 14
                            color: TimeService.showSeconds ? "#00ff00" : "#ff0000"
                        }
                    }
                    
                    // Show Date
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        Text {
                            text: "Show Date:"
                            font.pixelSize: 14
                            color: "#cccccc"
                            Layout.preferredWidth: 100
                        }
                        
                        Switch {
                            id: showDateSwitch
                            checked: TimeService.showDate
                            onCheckedChanged: {
                                if (checked !== TimeService.showDate) {
                                    setShowDate(checked)
                                }
                            }
                        }
                        
                        Text {
                            text: TimeService.showDate ? "Enabled" : "Disabled"
                            font.pixelSize: 14
                            color: TimeService.showDate ? "#00ff00" : "#ff0000"
                        }
                    }
                    
                    // Date Format
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        Text {
                            text: "Date Format:"
                            font.pixelSize: 14
                            color: "#cccccc"
                            Layout.preferredWidth: 100
                        }
                        
                        ComboBox {
                            id: dateFormatCombo
                            model: ["MMM dd", "MMM dd yyyy", "MM/dd", "MM/dd/yyyy", "dd/MM", "dd/MM/yyyy", "yyyy-MM-dd", "MM-dd", "dd-MM", "MMMM dd", "MMMM dd, yyyy"]
                            currentIndex: {
                                switch(TimeService.dateFormat) {
                                    case "MMM dd yyyy": return 1
                                    case "MM/dd": return 2
                                    case "MM/dd/yyyy": return 3
                                    case "dd/MM": return 4
                                    case "dd/MM/yyyy": return 5
                                    case "yyyy-MM-dd": return 6
                                    case "MM-dd": return 7
                                    case "dd-MM": return 8
                                    case "MMMM dd": return 9
                                    case "MMMM dd, yyyy": return 10
                                    default: return 0
                                }
                            }
                            Layout.preferredWidth: 150
                            
                            background: Rectangle {
                                color: "#2a2a2a"
                                radius: 6
                                border.color: "#555555"
                                border.width: 1
                            }
                            
                            contentItem: Text {
                                text: dateFormatCombo.displayText
                                color: "#ffffff"
                                font.pixelSize: 14
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                            }
                            
                            onActivated: {
                                setDateFormat(model[index])
                            }
                        }
                    }
                    
                    // NTP Toggle
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        Text {
                            text: "Network Time:"
                            font.pixelSize: 14
                            color: "#cccccc"
                            Layout.preferredWidth: 100
                        }
                        
                        Switch {
                            id: ntpSwitch
                            checked: ntpEnabled
                            onCheckedChanged: {
                                if (checked !== ntpEnabled) {
                                    toggleNTP()
                                }
                            }
                        }
                        
                        Text {
                            text: ntpEnabled ? "Enabled" : "Disabled"
                            font.pixelSize: 14
                            color: ntpEnabled ? "#00ff00" : "#ff0000"
                        }
                    }
                }
            }
            
            // Text Styling Settings
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 280
                color: "#333333"
                radius: 12
                border.color: "#44ffffff"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    Text {
                        text: "Text Styling"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    // Time Bold
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        Text {
                            text: "Time Bold:"
                            font.pixelSize: 14
                            color: "#cccccc"
                            Layout.preferredWidth: 100
                        }
                        
                        Switch {
                            id: timeBoldSwitch
                            checked: TimeService.timeBold
                            onCheckedChanged: {
                                if (checked !== TimeService.timeBold) {
                                    setTimeBold(checked)
                                }
                            }
                        }
                        
                        Text {
                            text: TimeService.timeBold ? "Enabled" : "Disabled"
                            font.pixelSize: 14
                            color: TimeService.timeBold ? "#00ff00" : "#ff0000"
                        }
                    }
                    
                    // Date Bold
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        Text {
                            text: "Date Bold:"
                            font.pixelSize: 14
                            color: "#cccccc"
                            Layout.preferredWidth: 100
                        }
                        
                        Switch {
                            id: dateBoldSwitch
                            checked: TimeService.dateBold
                            onCheckedChanged: {
                                if (checked !== TimeService.dateBold) {
                                    setDateBold(checked)
                                }
                            }
                        }
                        
                        Text {
                            text: TimeService.dateBold ? "Enabled" : "Disabled"
                            font.pixelSize: 14
                            color: TimeService.dateBold ? "#00ff00" : "#ff0000"
                        }
                    }
                    
                    // Time Size
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        Text {
                            text: "Time Size:"
                            font.pixelSize: 14
                            color: "#cccccc"
                            Layout.preferredWidth: 100
                        }
                        
                        Slider {
                            id: timeSizeSlider
                            from: 8
                            to: 24
                            value: TimeService.timeSize
                            stepSize: 1
                            Layout.fillWidth: true
                            
                            onValueChanged: {
                                setTimeSize(value)
                            }
                        }
                        
                        Text {
                            text: timeSizeSlider.value
                            font.pixelSize: 14
                            color: "#ffffff"
                            Layout.preferredWidth: 30
                        }
                    }
                    
                    // Date Size
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        Text {
                            text: "Date Size:"
                            font.pixelSize: 14
                            color: "#cccccc"
                            Layout.preferredWidth: 100
                        }
                        
                        Slider {
                            id: dateSizeSlider
                            from: 8
                            to: 20
                            value: TimeService.dateSize
                            stepSize: 1
                            Layout.fillWidth: true
                            
                            onValueChanged: {
                                setDateSize(value)
                            }
                        }
                        
                        Text {
                            text: dateSizeSlider.value
                            font.pixelSize: 14
                            color: "#ffffff"
                            Layout.preferredWidth: 30
                        }
                    }
                    
                    // Time Spacing
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        Text {
                            text: "Spacing:"
                            font.pixelSize: 14
                            color: "#cccccc"
                            Layout.preferredWidth: 100
                        }
                        
                        Slider {
                            id: spacingSlider
                            from: 0
                            to: 10
                            value: TimeService.timeSpacing
                            stepSize: 1
                            Layout.fillWidth: true
                            
                            onValueChanged: {
                                setTimeSpacing(value)
                            }
                        }
                        
                        Text {
                            text: spacingSlider.value
                            font.pixelSize: 14
                            color: "#ffffff"
                            Layout.preferredWidth: 30
                        }
                    }
                    
                    // Time Color
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        Text {
                            text: "Time Color:"
                            font.pixelSize: 14
                            color: "#cccccc"
                            Layout.preferredWidth: 100
                        }
                        
                        ComboBox {
                            id: timeColorCombo
                            model: colorOptions
                            textRole: "name"
                            valueRole: "value"
                            currentIndex: {
                                for (var i = 0; i < colorOptions.length; i++) {
                                    if (colorOptions[i].value === TimeService.timeColor) {
                                        return i
                                    }
                                }
                                return 0
                            }
                            Layout.preferredWidth: 120
                            
                            background: Rectangle {
                                color: "#2a2a2a"
                                radius: 6
                                border.color: "#555555"
                                border.width: 1
                            }
                            
                            contentItem: Text {
                                text: timeColorCombo.displayText
                                color: "#ffffff"
                                font.pixelSize: 14
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                            }
                            
                            onActivated: {
                                setTimeColor(colorOptions[index].value)
                            }
                        }
                        
                        Rectangle {
                            width: 40
                            height: 24
                            radius: 4
                            color: TimeService.timeColor
                            border.color: "#555555"
                            border.width: 1
                        }
                    }
                    
                    // Date Color
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        Text {
                            text: "Date Color:"
                            font.pixelSize: 14
                            color: "#cccccc"
                            Layout.preferredWidth: 100
                        }
                        
                        ComboBox {
                            id: dateColorCombo
                            model: colorOptions
                            textRole: "name"
                            valueRole: "value"
                            currentIndex: {
                                for (var i = 0; i < colorOptions.length; i++) {
                                    if (colorOptions[i].value === TimeService.dateColor) {
                                        return i
                                    }
                                }
                                return 0
                            }
                            Layout.preferredWidth: 120
                            
                            background: Rectangle {
                                color: "#2a2a2a"
                                radius: 6
                                border.color: "#555555"
                                border.width: 1
                            }
                            
                            contentItem: Text {
                                text: dateColorCombo.displayText
                                color: "#ffffff"
                                font.pixelSize: 14
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                            }
                            
                            onActivated: {
                                setDateColor(colorOptions[index].value)
                            }
                        }
                        
                        Rectangle {
                            width: 40
                            height: 24
                            radius: 4
                            color: TimeService.dateColor
                            border.color: "#555555"
                            border.width: 1
                        }
                    }
                }
            }
            
            // Timezone Selection
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                color: "#333333"
                radius: 12
                border.color: "#44ffffff"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    Text {
                        text: "Timezone"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    
                    // Search box
                    TextField {
                        id: timezoneSearch
                        placeholderText: "Search timezone..."
                        Layout.fillWidth: true
                        
                        background: Rectangle {
                            color: "#2a2a2a"
                            radius: 6
                            border.color: "#555555"
                            border.width: 1
                        }
                        
                        color: "#ffffff"
                        placeholderTextColor: "#888888"
                        font.pixelSize: 14
                        
                        onTextChanged: {
                            // Filter timezone list
                            timezoneList.model = getFilteredTimezones(text)
                        }
                    }
                    
                    // Timezone list
                    ListView {
                        id: timezoneList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: getTimezones()
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 40
                            color: timezoneList.currentIndex === index ? "#5700eeff" : "transparent"
                            radius: 6
                            
                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData
                                font.pixelSize: 14
                                color: timezoneList.currentIndex === index ? "#ffffff" : "#cccccc"
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    timezoneList.currentIndex = index
                                    setTimezone(modelData)
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
        }
    }
    
    function getTimezones() {
        // Comprehensive list of all timezones
        return [
            "UTC",
            "Africa/Abidjan", "Africa/Accra", "Africa/Addis_Ababa", "Africa/Algiers", "Africa/Asmara", "Africa/Bamako", "Africa/Bangui", "Africa/Banjul", "Africa/Bissau", "Africa/Blantyre", "Africa/Brazzaville", "Africa/Bujumbura", "Africa/Cairo", "Africa/Casablanca", "Africa/Ceuta", "Africa/Conakry", "Africa/Dakar", "Africa/Dar_es_Salaam", "Africa/Djibouti", "Africa/Douala", "Africa/El_Aaiun", "Africa/Freetown", "Africa/Gaborone", "Africa/Harare", "Africa/Johannesburg", "Africa/Juba", "Africa/Kampala", "Africa/Khartoum", "Africa/Kigali", "Africa/Kinshasa", "Africa/Lagos", "Africa/Libreville", "Africa/Lome", "Africa/Luanda", "Africa/Lubumbashi", "Africa/Lusaka", "Africa/Malabo", "Africa/Maputo", "Africa/Maseru", "Africa/Mbabane", "Africa/Mogadishu", "Africa/Monrovia", "Africa/Nairobi", "Africa/Ndjamena", "Africa/Niamey", "Africa/Nouakchott", "Africa/Ouagadougou", "Africa/Porto-Novo", "Africa/Sao_Tome", "Africa/Tripoli", "Africa/Tunis", "Africa/Windhoek",
            "America/Adak", "America/Anchorage", "America/Anguilla", "America/Antigua", "America/Araguaina", "America/Argentina/Buenos_Aires", "America/Argentina/Catamarca", "America/Argentina/Cordoba", "America/Argentina/Jujuy", "America/Argentina/La_Rioja", "America/Argentina/Mendoza", "America/Argentina/Rio_Gallegos", "America/Argentina/Salta", "America/Argentina/San_Juan", "America/Argentina/San_Luis", "America/Argentina/Tucuman", "America/Argentina/Ushuaia", "America/Aruba", "America/Asuncion", "America/Atikokan", "America/Bahia", "America/Bahia_Banderas", "America/Barbados", "America/Belem", "America/Belize", "America/Blanc-Sablon", "America/Boa_Vista", "America/Bogota", "America/Boise", "America/Cambridge_Bay", "America/Campo_Grande", "America/Cancun", "America/Caracas", "America/Cayenne", "America/Cayman", "America/Chicago", "America/Chihuahua", "America/Costa_Rica", "America/Creston", "America/Cuiaba", "America/Curacao", "America/Danmarkshavn", "America/Dawson", "America/Dawson_Creek", "America/Denver", "America/Detroit", "America/Dominica", "America/Edmonton", "America/Eirunepe", "America/El_Salvador", "America/Fort_Nelson", "America/Fortaleza", "America/Glace_Bay", "America/Goose_Bay", "America/Grand_Turk", "America/Grenada", "America/Guadeloupe", "America/Guatemala", "America/Guayaquil", "America/Guyana", "America/Halifax", "America/Havana", "America/Hermosillo", "America/Indiana/Indianapolis", "America/Indiana/Knox", "America/Indiana/Marengo", "America/Indiana/Petersburg", "America/Indiana/Tell_City", "America/Indiana/Vevay", "America/Indiana/Vincennes", "America/Indiana/Winamac", "America/Inuvik", "America/Iqaluit", "America/Jamaica", "America/Juneau", "America/Kentucky/Louisville", "America/Kentucky/Monticello", "America/Kralendijk", "America/La_Paz", "America/Lima", "America/Los_Angeles", "America/Lower_Princes", "America/Maceio", "America/Managua", "America/Manaus", "America/Marigot", "America/Martinique", "America/Matamoros", "America/Mazatlan", "America/Menominee", "America/Merida", "America/Metlakatla", "America/Mexico_City", "America/Miquelon", "America/Moncton", "America/Monterrey", "America/Montevideo", "America/Montreal", "America/Montserrat", "America/Nassau", "America/New_York", "America/Nipigon", "America/Nome", "America/Noronha", "America/North_Dakota/Beulah", "America/North_Dakota/Center", "America/North_Dakota/New_Salem", "America/Ojinaga", "America/Panama", "America/Pangnirtung", "America/Paramaribo", "America/Phoenix", "America/Port-au-Prince", "America/Port_of_Spain", "America/Porto_Velho", "America/Puerto_Rico", "America/Punta_Arenas", "America/Rainy_River", "America/Rankin_Inlet", "America/Recife", "America/Regina", "America/Resolute", "America/Rio_Branco", "America/Santarem", "America/Santiago", "America/Santo_Domingo", "America/Sao_Paulo", "America/Scoresbysund", "America/Sitka", "America/St_Barthelemy", "America/St_Johns", "America/St_Kitts", "America/St_Lucia", "America/St_Thomas", "America/St_Vincent", "America/Swift_Current", "America/Tegucigalpa", "America/Thule", "America/Thunder_Bay", "America/Tijuana", "America/Toronto", "America/Tortola", "America/Vancouver", "America/Whitehorse", "America/Winnipeg", "America/Yakutat", "America/Yellowknife",
            "Antarctica/Casey", "Antarctica/Davis", "Antarctica/DumontDUrville", "Antarctica/Macquarie", "Antarctica/Mawson", "Antarctica/McMurdo", "Antarctica/Palmer", "Antarctica/Rothera", "Antarctica/Syowa", "Antarctica/Troll", "Antarctica/Vostok",
            "Arctic/Longyearbyen",
            "Asia/Aden", "Asia/Almaty", "Asia/Amman", "Asia/Anadyr", "Asia/Aqtau", "Asia/Aqtobe", "Asia/Ashgabat", "Asia/Atyrau", "Asia/Baghdad", "Asia/Bahrain", "Asia/Baku", "Asia/Bangkok", "Asia/Barnaul", "Asia/Beirut", "Asia/Bishkek", "Asia/Brunei", "Asia/Chita", "Asia/Choibalsan", "Asia/Colombo", "Asia/Damascus", "Asia/Dhaka", "Asia/Dili", "Asia/Dubai", "Asia/Dushanbe", "Asia/Famagusta", "Asia/Gaza", "Asia/Hebron", "Asia/Ho_Chi_Minh", "Asia/Hong_Kong", "Asia/Hovd", "Asia/Irkutsk", "Asia/Jakarta", "Asia/Jayapura", "Asia/Jerusalem", "Asia/Kabul", "Asia/Kamchatka", "Asia/Karachi", "Asia/Kathmandu", "Asia/Khandyga", "Asia/Kolkata", "Asia/Krasnoyarsk", "Asia/Kuala_Lumpur", "Asia/Kuching", "Asia/Kuwait", "Asia/Macau", "Asia/Magadan", "Asia/Makassar", "Asia/Manila", "Asia/Muscat", "Asia/Nicosia", "Asia/Novokuznetsk", "Asia/Novosibirsk", "Asia/Omsk", "Asia/Oral", "Asia/Phnom_Penh", "Asia/Pontianak", "Asia/Pyongyang", "Asia/Qatar", "Asia/Qostanay", "Asia/Qyzylorda", "Asia/Riyadh", "Asia/Sakhalin", "Asia/Samarkand", "Asia/Seoul", "Asia/Shanghai", "Asia/Singapore", "Asia/Srednekolymsk", "Asia/Taipei", "Asia/Tashkent", "Asia/Tbilisi", "Asia/Tehran", "Asia/Thimphu", "Asia/Tokyo", "Asia/Tomsk", "Asia/Ulaanbaatar", "Asia/Urumqi", "Asia/Ust-Nera", "Asia/Vladivostok", "Asia/Yakutsk", "Asia/Yangon", "Asia/Yekaterinburg", "Asia/Yerevan",
            "Atlantic/Azores", "Atlantic/Bermuda", "Atlantic/Canary", "Atlantic/Cape_Verde", "Atlantic/Faroe", "Atlantic/Madeira", "Atlantic/Reykjavik", "Atlantic/South_Georgia", "Atlantic/St_Helena", "Atlantic/Stanley",
            "Australia/Adelaide", "Australia/Brisbane", "Australia/Broken_Hill", "Australia/Currie", "Australia/Darwin", "Australia/Eucla", "Australia/Hobart", "Australia/Lindeman", "Australia/Lord_Howe", "Australia/Melbourne", "Australia/Perth", "Australia/Sydney",
            "Europe/Amsterdam", "Europe/Andorra", "Europe/Astrakhan", "Europe/Athens", "Europe/Belgrade", "Europe/Berlin", "Europe/Bratislava", "Europe/Brussels", "Europe/Bucharest", "Europe/Budapest", "Europe/Busingen", "Europe/Chisinau", "Europe/Copenhagen", "Europe/Dublin", "Europe/Gibraltar", "Europe/Guernsey", "Europe/Helsinki", "Europe/Isle_of_Man", "Europe/Istanbul", "Europe/Jersey", "Europe/Kaliningrad", "Europe/Kiev", "Europe/Kirov", "Europe/Lisbon", "Europe/Ljubljana", "Europe/London", "Europe/Luxembourg", "Europe/Madrid", "Europe/Malta", "Europe/Mariehamn", "Europe/Minsk", "Europe/Monaco", "Europe/Moscow", "Europe/Oslo", "Europe/Paris", "Europe/Podgorica", "Europe/Prague", "Europe/Riga", "Europe/Rome", "Europe/Samara", "Europe/San_Marino", "Europe/Sarajevo", "Europe/Saratov", "Europe/Simferopol", "Europe/Skopje", "Europe/Sofia", "Europe/Stockholm", "Europe/Tallinn", "Europe/Tirane", "Europe/Ulyanovsk", "Europe/Uzhgorod", "Europe/Vaduz", "Europe/Vatican", "Europe/Vienna", "Europe/Vilnius", "Europe/Volgograd", "Europe/Warsaw", "Europe/Zagreb", "Europe/Zaporozhye", "Europe/Zurich",
            "Indian/Antananarivo", "Indian/Chagos", "Indian/Christmas", "Indian/Cocos", "Indian/Comoro", "Indian/Kerguelen", "Indian/Mahe", "Indian/Maldives", "Indian/Mauritius", "Indian/Mayotte", "Indian/Reunion",
            "Pacific/Apia", "Pacific/Auckland", "Pacific/Bougainville", "Pacific/Chatham", "Pacific/Chuuk", "Pacific/Easter", "Pacific/Efate", "Pacific/Enderbury", "Pacific/Fakaofo", "Pacific/Fiji", "Pacific/Funafuti", "Pacific/Galapagos", "Pacific/Gambier", "Pacific/Guadalcanal", "Pacific/Guam", "Pacific/Honolulu", "Pacific/Kiritimati", "Pacific/Kosrae", "Pacific/Kwajalein", "Pacific/Majuro", "Pacific/Marquesas", "Pacific/Midway", "Pacific/Nauru", "Pacific/Niue", "Pacific/Norfolk", "Pacific/Noumea", "Pacific/Pago_Pago", "Pacific/Palau", "Pacific/Pitcairn", "Pacific/Pohnpei", "Pacific/Port_Moresby", "Pacific/Rarotonga", "Pacific/Saipan", "Pacific/Tahiti", "Pacific/Tarawa", "Pacific/Tongatapu", "Pacific/Wake", "Pacific/Wallis"
        ]
    }
    
    function getFilteredTimezones(searchText) {
        if (!searchText || searchText.length === 0) {
            return getTimezones()
        }
        
        var timezones = getTimezones()
        var filtered = []
        
        for (var i = 0; i < timezones.length; i++) {
            if (timezones[i].toLowerCase().includes(searchText.toLowerCase())) {
                filtered.push(timezones[i])
            }
        }
        
        return filtered
    }
} 