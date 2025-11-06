import 'package:flutter/material.dart';
import 'src/app.dart';
import 'src/controllers/weather_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = await WeatherController.bootstrap();
  runApp(WeatherApp(controller: controller));
}
