import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore
import Quickshell
import Quickshell.Hyprland
import qs.Settings

// Enhanced Weather service (WeatherAPI.com + Open-Meteo backup)
pragma Singleton
Item {
    id: service
    
    property var shell
    
    // Public properties
    property bool loading: false
    property var weatherData: null
    property string location: "auto" // "auto" for IP-based detection, or specify a location
    property var detectedLocation: null
    property int cacheDurationMs: 15 * 60 * 1000 // 15 minutes
    
    // Enhanced location properties
    property string currentCity: ""
    property string currentCountry: ""
    property string currentRegion: ""
    property real currentLatitude: 0
    property real currentLongitude: 0
    
    // Enhanced weather data structure
    property var enhancedWeatherData: ({
        current: {
            temp: "",
            feelsLike: "",
            condition: "",
            humidity: "",
            wind: "",
            pressure: "",
            visibility: "",
            uv: "",
            dewPoint: "",
            airQuality: "",
            cloudCover: "",
            precipitation: "",
            lastUpdated: ""
        },
        forecast: {
            hourly: [],
            daily: [],
            alerts: []
        },
        astronomy: {
            sunrise: "",
            sunset: "",
            moonPhase: "",
            moonrise: "",
            moonset: ""
        },
        location: {
            name: "",
            region: "",
            country: "",
            lat: 0,
            lon: 0,
            timezone: ""
        }
    })
    
    // Signals that our weather tabs expect
    signal weatherUpdated(var weather, var hourly, var daily, var aqi, var alerts)
    signal locationUpdated(string location, string country, string region, real lat, real lon)
    
    // Private properties
    property var _xhr: null
    property var _geoXhr: null
    property var _airQualityXhr: null
    property int _retryCount: 0
    property int _maxRetries: 3
    property int _baseDelay: 1000 // 1 second base delay for exponential backoff
    
    // Simple weather cache storage (in-memory for now)
    property var _weatherCache: ({
        lastWeatherJson: "",
        lastLocation: "",
        lastWeatherTimestamp: 0,
        cachedLatitude: "",
        cachedLongitude: "",
        cachedLocationDisplay: "",
        lastLocationDetection: 0,
        weatherApiKey: "",
        useWeatherApi: true
    })
    
    // Initialize method that our weather tabs expect
    function initialize() {
        // Load cached weather data if available
        loadWeather();
    }
    
    // Load weather cache from memory (placeholder for now)
    function loadWeatherCache() {
        // In-memory cache is already initialized
    }
    
    // Save weather cache to memory (placeholder for now)
    function saveWeatherCache() {
        // In-memory cache is automatically saved
    }
    
    // Initialize on component completion
    // Component.onCompleted: {
    //     initialize()
    // }
    
    // Regular update timer
    Timer {
        id: updateTimer
        interval: 600000  // Update every 10 minutes
        running: false
        repeat: true
        onTriggered: loadWeather()
    }
    

    
    // Methods
    function loadWeather() {
            var now = Date.now();
    var locationKey = location ? location.trim().toLowerCase() : "auto";
    
    // Use cached data if available and fresh
    if (_weatherCache.lastWeatherJson && 
        _weatherCache.lastLocation === locationKey && 
        (now - _weatherCache.lastWeatherTimestamp) < cacheDurationMs) {
        try {
            parseEnhancedWeather(JSON.parse(_weatherCache.lastWeatherJson), location);
            return;
        } catch (e) {
            console.error("Failed to parse cached enhanced weather data:", e)
        }
    }
    
    loading = true;
    
    // Auto-detect location using IP or use specified location
    if (location === "auto") {
        // Check if we have a cached location from this session (within last 24 hours)
        if (_weatherCache.cachedLatitude && _weatherCache.cachedLongitude && 
            (now - _weatherCache.lastLocationDetection) < (24 * 60 * 60 * 1000)) {
            // Use cached location
            fetchEnhancedWeatherData(parseFloat(_weatherCache.cachedLatitude), 
                                   parseFloat(_weatherCache.cachedLongitude), 
                                   _weatherCache.cachedLocationDisplay);
        } else {
            // Detect location only if not cached or cache is old
        detectLocationFromIP();
        }
    } else {
        geocodeLocation(location);
    }
    }
    
    function detectLocationFromIP() {
        console.log("WeatherService: Starting IP location detection...");
        if (_geoXhr) {
            _geoXhr.abort();
        }
        
        _geoXhr = new XMLHttpRequest();
        // Using ipapi.co for IP-based geolocation (free, no API key required)
        var ipUrl = "https://ipapi.co/json/";
        console.log("WeatherService: Fetching location from:", ipUrl);
        
        _geoXhr.onreadystatechange = function() {
            if (_geoXhr.readyState === XMLHttpRequest.DONE) {
                if (_geoXhr.status === 200) {
                    try {
                        var ipData = JSON.parse(_geoXhr.responseText);

                        
                        if (ipData.latitude && ipData.longitude) {
                            var lat = parseFloat(ipData.latitude);
                            var lon = parseFloat(ipData.longitude);
                            var locationDisplay = [ipData.city, ipData.region, ipData.country_name].filter(x => x).join(", ");
                            
                            detectedLocation = {
                                latitude: lat,
                                longitude: lon,
                                city: ipData.city || "",
                                region: ipData.region || "",
                                country: ipData.country_name || "",
                                display: locationDisplay
                            };
                            
                            // Cache the location for future use
                            _weatherCache.cachedLatitude = lat.toString();
                            _weatherCache.cachedLongitude = lon.toString();
                            _weatherCache.cachedLocationDisplay = locationDisplay;
                            _weatherCache.lastLocationDetection = Date.now();
                            saveWeatherCache();

                            _retryCount = 0; // Reset retry count on success
                            fetchEnhancedWeatherData(lat, lon, locationDisplay);
                            
                            // Update current location properties
                            currentCity = ipData.city || ""
                            currentCountry = ipData.country_name || ""
                            currentRegion = ipData.region || ""
                            currentLatitude = lat
                            currentLongitude = lon
                            
                            // Emit location updated signal
                            locationUpdated(currentCity, currentCountry, currentRegion, currentLatitude, currentLongitude)
                        } else {
                            loading = false;
                            createDefaultWeatherData();
                        }
                    } catch (e) {
                        console.error("Error parsing IP geolocation response:", e);
                        loading = false;
                        createDefaultWeatherData();
                    }
                } else if (_geoXhr.status === 429) {
                    // Rate limited - immediately try fallback service
                    detectLocationFromIPFallback();
                } else {
                    // Any other error - immediately try fallback service
                    detectLocationFromIPFallback();
                }
            }
        };
        
        _geoXhr.open("GET", ipUrl);
        _geoXhr.send();
    }

    function detectLocationFromIPFallback() {
        if (_geoXhr) {
            _geoXhr.abort();
        }
        
        _geoXhr = new XMLHttpRequest();
        // Using ip-api.com as fallback (free, no API key required)
        var ipUrl = "http://ip-api.com/json/";
        
        _geoXhr.onreadystatechange = function() {
            if (_geoXhr.readyState === XMLHttpRequest.DONE) {
                if (_geoXhr.status === 200) {
                    try {
                        var ipData = JSON.parse(_geoXhr.responseText);

                        
                        if (ipData.lat && ipData.lon) {
                            var lat = parseFloat(ipData.lat);
                            var lon = parseFloat(ipData.lon);
                            var locationDisplay = [ipData.city, ipData.regionName, ipData.country].filter(x => x).join(", ");
                            
                            detectedLocation = {
                                latitude: lat,
                                longitude: lon,
                                city: ipData.city || "",
                                region: ipData.regionName || "",
                                country: ipData.country || "",
                                display: locationDisplay
                            };
                            
                            // Cache the location for future use
                            _weatherCache.cachedLatitude = lat.toString();
                            _weatherCache.cachedLongitude = lon.toString();
                            _weatherCache.cachedLocationDisplay = locationDisplay;
                            _weatherCache.lastLocationDetection = Date.now();
                            saveWeatherCache();

                            // Update current location properties
                            currentCity = ipData.city || ""
                            currentCountry = ipData.country || ""
                            currentRegion = ipData.regionName || ""
                            currentLatitude = lat
                            currentLongitude = lon
                            
                            fetchEnhancedWeatherData(lat, lon, locationDisplay);
                            
                            // Emit location updated signal
                            locationUpdated(currentCity, currentCountry, currentRegion, currentLatitude, currentLongitude)
                        } else {
                            loading = false;
                            createDefaultWeatherData();
                            Hyprland.dispatch(`exec notify-send "Weather Location Error" "Unable to detect your location automatically. Please set a manual location in settings." -u normal -a "Shell"`);
                        }
                    } catch (e) {
                        console.error("Error parsing fallback IP geolocation response:", e);
                        loading = false;
                        createDefaultWeatherData();
                        Hyprland.dispatch(`exec notify-send "Weather Location Error" "Unable to detect your location automatically. Please set a manual location in settings." -u normal -a "Shell"`);
                    }
                } else {
                    console.error("Fallback IP geolocation request failed with status:", _geoXhr.status);
                    loading = false;
                    createDefaultWeatherData();
                    Hyprland.dispatch(`exec notify-send "Weather Location Error" "Unable to detect your location automatically. Please set a manual location in settings." -u normal -a "Shell"`);
                }
            }
        };
        
        _geoXhr.open("GET", ipUrl);
        _geoXhr.send();
    }
    
    function geocodeLocation(locationName) {
        console.log("Geocoding location:", locationName);
        if (_geoXhr) {
            _geoXhr.abort();
        }
        
        _geoXhr = new XMLHttpRequest();
        var geoUrl = "https://geocoding-api.open-meteo.com/v1/search?name=" + 
                    encodeURIComponent(locationName) + 
                    "&count=1&language=en&format=json";
                    

                    
        _geoXhr.onreadystatechange = function() {
            if (_geoXhr.readyState === XMLHttpRequest.DONE) {
                if (_geoXhr.status === 200) {
                    try {
                        var geoData = JSON.parse(_geoXhr.responseText);

                        
                        if (geoData.results && geoData.results.length > 0) {
                            var lat = geoData.results[0].latitude;
                            var lon = geoData.results[0].longitude;
                            
                            // Update location display with full name
                            var locationParts = [];
                            if (geoData.results[0].name) locationParts.push(geoData.results[0].name);
                            if (geoData.results[0].admin1) locationParts.push(geoData.results[0].admin1);
                            if (geoData.results[0].country) locationParts.push(geoData.results[0].country);
                            
                            var locationDisplay = locationParts.join(", ");

                            
                            // Update current location properties
                            currentCity = geoData.results[0].name || ""
                            currentCountry = geoData.results[0].country || ""
                            currentRegion = geoData.results[0].admin1 || ""
                            currentLatitude = lat
                            currentLongitude = lon
                            
                            // Get weather data for these coordinates
                            fetchEnhancedWeatherData(lat, lon, locationDisplay);
                            
                            // Emit location updated signal
                            locationUpdated(currentCity, currentCountry, currentRegion, currentLatitude, currentLongitude)
                        } else {
                            loading = false;
                            createDefaultWeatherData();
                        }
                    } catch (e) {
                        console.error("Error parsing geocoding response:", e);
                        loading = false;
                        createDefaultWeatherData();
                    }
                } else {
                    console.error("Geocoding request failed with status:", _geoXhr.status);
                    loading = false;
                    createDefaultWeatherData();
                }
            }
        };
        
        _geoXhr.open("GET", geoUrl);
        _geoXhr.send();
    }
    
    function createDefaultWeatherData() {
        enhancedWeatherData = {
            current: {
                temp: "?",
                feelsLike: "?",
                condition: "No location data",
                humidity: "?",
                wind: "?",
                pressure: "?",
                visibility: "?",
                uv: "?",
                dewPoint: "?",
                airQuality: "?",
                cloudCover: "?",
                precipitation: "?",
                lastUpdated: new Date().toLocaleTimeString()
            },
            forecast: {
                hourly: [],
                daily: [],
                alerts: []
            },
            astronomy: {
                sunrise: "?",
                sunset: "?",
                moonPhase: "?",
                moonrise: "?",
                moonset: "?"
            },
            location: {
                name: "Location unavailable",
                region: "",
                country: "",
                lat: 0,
                lon: 0,
                timezone: ""
            }
        };
        
        // Also set legacy weatherData for compatibility
        weatherData = {
            locationDisplay: "Location unavailable",
            currentTemp: "?",
            feelsLike: "?",
            currentCondition: "No location data",
            forecast: [
                { date: "Today", condition: "No data", temp: "? / ?", emoji: "❓" },
                { date: "Tomorrow", condition: "No data", temp: "? / ?", emoji: "❓" }
            ]
        };
        
        // Also set the data structure our weather tabs expect
        weatherData = {
            current: {
                temperature_2m: "?",
                apparent_temperature: "?",
                weather_code: "No location data",
                relative_humidity_2m: "?",
                wind_speed_10m: "?",
                pressure_msl: "?",
                visibility: "?",
                cloud_cover: "?",
                precipitation: "?"
            },
            hourly: [],
            daily: [],
            alerts: [],
            location: {
                name: "Location unavailable",
                region: "",
                country: "",
                lat: 0,
                lon: 0,
                timezone: ""
            },
            astronomy: {
                sunrise: "?",
                sunset: "?",
                moonPhase: "?",
                moonrise: "?",
                moonset: "?"
            }
        };
        
        // Set fallback location properties
        if (!currentCity && !currentRegion) {
            currentCity = "Unknown City"
            currentRegion = "Unknown State"
        }
        
        loading = false;
    }
    
    function fetchEnhancedWeatherData(lat, lon, locationDisplay) {
        if (_xhr) {
            _xhr.abort();
        }
        
        // Try WeatherAPI.com first if API key is available
        if (_weatherCache.useWeatherApi && _weatherCache.weatherApiKey) {
            fetchWeatherApiData(lat, lon, locationDisplay);
        } else {
            // Fallback to Open-Meteo
            fetchOpenMeteoData(lat, lon, locationDisplay);
        }
    }
    
    function fetchWeatherApiData(lat, lon, locationDisplay) {

        
        _xhr = new XMLHttpRequest();
        var weatherUrl = `https://api.weatherapi.com/v1/forecast.json?` +
                        `key=${_weatherCache.weatherApiKey || ""}&` +
                        `q=${lat},${lon}&` +
                        `days=14&` +
                        `aqi=yes&` +
                        `alerts=yes&` +
                        `hour=24`;
                        
        _xhr.onreadystatechange = function() {
            if (_xhr.readyState === XMLHttpRequest.DONE) {
                if (_xhr.status === 200) {
                    try {
                        var data = JSON.parse(_xhr.responseText);
                        
                        // Cache the response
                        _weatherCache.lastWeatherJson = _xhr.responseText;
                        _weatherCache.lastWeatherTimestamp = Date.now();
                        _weatherCache.lastLocation = location.trim().toLowerCase();
                        saveWeatherCache();
                        
                        // Parse the enhanced weather data
                        parseWeatherApiData(data, locationDisplay);
                    } catch (e) {
                        console.error("Error parsing WeatherAPI.com data:", e);
                        // Fallback to Open-Meteo
                        fetchOpenMeteoData(lat, lon, locationDisplay);
                    }
                } else {
                    console.error("WeatherAPI.com request failed with status:", _xhr.status);
                    // Fallback to Open-Meteo
                    fetchOpenMeteoData(lat, lon, locationDisplay);
                }
            }
        };
        
        _xhr.open("GET", weatherUrl);
        _xhr.send();
    }
    
    function fetchOpenMeteoData(lat, lon, locationDisplay) {

        
        _xhr = new XMLHttpRequest();
        var weatherUrl = "https://api.open-meteo.com/v1/forecast?" +
                        "latitude=" + lat +
                        "&longitude=" + lon +
                        "&current=temperature_2m,apparent_temperature,weather_code,relative_humidity_2m,wind_speed_10m,wind_direction_10m,pressure_msl,visibility,cloud_cover,precipitation" +
                        "&hourly=temperature_2m,apparent_temperature,weather_code,relative_humidity_2m,wind_speed_10m,precipitation_probability,precipitation" +
                        "&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,wind_speed_10m_max,relative_humidity_2m_max" +
                        "&timezone=auto" +
                        "&forecast_days=14";
                        
        _xhr.onreadystatechange = function() {
            if (_xhr.readyState === XMLHttpRequest.DONE) {
                if (_xhr.status === 200) {
                    try {
                        var data = JSON.parse(_xhr.responseText);
                        
                        // Cache the response
                        _weatherCache.lastWeatherJson = _xhr.responseText;
                        _weatherCache.lastWeatherTimestamp = Date.now();
                        _weatherCache.lastLocation = location.trim().toLowerCase();
                        saveWeatherCache();
                        
                        // Parse the Open-Meteo data
                        parseOpenMeteoData(data, locationDisplay);
                    } catch (e) {
                        console.error("Error parsing Open-Meteo data:", e);
                        loading = false;
                    }
                } else {
                    console.error("Open-Meteo request failed with status:", _xhr.status);
                    loading = false;
                }
            }
        };
        
        _xhr.open("GET", weatherUrl);
        _xhr.send();
    }
    
    function parseWeatherApiData(data, locationDisplay) {
        if (!data || !data.current) {
            console.error("Invalid WeatherAPI.com data format");
            loading = false;
            return;
        }
        
        // Parse current weather
        var current = data.current;
        enhancedWeatherData.current = {
            temp: Math.round(current.temp_c) + "°C",
            feelsLike: Math.round(current.feelslike_c) + "°C",
            condition: current.condition.text,
            humidity: current.humidity + "%",
            wind: Math.round(current.wind_kph) + " km/h",
            pressure: Math.round(current.pressure_mb) + " mb",
            visibility: Math.round(current.vis_km) + " km",
            uv: current.uv,
            dewPoint: Math.round(current.dewpoint_c) + "°C",
            airQuality: data.current.air_quality ? data.current.air_quality["us-epa-index"] : "?",
            cloudCover: current.cloud + "%",
            precipitation: current.precip_mm + " mm",
            lastUpdated: new Date(current.last_updated_epoch * 1000).toLocaleTimeString()
        };
        
        // Parse location
        enhancedWeatherData.location = {
            name: data.location.name,
            region: data.location.region,
            country: data.location.country,
            lat: data.location.lat,
            lon: data.location.lon,
            timezone: data.location.tz_id
        };
        
        // Parse astronomy
        if (data.forecast && data.forecast.forecastday && data.forecast.forecastday.length > 0) {
            var today = data.forecast.forecastday[0];
            enhancedWeatherData.astronomy = {
                sunrise: today.astro.sunrise,
                sunset: today.astro.sunset,
                moonPhase: today.astro.moon_phase,
                moonrise: today.astro.moonrise,
                moonset: today.astro.moonset
            };
        }
        
        // Parse hourly forecast
        enhancedWeatherData.forecast.hourly = [];
        if (data.forecast && data.forecast.forecastday) {
            for (var i = 0; i < Math.min(3, data.forecast.forecastday.length); i++) {
                var day = data.forecast.forecastday[i];
                for (var j = 0; j < day.hour.length; j++) {
                    var hour = day.hour[j];
                    enhancedWeatherData.forecast.hourly.push({
                        time: new Date(hour.time_epoch * 1000).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'}),
                        temp: Math.round(hour.temp_c) + "°C",
                        feelsLike: Math.round(hour.feelslike_c) + "°C",
                        condition: hour.condition.text,
                        humidity: hour.humidity + "%",
                        wind: Math.round(hour.wind_kph) + " km/h",
                        precipitation: hour.chance_of_rain + "%",
                        icon: getWeatherEmoji(hour.condition.text)
                    });
                }
            }
        }
        
        // Parse daily forecast
        enhancedWeatherData.forecast.daily = [];
        if (data.forecast && data.forecast.forecastday) {
            for (var i = 0; i < data.forecast.forecastday.length; i++) {
                var day = data.forecast.forecastday[i];
                var date = new Date(day.date);
                var dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
                var dayName = dayNames[date.getDay()];
                
                enhancedWeatherData.forecast.daily.push({
                    date: dayName,
                    condition: day.day.condition.text,
                    tempMax: Math.round(day.day.maxtemp_c) + "°",
                    tempMin: Math.round(day.day.mintemp_c) + "°",
                    precipitation: day.day.daily_chance_of_rain + "%",
                    wind: Math.round(day.day.maxwind_kph) + " km/h",
                    humidity: day.day.avghumidity + "%",
                    icon: getWeatherEmoji(day.day.condition.text)
                });
            }
        }
        
        // Parse alerts
        enhancedWeatherData.forecast.alerts = [];
        if (data.alerts && data.alerts.alert) {
            for (var i = 0; i < data.alerts.alert.length; i++) {
                var alert = data.alerts.alert[i];
                enhancedWeatherData.forecast.alerts.push({
                    headline: alert.headline,
                    severity: alert.severity,
                    areas: alert.areas,
                    desc: alert.desc,
                    effective: alert.effective,
                    expires: alert.expires
                });
            }
        }
        
        // Set legacy weatherData for compatibility
        weatherData = {
            locationDisplay: locationDisplay || enhancedWeatherData.location.name,
            currentTemp: enhancedWeatherData.current.temp,
            feelsLike: enhancedWeatherData.current.feelsLike,
            currentCondition: enhancedWeatherData.current.condition,
            forecast: enhancedWeatherData.forecast.daily.slice(0, 7).map(function(day) {
                return {
                    date: day.date,
                    condition: day.condition,
                    temp: day.tempMax + " / " + day.tempMin,
                    emoji: day.icon
                };
            })
        };
        
        // Also set the data structure our weather tabs expect
        weatherData = {
            current: {
                temperature_2m: enhancedWeatherData.current.temp,
                apparent_temperature: enhancedWeatherData.current.feelsLike,
                weather_code: enhancedWeatherData.current.condition,
                relative_humidity_2m: enhancedWeatherData.current.humidity,
                wind_speed_10m: enhancedWeatherData.current.wind,
                pressure_msl: enhancedWeatherData.current.pressure,
                visibility: enhancedWeatherData.current.visibility,
                cloud_cover: enhancedWeatherData.current.cloudCover,
                precipitation: enhancedWeatherData.current.precipitation
            },
            hourly: enhancedWeatherData.forecast.hourly,
            daily: enhancedWeatherData.forecast.daily,
            alerts: enhancedWeatherData.forecast.alerts,
            location: enhancedWeatherData.location,
            astronomy: enhancedWeatherData.astronomy
        };
        
        loading = false;
        
        // Emit signals that our weather tabs expect
        weatherUpdated(enhancedWeatherData, enhancedWeatherData.forecast.hourly, enhancedWeatherData.forecast.daily, enhancedWeatherData.current.airQuality, enhancedWeatherData.forecast.alerts);
        locationUpdated(enhancedWeatherData.location.name, enhancedWeatherData.location.country, enhancedWeatherData.location.region, enhancedWeatherData.location.lat, enhancedWeatherData.location.lon);
    }
    
    function parseOpenMeteoData(data, locationDisplay) {
        if (!data || !data.current) {
            console.error("Invalid Open-Meteo data format");
            loading = false;
            return;
        }
        
        // Parse current weather
        var current = data.current;
        enhancedWeatherData.current = {
            temp: Math.round(current.temperature_2m), // Remove the °C suffix
            feelsLike: Math.round(current.apparent_temperature), // Remove the °C suffix
            condition: mapWeatherCode(current.weather_code),
            humidity: Math.round(current.relative_humidity_2m), // Remove the % suffix
            wind: Math.round(current.wind_speed_10m), // Remove the km/h suffix
            pressure: Math.round(current.pressure_msl) + " mb",
            visibility: current.visibility ? Math.round(current.visibility / 1000) + " km" : "?",
            uv: "?", // Not available in Open-Meteo
            dewPoint: "?", // Not available in Open-Meteo
            airQuality: "?", // Will be fetched separately
            cloudCover: current.cloud_cover ? current.cloud_cover + "%" : "?",
            precipitation: current.precipitation ? current.precipitation : 0, // Remove the mm suffix
            lastUpdated: new Date().toLocaleTimeString()
        };
        
        // Parse location
        var locParts = (typeof locationDisplay === 'string') ? locationDisplay.split(", ") : [];
        enhancedWeatherData.location = {
            name: locParts[0] || "Unknown",
            region: locParts[1] || "",
            country: locParts[2] || "",
            lat: data.latitude || 0,
            lon: data.longitude || 0,
            timezone: data.timezone || ""
        };
        
        // Parse hourly forecast
        enhancedWeatherData.forecast.hourly = [];
        if (data.hourly && data.hourly.time) {
            for (var i = 0; i < Math.min(24, data.hourly.time.length); i++) {
                var time = new Date(data.hourly.time[i]);
                enhancedWeatherData.forecast.hourly.push({
                    time: time.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'}),
                    temp: Math.round(data.hourly.temperature_2m[i]), // Remove the °C suffix
                    feelsLike: Math.round(data.hourly.apparent_temperature[i]), // Remove the °C suffix
                    condition: mapWeatherCode(data.hourly.weather_code[i]),
                    weather_code: data.hourly.weather_code[i], // Preserve the numeric code
                    humidity: Math.round(data.hourly.relative_humidity_2m[i]), // Remove the % suffix
                    wind: Math.round(data.hourly.wind_speed_10m[i]), // Remove the km/h suffix
                    precipitation: data.hourly.precipitation_probability ? data.hourly.precipitation_probability[i] : 0, // Remove the % suffix
                    icon: getWeatherEmoji(mapWeatherCode(data.hourly.weather_code[i]))
                });
            }
        }
        
        // Parse daily forecast
        enhancedWeatherData.forecast.daily = [];
        if (data.daily && data.daily.time) {
            for (var i = 0; i < data.daily.time.length; i++) {
                var date = new Date(data.daily.time[i]);
                var dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
                var dayName = dayNames[date.getDay()];
                
                enhancedWeatherData.forecast.daily.push({
                    date: dayName,
                    condition: mapWeatherCode(data.daily.weather_code[i]),
                    weather_code: data.daily.weather_code[i], // Preserve the numeric code
                    tempMax: Math.round(data.daily.temperature_2m_max[i]), // Remove the ° suffix
                    tempMin: Math.round(data.daily.temperature_2m_min[i]), // Remove the ° suffix
                    precipitation: data.daily.precipitation_probability_max ? data.daily.precipitation_probability_max[i] + "%" : "0%",
                    wind: Math.round(data.daily.wind_speed_10m_max[i]), // Remove the km/h suffix
                    humidity: Math.round(data.daily.relative_humidity_2m_max[i]), // Remove the % suffix
                    icon: getWeatherEmoji(mapWeatherCode(data.daily.weather_code[i]))
                });
            }
        }
        
        // Set legacy weatherData for compatibility
        weatherData = {
            locationDisplay: locationDisplay || enhancedWeatherData.location.name,
            currentTemp: enhancedWeatherData.current.temp,
            feelsLike: enhancedWeatherData.current.feelsLike,
            currentCondition: enhancedWeatherData.current.condition,
            forecast: enhancedWeatherData.forecast.daily.slice(0, 7).map(function(day) {
                return {
                    date: day.date,
                    condition: day.condition,
                    temp: day.tempMax + " / " + day.tempMin,
                    emoji: day.icon
                };
            })
        };
        
        // Also set the data structure our weather tabs expect
        weatherData = {
            current: {
                temperature_2m: enhancedWeatherData.current.temp,
                apparent_temperature: enhancedWeatherData.current.feelsLike,
                weather_code: data.current.weather_code, // Use the numeric code, not the text description
                relative_humidity_2m: enhancedWeatherData.current.humidity,
                wind_speed_10m: enhancedWeatherData.current.wind,
                pressure_msl: enhancedWeatherData.current.pressure,
                visibility: enhancedWeatherData.current.visibility,
                cloud_cover: enhancedWeatherData.current.cloudCover,
                precipitation: enhancedWeatherData.current.precipitation
            },
            hourly: enhancedWeatherData.forecast.hourly,
            daily: enhancedWeatherData.forecast.daily,
            alerts: enhancedWeatherData.forecast.alerts,
            location: enhancedWeatherData.location,
            astronomy: enhancedWeatherData.astronomy
        };
        
        loading = false;
        
        // Emit signals that our weather tabs expect
        weatherUpdated(enhancedWeatherData, enhancedWeatherData.forecast.hourly, enhancedWeatherData.forecast.daily, enhancedWeatherData.current.airQuality, enhancedWeatherData.forecast.alerts);
        locationUpdated(enhancedWeatherData.location.name, enhancedWeatherData.location.country, enhancedWeatherData.location.region, enhancedWeatherData.location.lat, enhancedWeatherData.location.lon);
    }
    
    function parseEnhancedWeather(data, locationDisplay) {
        // This function handles cached data parsing
        if (data.current && data.current.temp) {
            // WeatherAPI.com format
            parseWeatherApiData(data, locationDisplay);
        } else if (data.current && data.current.temperature_2m) {
            // Open-Meteo format
            parseOpenMeteoData(data, locationDisplay);
        } else {
            console.error("Unknown weather data format");
            loading = false;
        }
        
        // Emit signals for cached data
        weatherUpdated(enhancedWeatherData, enhancedWeatherData.forecast.hourly, enhancedWeatherData.forecast.daily, enhancedWeatherData.current.airQuality, enhancedWeatherData.forecast.alerts);
        locationUpdated(enhancedWeatherData.location.name, enhancedWeatherData.location.country, enhancedWeatherData.location.region, enhancedWeatherData.location.lat, enhancedWeatherData.location.lon);
    }
    
    function mapWeatherCode(code) {
        // WMO Weather interpretation codes (WW)
        // https://open-meteo.com/en/docs
        switch(code) {
            case 0: return "Clear sky";
            case 1: return "Mainly clear";
            case 2: return "Partly cloudy";
            case 3: return "Overcast";
            case 45: return "Fog";
            case 48: return "Depositing rime fog";
            case 51: return "Light drizzle";
            case 53: return "Moderate drizzle";
            case 55: return "Dense drizzle";
            case 56: return "Light freezing drizzle";
            case 57: return "Dense freezing drizzle";
            case 61: return "Slight rain";
            case 63: return "Moderate rain";
            case 65: return "Heavy rain";
            case 66: return "Light freezing rain";
            case 67: return "Heavy freezing rain";
            case 71: return "Slight snow fall";
            case 73: return "Moderate snow fall";
            case 75: return "Heavy snow fall";
            case 77: return "Snow grains";
            case 80: return "Slight rain showers";
            case 81: return "Moderate rain showers";
            case 82: return "Violent rain showers";
            case 85: return "Slight snow showers";
            case 86: return "Heavy snow showers";
            case 95: return "Thunderstorm";
            case 96: return "Thunderstorm with slight hail";
            case 99: return "Thunderstorm with heavy hail";
            default: return "Unknown";
        }
    }
    
    function getWeatherEmoji(condition) {
        if (!condition) return "❓"
        condition = condition.toLowerCase()

        if (condition.includes("clear")) return "☀️"
        if (condition.includes("mainly clear")) return "🌤️"
        if (condition.includes("partly cloudy")) return "⛅"
        if (condition.includes("cloud") || condition.includes("overcast")) return "☁️"
        if (condition.includes("fog") || condition.includes("mist")) return "🌫️"
        if (condition.includes("drizzle")) return "🌦️"
        if (condition.includes("rain") || condition.includes("showers")) return "🌧️"
        if (condition.includes("freezing rain")) return "🌧️❄️"
        if (condition.includes("snow") || condition.includes("snow grains") || condition.includes("snow showers")) return "❄️"
        if (condition.includes("thunderstorm")) return "⛈️"
        if (condition.includes("wind")) return "🌬️"
        return "❓"
    }
    
    function clearCache() {
        _weatherCache.lastWeatherJson = "";
        _weatherCache.lastWeatherTimestamp = 0;
        _weatherCache.lastLocation = "";
        saveWeatherCache();
    }
    
    // Function to set WeatherAPI.com API key
    function setWeatherApiKey(key) {
        _weatherCache.weatherApiKey = key;
        _weatherCache.useWeatherApi = true;
        saveWeatherCache();
    }
    
    // Function to toggle between APIs
    function toggleApi(useWeatherApi) {
        _weatherCache.useWeatherApi = useWeatherApi;
        saveWeatherCache();
        clearCache();
        loadWeather();
    }
} 