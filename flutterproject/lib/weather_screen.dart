import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

String getWeatherDescription(int code, bool isEnglish) {
  const descriptions = {
    0: {'en': 'Clear Sky', 'hi': 'साफ आसमान'},
    1: {'en': 'Mainly Clear', 'hi': 'मुख्यतः साफ'},
    2: {'en': 'Partly Cloudy', 'hi': 'आंशिक रूप से बादल छाए हुए'},
    3: {'en': 'Overcast', 'hi': 'घने बादल'},
    45: {'en': 'Fog', 'hi': 'कोहरा'},
    61: {'en': 'Slight Rain', 'hi': 'हलकी बारिश'},
    95: {'en': 'Thunderstorm', 'hi': 'आंधी-तूफान'},
  };
  final lang = isEnglish ? 'en' : 'hi';
  return descriptions[code]?[lang] ?? (isEnglish ? 'Unknown' : 'अज्ञात');
}


class WeatherScreen extends StatefulWidget {
  final String selectedLanguage;
  const WeatherScreen({super.key, required this.selectedLanguage});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _weatherData;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _isOffline = false;
    });

    final prefs = await SharedPreferences.getInstance();

    final cachedData = prefs.getString('weatherData');
    if (cachedData != null) {
      if (mounted) {
        setState(() {
          _weatherData = json.decode(cachedData);
        });
      }
    }

    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      if (mounted) {
        setState(() {
          _isOffline = true;
          _isLoading = false;
          if (_weatherData == null) {
            _errorMessage = widget.selectedLanguage == 'English'
                ? 'You are offline and no cached data is available.'
                : 'आप ऑफ़लाइन हैं और कोई कैश डेटा उपलब्ध नहीं है।';
          }
        });
      }
      return;
    }

    try {
      Position position = await _determinePosition();
      await _fetchWeatherFromApi(position.latitude, position.longitude);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  Future<void> _fetchWeatherFromApi(double lat, double lon) async {
    const fields = [
      'temperature_2m', 'relative_humidity_2m', 'apparent_temperature', 'precipitation',
      'weather_code', 'wind_speed_10m', 'pressure_msl', 'surface_pressure',
      'cloud_cover', 'visibility', 'uv_index', 'is_day', 'soil_temperature_0cm', 'soil_moisture_0_1cm'
    ];
    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=${fields.join(",")}&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum&timezone=auto&forecast_days=7');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('weatherData', response.body);
      if (mounted) {
        setState(() {
          _weatherData = data;
        });
      }
    } else {
      throw Exception('Failed to load weather data from API');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    bool isEnglish = widget.selectedLanguage == 'English';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? 'Weather Report' : 'मौसम रिपोर्ट'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadWeather(forceRefresh: true),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    bool isEnglish = widget.selectedLanguage == 'English';

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_weatherData == null) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(_errorMessage.isNotEmpty ? _errorMessage : (isEnglish ? 'No weather data available.' : 'कोई मौसम डेटा उपलब्ध नहीं है।'),
            style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
      ));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isOffline)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.orange.shade800),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isEnglish
                          ? 'You are offline. Showing last updated data.'
                          : 'आप ऑफ़लाइन हैं। अंतिम अपडेट किया गया डेटा दिखाया जा रहा है।',
                      style: TextStyle(color: Colors.orange.shade800),
                    ),
                  ),
                ],
              ),
            ),
          if (_isOffline) const SizedBox(height: 16),

          Text(isEnglish ? 'Current Weather' : 'वर्तमान मौसम', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildCurrentWeather(),
          const SizedBox(height: 24),
          Text(isEnglish ? 'Agriculture Insights' : 'कृषि संबंधी जानकारी', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildInsightCards(),
           const SizedBox(height: 24),
          Text(isEnglish ? '7-Day Forecast' : '7-दिन का पूर्वानुमान', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _build7DayForecast(),
        ],
      ),
    );
  }

  Map<String, String> _getAgricultureInsights() {
    if (_weatherData == null) return {};
    final current = _weatherData!['current'];
    bool isEnglish = widget.selectedLanguage == 'English';

    String irrigation = isEnglish ? 'Normal irrigation recommended' : 'सामान्य सिंचाई की सलाह दी जाती है';
    if (current['soil_moisture_0_1cm'] < 0.3) {
      irrigation = isEnglish ? 'Irrigation is needed' : 'सिंचाई की आवश्यकता है';
    } else if (current['soil_moisture_0_1cm'] > 0.8) {
      irrigation = isEnglish ? 'Reduce irrigation, soil is wet' : 'सिंचाई कम करें, मिट्टी गीली है';
    }

    String cropHealth = isEnglish ? 'Good conditions for crop growth' : 'फसल वृद्धि के लिए अच्छी स्थितियाँ';
    if (current['temperature_2m'] > 35) {
      cropHealth = isEnglish ? 'High temperature stress possible' : 'उच्च तापमान का तनाव संभव है';
    } else if (current['temperature_2m'] < 10) {
      cropHealth = isEnglish ? 'Low temperature may slow growth' : 'कम तापमान वृद्धि को धीमा कर सकता है';
    }

    return {
      'irrigation': irrigation,
      'cropHealth': cropHealth,
    };
  }

  // --- UPDATED METHOD ---
  Widget _buildInsightCards() {
    final insights = _getAgricultureInsights();
    bool isEnglish = widget.selectedLanguage == 'English';
    return Column(
      children: [
        _buildInsightCard(isEnglish ? 'Irrigation' : 'सिंचाई', insights['irrigation'] ?? '', Icons.water_drop_outlined),
        const SizedBox(height: 8),
        _buildInsightCard(isEnglish ? 'Crop Health' : 'फसल स्वास्थ्य', insights['cropHealth'] ?? '', Icons.grass_outlined),
      ],
    );
  }

  Widget _buildCurrentWeather() {
    final current = _weatherData!['current'];
    bool isEnglish = widget.selectedLanguage == 'English';
    final description = getWeatherDescription(current['weather_code'], isEnglish);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.wb_sunny, color: Colors.orange, size: 50), // Placeholder
                    Text(description, style: const TextStyle(fontSize: 18)),
                  ],
                ),
                Text('${current['temperature_2m']}°C', style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(isEnglish ? 'Feels Like' : 'महसूस होता है', '${current['apparent_temperature']}°C'),
                _buildWeatherDetail(isEnglish ? 'Humidity' : 'नमी', '${current['relative_humidity_2m']}%'),
                _buildWeatherDetail(isEnglish ? 'UV Index' : 'यूवी इंडेक्स', '${current['uv_index']}'),
              ],
            ),
            const SizedBox(height: 16),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(isEnglish ? 'Soil Temp' : 'मिट्टी का तापमान', '${current['soil_temperature_0cm']}°C'),
                _buildWeatherDetail(isEnglish ? 'Soil Moisture' : 'मिट्टी में नमी', '${current['soil_moisture_0_1cm']}%'),
                _buildWeatherDetail(isEnglish ? 'Wind' : 'हवा', '${current['wind_speed_10m']} km/h'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }

  // --- UPDATED METHOD ---
  Widget _buildInsightCard(String title, String subtitle, IconData icon) {
    return Card(
      elevation: 2,
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.green.shade800, size: 30),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade800),
        ),
      ),
    );
  }

  Widget _build7DayForecast() {
    final daily = _weatherData!['daily'];
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = DateTime.parse(daily['time'][index]);
          final description = getWeatherDescription(daily['weather_code'][index], widget.selectedLanguage == 'English');
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(DateFormat('E').format(date), style: const TextStyle(fontWeight: FontWeight.bold)),
                const Icon(Icons.wb_sunny, color: Colors.orange, size: 30),
                Text(description, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 1),
                Text('${daily['temperature_2m_max'][index]}° / ${daily['temperature_2m_min'][index]}°'),
              ],
            ),
          );
        },
      ),
    );
  }
}