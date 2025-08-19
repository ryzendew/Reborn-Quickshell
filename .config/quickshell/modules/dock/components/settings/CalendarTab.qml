import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Settings
import qs.Services

Rectangle {
    id: calendarTab
    color: "transparent"
    
    // Main background behind everything
    Rectangle {
        anchors.fill: parent
        color: "#00747474"
        opacity: 0.8
        radius: 8
    }
    
    // Current date properties
    property date currentDate: new Date()
    property int currentMonth: currentDate.getMonth()
    property int currentYear: currentDate.getFullYear()
    property int selectedDay: currentDate.getDate()
    
    // Holiday properties
    property var currentMonthHolidays: []
    property bool holidaysLoaded: false
    
    // Initialize holidays
    Component.onCompleted: {
        loadHolidaysForMonth()
    }
    
    // Calendar navigation
    function nextMonth() {
        if (currentMonth === 11) {
            currentMonth = 0
            currentYear++
        } else {
            currentMonth++
        }
        selectedDay = 1
        loadHolidaysForMonth()
    }
    
    function previousMonth() {
        if (currentMonth === 0) {
            currentMonth = 11
            currentYear--
        } else {
            currentMonth--
        }
        selectedDay = 1
        loadHolidaysForMonth()
    }
    
    function goToToday() {
        currentDate = new Date()
        currentMonth = currentDate.getMonth()
        currentYear = currentDate.getFullYear()
        selectedDay = currentDate.getDate()
        loadHolidaysForMonth()
    }
    
    // Get days in month
    function getDaysInMonth(month, year) {
        return new Date(year, month + 1, 0).getDate()
    }
    
    // Get first day of month (0 = Sunday, 1 = Monday, etc.)
    function getFirstDayOfMonth(month, year) {
        const firstDay = new Date(year, month, 1).getDay()
        if (Settings.settings.calendarWeekStart === "Monday") {
            // Convert Sunday=0 to Monday=0
            return firstDay === 0 ? 6 : firstDay - 1
        }
        return firstDay
    }
    
    // Get month name
    function getMonthName(month) {
        const months = ["January", "February", "March", "April", "May", "June",
                       "July", "August", "September", "October", "November", "December"]
        return months[month]
    }
    
    // Get day name
    function getDayName(day) {
        if (Settings.settings.calendarWeekStart === "Monday") {
            const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            return days[day]
        } else {
            const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            return days[day]
        }
    }
    
    // Load holidays for current month
    function loadHolidaysForMonth() {
        currentMonthHolidays = HolidayService.getHolidaysForMonth(currentMonth, currentYear)
        holidaysLoaded = true
    }
    
    // Check if a date has holidays
    function hasHolidays(day) {
        if (!holidaysLoaded || day <= 0) return false
        const date = new Date(currentYear, currentMonth, day)
        return HolidayService.hasHolidays(date)
    }
    
    // Get holiday names for a date
    function getHolidayNames(day) {
        if (!holidaysLoaded || day <= 0) return []
        const date = new Date(currentYear, currentMonth, day)
        return HolidayService.getHolidayNames(date)
    }
    
    ColumnLayout {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 12
        spacing: 12
        

        
        // Calendar Navigation and Display
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            radius: 12
            border.color: "#33ffffff"
            border.width: 1
            
            // macOS Tahoe-style transparency effect
            Rectangle {
                anchors.fill: parent
                color: "#2a2a2a"
                opacity: 0.8
                radius: 12
            }
            
            // Dark mode backdrop
            Rectangle {
                anchors.fill: parent
                color: "#1a1a1a"
                opacity: 0.3
                radius: 12
            }
            
            // Semi-transparent white border overlay
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                radius: 12
                border.color: "#40ffffff"
                border.width: 1
            }
            
            // Semi-transparent white overlay for macOS-like shine
            Rectangle {
                anchors.fill: parent
                color: "#15ffffff"
                radius: 12
            }
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 2
                
                // Month/Year Navigation
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    spacing: 16
                    
                    // Previous month button
                    Rectangle {
                        width: 40
                        implicitHeight: 40
                        radius: 8
                        color: prevMonthMouseArea.containsMouse ? "#404040" : "#333333"
                        border.color: "#44ffffff"
                        border.width: 1
                        
                        Text {
                            anchors.centerIn: parent
                            text: "chevron_left"
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: 32
                            color: "#ffffff"
                        }
                        
                        MouseArea {
                            id: prevMonthMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: previousMonth()
                        }
                    }
                    
                    // Month/Year display
                    Text {
                        text: getMonthName(currentMonth) + " " + currentYear
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: "#ffffff"
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    // Next month button
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 8
                        color: nextMonthMouseArea.containsMouse ? "#404040" : "#333333"
                        border.color: "#44ffffff"
                        border.width: 1
                        
                        Text {
                            anchors.centerIn: parent
                            text: "chevron_right"
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: 20
                            color: "#ffffff"
                        }
                        
                        MouseArea {
                            id: nextMonthMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: nextMonth()
                        }
                    }
                    
                    // Today button
                    Rectangle {
                        width: 80
                        height: 40
                        radius: 8
                        color: todayMouseArea.containsMouse ? "#5700eeff" : "#333333"
                        border.color: "#44ffffff"
                        border.width: 1
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Today"
                            font.pixelSize: 24
                            font.weight: Font.Medium
                            color: "#ffffff"
                        }
                        
                        MouseArea {
                            id: todayMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: goToToday()
                        }
                    }
                }
                
                // Day headers
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    spacing: 4
                    
                    Repeater {
                        model: 7
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            Layout.preferredWidth: 30
                            color: "transparent"
                            border.color: "#33ffffff"
                            border.width: 1
                            radius: 6
                            
                            Text {
                                anchors.centerIn: parent
                                text: getDayName(index)
                                font.pixelSize: 24
                                font.weight: Font.Medium
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
                
                // Calendar grid
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 7
                    rowSpacing: 4
                    columnSpacing: 4
                    
                    Repeater {
                        model: {
                            const daysInMonth = getDaysInMonth(currentMonth, currentYear)
                            const firstDay = getFirstDayOfMonth(currentMonth, currentYear)
                            const totalCells = Math.ceil((firstDay + daysInMonth) / 7) * 7
                            const cells = []
                            
                            // Add empty cells for days before month starts
                            for (let i = 0; i < firstDay; i++) {
                                cells.push({ day: 0, isCurrentMonth: false })
                            }
                            
                            // Add days of the month
                            for (let day = 1; day <= daysInMonth; day++) {
                                const isToday = day === new Date().getDate() && 
                                              currentMonth === new Date().getMonth() && 
                                              currentYear === new Date().getFullYear()
                                cells.push({ day: day, isCurrentMonth: true, isToday: isToday })
                            }
                            
                            // Add empty cells to complete the grid
                            while (cells.length < totalCells) {
                                cells.push({ day: 0, isCurrentMonth: false })
                            }
                            
                            return cells
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredHeight: 80
                            Layout.preferredWidth: 80
                            color: {
                                if (modelData.day === 0) return "transparent"
                                if (modelData.day === selectedDay) return "#5700eeff"
                                if (modelData.isToday) return "#333333"
                                return "transparent"
                            }
                            radius: 6
                            border.color: "#33ffffff"
                            border.width: 1
                            
                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.top: parent.top
                                anchors.topMargin: 8
                                text: modelData.day > 0 ? modelData.day : ""
                                font.pixelSize: 24
                                font.weight: modelData.day === selectedDay ? Font.Bold : Font.Normal
                                color: {
                                    if (modelData.day === 0) return "transparent"
                                    if (modelData.day === selectedDay) return "#ffffff"
                                    if (modelData.isToday) return "#00eeff"
                                    if (modelData.isCurrentMonth) return "#ffffff"
                                    return "#666666"
                                }
                            }
                            
                            // Holiday names in bottom left corner
                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 4
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 4
                                text: modelData.day > 0 && hasHolidays(modelData.day) ? 
                                    getHolidayNames(modelData.day).join(", ") : ""
                                font.pixelSize: 16
                                color: "#ffffff"
                                font.weight: Font.Medium
                                visible: modelData.day > 0 && hasHolidays(modelData.day) && Settings.settings.calendarShowHolidays
                                wrapMode: Text.WordWrap
                                width: parent.width - 8
                            }
                            

                            
                            MouseArea {
                                anchors.fill: parent
                                enabled: modelData.day > 0
                                onClicked: {
                                    if (modelData.day > 0) {
                                        selectedDay = modelData.day
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Country Selector and Upcoming Holidays
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            color: "transparent"
            radius: 12
            border.color: "#33ffffff"
            border.width: 1
            
            // macOS Tahoe-style transparency effect
            Rectangle {
                anchors.fill: parent
                color: "#2a2a2a"
                opacity: 0.8
                radius: 12
            }
            
            // Dark mode backdrop
            Rectangle {
                anchors.fill: parent
                color: "#1a1a1a"
                opacity: 0.3
                radius: 12
            }
            
            // Semi-transparent white border overlay
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                radius: 12
                border.color: "#40ffffff"
                border.width: 1
            }
            
            // Semi-transparent white overlay for macOS-like shine
            Rectangle {
                anchors.fill: parent
                color: "#15ffffff"
                radius: 12
            }
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16
                
                // Country Selector
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16
                    
                    Text {
                        text: "Country:"
                        font.pixelSize: 18
                        font.weight: Font.Medium
                        color: "#ffffff"
                    }
                    
                    ComboBox {
                        id: countryComboBox
                        Layout.preferredWidth: 200
                        model: HolidayService.availableCountries.map(country => 
                            country.countryCode + " - " + country.name
                        )
                        currentIndex: HolidayService.availableCountries.findIndex(c => c.countryCode === HolidayService.currentCountry)
                        
                        onActivated: {
                            const selectedCountry = HolidayService.availableCountries[index]
                            HolidayService.loadHolidaysForCountry(selectedCountry.countryCode, currentYear)
                            Settings.settings.calendarHolidayCountry = selectedCountry.countryCode
                            loadHolidaysForMonth()
                        }
                        
                        delegate: Text {
                            text: modelData
                            font.pixelSize: 16
                            color: "#ffffff"
                            padding: 8
                        }
                    }
                    
                    Text {
                        text: "Year:"
                        font.pixelSize: 18
                        font.weight: Font.Medium
                        color: "#ffffff"
                    }
                    
                    SpinBox {
                        id: yearSpinBox
                        Layout.preferredWidth: 100
                        from: 2020
                        to: 2030
                        value: currentYear
                        
                        onValueChanged: {
                            currentYear = value
                            HolidayService.loadHolidaysForCountry(HolidayService.currentCountry, currentYear)
                            loadHolidaysForMonth()
                        }
                    }
                }
                
                // Upcoming Holidays
                Text {
                    text: "Upcoming Holidays"
                    font.pixelSize: 20
                    font.weight: Font.Bold
                    color: "#ffffff"
                }
                
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    ListView {
                        model: HolidayService.getUpcomingHolidays()
                        spacing: 8
                        
                        delegate: Rectangle {
                            width: ListView.view.width - 20
                            height: 50
                            color: "transparent"
                            radius: 8
                            border.color: "#33ffffff"
                            border.width: 1
                            
                            // Holiday background
                            Rectangle {
                                anchors.fill: parent
                                color: "#2a2a2a"
                                opacity: 0.8
                                radius: 8
                            }
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 16
                                
                                Text {
                                    text: HolidayService.getCountryDisplay(HolidayService.currentCountry)
                                    font.pixelSize: 14
                                    color: "#74b9ff"
                                    font.weight: Font.Medium
                                }
                                
                                Text {
                                    text: modelData.name
                                    font.pixelSize: 16
                                    font.weight: Font.Medium
                                    color: "#ffffff"
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: modelData.date
                                    font.pixelSize: 14
                                    color: "#aaaaaa"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
} 