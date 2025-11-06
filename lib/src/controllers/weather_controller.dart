import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/city.dart';
import '../models/settings.dart';
import '../models/weather_models.dart';
import '../services/favorites_service.dart';
import '../services/location_service.dart';
import '../services/settings_service.dart';
import '../services/weather_service.dart';
import '../utils/weather_exceptions.dart';

class WeatherController extends ChangeNotifier {
  WeatherController({
    required WeatherService weatherService,
    required FavoritesService favoritesService,
    required SettingsService settingsService,
    required LocationService locationService,
  })  : _weatherService = weatherService,
        _favoritesService = favoritesService,
        _settingsService = settingsService,
        _locationService = locationService;

  final WeatherService _weatherService;
  final FavoritesService _favoritesService;
  final SettingsService _settingsService;
  final LocationService _locationService;

  WeatherReport? _currentWeather;
  List<DailyForecast> _dailyForecast = <DailyForecast>[];
  List<HourlyForecast> _hourlyForecast = <HourlyForecast>[];
  List<CityLocation> _favorites = <CityLocation>[];
  List<CityLocation> _searchResults = <CityLocation>[];
  Settings _settings = Settings.initial();
  CityLocation? _selectedCity;
  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;
  int _searchToken = 0;
  bool _initialized = false;

  WeatherReport? get currentWeather => _currentWeather;

  List<DailyForecast> get dailyForecast => _dailyForecast;

  List<HourlyForecast> get hourlyForecast => _hourlyForecast;

  List<CityLocation> get favorites =>
      List<CityLocation>.unmodifiable(_favorites);

  List<CityLocation> get searchResults =>
      List<CityLocation>.unmodifiable(_searchResults);

  Settings get settings => _settings;

  CityLocation? get selectedCity => _selectedCity;

  bool get isLoading => _isLoading;

  bool get isSearching => _isSearching;

  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;

  String? get errorMessage => _errorMessage;

  bool get initialized => _initialized;

  static Future<WeatherController> bootstrap() async {
    final controller = WeatherController(
      weatherService: WeatherService(),
      favoritesService: FavoritesService(),
      settingsService: SettingsService(),
      locationService: LocationService(),
    );
    await controller._initialize();
    return controller;
  }

  Future<void> _initialize() async {
    _settings = await _settingsService.loadSettings();
    _favorites = await _favoritesService.loadFavorites();
    _selectedCity = await _settingsService.loadLastCity();
    _initialized = true;
    notifyListeners();

    if (_selectedCity != null) {
      await loadWeatherForLocation(_selectedCity!, saveSelection: false);
    } else if (_favorites.isNotEmpty) {
      await loadWeatherForLocation(_favorites.first);
    } else {
      await loadWeatherForCurrentLocation();
    }
  }

  Future<void> refresh() async {
    if (_selectedCity != null) {
      await loadWeatherForLocation(_selectedCity!, saveSelection: false);
    } else {
      await loadWeatherForCurrentLocation();
    }
  }

  Future<void> loadWeatherForLocation(CityLocation location,
      {bool saveSelection = true}) async {
    _setLoading(true);
    _clearError();
    try {
      final result = await _weatherService.fetchWeatherByCoordinates(
        location.latitude,
        location.longitude,
      );
      _applyWeatherBundle(result);
      _selectedCity = result.report.location.copyWith(
        name:
            location.name.isEmpty ? result.report.location.name : location.name,
        country: location.country.isEmpty
            ? result.report.location.country
            : location.country,
        state: location.state ?? result.report.location.state,
      );
      if (saveSelection && _selectedCity != null) {
        await _settingsService.saveLastCity(_selectedCity!);
      }
    } on WeatherException catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = 'Something went wrong: $error';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadWeatherForCurrentLocation() async {
    _setLoading(true);
    _clearError();
    try {
      final position = await _locationService.currentPosition();
      final bundle = await _weatherService.fetchWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );
      _applyWeatherBundle(bundle);
      _selectedCity = bundle.report.location;
      await _settingsService.saveLastCity(_selectedCity!);
    } on LocationException catch (error) {
      _errorMessage = error.message;
      if (_favorites.isNotEmpty) {
        await loadWeatherForLocation(_favorites.first);
      }
    } on WeatherException catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = 'Unable to load current location weather: $error';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchCities(String query) async {
    final trimmed = query.trim();
    _searchToken += 1;
    final currentToken = _searchToken;
    if (trimmed.length < 2) {
      _searchResults = <CityLocation>[];
      _isSearching = false;
      _errorMessage = null;
      notifyListeners();
      return;
    }
    _isSearching = true;
    notifyListeners();
    try {
      final results = await _weatherService.searchCities(trimmed);
      if (currentToken == _searchToken) {
        _searchResults = results;
        _errorMessage = null;
      }
    } on WeatherException catch (error) {
      if (currentToken == _searchToken) {
        _errorMessage = error.message;
      }
    } catch (error) {
      if (currentToken == _searchToken) {
        _errorMessage = 'Unable to search cities: $error';
      }
    } finally {
      if (currentToken == _searchToken) {
        _isSearching = false;
        notifyListeners();
      }
    }
  }

  void clearSearchResults() {
    _searchResults = <CityLocation>[];
    notifyListeners();
  }

  bool isFavorite(CityLocation city) {
    return _favorites.any((item) => _isSameCity(item, city));
  }

  Future<void> toggleFavorite() async {
    final city = _selectedCity;
    if (city == null) {
      return;
    }
    if (isFavorite(city)) {
      _favorites.removeWhere((item) => _isSameCity(item, city));
    } else {
      _favorites.add(city);
    }
    await _favoritesService.saveFavorites(_favorites);
    notifyListeners();
  }

  Future<void> removeFavorite(CityLocation city) async {
    _favorites.removeWhere((item) => _isSameCity(item, city));
    await _favoritesService.saveFavorites(_favorites);
    notifyListeners();
  }

  Future<void> selectFavorite(CityLocation city) async {
    await loadWeatherForLocation(city);
  }

  Future<void> updateTemperatureUnit(TemperatureUnit unit) async {
    if (_settings.temperatureUnit == unit) {
      return;
    }
    _settings = _settings.copyWith(temperatureUnit: unit);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateWindSpeedUnit(WindSpeedUnit unit) async {
    if (_settings.windSpeedUnit == unit) {
      return;
    }
    _settings = _settings.copyWith(windSpeedUnit: unit);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void _applyWeatherBundle(WeatherBundle bundle) {
    _currentWeather = bundle.report;
    _dailyForecast = bundle.daily;
    _hourlyForecast = bundle.hourly;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  bool _isSameCity(CityLocation a, CityLocation b) {
    const precision = 0.01;
    final sameLat = (a.latitude - b.latitude).abs() < precision;
    final sameLon = (a.longitude - b.longitude).abs() < precision;
    return sameLat && sameLon && a.name.toLowerCase() == b.name.toLowerCase();
  }

  @override
  void dispose() {
    unawaited(_weatherService.close());
    super.dispose();
  }
}
