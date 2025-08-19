import QtQuick
import QtQml

pragma Singleton

QtObject {
    id: holidayService
    
    // Signals
    signal holidaysUpdated(var holidays)
    signal holidaysError(string error)
    
    // Properties
    property var holidays: []
    property string currentCountry: "US"  // Default to US
    property int currentYear: new Date().getFullYear()
    property bool isLoading: false
    
    // Cache properties
    property var holidayCache: ({})  // Cache: { "US_2024": [...], "US_2025": [...] }
    property var countriesCache: []  // Cache for available countries
    
    // API base URL
    readonly property string apiBaseUrl: "https://date.nager.at/api/v3"
    
    // Available countries for holidays
    property var availableCountries: []
    
    // Initialize the service
    Component.onCompleted: {
        loadAvailableCountries()
    }
    
    // Property change handler for when countries are loaded
    onAvailableCountriesChanged: {
        if (availableCountries.length > 0) {
            // Delay a bit to ensure everything is ready
            Qt.callLater(function() {
                autoDetectCountry()
                loadHolidays()
                // Preload next year's holidays for smooth navigation
                preloadNextYearHolidays()
            })
        }
    }
    
    // Load available countries
    function loadAvailableCountries() {
        // Check cache first
        if (countriesCache.length > 0) {
            availableCountries = countriesCache
            console.log("HolidayService: Using cached countries:", countriesCache.length)
            return
        }
        
        const xhr = new XMLHttpRequest()
        xhr.open("GET", apiBaseUrl + "/AvailableCountries")
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        const countries = JSON.parse(xhr.responseText)
                        availableCountries = countries
                        countriesCache = countries  // Cache the countries
                        console.log("HolidayService: Loaded and cached", countries.length, "countries")
                    } catch (e) {
                        console.error("HolidayService: Failed to parse countries:", e)
                    }
                } else {
                    console.error("HolidayService: Failed to load countries, status:", xhr.status)
                }
            }
        }
        xhr.send()
    }
    
    // Load holidays for current country and year
    function loadHolidays() {
        if (isLoading) return
        
        // Check cache first
        const cacheKey = `${currentCountry}_${currentYear}`
        if (holidayCache[cacheKey]) {
            holidays = holidayCache[cacheKey]
            holidaysUpdated(holidays)
            console.log("HolidayService: Using cached holidays for", cacheKey, "(", holidays.length, "holidays)")
            return
        }
        
        isLoading = true
        const url = `${apiBaseUrl}/PublicHolidays/${currentYear}/${currentCountry}`
        
        const xhr = new XMLHttpRequest()
        xhr.open("GET", url)
        xhr.timeout = 10000 // 10 second timeout
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                isLoading = false
                if (xhr.status === 200) {
                    try {
                        const holidayData = JSON.parse(xhr.responseText)
                        holidays = holidayData
                        holidayCache[cacheKey] = holidayData  // Cache the holidays
                        holidaysUpdated(holidays)
                        console.log("HolidayService: Loaded and cached", holidays.length, "holidays for", currentCountry, currentYear)
                    } catch (e) {
                        console.error("HolidayService: Failed to parse holidays:", e)
                        holidaysError("Failed to parse holiday data")
                    }
                } else {
                    console.error("HolidayService: Failed to load holidays, status:", xhr.status)
                    holidaysError("Failed to load holidays")
                }
            }
        }
        
        xhr.ontimeout = function() {
            isLoading = false
            holidaysError("Request timeout")
        }
        
        xhr.onerror = function() {
            isLoading = false
            holidaysError("Network error")
        }
        
        xhr.send()
    }
    
    // Load holidays for specific country and year
    function loadHolidaysForCountry(countryCode, year) {
        currentCountry = countryCode
        currentYear = year
        loadHolidays()
    }
    
    // Get holidays for a specific date
    function getHolidaysForDate(date) {
        if (!date || !holidays.length) return []
        
        const dateStr = date.toISOString().split('T')[0] // Format: YYYY-MM-DD
        return holidays.filter(holiday => holiday.date === dateStr)
    }
    
    // Get upcoming holidays (next 30 days)
    function getUpcomingHolidays() {
        if (!holidays.length) return []
        
        const today = new Date()
        const thirtyDaysFromNow = new Date()
        thirtyDaysFromNow.setDate(today.getDate() + 30)
        
        return holidays.filter(holiday => {
            const holidayDate = new Date(holiday.date)
            return holidayDate >= today && holidayDate <= thirtyDaysFromNow
        }).sort((a, b) => new Date(a.date) - new Date(b.date))
    }
    
    // Get holidays for current month
    function getHolidaysForMonth(month, year) {
        if (!holidays.length) return []
        
        return holidays.filter(holiday => {
            const holidayDate = new Date(holiday.date)
            return holidayDate.getMonth() === month && holidayDate.getFullYear() === year
        }).sort((a, b) => new Date(a.date) - new Date(b.date))
    }
    
    // Check if a date has holidays
    function hasHolidays(date) {
        return getHolidaysForDate(date).length > 0
    }
    
    // Get holiday names for a date
    function getHolidayNames(date) {
        const holidaysForDate = getHolidaysForDate(date)
        return holidaysForDate.map(holiday => holiday.name)
    }
    
    // Get country name from country code
    function getCountryName(countryCode) {
        const country = availableCountries.find(c => c.countryCode === countryCode)
        return country ? country.name : countryCode
    }
    
    // Get country display text
    function getCountryDisplay(countryCode) {
        return getCountryName(countryCode)
    }
    
    // Auto-detect country based on system locale
    function autoDetectCountry() {
        try {
            // Try to get country from system locale
            const locale = Qt.locale()
            if (locale && locale.name) {
                const parts = locale.name.split('_')
                if (parts.length > 1) {
                    const detectedCountry = parts[1].toUpperCase()
                    // Check if it's in our available countries
                    const found = availableCountries.find(c => c.countryCode === detectedCountry)
                    if (found) {
                        currentCountry = detectedCountry
                        console.log("HolidayService: Auto-detected country:", detectedCountry)
                        return detectedCountry
                    }
                }
            }
        } catch (e) {
            console.log("HolidayService: Could not auto-detect country, using default")
        }
        
        // Fallback to US
        currentCountry = "US"
        return "US"
    }
    
    // Preload holidays for next year to improve navigation performance
    function preloadNextYearHolidays() {
        const nextYear = currentYear + 1
        const cacheKey = `${currentCountry}_${nextYear}`
        
        // Only preload if not already cached
        if (!holidayCache[cacheKey]) {
            console.log("HolidayService: Preloading holidays for", nextYear)
            const url = `${apiBaseUrl}/PublicHolidays/${nextYear}/${currentCountry}`
            
            const xhr = new XMLHttpRequest()
            xhr.open("GET", url)
            xhr.timeout = 10000
            
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                    try {
                        const holidayData = JSON.parse(xhr.responseText)
                        holidayCache[cacheKey] = holidayData
                        console.log("HolidayService: Preloaded and cached", holidayData.length, "holidays for", nextYear)
                    } catch (e) {
                        console.error("HolidayService: Failed to preload holidays for", nextYear, e)
                    }
                }
            }
            
            xhr.send()
        }
    }
    
    // Clear cache (useful for debugging or memory management)
    function clearCache() {
        holidayCache = ({})
        countriesCache = []
        console.log("HolidayService: Cache cleared")
    }
} 