import 'package:flutter/material.dart';

import '../screens/favorites_screen.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/weather_detail_screen.dart';

class AppRouter {
  const AppRouter();

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case HomeScreen.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case SearchScreen.routeName:
        return MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => const SearchScreen(),
          settings: settings,
        );
      case WeatherDetailScreen.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => const WeatherDetailScreen(),
          settings: settings,
        );
      case FavoritesScreen.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => const FavoritesScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
    }
  }
}
