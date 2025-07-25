// lib/src/data/api/test_api.dart

import 'dart:math';
import 'package:quick_dot_test/src/core/utils/test_id.dart';

/// Simulates API calls to a remote server for test-related data.
class TestApi {
  // --- MOCK DATABASE ---
  // This data would live on your server.

  static final _testData = {
    'id': {'value': 'T123'},
    'testName': 'Flutter Basics Quiz',
    'durationInMinutes': 10,
    'totalMarks': 50,
  };

  static final _questionsData = [
    {
      'questionText': 'What is the main programming language used for Flutter development?',
      'options': ['Kotlin', 'Swift', 'Dart', 'Java'],
      'correctOptionIndex': 2,
    },
    {
      'questionText': 'Which widget is the base for creating custom layouts?',
      'options': ['Container', 'Scaffold', 'StatelessWidget', 'CustomPaint'],
      'correctOptionIndex': 3,
    },
    {
      'questionText': 'How do you manage state in a simple Flutter app?',
      'options': ['setState', 'Provider', 'Bloc', 'Riverpod'],
      'correctOptionIndex': 0,
    },
  ];

  static final _submissionsData = [
    {
      'userId': 'U001',
      'testId': {'value': 'T123'},
      'answers': {'0': 2, '1': 1, '2': 0}, // User U001 answers
      'marksObtained': 33, // Assuming some marking logic
    },
    {
      'userId': 'U002',
      'testId': {'value': 'T123'},
      'answers': {'0': 2, '1': 3, '2': 0}, // User U002 answers
      'marksObtained': 50,
    },
  ];

  // --- MOCK API ENDPOINTS ---

  Future<Map<String, dynamic>> fetchParticipationDetails({
    required TestID testID,
    required String userID,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network latency

    final submission = _submissionsData.firstWhere((s) => s['userId'] == userID);

    return {
      'testName': _testData['testName'],
      'marksObtained': submission['marksObtained'],
      'totalMarks': _testData['totalMarks'],
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> fetchCreationDetails({required TestID testID}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final submissionsForTest = _submissionsData.where((s) => (s['testId'] as Map)['value'] == testID.value);
    final totalMarks = submissionsForTest.fold<int>(0, (sum, s) => sum + (s['marksObtained'] as int));
    final averageScore = submissionsForTest.isEmpty ? 0 : totalMarks / submissionsForTest.length;

    return {
      'testName': _testData['testName'],
      'numberOfParticipants': submissionsForTest.length,
      'averageScore': averageScore,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> fetchJoinedTestDetail({
    required TestID testID,
    required String userID,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final submission = _submissionsData.firstWhere((s) => s['userId'] == userID);

    return {
      'questions': _questionsData.map((q) => {...q}..remove('correctOptionIndex')).toList(), // Remove correct answer for student
      'testName': _testData['testName'],
      'marksObtained': submission['marksObtained'],
      'totalMarks': _testData['totalMarks'],
      'timestamp': DateTime.now().toIso8601String(),
      'optionsSelectedByUser': submission['answers'],
    };
  }

  Future<Map<String, dynamic>> fetchCreatedTestDetail({required TestID testID}) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final participants = _submissionsData
        .map((s) => {
              'userID': s['userId'],
              'marksObtained': s['marksObtained'],
            })
        .toList();

    return {
      'questions': _questionsData, // Creator gets correct answers
      'testName': _testData['testName'],
      'totalMarks': _testData['totalMarks'],
      'timestamp': DateTime.now().toIso8601String(),
      'participants': participants,
    };
  }
}