import 'city.dart';

class WeatherReport {
  WeatherReport({
    required this.location,
    required this.observationTime,
    required this.temperatureKelvin,
    required this.feelsLikeKelvin,
    required this.humidity,
    required this.windSpeedMetersPerSecond,
    required this.description,
    required this.iconCode,
    required this.sunrise,
    required this.sunset,
    required this.timezoneOffsetSeconds,
  });

  final CityLocation location;
  final DateTime observationTime;
  final double temperatureKelvin;
  final double feelsLikeKelvin;
  final int humidity;
  final double windSpeedMetersPerSecond;
  final String description;
  final String iconCode;
  final DateTime sunrise;
  final DateTime sunset;
  final int timezoneOffsetSeconds;

  double get temperatureCelsius => temperatureKelvin - 273.15;

  double get feelsLikeCelsius => feelsLikeKelvin - 273.15;

  double get temperatureFahrenheit => (temperatureCelsius * 9 / 5) + 32;

  double get feelsLikeFahrenheit => (feelsLikeCelsius * 9 / 5) + 32;

  double get windSpeedKilometresPerHour => windSpeedMetersPerSecond * 3.6;

  double get windSpeedMilesPerHour => windSpeedMetersPerSecond * 2.23693629;

  DateTime get localObservationTime =>
      observationTime.add(Duration(seconds: timezoneOffsetSeconds));

  DateTime get localSunrise =>
      sunrise.add(Duration(seconds: timezoneOffsetSeconds));

  DateTime get localSunset =>
      sunset.add(Duration(seconds: timezoneOffsetSeconds));
}

class DailyForecast {
  DailyForecast({
    required this.date,
    required this.minTempKelvin,
    required this.maxTempKelvin,
    required this.iconCode,
    required this.description,
  });

  final DateTime date;
  final double minTempKelvin;
  final double maxTempKelvin;
  final String iconCode;
  final String description;

  double get minTempCelsius => minTempKelvin - 273.15;

  double get maxTempCelsius => maxTempKelvin - 273.15;

  double get minTempFahrenheit => (minTempCelsius * 9 / 5) + 32;

  double get maxTempFahrenheit => (maxTempCelsius * 9 / 5) + 32;
}

class HourlyForecast {
  HourlyForecast({
    required this.time,
    required this.tempKelvin,
    required this.iconCode,
  });

  final DateTime time;
  final double tempKelvin;
  final String iconCode;

  double get tempCelsius => tempKelvin - 273.15;

  double get tempFahrenheit => (tempCelsius * 9 / 5) + 32;
}

class WeatherBundle {
  WeatherBundle({
    required this.report,
    required this.daily,
    required this.hourly,
  });

  final WeatherReport report;
  final List<DailyForecast> daily;
  final List<HourlyForecast> hourly;
}
