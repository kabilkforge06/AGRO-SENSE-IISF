import 'dart:developer' as developer;
import '../models/government_scheme.dart';
import 'scheme_data_expander.dart';
import 'scheme_sync_service.dart';
import 'mongodb_service.dart';

/// Service for managing government schemes using MongoDB
class SchemeService {
  final SchemeSyncService _syncService = SchemeSyncService();

  /// Get all active schemes (from MongoDB with fallback)
  Future<List<GovernmentScheme>> getActiveSchemes() async {
    try {
      final schemes = await MongoDBService.getSchemes();

      if (schemes.isEmpty) {
        // Fallback to hardcoded schemes if MongoDB is empty
        developer.log(
          '⚠️ WARNING: No schemes in MongoDB! Using fallback data.',
          name: 'SchemeService',
        );
        developer.log(
          'Please use Scheme Sync Admin to populate real-time schemes',
          name: 'SchemeService',
        );
        return SchemeDataExpander.getAllSchemesAsObjects();
      }

      developer.log(
        '✅ Loaded ${schemes.length} schemes from MongoDB',
        name: 'SchemeService',
      );
      return schemes;
    } catch (e) {
      developer.log('Error getting active schemes: $e', name: 'SchemeService');
      return SchemeDataExpander.getAllSchemesAsObjects();
    }
  }

  /// Get schemes by category
  Future<List<GovernmentScheme>> getSchemesByCategory(String category) async {
    try {
      return await MongoDBService.getSchemes(category: category);
    } catch (e) {
      developer.log(
        'Error getting schemes by category: $e',
        name: 'SchemeService',
      );
      return [];
    }
  }

  /// Get schemes by state
  Future<List<GovernmentScheme>> getSchemesByState(String state) async {
    try {
      return await MongoDBService.getSchemes(state: state);
    } catch (e) {
      developer.log(
        'Error getting schemes by state: $e',
        name: 'SchemeService',
      );
      return [];
    }
  }

  /// Get expiring schemes (schemes expiring within 30 days)
  Future<List<GovernmentScheme>> getExpiringSchemes() async {
    try {
      final allSchemes = await MongoDBService.getSchemes();
      final now = DateTime.now();
      final thirtyDaysLater = now.add(const Duration(days: 30));

      return allSchemes.where((scheme) {
        if (scheme.expiryDate == null) return false;
        return scheme.expiryDate!.isAfter(now) &&
            scheme.expiryDate!.isBefore(thirtyDaysLater);
      }).toList();
    } catch (e) {
      developer.log(
        'Error getting expiring schemes: $e',
        name: 'SchemeService',
      );
      return [];
    }
  }

  /// Get scheme analytics
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final totalCount = await MongoDBService.getSchemesCount();
      final categoryStats = await MongoDBService.getSchemesByCategory();

      return {
        'totalSchemes': totalCount,
        'categoryCounts': categoryStats,
        'lastSyncTime': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      developer.log('Error getting sync stats: $e', name: 'SchemeService');
      return {
        'totalSchemes': 0,
        'categoryCounts': <String, int>{},
        'lastSyncTime': null,
      };
    }
  }

  /// Get last sync time (mock implementation for MongoDB)
  Future<DateTime?> getLastSyncTime() async {
    // For now, return current time as we don't track sync times in MongoDB yet
    return DateTime.now().subtract(const Duration(hours: 1));
  }

  /// Sync latest schemes from web and save to MongoDB
  Future<SyncResult> syncLatestSchemesFromWeb({
    bool forceUpdate = false,
  }) async {
    try {
      developer.log(
        '🔄 Starting scheme sync to MongoDB...',
        name: 'SchemeService',
      );

      // Use the existing sync service to fetch schemes
      final result = await _syncService.syncAllSchemes(
        forceUpdate: forceUpdate,
      );

      if (result.success && result.schemesAdded > 0) {
        developer.log(
          '✅ Sync completed: ${result.schemesAdded} added, ${result.schemesUpdated} updated',
          name: 'SchemeService',
        );
      }

      return result;
    } catch (e) {
      developer.log('❌ Error syncing schemes: $e', name: 'SchemeService');
      return SyncResult(
        success: false,
        message: 'Sync failed: $e',
        schemesAdded: 0,
        schemesUpdated: 0,
        schemesFailed: 1,
      );
    }
  }

  /// Search schemes
  Future<List<GovernmentScheme>> searchSchemes(String query) async {
    try {
      return await MongoDBService.searchSchemes(query);
    } catch (e) {
      developer.log('Error searching schemes: $e', name: 'SchemeService');
      return [];
    }
  }

  /// Get scheme by ID
  Future<GovernmentScheme?> getSchemeById(String schemeId) async {
    try {
      final schemes = await MongoDBService.getSchemes();
      return schemes.firstWhere(
        (scheme) => scheme.id == schemeId,
        orElse: () => throw StateError('Scheme not found'),
      );
    } catch (e) {
      developer.log('Scheme not found: $schemeId', name: 'SchemeService');
      return null;
    }
  }

  /// Upload sample schemes to MongoDB
  Future<bool> uploadSampleSchemes() async {
    try {
      final sampleSchemes = SchemeDataExpander.getAllSchemesAsObjects();
      await MongoDBService.insertManySchemes(sampleSchemes);
      developer.log(
        '✅ Uploaded ${sampleSchemes.length} sample schemes to MongoDB',
        name: 'SchemeService',
      );
      return true;
    } catch (e) {
      developer.log(
        '❌ Error uploading sample schemes: $e',
        name: 'SchemeService',
      );
      return false;
    }
  }

  // Missing methods from original scheme service for backward compatibility

  /// Get active schemes once (alias for getActiveSchemes)
  Future<List<GovernmentScheme>> getActiveSchemesOnce() async {
    return await getActiveSchemes();
  }

  /// Get all detailed scheme objects (alias for getActiveSchemes)
  Future<List<GovernmentScheme>> getAllDetailedSchemeObjects() async {
    return await getActiveSchemes();
  }

  /// Sync detailed schemes to MongoDB (uses uploadSampleSchemes)
  Future<bool> syncDetailedSchemesToFirestore() async {
    return await uploadSampleSchemes();
  }
}
