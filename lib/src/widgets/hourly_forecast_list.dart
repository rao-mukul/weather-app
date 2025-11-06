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
      height: 140,
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
            child: SizedBox(
              width: 110,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      Formatters.formatHour(item.time),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 38,
                      child: Image.network(
                        Formatters.iconUrl(item.iconCode),
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      temperature,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
