import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/land_selection_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/advisory_screen.dart';
import 'screens/scan_leaf_screen.dart';
import 'screens/market_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/cold_storage_finder_screen.dart';
import 'screens/schemes/scheme_sync_admin_screen.dart';
import 'services/app_state_service.dart';
import 'services/auth_service.dart';
import 'services/mongodb_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for authentication
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize database service (in-memory mode)
  try {
    await MongoDBService.connect();
    print('Database service initialized successfully');
  } catch (e) {
    print('Failed to initialize database service: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppStateService()),
        ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      child: const FarmingAssistApp(),
    ),
  );
}

class FarmingAssistApp extends StatelessWidget {
  const FarmingAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateService>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'Farming Assist',
          debugShowCheckedModeBanner: false,
          locale: appState.locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('hi'),
            Locale('ta'),
            Locale('te'),
          ],
          theme: ThemeData(
            primarySwatch: Colors.green,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          home: const SplashScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/dashboard': (context) => Consumer2<AppStateService, AuthService>(
              builder: (context, appState, authService, child) {
                if (!authService.isLoggedIn && !appState.isLoggedIn) {
                  return const LoginScreen();
                } else if (appState.selectedLanguage.isEmpty) {
                  return const LanguageSelectionScreen();
                } else if (!appState.hasSelectedLand) {
                  return const LandSelectionScreen();
                } else {
                  return const MainNavigationScreen();
                }
              },
            ),
            '/ai-chat': (context) => const AIChatScreen(),
            '/cold-storage': (context) => const ColdStorageFinderScreen(),
            '/scheme-sync-admin': (context) => const SchemeSyncAdminScreen(),
          },
        );
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AdvisoryScreen(),
    const ScanLeafScreen(),
    const MarketScreen(),
    const ColdStorageFinderScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateService>(context);

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: appState.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.lightbulb),
            label: appState.translate('advisory'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.camera_alt),
            label: appState.translate('scan_leaf'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.store),
            label: appState.translate('market'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.warehouse),
            label: appState.translate('cold_storage'),
          ),
        ],
      ),
    );
  }
}
