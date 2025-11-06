import 'package:flutter/material.dart';

import '../controllers/weather_controller.dart';
import '../models/city.dart';
import '../models/settings.dart';
import '../utils/formatters.dart';
import '../widgets/weather_scope.dart';
import '../widgets/hourly_forecast_list.dart';
import '../widgets/daily_forecast_list.dart';
import '../widgets/unit_toggle.dart';
import 'favorites_screen.dart';
import 'search_screen.dart';
import 'weather_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    final controller = WeatherScope.of(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Forecast'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.star_outline),
            tooltip: 'Favorites',
            onPressed: () =>
                Navigator.pushNamed(context, FavoritesScreen.routeName),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final weather = controller.currentWeather;
          final daily = controller.dailyForecast;
          final hourly = controller.hourlyForecast;
          final favorites = controller.favorites;
          final settings = controller.settings;

          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    readOnly: true,
                    onTap: () =>
                        Navigator.pushNamed(context, SearchScreen.routeName),
                    decoration: const InputDecoration(
                      hintText: 'Search for a city',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                if (controller.isLoading)
                  const _LoadingSection()
                else if (controller.hasError)
                  _ErrorSection(
                    message: controller.errorMessage ?? 'Something went wrong',
                    onRetry: controller.refresh,
                  )
                else if (weather == null)
                  const _EmptySection()
                else ...[
                  _CurrentWeatherCard(
                    controller: controller,
                    settings: settings,
                  ),
                  if (hourly.isNotEmpty)
                    HourlyForecastList(
                      forecasts: hourly,
                      settings: settings,
                    ),
                  if (daily.isNotEmpty)
                    DailyForecastList(
                      forecasts: daily,
                      settings: settings,
                    ),
                  UnitToggleRow(
                    temperatureUnit: settings.temperatureUnit,
                    windSpeedUnit: settings.windSpeedUnit,
                    onTemperatureChanged: controller.updateTemperatureUnit,
                    onWindChanged: controller.updateWindSpeedUnit,
                  ),
                  _FavoritesSection(
                    favorites: favorites,
                    selectedCity: controller.selectedCity,
                    onSelect: controller.selectFavorite,
                    onViewAll: () =>
                        Navigator.pushNamed(context, FavoritesScreen.routeName),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LoadingSection extends StatelessWidget {
  const _LoadingSection();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  const _ErrorSection({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              onRetry();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          Icon(Icons.cloud_outlined, size: 48),
          SizedBox(height: 12),
          Text('Search for a city to see the weather'),
        ],
      ),
    );
  }
}

class _CurrentWeatherCard extends StatelessWidget {
  const _CurrentWeatherCard({required this.controller, required this.settings});

  final WeatherController controller;
  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final weather = controller.currentWeather!;
    final description =
        Formatters.formatWeatherDescription(weather.description);
    final temperature = Formatters.formatTemperature(
        weather.temperatureCelsius, settings.temperatureUnit);
    final feelsLike = Formatters.formatTemperature(
        weather.feelsLikeCelsius, settings.temperatureUnit);
    final wind = Formatters.formatWind(
        weather.windSpeedMetersPerSecond, settings.windSpeedUnit);

    final gradient = _backgroundGradient(weather.iconCode);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, WeatherDetailScreen.routeName),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(
            gradient: gradient,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          weather.location.displayName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.formatDate(weather.localObservationTime),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          temperature,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Feels like $feelsLike',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Image.network(
                        Formatters.iconUrl(weather.iconCode),
                        width: 88,
                        height: 88,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _InfoTile(
                      label: 'Humidity',
                      value: Formatters.formatHumidity(weather.humidity),
                      icon: Icons.water_drop,
                    ),
                  ),
                  Expanded(
                    child: _InfoTile(
                      label: 'Wind',
                      value: wind,
                      icon: Icons.air,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _backgroundGradient(String iconCode) {
    if (iconCode.contains('n')) {
      return const LinearGradient(
        colors: <Color>[Color(0xFF141E30), Color(0xFF243B55)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (iconCode.startsWith('09') || iconCode.startsWith('10')) {
      return const LinearGradient(
        colors: <Color>[Color(0xFF536976), Color(0xFF292E49)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (iconCode.startsWith('13')) {
      return const LinearGradient(
        colors: <Color>[Color(0xFF83a4d4), Color(0xFFb6fbff)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (iconCode.startsWith('50')) {
      return const LinearGradient(
        colors: <Color>[Color(0xFF757F9A), Color(0xFFD7DDE8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: <Color>[Color(0xFF56CCF2), Color(0xFF2F80ED)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(
      {required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 20, color: Colors.white),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white70),
            ),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}

class _FavoritesSection extends StatelessWidget {
  const _FavoritesSection({
    required this.favorites,
    required this.selectedCity,
    required this.onSelect,
    required this.onViewAll,
  });

  final List<CityLocation> favorites;
  final CityLocation? selectedCity;
  final Future<void> Function(CityLocation) onSelect;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: OutlinedButton.icon(
          onPressed: onViewAll,
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text('Add your first favorite city'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Favorite Cities',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('Manage'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final city = favorites[index];
                final isSelected = selectedCity != null &&
                    city.latitude == selectedCity!.latitude &&
                    city.longitude == selectedCity!.longitude &&
                    city.name == selectedCity!.name;
                return ChoiceChip(
                  label: Text(city.displayName),
                  selected: isSelected,
                  onSelected: (_) {
                    onSelect(city);
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: favorites.length,
            ),
          ),
        ],
      ),
    );
  }
}
