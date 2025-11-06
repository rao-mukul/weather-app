import 'package:flutter/material.dart';
import 'config/app_router.dart';
import 'config/app_theme.dart';
import 'controllers/weather_controller.dart';
import 'widgets/weather_scope.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({required this.controller, super.key});

  final WeatherController controller;

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  final AppRouter _router = const AppRouter();

  @override
  Widget build(BuildContext context) {
    return WeatherScope(
      controller: widget.controller,
      child: MaterialApp(
        title: 'Weather Forecast',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        onGenerateRoute: _router.onGenerateRoute,
      ),
    );
  }
}
