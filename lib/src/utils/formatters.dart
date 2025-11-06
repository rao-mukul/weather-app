import 'package:intl/intl.dart';

import '../models/settings.dart';

class Formatters {
  const Formatters._();

  static String formatTemperature(double celsius, TemperatureUnit unit) {
    final value =
        unit == TemperatureUnit.celsius ? celsius : (celsius * 9 / 5) + 32;
    final suffix = unit == TemperatureUnit.celsius ? '°C' : '°F';
    return '${value.toStringAsFixed(1)}$suffix';
  }

  static String formatWind(double metresPerSecond, WindSpeedUnit unit) {
    final value = unit == WindSpeedUnit.kilometresPerHour
        ? metresPerSecond * 3.6
        : metresPerSecond * 2.23693629;
    final suffix = unit == WindSpeedUnit.kilometresPerHour ? 'km/h' : 'mph';
    return '${value.toStringAsFixed(1)} $suffix';
  }

  static String formatHumidity(int humidity) => '$humidity%';

  static String dayLabel(DateTime date) {
    final now = DateTime.now();
    final localDate = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    if (localDate == today) {
      return 'Today';
    }
    if (localDate == tomorrow) {
      return 'Tomorrow';
    }
    return DateFormat('EEE').format(date);
  }

  static String formatDate(DateTime date) =>
      DateFormat('EEE, MMM d').format(date);

  static String formatHour(DateTime date) => DateFormat('ha').format(date);

  static String formatWeatherDescription(String description) {
    if (description.isEmpty) {
      return description;
    }
    return description
        .split(' ')
        .map((word) =>
            word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  static String iconUrl(String iconCode) =>
      'https://openweathermap.org/img/wn/$iconCode@2x.png';
}
