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

## API Integration

- **Base URL**: `https://api.openweathermap.org/data/2.5/`
- **Endpoints**:
  - Current weather (`/weather`) by city name or geographic coordinates.
  - 5-day / 3-hour forecast (`/forecast`) for daily/hourly views.
  - City search uses the Geocoding endpoint (`/geo/1.0/direct`) for auto-complete suggestions.
- **Authentication**: API key injected via `--dart-define=OPENWEATHER_API_KEY=...`.
- **Units**: Requests use Kelvin / m·s⁻¹ defaults; conversions handled locally to support user preferences.

## Assumptions & Constraints

- Free-tier API limits (1,000 calls/day, 60/min) are respected through efficient caching of the current selection; users must avoid rapid, repeated refreshes.
- Location access may be denied; when that occurs the controller falls back to favorites or prompts the user.
- Network errors display user-friendly messages; detailed diagnostics appear in debug console logs.
- UI assets rely on OpenWeather icon URLs; custom theming/animations can be layered on later.
- The project targets Flutter 3.16+ with Dart 3.2+, aligning with the latest stable channel at the time of writing.

## Extension Ideas

- Integrate `lottie` animations for background transitions based on weather conditions.
- Add offline caching for the last fetched weather bundle using `hydrated_bloc` or local storage.
- Support multi-language output by localizing strings with `intl` ARB files.
- Introduce integration tests covering search, favorites, and unit toggles using the `integration_test` package.
