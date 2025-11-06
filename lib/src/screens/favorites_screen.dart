import 'package:flutter/material.dart';

import '../widgets/weather_scope.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  static const String routeName = '/favorites';

  @override
  Widget build(BuildContext context) {
    final controller = WeatherScope.of(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Cities'),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final favorites = controller.favorites;
          if (favorites.isEmpty) {
            return const Center(
              child:
                  Text('No favorites yet. Add cities from the detail screen.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            itemBuilder: (context, index) {
              final city = favorites[index];
              final selected = controller.selectedCity;
              final isActive = selected != null &&
                  city.latitude == selected.latitude &&
                  city.longitude == selected.longitude &&
                  city.name == selected.name;
              return Dismissible(
                key:
                    ValueKey('${city.name}-${city.latitude}-${city.longitude}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) {
                  controller.removeFavorite(city);
                },
                child: Card(
                  child: ListTile(
                    title: Text(city.displayName),
                    subtitle: isActive ? const Text('Currently viewing') : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded),
                      onPressed: () async {
                        await controller.selectFavorite(city);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                    ),
                    onTap: () async {
                      await controller.selectFavorite(city);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: favorites.length,
          );
        },
      ),
    );
  }
}
