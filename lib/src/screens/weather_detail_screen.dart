import 'package:flutter/material.dart';

import '../utils/formatters.dart';
import '../widgets/daily_forecast_list.dart';
import '../widgets/hourly_forecast_list.dart';
import '../widgets/weather_scope.dart';

class WeatherDetailScreen extends StatelessWidget {
  const WeatherDetailScreen({super.key});

  static const String routeName = '/details';

  @override
  Widget build(BuildContext context) {
    final controller = WeatherScope.of(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Details'),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final weather = controller.currentWeather;
          final settings = controller.settings;
          if (controller.isLoading && weather == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (weather == null) {
            return const Center(
                child: Text('No weather data. Search for a location first.'));
          }

          final isFavorite = controller.isFavorite(weather.location);
          final sunrise = Formatters.formatHour(weather.localSunrise);
          final sunset = Formatters.formatHour(weather.localSunset);
          final temperature = Formatters.formatTemperature(
              weather.temperatureCelsius, settings.temperatureUnit);
          final feelsLike = Formatters.formatTemperature(
              weather.feelsLikeCelsius, settings.temperatureUnit);
          final wind = Formatters.formatWind(
              weather.windSpeedMetersPerSecond, settings.windSpeedUnit);

          return ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
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
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(Formatters.formatDate(
                                  weather.localObservationTime)),
                              const SizedBox(height: 16),
                              Text(
                                temperature,
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text('Feels like $feelsLike'),
                              const SizedBox(height: 16),
                              Row(
                                children: <Widget>[
                                  _DetailChip(
                                      label: 'Humidity',
                                      value: Formatters.formatHumidity(
                                          weather.humidity)),
                                  const SizedBox(width: 12),
                                  _DetailChip(label: 'Wind', value: wind),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Image.network(
                              Formatters.iconUrl(weather.iconCode),
                              width: 120,
                              height: 120,
                            ),
                            const SizedBox(height: 8),
                            Text(Formatters.formatWeatherDescription(
                                weather.description)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _DetailTile(
                            icon: Icons.wb_sunny_outlined,
                            label: 'Sunrise',
                            value: sunrise,
                          ),
                        ),
                        Expanded(
                          child: _DetailTile(
                            icon: Icons.dark_mode_outlined,
                            label: 'Sunset',
                            value: sunset,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        controller.toggleFavorite();
                      },
                      icon: Icon(isFavorite ? Icons.star : Icons.star_border),
                      label: Text(isFavorite
                          ? 'Remove from favorites'
                          : 'Save to favorites'),
                    ),
                  ],
                ),
              ),
              if (controller.hourlyForecast.isNotEmpty)
                HourlyForecastList(
                  forecasts: controller.hourlyForecast,
                  settings: settings,
                ),
              if (controller.dailyForecast.isNotEmpty)
                DailyForecastList(
                  forecasts: controller.dailyForecast,
                  settings: settings,
                ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(label),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 36),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
