enum TemperatureUnit { celsius, fahrenheit }

enum WindSpeedUnit { kilometresPerHour, milesPerHour }

class Settings {
  const Settings({
    required this.temperatureUnit,
    required this.windSpeedUnit,
  });

  final TemperatureUnit temperatureUnit;
  final WindSpeedUnit windSpeedUnit;

  factory Settings.initial() {
    return const Settings(
      temperatureUnit: TemperatureUnit.celsius,
      windSpeedUnit: WindSpeedUnit.kilometresPerHour,
    );
  }

  Settings copyWith({
    TemperatureUnit? temperatureUnit,
    WindSpeedUnit? windSpeedUnit,
  }) {
    return Settings(
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      windSpeedUnit: windSpeedUnit ?? this.windSpeedUnit,
    );
  }
}
