import 'package:flutter/material.dart';

import '../models/settings.dart';
import '../models/weather_models.dart';
import '../utils/formatters.dart';

class DailyForecastList extends StatelessWidget {
  const DailyForecastList({
    required this.forecasts,
    required this.settings,
    super.key,
  });

  final List<DailyForecast> forecasts;
  final Settings settings;

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '5-Day Forecast',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...forecasts.map((daily) {
            final min = Formatters.formatTemperature(
                daily.minTempCelsius, settings.temperatureUnit);
            final max = Formatters.formatTemperature(
                daily.maxTempCelsius, settings.temperatureUnit);
            final description =
                Formatters.formatWeatherDescription(daily.description);
            return Card(
              child: ListTile(
                leading: Image.network(
                  Formatters.iconUrl(daily.iconCode),
                  width: 48,
                  height: 48,
                ),
                title: Text(Formatters.dayLabel(daily.date)),
                subtitle: Text(description),
                trailing: Text('$min / $max'),
              ),
            );
          }),
        ],
      ),
    );
  }
}
