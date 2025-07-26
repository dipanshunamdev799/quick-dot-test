import 'package:quick_dot_test/src/core/utils/test_id.dart';

/// A mock API service that simulates network calls for test-related data.
class TestApiDataSource {
  // --- MOCK TEST DATABASE ---
  // A map where the key is a unique identifier for the test (timestamp as string)
  // and the value contains all data related to that test.
  static final Map<String, Map<String, dynamic>> _mockTestDatabase = {
    // Test 1: Data Structures & Algorithms (created by prof_davis on 2025-06-15)
    _getKey(2025, 6, 15): {
      'creationData': {
        'testName': 'Data Structures & Algorithms',
        'numberOfParticipants': 2,
        'averageScore': 35.0, // (30+40)/2
        'timestamp': DateTime(2025, 6, 15).toIso8601String(),
        'totalMarks': 40,
        'questions': [
          {'questionText': 'What is the time complexity of bubble sort?', 'options': ['O(n)', 'O(log n)', 'O(n^2)', 'O(1)'], 'correctOptionIndex': 2,},
          {'questionText': 'Which data structure uses FIFO?', 'options': ['Queue', 'Stack', 'Tree', 'Graph'], 'correctOptionIndex': 0,},
          {'questionText': 'A node in a singly linked list contains a value and a...?', 'options': ['Pointer to previous node', 'Pointer to next node', 'Pointer to the head', 'An array of pointers'], 'correctOptionIndex': 1,},
          {'questionText': 'What is the height of a balanced binary tree with N nodes?', 'options': ['O(N)', 'O(N^2)', 'O(log N)', 'O(1)'], 'correctOptionIndex': 2,},
        ],
        'participants': [
          {'userId': 'iMEJYT1R4sMoria34AtgrJFr4ls2', 'marksObtained': 30},
          {'userId': 'user_456_def', 'marksObtained': 40},
        ]
      },
      'participationData_iMEJYT1R4sMoria34AtgrJFr4ls2': {
        'marksObtained': 30, 'optionsSelectedByUser': {'0': 2, '1': 0, '2': 1, '3': 0}, // 3 correct
      },
      'participationData_user_456_def': {
        'marksObtained': 40, 'optionsSelectedByUser': {'0': 2, '1': 0, '2': 1, '3': 2}, // All 4 correct
      },
    },

    // Test 2: Flutter Widgets Mastery (created by iMEJYT1R4sMoria34AtgrJFr4ls2 on 2025-07-20)
    _getKey(2025, 7, 20): {
      'creationData': {
        'testName': 'Flutter Widgets Mastery',
        'numberOfParticipants': 1, 'averageScore': 30.0,
        'timestamp': DateTime(2025, 7, 20).toIso8601String(),
        'totalMarks': 50,
        'questions': [
            {'questionText': 'Which widget is used for layout with a single child?', 'options': ['Column', 'Row', 'Container', 'ListView'], 'correctOptionIndex': 2},
            {'questionText': 'What command checks for potential issues in your project?', 'options': ['flutter run', 'flutter create', 'flutter doctor', 'flutter build'], 'correctOptionIndex': 2},
            {'questionText': 'What is the entry point for a Dart application?', 'options': ['pubspec.yaml', 'main.dart', 'index.html', 'App.java'], 'correctOptionIndex': 1},
            {'questionText': 'Which is NOT a valid type of test in Flutter?', 'options': ['Unit Test', 'Widget Test', 'Integration Test', 'Component Test'], 'correctOptionIndex': 3},
            {'questionText': 'What does `pubspec.yaml` manage?', 'options': ['UI layout', 'App state', 'Project dependencies and metadata', 'User authentication'], 'correctOptionIndex': 2}
        ],
        'participants': [ {'userId': 'user_456_def', 'marksObtained': 30}, ]
      },
      'participationData_user_456_def': {
        'marksObtained': 30, 'optionsSelectedByUser': {'0': 2, '1': 2, '2': 1, '3': 0, '4': 1}, // 3 correct
      },
    },
    
    // Test 3: Quantum Physics 101 (created by dr_einstein on 2025-05-10)
    _getKey(2025, 5, 10): {
       'creationData': {
        'testName': 'Quantum Physics 101',
        'numberOfParticipants': 1, 'averageScore': 50.0,
        'timestamp': DateTime(2025, 5, 10).toIso8601String(),
        'totalMarks': 100,
        'questions': [
          {'questionText': "What does the Schrödinger equation describe?", 'options': ["The law of gravity", "The evolution of a quantum system", "The speed of light", "Thermodynamics"], 'correctOptionIndex': 1},
          {'questionText': "Heisenberg's Uncertainty Principle involves position and ___.", 'options': ["mass", "charge", "spin", "momentum"], 'correctOptionIndex': 3},
        ],
        'participants': [ {'userId': 'iMEJYT1R4sMoria34AtgrJFr4ls2', 'marksObtained': 50}, ]
      },
      'participationData_iMEJYT1R4sMoria34AtgrJFr4ls2': {
        'marksObtained': 50, 'optionsSelectedByUser': {'0': 1, '1': 0}, // 1 correct
      },
    },

    // Test 4: Welcome Test (created by quickdot_admin on 2025-01-01)
    _getKey(2025, 1, 1): {
      'creationData': { // Minimal creation data needed for questions
        'testName': 'Welcome to QuickDot!',
        'totalMarks': 10,
        'timestamp': DateTime(2025, 1, 1).toIso8601String(),
        'questions': [{'questionText': 'Is this a demo test?', 'options': ['Yes', 'No'], 'correctOptionIndex': 0}],
      },
      'participationData_default': { // A default for any new user
        'marksObtained': 10, 'optionsSelectedByUser': {'0': 0}, // Correct
      },
    }
  };
  // --- END MOCK TEST DATABASE ---

