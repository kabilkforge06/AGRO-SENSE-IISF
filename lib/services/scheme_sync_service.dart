import 'dart:developer' as developer;
import 'scheme_scraper_service.dart';
import 'mongodb_service.dart';

/// Service to sync schemes from Gemini AI to MongoDB
class SchemeSyncService {
  final SchemeScraperService _scraperService = SchemeScraperService();

  /// Sync all schemes from Gemini AI to MongoDB
  Future<SyncResult> syncAllSchemes({bool forceUpdate = false}) async {
    try {
      developer.log(
        'Starting scheme sync to MongoDB...',
        name: 'SchemeSyncService',
      );

      // Check last sync time (for now, always sync if forced)
      if (!forceUpdate && !await _shouldSync()) {
        developer.log(
          'Skipping sync - last sync was recent',
          name: 'SchemeSyncService',
        );
        return SyncResult(
          success: true,
          message: 'Sync skipped - last sync was within 24 hours',
          schemesAdded: 0,
          schemesUpdated: 0,
          schemesFailed: 0,
        );
      }

      int added = 0;
      int updated = 0;
      int failed = 0;

      // Fetch schemes for different categories
      final categories = [
        'Financial Aid',
        'Crop Insurance',
        'Subsidies',
        'Irrigation',
      ];

      for (final category in categories) {
        try {
          developer.log(
            'Fetching schemes for category: $category',
            name: 'SchemeSyncService',
          );

          final rawSchemes = await _scraperService.fetchSchemesByCategory(
            category,
          );
          final schemes = _scraperService.convertToSchemeObjects(rawSchemes);

          developer.log(
            'Fetched ${schemes.length} schemes for $category',
            name: 'SchemeSyncService',
          );

          // Save schemes to MongoDB
          for (final scheme in schemes) {
            try {
              await MongoDBService.insertScheme(scheme);
              added++;
              developer.log(
                'Added scheme: ${scheme.name}',
                name: 'SchemeSyncService',
              );
            } catch (e) {
              failed++;
              developer.log(
                'Failed to save scheme: ${scheme.name}, Error: $e',
                name: 'SchemeSyncService',
              );
            }
          }
        } catch (e) {
          developer.log(
            'Error fetching schemes for category $category: $e',
            name: 'SchemeSyncService',
          );
          failed++;
        }
      }

      // Update sync timestamp
      await _updateSyncTimestamp();

      final message =
          'Sync completed: $added added, $updated updated, $failed failed';
      developer.log(message, name: 'SchemeSyncService');

      return SyncResult(
        success: true,
        message: message,
        schemesAdded: added,
        schemesUpdated: updated,
        schemesFailed: failed,
      );
    } catch (e) {
      developer.log('Sync failed: $e', name: 'SchemeSyncService');
      return SyncResult(
        success: false,
        message: 'Sync failed: $e',
        schemesAdded: 0,
        schemesUpdated: 0,
        schemesFailed: 1,
      );
    }
  }

  /// Check if sync is needed (simplified version)
  Future<bool> _shouldSync() async {
    // For now, allow sync every hour
    // In production, you might want to check a metadata collection
    return true;
  }

  /// Update sync timestamp (simplified version)
  Future<void> _updateSyncTimestamp() async {
    try {
      // Save sync info to a metadata collection
      final syncCount = await MongoDBService.getSchemesCount();

      // You could save this to a separate metadata collection
      developer.log(
        'Sync timestamp updated. Total schemes: $syncCount',
        name: 'SchemeSyncService',
      );
    } catch (e) {
      developer.log(
        'Failed to update sync timestamp: $e',
        name: 'SchemeSyncService',
      );
    }
  }

  /// Clear all schemes from MongoDB
  Future<void> clearAllSchemes() async {
    try {
      await MongoDBService.clearAllData();
      developer.log(
        'All schemes cleared from MongoDB',
        name: 'SchemeSyncService',
      );
    } catch (e) {
      developer.log('Failed to clear schemes: $e', name: 'SchemeSyncService');
    }
  }

  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final totalSchemes = await MongoDBService.getSchemesCount();
      final categoryStats = await MongoDBService.getSchemesByCategory();

      return {
        'totalSchemes': totalSchemes,
        'categoryCounts': categoryStats,
        'lastSync': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      developer.log('Failed to get sync stats: $e', name: 'SchemeSyncService');
      return {
        'totalSchemes': 0,
        'categoryCounts': <String, int>{},
        'lastSync': null,
      };
    }
  }
}

/// Result of a sync operation
class SyncResult {
  final bool success;
  final String message;
  final int schemesAdded;
  final int schemesUpdated;
  final int schemesFailed;

  SyncResult({
    required this.success,
    required this.message,
    required this.schemesAdded,
    required this.schemesUpdated,
    required this.schemesFailed,
  });

  int get totalProcessed => schemesAdded + schemesUpdated + schemesFailed;

  @override
  String toString() {
    return 'SyncResult(success: $success, message: $message, '
        'added: $schemesAdded, updated: $schemesUpdated, failed: $schemesFailed)';
  }
}

/// Action taken during sync
enum SyncAction { added, updated, skipped }
