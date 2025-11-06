# Weather Forecast App

A Flutter application built for the **Flutter Intern Hackathon Challenge**. The app lets users search for cities, view real-time weather conditions, explore 5-day and hourly forecasts, and manage favorite locations using local storage.

## Features

- 🔍 **City search** with type-ahead suggestions, loading indicators, and graceful error handling.
- ☀️ **Current conditions** including temperature, feels-like, humidity, wind, status icon, and timestamps.
- � **Hourly outlook** (next 24h) in a horizontal carousel with icons and temperatures.
- 📅 **5-day forecast** with min/max temperatures, icons, and friendly day labels.
- ⭐ **Favorite cities** persisted with `shared_preferences`, quick access chips, and swipe-to-delete management.
- 📍 **Current location weather** using `geolocator`, with permission handling and fallbacks.
- 🔄 **Unit conversion** toggles for °C/°F and km/h/mph, saved between sessions.
- 🎨 **Responsive UI** with light/dark themes, animated layout changes, and smooth navigation.

## Getting Started

### Prerequisites

- Flutter SDK (latest stable) installed and added to your PATH
- OpenWeatherMap API key ([sign up](https://openweathermap.org/api))

### Installation

```bash
# Clone this repository
git clone <your-fork-url>
cd weather_app

# (Optional) if project metadata folders are missing, generate them:
flutter create .

# Fetch dependencies
flutter pub get

# Run the app (replace YOUR_KEY)
flutter run --dart-define=OPENWEATHER_API_KEY=YOUR_KEY
```

### Environment configuration

The application reads the OpenWeather API key via a compile-time define:

```bash
flutter run --dart-define=OPENWEATHER_API_KEY=YOUR_KEY
```

You can also set this flag in your IDE run configuration. The default value is `YOUR_API_KEY`, which will trigger a runtime error reminder.

### Platform setup notes

- **Android**: Location permissions are requested at runtime via `geolocator`.
- **iOS**: Update `Info.plist` with `NSLocationWhenInUseUsageDescription` to explain location usage.
- **Web/Desktop**: Location access requires serving over HTTPS or localhost.

## Project Structure

```
lib/
  main.dart
  src/
    app.dart
    config/
      app_router.dart
      app_theme.dart
    controllers/
      weather_controller.dart
    models/
      city.dart
      settings.dart
      weather_models.dart
    screens/
      favorites_screen.dart
      home_screen.dart
      search_screen.dart
      weather_detail_screen.dart
    services/
      favorites_service.dart
      location_service.dart
      settings_service.dart
      weather_service.dart
    utils/
      formatters.dart
      weather_exceptions.dart
    widgets/
      daily_forecast_list.dart
      hourly_forecast_list.dart
      unit_toggle.dart
      weather_scope.dart
```

Supporting documentation lives under `docs/`:

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) – component overview, data flow, API notes, and assumptions.

## Testing

Run the placeholder test suite (extend with real tests as you iterate):

```bash
flutter test
```

## Known Issues & Future Enhancements

- Weather icons come directly from OpenWeather; consider caching or local assets for offline use.
- Hourly forecast currently samples the first eight entries (24h). Extend to show the full 48h window if needed.
- Search suggestions leverage the OpenWeather geocoding API; rate limiting may apply on free tiers.
- Add shimmer/loading animations or integrate Lottie assets for richer feedback.

## License

This project is provided for hackathon evaluation purposes. Adapt and extend as needed for production use.
