import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/city.dart';
import '../models/weather_models.dart';
import '../utils/weather_exceptions.dart';

class WeatherService {
  WeatherService({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        _apiKey = apiKey ??
            const String.fromEnvironment('OPENWEATHER_API_KEY',
                defaultValue: 'YOUR_API_KEY');

  static const String _baseAuthority = 'api.openweathermap.org';
  static const String _dataPath = '/data/2.5';

  final http.Client _client;
  final String _apiKey;

  Future<WeatherBundle> fetchWeatherByCity(String cityName) async {
    _assertApiKey();
    final uri =
        _buildUri('$_dataPath/weather', <String, String>{'q': cityName});
    final currentResponse = await _safeGet(uri);
    final currentData = _decodeBody(currentResponse);
    final coord = currentData['coord'] as Map<String, dynamic>?;
    if (coord == null) {
      throw const WeatherException('City coordinates are missing in response.');
    }
    final latitude = (coord['lat'] as num?)?.toDouble();
    final longitude = (coord['lon'] as num?)?.toDouble();
    if (latitude == null || longitude == null) {
      throw const WeatherException('City coordinates are invalid.');
    }
    final location = _parseCityFromWeather(currentData);
    final report = _mapCurrentWeather(currentData, location);
    final forecastBundle = await _fetchForecast(latitude, longitude);
    return WeatherBundle(
      report: report,
      daily: forecastBundle.daily,
      hourly: forecastBundle.hourly,
    );
  }

  Future<WeatherBundle> fetchWeatherByCoordinates(
      double latitude, double longitude) async {
    _assertApiKey();
    final uri = _buildUri('$_dataPath/weather', <String, String>{
      'lat': latitude.toString(),
      'lon': longitude.toString(),
    });
    final currentResponse = await _safeGet(uri);
    final data = _decodeBody(currentResponse);
    final location = _parseCityFromWeather(data);
    final report = _mapCurrentWeather(data, location);
    final forecastBundle = await _fetchForecast(latitude, longitude);
    return WeatherBundle(
      report: report,
      daily: forecastBundle.daily,
      hourly: forecastBundle.hourly,
    );
  }

  Future<List<CityLocation>> searchCities(String query) async {
    _assertApiKey();
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      return <CityLocation>[];
    }
    final uri = Uri.https(
      _baseAuthority,
      '/geo/1.0/direct',
      <String, String>{
        'q': trimmed,
        'limit': '5',
        'appid': _apiKey,
      },
    );
    final response = await _safeGet(uri);
    final payload = _decodeBody(response);
    if (payload is! List) {
      throw const WeatherException(
          'Unexpected response when searching for cities.');
    }
    return payload
        .cast<Map<String, dynamic>>()
        .map(CityLocation.fromJson)
        .where((city) => city.name.isNotEmpty)
        .toList();
  }

  Future<void> close() async {
    _client.close();
  }

  Uri _buildUri(String path, Map<String, String> queryParameters) {
    _assertApiKey();
    final qp = Map<String, String>.from(queryParameters)..['appid'] = _apiKey;
    return Uri.https(_baseAuthority, path.replaceAll(' ', ''), qp);
  }

  Future<http.Response> _safeGet(Uri uri) async {
    try {
      final response = await _client.get(uri);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }
      final body = response.body;
      if (response.statusCode == 404) {
        throw const WeatherException(
            'City not found. Try searching for a different location.');
      }
      throw WeatherException(
          'OpenWeather request failed (${response.statusCode}): $body');
    } on SocketException {
      throw const WeatherException(
          'Unable to reach OpenWeather. Check your internet connection.');
    }
  }

  dynamic _decodeBody(http.Response response) {
    try {
      return json.decode(response.body);
    } on FormatException {
      throw const WeatherException(
          'Invalid response received from OpenWeather.');
    }
  }

