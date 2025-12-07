import 'package:flutter/material.dart';
import '../../services/scheme_scraper_service.dart';
import '../../services/scheme_sync_service.dart';
import '../../services/scheme_service.dart';

/// Test screen to verify real-time scheme fetching
class SchemeTestScreen extends StatefulWidget {
  const SchemeTestScreen({super.key});

  @override
  State<SchemeTestScreen> createState() => _SchemeTestScreenState();
}

class _SchemeTestScreenState extends State<SchemeTestScreen> {
  final SchemeScraperService _scraperService = SchemeScraperService();
  final SchemeSyncService _syncService = SchemeSyncService();
  final SchemeService _schemeService = SchemeService();

  String _status = 'Ready to test';
  bool _isTesting = false;
  final List<String> _testResults = [];

  Future<void> _runTests() async {
    setState(() {
      _isTesting = true;
      _testResults.clear();
      _status = 'Running tests...';
    });

    try {
      // Test 1: Scraper Service
      _addResult('Test 1: Testing Gemini AI Scraper...');
      final schemes = await _scraperService.fetchLatestSchemes(limit: 3);
      _addResult('✅ Fetched ${schemes.length} schemes from Gemini');

      if (schemes.isEmpty) {
        _addResult('❌ No schemes fetched - Check Gemini API key');
      } else {
        _addResult('Sample scheme: ${schemes[0]['name']}');
      }

      // Test 2: Sync Service
      _addResult('\nTest 2: Testing Sync Service...');
      final syncResult = await _syncService.syncAllSchemes(forceUpdate: true);
      _addResult('✅ Sync completed: ${syncResult.message}');
      _addResult(
        'Added: ${syncResult.schemesAdded}, Updated: ${syncResult.schemesUpdated}',
      );

      // Test 3: Scheme Service
      _addResult('\nTest 3: Testing Scheme Service...');
      final firestoreSchemes = await _schemeService.getActiveSchemesOnce();
      _addResult('✅ Loaded ${firestoreSchemes.length} schemes from Firestore');

      if (firestoreSchemes.isNotEmpty) {
        _addResult('Sample: ${firestoreSchemes[0].name}');
      }

      // Test 4: Statistics
      _addResult('\nTest 4: Checking Statistics...');
      final stats = await _schemeService.getSyncStats();
      _addResult('Total schemes: ${stats['totalSchemes']}');
      _addResult('Active schemes: ${stats['activeSchemes']}');
      _addResult('Last sync: ${stats['lastSyncTime']}');

      setState(() {
        _status = 'All tests completed! ✅';
      });
    } catch (e) {
      _addResult('\n❌ Error: $e');
      setState(() {
        _status = 'Tests failed with errors';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheme System Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      _isTesting ? Icons.hourglass_empty : Icons.check_circle,
                      size: 48,
                      color: _isTesting ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isTesting ? null : _runTests,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Run System Test'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test Results:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child: _testResults.isEmpty
                            ? const Center(
                                child: Text('No results yet. Run the test!'),
                              )
                            : ListView.builder(
                                itemCount: _testResults.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Text(
                                      _testResults[index],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