  /// Helper to generate a consistent key string from a date.
  static String _getKey(int year, int month, int day) {
    return DateTime(year, month, day).toIso8601String();
  }

  /// Helper to generate a key from a TestID's timestamp.
  String _getTestKeyFromId(TestID testId) {
    final dt = testId.testTimeStamp.toDate();
    return _getKey(dt.year, dt.month, dt.day);
  }

  Future<Map<String, dynamic>> getParticipationDetails({ required TestID testId, required String userId, }) async {
    print('API: Fetching participation details for test ${testId.toJson()} and user $userId...');
    await Future.delayed(const Duration(milliseconds: 300));
    
    final key = _getTestKeyFromId(testId);
    final testData = _mockTestDatabase[key];
    if (testData == null) return {'error': 'Test not found'};
    
    final creationData = testData['creationData'] as Map<String, dynamic>;
    final participationData = testData['participationData_$userId'] ?? testData['participationData_default'];
    if (participationData == null) return {'error': 'Participation data not found'};

    return {
      'testName': creationData['testName'],
      'marksObtained': participationData['marksObtained'],
      'totalMarks': creationData['totalMarks'],
      'timestamp': creationData['timestamp'],
    };
  }

  Future<Map<String, dynamic>> getCreationDetails({required TestID testId}) async {
    print('API: Fetching creation details for test ${testId.toJson()}...');
    await Future.delayed(const Duration(milliseconds: 400));
    
    final key = _getTestKeyFromId(testId);
    final creationData = _mockTestDatabase[key]?['creationData'];
    if (creationData == null) return {'error': 'Test not found'};

    return {
      'testName': creationData['testName'],
      'numberOfParticipants': creationData['numberOfParticipants'],
      'averageScore': creationData['averageScore'],
      'timestamp': creationData['timestamp'],
    };
  }

  Future<Map<String, dynamic>> getJoinedTestDetail({ required TestID testId, required String userId, }) async {
    print('API: Fetching joined test details for test ${testId.toJson()} and user $userId...');
    await Future.delayed(const Duration(seconds: 1));

    final key = _getTestKeyFromId(testId);
    final testData = _mockTestDatabase[key];
    if (testData == null) return {'error': 'Test not found'};
    
    final creationData = testData['creationData'] as Map<String, dynamic>;
    final participationData = testData['participationData_$userId'] ?? testData['participationData_default'];
    if (participationData == null) return {'error': 'Incomplete test data'};

    return {
      'testName': creationData['testName'],
      'marksObtained': participationData['marksObtained'],
      'totalMarks': creationData['totalMarks'],
      'timestamp': creationData['timestamp'],
      'questions': creationData['questions'],
      'optionsSelectedByUser': participationData['optionsSelectedByUser'],
    };
  }

  Future<Map<String, dynamic>> getCreatedTestDetail({required TestID testId}) async {
    print('API: Fetching created test details for test ${testId.toJson()}...');
    await Future.delayed(const Duration(seconds: 1));

    final key = _getTestKeyFromId(testId);
    final creationData = _mockTestDatabase[key]?['creationData'];
    if (creationData == null) return {'error': 'Test not found'};
    
    return Map<String, dynamic>.from(creationData);
  }
}