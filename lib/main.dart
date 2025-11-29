import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/land_selection_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/advisory_screen.dart';
import 'screens/scan_leaf_screen.dart';
import 'screens/market_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/schemes/scheme_sync_admin_screen.dart';
import 'services/app_state_service.dart';
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
    ChangeNotifierProvider(
      create: (context) => AppStateService(),
      child: const FarmingAssistApp(),
    ),
  );
}

class FarmingAssistApp extends StatelessWidget {
  const FarmingAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farming Assist',
      debugShowCheckedModeBanner: false,
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
      home: Consumer<AppStateService>(
        builder: (context, appState, child) {
          // Navigation flow based on app state
          if (!appState.isLoggedIn) {
            return const LoginScreen();
          } else if (appState.selectedLanguage.isEmpty) {
            // If no language selected, show language selection first
            return const LanguageSelectionScreen();
          } else if (!appState.hasSelectedLand) {
            // Show land selection if language is selected but land is not
            return const LandSelectionScreen();
          } else {
            // Show main dashboard with navigation
            return const MainNavigationScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const MainNavigationScreen(),
        '/ai-chat': (context) => const AIChatScreen(),
        '/scheme-sync-admin': (context) => const SchemeSyncAdminScreen(),
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
  ];

  @override
  Widget build(BuildContext context) {
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Advisory',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Market'),
        ],
      ),
    );
  }
}
