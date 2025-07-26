import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_dot_test/src/core/utils/test_id.dart';
import 'package:quick_dot_test/src/logic/test_session_manager.dart';

/// Enum to represent the initial status of the test session.
enum TestEligibility {
  eligible,
  alreadyJoined,
  expired,
}

class LiveTestController extends ChangeNotifier {
  final TestID testId;
  final Duration duration;
  final Timestamp testTimestamp;
  final bool hasUserAlreadyJoined;

  LiveTestController({
    required this.testId,
    required this.duration,
    required this.testTimestamp,
    required this.hasUserAlreadyJoined, 
  });

  Timer? _timer;
  late Duration _remainingTime;
  bool _isSubmitting = false;
  final Map<int, int> _selectedAnswers = {};

  // --- Getters for UI to consume ---
  Duration get remainingTime => _remainingTime;
  bool get isSubmitting => _isSubmitting;
  Map<int, int> get selectedAnswers => _selectedAnswers;

  /// Performs initial checks and starts the timer if eligible.
  TestEligibility initializeTest() {
    if (hasUserAlreadyJoined) {
      return TestEligibility.alreadyJoined;
    }

    final expirationTime = testTimestamp.toDate().add(duration);
    final now = DateTime.now();

    if (now.isAfter(expirationTime)) {
      return TestEligibility.expired;
    }

    _remainingTime = expirationTime.difference(now);
    _startTimer();
    return TestEligibility.eligible;
  }

  void _startTimer() {
    // Ensure no existing timer is running.
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds <= 0) {
        timer.cancel();
        // The UI layer will be responsible for calling submitTest.
        // We just notify it that time is up.
      } else {
        _remainingTime -= const Duration(seconds: 1);
      }
      notifyListeners();
    });
  }

  /// Updates the selected answer for a given question.
  void selectAnswer(int questionIndex, int optionIndex) {
    _selectedAnswers[questionIndex] = optionIndex;
    notifyListeners();
  }

  /// Handles the submission logic. Returns true on success, false on failure.
  Future<bool> submitTest() async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _timer?.cancel();
    notifyListeners();

    try {
      await TestSessionManager.instance.submitTest(
        testId: testId,
        answers: _selectedAnswers,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      // If submission fails, resume the timer if there's time left.
      if (_remainingTime.inSeconds > 0) {
        _startTimer();
      }
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}