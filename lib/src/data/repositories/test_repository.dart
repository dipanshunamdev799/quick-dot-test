import 'package:quick_dot_test/src/core/utils/test_id.dart';
import 'package:quick_dot_test/src/data/datasources/test_api.dart';
import 'package:quick_dot_test/src/data/models/question_model.dart';

// -- DATA MODELS (Unchanged) --

/// A model representing a summary of a user's participation in a test.
class ParticipationDetails {
  final String testName;
  final int marksObtained;
  final int totalMarks;
  final DateTime timestamp;

  ParticipationDetails({
    required this.testName,
    required this.marksObtained,
    required this.totalMarks,
    required this.timestamp,
  });

  factory ParticipationDetails.fromJson(Map<String, dynamic> json) {
    return ParticipationDetails(
      testName: json['testName'] as String,
      marksObtained: json['marksObtained'] as int,
      totalMarks: json['totalMarks'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// A model representing aggregated details for a test creator's dashboard.
class CreationDetails {
  final String testName;
  final int numberOfParticipants;
  final double averageScore;
  final DateTime timestamp;

  CreationDetails({
    required this.testName,
    required this.numberOfParticipants,
    required this.averageScore,
    required this.timestamp,
  });

  factory CreationDetails.fromJson(Map<String, dynamic> json) {
    return CreationDetails(
      testName: json['testName'] as String,
      numberOfParticipants: json['numberOfParticipants'] as int,
      averageScore: json['averageScore'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// A model representing a participant's score.
class ParticipantScore {
  final String userId;
  final int marksObtained;

  ParticipantScore({required this.userId, required this.marksObtained});

  factory ParticipantScore.fromJson(Map<String, dynamic> json) {
    return ParticipantScore(
      userId: json['userId'] as String,
      marksObtained: json['marksObtained'] as int,
    );
  }
}

/// A model for the detailed results of a test a user has completed.
class JoinedTestDetail {
  final List<Question> questions;
  final String testName;
  final int marksObtained;
  final int totalMarks;
  final DateTime timestamp;
  final Map<int, int> optionsSelectedByUser;

  JoinedTestDetail({
    required this.questions,
    required this.testName,
    required this.marksObtained,
    required this.totalMarks,
    required this.timestamp,
    required this.optionsSelectedByUser,
  });

  factory JoinedTestDetail.fromJson(Map<String, dynamic> json) {
    final questions = (json['questions'] as List)
        .map((qJson) => Question.fromJson(qJson as Map<String, dynamic>))
        .toList();

    final answers = (json['optionsSelectedByUser'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(int.parse(key), value as int),
    );

    return JoinedTestDetail(
      questions: questions,
      testName: json['testName'] as String,
      marksObtained: json['marksObtained'] as int,
      totalMarks: json['totalMarks'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      optionsSelectedByUser: answers,
    );
  }
}

/// A model for the detailed results of a created test for its creator.
class CreatedTestDetail {
  final List<Question> questions;
  final String testName;
  final int totalMarks;
  final DateTime timestamp;
  final List<ParticipantScore> participants;

  CreatedTestDetail({
    required this.questions,
    required this.testName,
    required this.totalMarks,
    required this.timestamp,
    required this.participants,
  });

  factory CreatedTestDetail.fromJson(Map<String, dynamic> json) {
    final questions = (json['questions'] as List)
        .map((qJson) => Question.fromJson(qJson as Map<String, dynamic>))
        .toList();

    final participants = (json['participants'] as List)
        .map((pJson) => ParticipantScore.fromJson(pJson as Map<String, dynamic>))
        .toList();

    return CreatedTestDetail(
      questions: questions,
      testName: json['testName'] as String,
      totalMarks: json['totalMarks'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      participants: participants,
    );
  }
}


// -- REPOSITORY INTERFACE (Unchanged) --

abstract class ITestRepository {
  Future<ParticipationDetails> getParticipationDetails({
    required TestID testId,
    required String userId,
  });

  Future<CreationDetails> getCreationDetails({
    required TestID testId,
  });

  Future<JoinedTestDetail> getJoinedTestDetail({
    required TestID testId,
    required String userId,
  });

  Future<CreatedTestDetail> getCreatedTestDetail({
    required TestID testId,
  });
}


// -- SINGLETON REPOSITORY IMPLEMENTATION --

/// A repository to handle test-related data operations, implemented as a singleton.
class TestRepository implements ITestRepository {
  final TestApiDataSource _testApi;

  // 1. Private constructor
  TestRepository._() : _testApi = TestApiDataSource();

  // 2. Static private instance
  static final TestRepository _instance = TestRepository._();

  // 3. Static public accessor
  static TestRepository get instance => _instance;

  @override
  Future<ParticipationDetails> getParticipationDetails({
    required TestID testId,
    required String userId,
  }) async {
    try {
      final json = await _testApi.getParticipationDetails(testId: testId, userId: userId);
      return ParticipationDetails.fromJson(json);
    } catch (e) {
      print('Error fetching participation details: $e');
      rethrow;
    }
  }

  @override
  Future<CreationDetails> getCreationDetails({
    required TestID testId,
  }) async {
    try {
      final json = await _testApi.getCreationDetails(testId: testId);
      return CreationDetails.fromJson(json);
    } catch (e) {
      print('Error fetching creation details: $e');
      rethrow;
    }
  }

  @override
  Future<JoinedTestDetail> getJoinedTestDetail({
    required TestID testId,
    required String userId,
  }) async {
    try {
      final json = await _testApi.getJoinedTestDetail(testId: testId, userId: userId);
      return JoinedTestDetail.fromJson(json);
    } catch (e) {
      print('Error fetching joined test detail: $e');
      rethrow;
    }
  }

  @override
  Future<CreatedTestDetail> getCreatedTestDetail({
    required TestID testId,
  }) async {
    try {
      final json = await _testApi.getCreatedTestDetail(testId: testId);
      return CreatedTestDetail.fromJson(json);
    } catch (e) {
      print('Error fetching created test detail: $e');
      rethrow;
    }
  }
}