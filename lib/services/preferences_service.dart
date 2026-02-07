import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf_points/data/lift_user.dart';

class PreferencesService {
  static const String _keyDefaultLift = 'default_lift';
  static const String _keyDefaultLiftType = 'default_lift_type';
  static const String _keySelectedLiftUsers = 'selected_lift_users';
  static const String _keyUnselectedLiftUsers = 'unselected_lift_users';

  static PreferencesService? _instance;
  static SharedPreferences? _prefs;

  PreferencesService._();

  static Future<PreferencesService> getInstance() async {
    if (_instance == null) {
      _instance = PreferencesService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // Save default lift
  Future<void> saveDefaultLift(String lift) async {
    await _prefs?.setString(_keyDefaultLift, lift);
  }

  // Load default lift
  String? getDefaultLift() {
    return _prefs?.getString(_keyDefaultLift);
  }

  // Save default lift type
  Future<void> saveDefaultLiftType(String liftType) async {
    await _prefs?.setString(_keyDefaultLiftType, liftType);
  }

  // Load default lift type
  String? getDefaultLiftType() {
    return _prefs?.getString(_keyDefaultLiftType);
  }

  // Save selected lift users (only their IDs)
  Future<void> saveSelectedLiftUsers(List<LiftUser> users) async {
    final ids = users.map((user) => user.id).toList();
    await _prefs?.setString(_keySelectedLiftUsers, jsonEncode(ids));
  }

  // Load selected lift users IDs
  List<String> getSelectedLiftUserIds() {
    final jsonString = _prefs?.getString(_keySelectedLiftUsers);
    if (jsonString == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  // Save unselected lift users (only their IDs)
  Future<void> saveUnselectedLiftUsers(List<LiftUser> users) async {
    final ids = users.map((user) => user.id).toList();
    await _prefs?.setString(_keyUnselectedLiftUsers, jsonEncode(ids));
  }

  // Load unselected lift users IDs
  List<String> getUnselectedLiftUserIds() {
    final jsonString = _prefs?.getString(_keyUnselectedLiftUsers);
    if (jsonString == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  // Clear all lift-related preferences
  Future<void> clearLiftPreferences() async {
    await _prefs?.remove(_keyDefaultLift);
    await _prefs?.remove(_keyDefaultLiftType);
    await _prefs?.remove(_keySelectedLiftUsers);
    await _prefs?.remove(_keyUnselectedLiftUsers);
  }
}