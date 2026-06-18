import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/challenge_model.dart';

class StorageService {
  static const String _usersKey = 'mg_users';
  static const String _currentUserKey = 'mg_current_user';
  static const String _challengesKey = 'mg_challenges';
  static const String _weeklyAssignmentsKey = 'mg_weekly_assignments';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) throw Exception('StorageService not initialized');
    return _prefs!;
  }

  // ===== PIN HASHING =====
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  // ===== USER MANAGEMENT =====
  static List<UserModel> getAllUsers() {
    final raw = prefs.getString(_usersKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((u) => UserModel.fromJson(u as Map<String, dynamic>)).toList();
  }

  static Future<void> saveUser(UserModel user) async {
    final users = getAllUsers();
    final idx = users.indexWhere((u) => u.id == user.id);
    if (idx >= 0) {
      users[idx] = user;
    } else {
      users.add(user);
    }
    await prefs.setString(_usersKey, jsonEncode(users.map((u) => u.toJson()).toList()));
  }

  static Future<void> deleteUser(String userId) async {
    final users = getAllUsers();
    users.removeWhere((u) => u.id == userId);
    await prefs.setString(_usersKey, jsonEncode(users.map((u) => u.toJson()).toList()));
  }

  static UserModel? getUserByUsername(String username) {
    final users = getAllUsers();
    try {
      return users.firstWhere(
          (u) => u.username.toLowerCase() == username.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  static bool usernameExists(String username) {
    return getUserByUsername(username) != null;
  }

  static String? getCurrentUserId() {
    return prefs.getString(_currentUserKey);
  }

  static Future<void> setCurrentUser(String userId) async {
    await prefs.setString(_currentUserKey, userId);
  }

  static Future<void> clearCurrentUser() async {
    await prefs.remove(_currentUserKey);
  }

  static UserModel? getCurrentUser() {
    final id = getCurrentUserId();
    if (id == null) return null;
    final users = getAllUsers();
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  // ===== USER CHALLENGES =====
  static List<UserChallenge> getUserChallenges(String userId) {
    final raw = prefs.getString('${_challengesKey}_$userId');
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((c) => UserChallenge.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveUserChallenge(UserChallenge uc) async {
    final challenges = getUserChallenges(uc.userId);
    final idx = challenges.indexWhere((c) => c.id == uc.id);
    if (idx >= 0) {
      challenges[idx] = uc;
    } else {
      challenges.add(uc);
    }
    await prefs.setString(
      '${_challengesKey}_${uc.userId}',
      jsonEncode(challenges.map((c) => c.toJson()).toList()),
    );
  }

  static Future<void> saveAllUserChallenges(
      String userId, List<UserChallenge> challenges) async {
    await prefs.setString(
      '${_challengesKey}_$userId',
      jsonEncode(challenges.map((c) => c.toJson()).toList()),
    );
  }

  // ===== WEEKLY ASSIGNMENTS =====
  static Map<String, dynamic> getWeeklyAssignments(String userId) {
    final raw = prefs.getString('${_weeklyAssignmentsKey}_$userId');
    if (raw == null) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> saveWeeklyAssignments(
      String userId, Map<String, dynamic> data) async {
    await prefs.setString('${_weeklyAssignmentsKey}_$userId', jsonEncode(data));
  }

  // ===== API KEY =====
  static Future<void> saveApiKey(String userId, String apiKey) async {
    final users = getAllUsers();
    final idx = users.indexWhere((u) => u.id == userId);
    if (idx >= 0) {
      users[idx].openRouterApiKey = apiKey;
      await prefs.setString(
          _usersKey, jsonEncode(users.map((u) => u.toJson()).toList()));
    }
  }
}