  CityLocation _parseCityFromWeather(Map<String, dynamic> payload) {
    final name = payload['name'] as String? ?? '';
    final sys = payload['sys'] as Map<String, dynamic>?;
    final country = sys?['country'] as String? ?? '';
    final coord =
        payload['coord'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return CityLocation(
      name: name,
      country: country,
      latitude: (coord['lat'] as num?)?.toDouble() ?? 0,
      longitude: (coord['lon'] as num?)?.toDouble() ?? 0,
    );
  }

  Future<_ForecastData> _fetchForecast(
      double latitude, double longitude) async {
    final uri = _buildUri('$_dataPath/forecast', <String, String>{
      'lat': latitude.toString(),
      'lon': longitude.toString(),
    });
    final response = await _safeGet(uri);
    final data = _decodeBody(response) as Map<String, dynamic>;
    final city = data['city'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final timezoneOffset = (city['timezone'] as num?)?.toInt() ?? 0;
    final list = (data['list'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();
    final hourly = _buildHourly(list, timezoneOffset);
    final daily = _buildDaily(list, timezoneOffset);
    return _ForecastData(
      daily: daily,
      hourly: hourly,
    );
  }

  WeatherReport _mapCurrentWeather(
      Map<String, dynamic> payload, CityLocation location) {
    final main =
        payload['main'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final weatherList = payload['weather'] as List<dynamic>? ?? <dynamic>[];
    final weather = weatherList.isNotEmpty
        ? weatherList.first as Map<String, dynamic>
        : <String, dynamic>{};
    final wind =
        payload['wind'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final sys = payload['sys'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final timezoneOffset = (payload['timezone'] as num?)?.toInt() ?? 0;

    return WeatherReport(
      location: location,
      observationTime: DateTime.fromMillisecondsSinceEpoch(
        ((payload['dt'] as num?)?.toInt() ?? 0) * 1000,
        isUtc: true,
      ),
      temperatureKelvin: (main['temp'] as num?)?.toDouble() ?? 0,
      feelsLikeKelvin: (main['feels_like'] as num?)?.toDouble() ?? 0,
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeedMetersPerSecond: (wind['speed'] as num?)?.toDouble() ?? 0,
      description: (weather['description'] as String? ?? '').toLowerCase(),
      iconCode: weather['icon'] as String? ?? '01d',
      sunrise: DateTime.fromMillisecondsSinceEpoch(
        ((sys['sunrise'] as num?)?.toInt() ?? 0) * 1000,
        isUtc: true,
      ),
      sunset: DateTime.fromMillisecondsSinceEpoch(
        ((sys['sunset'] as num?)?.toInt() ?? 0) * 1000,
        isUtc: true,
      ),
      timezoneOffsetSeconds: timezoneOffset,
    );
  }

  List<HourlyForecast> _buildHourly(
      List<Map<String, dynamic>> entries, int timezoneOffset) {
    final list = entries.map((entry) {
      final forecastTime = DateTime.fromMillisecondsSinceEpoch(
        ((entry['dt'] as num?)?.toInt() ?? 0) * 1000,
        isUtc: true,
      ).add(Duration(seconds: timezoneOffset));
      final main =
          entry['main'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final weather = (entry['weather'] as List<dynamic>? ?? <dynamic>[]);
      final icon = weather.isNotEmpty
          ? (weather.first as Map<String, dynamic>)['icon'] as String?
          : null;
      return HourlyForecast(
        time: forecastTime,
        tempKelvin: (main['temp'] as num?)?.toDouble() ?? 0,
        iconCode: icon ?? '01d',
      );
    }).toList();
    return list.take(8).toList();
  }

  List<DailyForecast> _buildDaily(
      List<Map<String, dynamic>> entries, int timezoneOffset) {
    final Map<DateTime, List<Map<String, dynamic>>> buckets =
        <DateTime, List<Map<String, dynamic>>>{};
    for (final entry in entries) {
      final date = DateTime.fromMillisecondsSinceEpoch(
        ((entry['dt'] as num?)?.toInt() ?? 0) * 1000,
        isUtc: true,
      ).add(Duration(seconds: timezoneOffset));
      final dayKey = DateTime(date.year, date.month, date.day);
      buckets.putIfAbsent(dayKey, () => <Map<String, dynamic>>[]).add(entry);
    }

    final sortedKeys = buckets.keys.toList()..sort();
    final localNow =
        DateTime.now().toUtc().add(Duration(seconds: timezoneOffset));
    final todayKey = DateTime(localNow.year, localNow.month, localNow.day);
    final upcoming = sortedKeys.where((day) => !day.isBefore(todayKey)).take(5);
    final result = <DailyForecast>[];

    for (final key in upcoming) {
      final samples = buckets[key]!;
      double minKelvin = double.infinity;
      double maxKelvin = double.negativeInfinity;
      String description = '';
      String icon = '01d';
      for (final sample in samples) {
        final main =
            sample['main'] as Map<String, dynamic>? ?? <String, dynamic>{};
        final tempMin = (main['temp_min'] as num?)?.toDouble();
        final tempMax = (main['temp_max'] as num?)?.toDouble();
        if (tempMin != null && tempMin < minKelvin) {
          minKelvin = tempMin;
        }
        if (tempMax != null && tempMax > maxKelvin) {
          maxKelvin = tempMax;
        }
        final weatherList = sample['weather'] as List<dynamic>?;
        if (weatherList != null && weatherList.isNotEmpty) {
          final weather = weatherList.first as Map<String, dynamic>;
          description = (weather['description'] as String? ?? '').toLowerCase();
          icon = weather['icon'] as String? ?? icon;
        }
      }
      if (!minKelvin.isFinite || !maxKelvin.isFinite) {
        continue;
      }
      result.add(
        DailyForecast(
          date: key,
          minTempKelvin: minKelvin,
          maxTempKelvin: maxKelvin,
          iconCode: icon,
          description: description,
        ),
      );
    }
    return result;
  }

  void _assertApiKey() {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_API_KEY') {
      throw const WeatherException(
        'Missing OpenWeather API key. Provide it via --dart-define OPENWEATHER_API_KEY=YOUR_KEY.',
      );
    }
  }
}

class _ForecastData {
  const _ForecastData({
    required this.daily,
    required this.hourly,
  });

  final List<DailyForecast> daily;
  final List<HourlyForecast> hourly;
}
