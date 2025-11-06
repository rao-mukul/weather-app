import 'package:flutter/material.dart';

import '../models/settings.dart';

class UnitToggleRow extends StatelessWidget {
  const UnitToggleRow({
    required this.temperatureUnit,
    required this.windSpeedUnit,
    required this.onTemperatureChanged,
    required this.onWindChanged,
    super.key,
  });

  final TemperatureUnit temperatureUnit;
  final WindSpeedUnit windSpeedUnit;
  final ValueChanged<TemperatureUnit> onTemperatureChanged;
  final ValueChanged<WindSpeedUnit> onWindChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Preferences',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              SegmentedButton<TemperatureUnit>(
                segments: const <ButtonSegment<TemperatureUnit>>[
                  ButtonSegment<TemperatureUnit>(
                      value: TemperatureUnit.celsius, label: Text('Celsius')),
                  ButtonSegment<TemperatureUnit>(
                      value: TemperatureUnit.fahrenheit,
                      label: Text('Fahrenheit')),
                ],
                selected: <TemperatureUnit>{temperatureUnit},
                onSelectionChanged: (selection) =>
                    onTemperatureChanged(selection.first),
              ),
              SegmentedButton<WindSpeedUnit>(
                segments: const <ButtonSegment<WindSpeedUnit>>[
                  ButtonSegment<WindSpeedUnit>(
                    value: WindSpeedUnit.kilometresPerHour,
                    label: Text('km/h'),
                  ),
                  ButtonSegment<WindSpeedUnit>(
                    value: WindSpeedUnit.milesPerHour,
                    label: Text('mph'),
                  ),
                ],
                selected: <WindSpeedUnit>{windSpeedUnit},
                onSelectionChanged: (selection) =>
                    onWindChanged(selection.first),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
