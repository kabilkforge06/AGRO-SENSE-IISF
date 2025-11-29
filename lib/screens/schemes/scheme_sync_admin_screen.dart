import 'package:flutter/material.dart';
import '../../services/scheme_service.dart';
import '../../services/scheme_sync_service.dart';

/// Admin screen for managing government schemes sync
class SchemeSyncAdminScreen extends StatefulWidget {
  const SchemeSyncAdminScreen({super.key});

  @override
  State<SchemeSyncAdminScreen> createState() => _SchemeSyncAdminScreenState();
}

class _SchemeSyncAdminScreenState extends State<SchemeSyncAdminScreen> {
  final SchemeService _schemeService = SchemeService();
  bool _isSyncing = false;
  String? _syncMessage;
  SyncResult? _lastResult;
  Map<String, dynamic>? _stats;
  DateTime? _lastSyncTime;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _schemeService.getSyncStats();
    final lastSync = await _schemeService.getLastSyncTime();

    setState(() {
      _stats = stats;
      _lastSyncTime = lastSync;
    });
  }

  Future<void> _syncAllSchemes({bool forceUpdate = false}) async {
    setState(() {
      _isSyncing = true;
      _syncMessage = 'Fetching latest schemes from Gemini AI...';
      _lastResult = null;
    });

    try {
      final result = await _schemeService
          .syncLatestSchemesFromWeb(forceUpdate: forceUpdate)
          .timeout(
            const Duration(seconds: 90),
            onTimeout: () {
              return SyncResult(
                success: false,
                message:
                    'Sync timeout - Gemini API is slow. Try "Upload Sample Schemes" instead.',
                schemesAdded: 0,
                schemesUpdated: 0,
                schemesFailed: 0,
              );
            },
          );

      setState(() {
        _lastResult = result;
        _syncMessage = result.message;
      });

      await _loadStats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 6),
            action: result.success
                ? null
                : SnackBarAction(
                    label: 'Use Samples',
                    textColor: Colors.white,
                    onPressed: _syncHardcodedSchemes,
                  ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _syncMessage = 'Error: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _syncHardcodedSchemes() async {
    setState(() {
      _isSyncing = true;
      _syncMessage = 'Syncing hardcoded sample schemes...';
    });

    try {
      await _schemeService.syncDetailedSchemesToFirestore();

      setState(() {
        _syncMessage = 'Successfully synced hardcoded schemes!';
      });

      await _loadStats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully synced hardcoded schemes to Firestore'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _syncMessage = 'Error: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheme Sync Admin'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stats Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Scheme Statistics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_stats != null && _stats!.isNotEmpty) ...[
                      _buildStatRow(
                        'Total Schemes',
                        (_stats!['totalSchemes'] ?? 0).toString(),
                      ),
                      _buildStatRow(
                        'Active Schemes',
                        (_stats!['activeSchemes'] ?? 0).toString(),
                      ),
                      const Divider(height: 24),
                      const Text(
                        'By Category:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (_stats!['categoriesCount'] != null)
                        ...((_stats!['categoriesCount'] as Map<String, dynamic>)
                            .entries
                            .map(
                              (e) => _buildStatRow(
                                '  ${e.key}',
                                e.value.toString(),
                              ),
                            )),
                      const Divider(height: 24),
                      if (_lastSyncTime != null)
                        _buildStatRow(
                          'Last Sync',
                          _formatDateTime(_lastSyncTime!),
                        ),
                    ] else
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Sync Controls
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Sync Controls',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sync from Web (Gemini AI)
                    ElevatedButton.icon(
                      onPressed: _isSyncing ? null : () => _syncAllSchemes(),
                      icon: const Icon(Icons.cloud_sync),
                      label: const Text('Sync Latest Schemes (Auto)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Fetches latest schemes from Gemini AI. Runs only if last sync was >24h ago.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Force Sync
                    ElevatedButton.icon(
                      onPressed: _isSyncing
                          ? null
                          : () => _syncAllSchemes(forceUpdate: true),
                      icon: const Icon(Icons.sync),
                      label: const Text('Force Sync (Ignore Timer)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Forces immediate sync regardless of last sync time.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Sync Hardcoded Schemes
                    ElevatedButton.icon(
                      onPressed: _isSyncing ? null : _syncHardcodedSchemes,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Sample Schemes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Uploads the 10 hardcoded sample schemes to Firestore.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Sync Status
            if (_isSyncing || _syncMessage != null)
              Card(
                elevation: 4,
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (_isSyncing)
                        const CircularProgressIndicator()
                      else if (_lastResult != null)
                        Icon(
                          _lastResult!.success
                              ? Icons.check_circle
                              : Icons.error,
                          color: _lastResult!.success
                              ? Colors.green
                              : Colors.red,
                          size: 48,
                        ),
                      const SizedBox(height: 12),
                      Text(
                        _syncMessage ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (_lastResult != null && _lastResult!.success) ...[
                        const SizedBox(height: 16),
                        _buildStatRow(
                          'Added',
                          _lastResult!.schemesAdded.toString(),
                        ),
                        _buildStatRow(
                          'Updated',
                          _lastResult!.schemesUpdated.toString(),
                        ),
                        _buildStatRow(
                          'Failed',
                          _lastResult!.schemesFailed.toString(),
                        ),
                        _buildStatRow(
                          'Total Processed',
                          _lastResult!.totalProcessed.toString(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Instructions
            Card(
              elevation: 2,
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'How It Works',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Use "Sync Latest Schemes" to automatically fetch real-time government schemes using Gemini AI\n\n'
                      '2. The system will check if last sync was more than 24 hours ago\n\n'
                      '3. Schemes are fetched by category and validated before storing in Firestore\n\n'
                      '4. Your app will automatically show the updated schemes\n\n'
                      '5. Use "Force Sync" to bypass the 24-hour timer and fetch immediately\n\n'
                      '6. Use "Upload Sample Schemes" to populate Firestore with initial data',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
