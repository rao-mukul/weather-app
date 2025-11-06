# Architecture & Implementation Notes

## Overview

The app follows a lightweight layered structure to keep the codebase approachable while separating responsibilities:

- **Presentation** (`screens/`, `widgets/`): Flutter UI widgets composed of small, testable pieces. Screens subscribe to the `WeatherController` through `WeatherScope` (an `InheritedNotifier`).
- **State Management** (`controllers/`): `WeatherController` orchestrates API calls, local storage, unit preferences, and exposes immutable view models to the UI.
- **Domain Models** (`models/`): Simple data classes for cities, weather observations, forecasts, and user settings. Conversion helpers (°C/°F, km/h/mph) live on the models where possible.
- **Services** (`services/`): Infrastructure code for networking (`WeatherService`), location (`LocationService`), and persistence (`FavoritesService`, `SettingsService`).
- **Utilities** (`utils/`): Formatting helpers and exception types shared across layers.

Navigation is handled via `AppRouter` with four primary routes: home, search, detail, and favorites.

## Data Flow

1. **Initialization** (`WeatherController.bootstrap`):
   - Load user settings and favorites from `SharedPreferences`.
   - Restore the last selected city or fall back to current location weather.
2. **Fetching weather**:
   - `WeatherService` performs `GET` requests against OpenWeather Map REST endpoints using the `http` package.
   - `/weather` responses hydrate `WeatherReport`; `/forecast` drives both `DailyForecast` (grouped by day) and `HourlyForecast` (first 8 entries ≈ 24h).
3. **State updates**:
   - Controller updates trigger `notifyListeners`, allowing UI to rebuild via `AnimatedBuilder`.
   - Unit toggles modify `Settings`; conversions happen on the fly when formatted for display.
4. **Persistence**:
   - Favorites stored as JSON-encoded `CityLocation` entries in `SharedPreferences`.
   - Settings persist enum names; last-selected city stored separately for startup hydration.

## API Setup & Integration

- **Provider**: [OpenWeatherMap](https://openweathermap.org/api)
- **Base URL**: `https://api.openweathermap.org/data/2.5/`
- **Endpoints**:
  - `/weather` for the selected city or current coordinates.
  - `/forecast` (5-day / 3-hour cadence) for daily and hourly forecasts.
  - `/geo/1.0/direct` for city lookup and auto-complete.
- **Authentication**:
  1.  Create an account at OpenWeatherMap and copy your API key from _My API Keys_.
  2.  Run the app with `flutter run --dart-define=OPENWEATHER_API_KEY=YOUR_KEY` or configure the same flag in IDE launch settings.
  3.  The key is required at runtime; missing keys emit a user-facing error from `WeatherService`.
- **Units**: Requests use Kelvin and m·s⁻¹ defaults; conversions happen client-side via model getters to support user-selected units.

## Assumptions & Constraints

- Free-tier API limits (1,000 calls/day, 60/min) apply; avoid spamming refresh/search.
- Location permission can be denied; the controller falls back to favorites or manual search.
- Network or API failures display concise messages; more detail is available through debug logging.
- OpenWeather icon URLs are used directly; bundle or cache assets if offline support is needed.
- Targeted Flutter version is 3.16+ on the stable channel with Dart 3.2+.

## Extension Ideas

- Integrate `lottie` animations for background transitions based on weather conditions.
- Add offline caching for the last fetched weather bundle using `hydrated_bloc` or local storage.
- Support multi-language output by localizing strings with `intl` ARB files.
- Introduce integration tests covering search, favorites, and unit toggles using the `integration_test` package.
