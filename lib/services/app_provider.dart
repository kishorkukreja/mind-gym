import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/challenge_model.dart';
import 'storage_service.dart';
import 'schedule_service.dart';
import 'openrouter_service.dart';
import 'challenge_library.dart';

class AppProvider extends ChangeNotifier {
  static const _uuid = Uuid();

  UserModel? _currentUser;
  List<UserChallenge> _weekChallenges = [];
  bool _isLoading = false;
  String? _error;
  bool _isDebating = false;

  UserModel? get currentUser => _currentUser;
  List<UserChallenge> get weekChallenges => _weekChallenges;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isDebating => _isDebating;

  Future<void> init() async {
    await StorageService.init();
    final user = StorageService.getCurrentUser();
    if (user != null) {
      _currentUser = user;
      await _loadWeekChallenges();
    }
  }

  // ===== AUTH =====
  Future<bool> login(String username, String pin) async {
    _setLoading(true);
    _error = null;
    final user = StorageService.getUserByUsername(username);
    if (user == null) {
      _error = 'Username not found';
      _setLoading(false);
      return false;
    }
    if (user.pinHash != StorageService.hashPin(pin)) {
      _error = 'Incorrect PIN';
      _setLoading(false);
      return false;
    }
    await StorageService.setCurrentUser(user.id);
    _currentUser = user;
    await _loadWeekChallenges();
    _error = null;
    _setLoading(false);
    return true;
  }

  Future<String?> register(String username, String pin, {String? apiKey}) async {
    _setLoading(true);
    if (username.trim().isEmpty) {
      _setLoading(false);
      return 'Username cannot be empty';
    }
    if (pin.length < 4) {
      _setLoading(false);
      return 'PIN must be at least 4 digits';
    }
    if (StorageService.usernameExists(username)) {
      _setLoading(false);
      return 'Username already taken';
    }
    final user = UserModel(
      id: _uuid.v4(),
      username: username.trim(),
      pinHash: StorageService.hashPin(pin),
      openRouterApiKey: apiKey,
    );
    await StorageService.saveUser(user);
    await StorageService.setCurrentUser(user.id);
    _currentUser = user;
    await _loadWeekChallenges();
    _error = null;
    _setLoading(false);
    return null;
  }

  Future<void> logout() async {
    await StorageService.clearCurrentUser();
    _currentUser = null;
    _weekChallenges = [];
    notifyListeners();
  }

  // ===== CHALLENGES =====
  Future<void> _loadWeekChallenges() async {
    if (_currentUser == null) return;
    await ScheduleService.processExpiredChallenges(_currentUser!);
    _weekChallenges = ScheduleService.getThisWeekChallenges(_currentUser!);
    notifyListeners();
  }

  Future<void> refreshChallenges() async {
    await _loadWeekChallenges();
  }

  UserChallenge? getChallenge(String ucId) {
    try {
      return _weekChallenges.firstWhere((uc) => uc.id == ucId);
    } catch (_) {
      final allUc = StorageService.getUserChallenges(_currentUser!.id);
      try {
        return allUc.firstWhere((uc) => uc.id == ucId);
      } catch (_) {
        return null;
      }
    }
  }

  Future<void> openChallenge(String ucId) async {
    final uc = getChallenge(ucId);
    if (uc == null || _currentUser == null) return;
    if (uc.status == ChallengeStatus.pending || uc.status == ChallengeStatus.open) {
      uc.status = ChallengeStatus.inProgress;
      uc.openedAt = DateTime.now();
      await StorageService.saveUserChallenge(uc);
      notifyListeners();
    }
  }

  /// Send a message in the Socratic debate
  Future<String> sendDebateMessage(String ucId, String userMessage) async {
    final uc = getChallenge(ucId);
    if (uc == null || _currentUser == null) return 'Challenge not found';
    if (_currentUser!.openRouterApiKey == null ||
        _currentUser!.openRouterApiKey!.isEmpty) {
      return '⚠️ No API key set. Please add your OpenRouter key in Settings.';
    }

    // Add user message
    uc.conversation.add(ChallengeMessage(
      role: 'user',
      content: userMessage,
      timestamp: DateTime.now(),
    ));
    uc.responseCount++;
    uc.status = ChallengeStatus.inProgress;
    await StorageService.saveUserChallenge(uc);
    notifyListeners();

    _isDebating = true;
    notifyListeners();

    final challenge = ChallengeLibrary.getById(uc.challengeId);
    if (challenge == null) {
      _isDebating = false;
      notifyListeners();
      return '⚠️ Challenge definition not found.';
    }

    final aiResponse = await OpenRouterService.getSocraticResponse(
      apiKey: _currentUser!.openRouterApiKey!,
      challenge: challenge,
      conversation: uc.conversation,
      hintsUsed: uc.hintsUsed,
      userLevel: _currentUser!.level,
    );

    uc.conversation.add(ChallengeMessage(
      role: 'assistant',
      content: aiResponse,
      timestamp: DateTime.now(),
    ));
    await StorageService.saveUserChallenge(uc);

    _isDebating = false;
    notifyListeners();
    return aiResponse;
  }

