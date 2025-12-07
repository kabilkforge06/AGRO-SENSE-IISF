import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state_service.dart';
import '../services/weather_service.dart';
import 'ai_chat_screen.dart';
import 'schemes/schemes_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weatherData;
  bool _isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    try {
      final appState = Provider.of<AppStateService>(context, listen: false);
      WeatherData? weather;

      // Try to get weather from current GPS location first
      weather = await _weatherService.getWeatherByCurrentLocation();

      // If GPS fails, fallback to stored land location
      if (weather == null &&
          appState.landLatitude != null &&
          appState.landLongitude != null) {
        weather = await _weatherService.getFarmingWeather(
          latitude: appState.landLatitude,
          longitude: appState.landLongitude,
        );
      }

      // Final fallback to Delhi
      weather ??= await _weatherService.getFarmingWeather();

      setState(() {
        _weatherData = weather;
        _isLoadingWeather = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingWeather = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateService>(context);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: () {
            // Hidden admin feature - long press on title
            Navigator.pushNamed(context, '/scheme-sync-admin');
          },
          child: Text(appState.translate('farming_assist')),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Scheme Admin',
            onPressed: () {
              Navigator.pushNamed(context, '/scheme-sync-admin');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AppStateService>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.wb_sunny,
                      size: 40,
                      color: Colors.orange.shade600,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<AppStateService>(
                            builder: (context, appState, child) {
                              String userName = 'Farmer';
                              if (appState.username.isNotEmpty) {
                                userName = appState.username;
                              }

                              final greeting = _weatherService
                                  .getTimeBasedGreeting(
                                    language: appState.selectedLanguage,
                                  );

                              return Text(
                                '$greeting, $userName!',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          Consumer<AppStateService>(
                            builder: (context, appState, child) {
                              final subtitle = _weatherService
                                  .getTimeBasedSubtitle(
                                    language: appState.selectedLanguage,
                                  );

                              return Text(
                                subtitle,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey.shade600),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Weather Card
            _buildWeatherCard(context),
            const SizedBox(height: 16),

            // Today's Task Card
            _buildTodayTaskCard(context),
            const SizedBox(height: 16),

            // Quick Actions
            Consumer<AppStateService>(
              builder: (context, appState, child) {
                return Text(
                  appState.translate('quick_actions'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Action Buttons Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildActionCard(
                  context,
                  appState.translate('ai_assistant'),
                  Icons.smart_toy,
                  Colors.blue,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AIChatScreen(),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  context,
                  appState.translate('scan_leaf'),
                  Icons.camera_alt,
                  Colors.green,
                  () {
                    // Will be handled by bottom navigation
                  },
                ),
                _buildActionCard(
                  context,
                  appState.translate('market_prices'),
                  Icons.trending_up,
                  Colors.orange,
                  () {
                    // Will be handled by bottom navigation
                  },
                ),
                _buildActionCard(
                  context,
                  appState.translate('advisory'),
                  Icons.lightbulb,
                  Colors.purple,
                  () {
                    // Will be handled by bottom navigation
                  },
                ),
                _buildActionCard(
                  context,
                  appState.translate('government_schemes'),
                  Icons.account_balance,
                  Colors.teal,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SchemesListScreen(),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  context,
                  appState.translate('weather'),
                  Icons.wb_cloudy,
                  Colors.cyan,
                  () {
                    // Weather is already shown on dashboard
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AIChatScreen()),
          );
        },
        icon: const Icon(Icons.chat),
        label: const Text('AI Helper'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildWeatherCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud, color: Colors.blue.shade600, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Weather Today',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_weatherData != null)
                  Text(
                    _weatherService.getWeatherEmoji(_weatherData!.icon),
                    style: const TextStyle(fontSize: 24),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoadingWeather)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_weatherData?.temperature.round() ?? 28}°C',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                      ),
                      Text(
                        _weatherData?.description != null
                            ? _weatherData!.description[0].toUpperCase() +
                                  _weatherData!.description.substring(1)
                            : 'Partly Cloudy',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (_weatherData != null)
                        Text(
                          _weatherData!.cityName,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Humidity: ${_weatherData?.humidity ?? 65}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Wind: ${_weatherData?.windSpeed.round() ?? 12} km/h',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                _weatherData != null
                    ? _weatherService.getFarmingAdvice(_weatherData!)
                    : '🌱 Perfect weather for farming activities!',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayTaskCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.task_alt, color: Colors.green.shade600, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Today\'s Priority Task',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.water_drop, color: Colors.blue.shade600, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Irrigate the Wheat Field',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Water the wheat crops in the northern field. Estimated time: 2 hours',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.green.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
