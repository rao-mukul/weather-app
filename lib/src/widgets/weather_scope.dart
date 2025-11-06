import 'package:flutter/widgets.dart';

import '../controllers/weather_controller.dart';

class WeatherScope extends InheritedNotifier<WeatherController> {
  const WeatherScope({
    required WeatherController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static WeatherController of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<WeatherScope>()
        : context.getInheritedWidgetOfExactType<WeatherScope>();
    final controller = scope?.notifier;
    assert(controller != null, 'WeatherScope not found in context');
    return controller!;
  }

  @override
  bool updateShouldNotify(covariant WeatherScope oldWidget) =>
      notifier != oldWidget.notifier;
}