  Future<String> requestHint(String ucId) async {
    final uc = getChallenge(ucId);
    if (uc == null) return 'Challenge not found';
    final challenge = ChallengeLibrary.getById(uc.challengeId);
    if (challenge == null) return 'Challenge definition not found';

    if (uc.hintsUsed >= challenge.hintTiers.length) {
      return '💡 No more hints available. You have all the clues you need — now THINK.';
    }

    final hintMessage =
        '💡 Hint ${uc.hintsUsed + 1} of ${challenge.hintTiers.length}:\n\n${challenge.hintTiers[uc.hintsUsed]}';
    uc.hintsUsed++;
    uc.conversation.add(ChallengeMessage(
      role: 'assistant',
      content: hintMessage,
      timestamp: DateTime.now(),
    ));
    await StorageService.saveUserChallenge(uc);
    notifyListeners();
    return hintMessage;
  }

  Future<CompletionSummary?> markChallengeComplete(String ucId) async {
    final uc = getChallenge(ucId);
    if (uc == null || _currentUser == null) return null;

    final challenge = ChallengeLibrary.getById(uc.challengeId);
    final xpBreakdown = ScheduleService.calculateXpBreakdown(
      hintsUsed: uc.hintsUsed,
      responseCount: uc.responseCount,
      difficulty: challenge?.difficulty ?? 3,
      onTime: DateTime.now()
          .isBefore(uc.scheduledFor.add(const Duration(days: 2))),
    );
    final xp = xpBreakdown.totalXp;
    final summary = CompletionSummary(
      totalXp: xp,
      factors: xpBreakdown.factors,
      feedback: _completionFeedback(uc, challenge),
      nextStep: _completionNextStep(uc, challenge),
    );

    uc.status = ChallengeStatus.completed;
    uc.completedAt = DateTime.now();
    uc.xpEarned = xp;
    uc.completionSummary = summary;

    _currentUser!.xp += xp;
    _currentUser!.totalChallengesCompleted++;

    // Streak logic
    final now = DateTime.now();
    final lastActive = _currentUser!.lastActiveDate;
    if (lastActive != null) {
      final diff = now.difference(lastActive).inDays;
      if (diff <= 1) {
        _currentUser!.currentStreak++;
      } else {
        _currentUser!.currentStreak = 1;
      }
    } else {
      _currentUser!.currentStreak = 1;
    }
    _currentUser!.lastActiveDate = now;

    if (_currentUser!.currentStreak > _currentUser!.bestStreak) {
      _currentUser!.bestStreak = _currentUser!.currentStreak;
    }

    // Level up
    while (_currentUser!.xp >= (_currentUser!.level * 150)) {
      _currentUser!.level++;
    }

    _currentUser!.completedChallengeIds.add(ucId);

    await StorageService.saveUserChallenge(uc);
    await StorageService.saveUser(_currentUser!);
    notifyListeners();
    return summary;
  }

  String _completionFeedback(UserChallenge uc, Challenge? challenge) {
    if (uc.hintsUsed == 0 && uc.responseCount >= 4) {
      return 'You stayed with the problem and built your answer without leaning on hints.';
    }
    if (uc.responseCount >= 4) {
      return 'You gave the debate enough material to test your reasoning from multiple angles.';
    }
    if (challenge?.type == ChallengeType.cognitiveBias) {
      return 'You identified the bias pattern and completed the debate with enough engagement to score.';
    }
    return 'You formed a position and defended it through the minimum debate loop.';
  }

  String _completionNextStep(UserChallenge uc, Challenge? challenge) {
    if (uc.hintsUsed > 0) {
      return 'Next time, pause before using a hint and write one concrete counterexample first.';
    }
    if (uc.responseCount < 4) {
      return 'Next time, add one more response that directly answers the strongest objection.';
    }
    final category = challenge?.category;
    if (category != null && category.isNotEmpty) {
      return 'Carry this into your next $category challenge: name the tradeoff before defending your answer.';
    }
    return 'For the next challenge, state your best objection before you settle on an answer.';
  }

  // ===== SETTINGS =====
  Future<void> updateApiKey(String apiKey) async {
    if (_currentUser == null) return;
    _currentUser!.openRouterApiKey = apiKey;
    await StorageService.saveUser(_currentUser!);
    notifyListeners();
  }

  Future<void> updateSchedule({
    required int weekdayHour,
    required int weekendHour,
    required int weekdayChallengeDay,
    required int weekendChallengeDay,
  }) async {
    if (_currentUser == null) return;
    _currentUser!.weekdayHour = weekdayHour;
    _currentUser!.weekendHour = weekendHour;
    _currentUser!.weekdayChallengeDay = weekdayChallengeDay;
    _currentUser!.weekendChallengeDay = weekendChallengeDay;
    await StorageService.saveUser(_currentUser!);
    notifyListeners();
  }

  Map<String, dynamic> getWeeklyPerformance() {
    if (_currentUser == null) return {};
    return ScheduleService.getWeeklyPerformance(_currentUser!);
  }

  Duration? getCountdownToNextChallenge() {
    return ScheduleService.getCountdownToNextChallenge(_weekChallenges);
  }

  List<UserChallenge> getAllUserChallenges() {
    if (_currentUser == null) return [];
    return StorageService.getUserChallenges(_currentUser!.id);
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  List<UserModel> getAllUsers() => StorageService.getAllUsers();
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
