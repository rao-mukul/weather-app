import 'package:flutter/material.dart';

import '../models/settings.dart';
import '../models/weather_models.dart';
import '../utils/formatters.dart';

class HourlyForecastList extends StatelessWidget {
  const HourlyForecastList({
    required this.forecasts,
    required this.settings,
    super.key,
  });

  final List<HourlyForecast> forecasts;
  final Settings settings;

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: forecasts.length,
        itemBuilder: (context, index) {
          final item = forecasts[index];
          final temperature = Formatters.formatTemperature(
            item.tempCelsius,
            settings.temperatureUnit,
          );
          return Card(
            child: Container(
              width: 110,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    Formatters.formatHour(item.time),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Image.network(
                    Formatters.iconUrl(item.iconCode),
                    width: 54,
                    height: 54,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    temperature,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
