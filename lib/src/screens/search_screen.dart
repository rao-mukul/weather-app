import 'package:flutter/material.dart';

import '../controllers/weather_controller.dart';
import '../widgets/weather_scope.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  static const String routeName = '/search';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final WeatherController _controller;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = WeatherScope.of(context, listen: false);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search cities'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _textController.clear();
              _controller.clearSearchResults();
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _textController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Type a city name',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _controller.clearError();
                _controller.searchCities(value);
              },
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                if (_controller.isSearching) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_controller.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _controller.errorMessage ?? 'Something went wrong',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            _controller.clearError();
                          },
                          child: const Text('Dismiss'),
                        ),
                      ],
                    ),
                  );
                }
                final results = _controller.searchResults;
                if (results.isEmpty) {
                  return const Center(
                      child: Text('No cities yet. Start typing to search.'));
                }
                return ListView.separated(
                  itemBuilder: (context, index) {
                    final city = results[index];
                    return ListTile(
                      leading: const Icon(Icons.location_city_outlined),
                      title: Text(city.displayName),
                      onTap: () async {
                        await _controller.loadWeatherForLocation(city);
                        if (!mounted) return;
                        Navigator.pop(context);
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemCount: results.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
