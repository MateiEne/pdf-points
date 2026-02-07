import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pdf_points/data/lift_info.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized service for managing lift points across the application.
/// 
/// This service:
/// - Listens to Firebase for real-time lift points updates
/// - Caches data in SharedPreferences for offline access
/// - Provides a single source of truth for lift points
/// - Notifies listeners when data changes (via ChangeNotifier)
class LiftPointsService extends ChangeNotifier {
  // Singleton instance
  static final LiftPointsService _instance = LiftPointsService._internal();
  factory LiftPointsService() => _instance;
  LiftPointsService._internal();

  // State
  final Map<String, LiftInfo> _liftInfoMap = {};
  StreamSubscription<List<LiftInfo>>? _firebaseSubscription;
  bool _isInitialized = false;
  bool _isLoading = false;

  // Cache keys for SharedPreferences
  static const String _cacheKey = 'lift_points_cache';
  static const String _cacheTimestampKey = 'lift_points_cache_timestamp';

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  Map<String, LiftInfo> get allLifts => Map.unmodifiable(_liftInfoMap);

  /// Initialize the service - load from cache then listen to Firebase
  /// This should be called once at app startup
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Load from cache first (for instant access)
      await _loadFromCache();

      // 2. Start listening to Firebase (for real-time updates)
      _listenToFirebase();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing LiftPointsService: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get points for a specific lift by name
  /// Returns null if the lift is not found
  int? getLiftPoints(String liftName) {
    return _liftInfoMap[liftName]?.points;
  }

  /// Get full LiftInfo for a specific lift by name
  /// Returns null if the lift is not found
  LiftInfo? getLiftInfo(String liftName) {
    return _liftInfoMap[liftName];
  }

  /// Calculate total points for a list of lift names
  /// Ignores lifts that are not found
  int calculateTotalPoints(List<String> liftNames) {
    return liftNames.fold(0, (sum, name) => sum + (getLiftPoints(name) ?? 0));
  }

  /// Check if a lift exists in the cache
  bool hasLift(String liftName) {
    return _liftInfoMap.containsKey(liftName);
  }

  // Private methods

  /// Start listening to Firebase for real-time updates
  void _listenToFirebase() {
    _firebaseSubscription = FirebaseManager.instance
        .listenToAllLiftsInfo()
        .listen(_handleFirebaseUpdate, onError: _handleFirebaseError);
  }

  /// Handle updates from Firebase
  void _handleFirebaseUpdate(List<LiftInfo> lifts) {
    bool hasChanges = false;

    for (var lift in lifts) {
      final existing = _liftInfoMap[lift.name];
      // Only update if the lift is new or points have changed
      if (existing == null || existing.points != lift.points || existing.modifiedAt != lift.modifiedAt) {
        _liftInfoMap[lift.name] = lift;
        hasChanges = true;
      }
    }

    if (hasChanges) {
      _saveToCache(); // Save asynchronously (fire and forget)
      notifyListeners(); // Notify all listeners of the change
    }
  }

  /// Handle errors from Firebase stream
  void _handleFirebaseError(error) {
    debugPrint('Firebase stream error in LiftPointsService: $error');
    // Continue using cached data - don't crash the app
  }

  /// Load lift points from SharedPreferences cache
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);

      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        for (var json in decoded) {
          final lift = LiftInfo.fromJson(json);
          _liftInfoMap[lift.name] = lift;
        }
        debugPrint('Loaded ${_liftInfoMap.length} lifts from cache');
      }
    } catch (e) {
      debugPrint('Error loading lift points from cache: $e');
    }
  }

  /// Save lift points to SharedPreferences cache
  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _liftInfoMap.values.map((l) => l.toJson()).toList();
      await prefs.setString(_cacheKey, jsonEncode(list));
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
      debugPrint('Saved ${_liftInfoMap.length} lifts to cache');
    } catch (e) {
      debugPrint('Error saving lift points to cache: $e');
    }
  }

  /// Clear the cache - useful for testing or logout
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimestampKey);
      _liftInfoMap.clear();
      notifyListeners();
      debugPrint('Cleared lift points cache');
    } catch (e) {
      debugPrint('Error clearing lift points cache: $e');
    }
  }

  @override
  void dispose() {
    _firebaseSubscription?.cancel();
    super.dispose();
  }
}
