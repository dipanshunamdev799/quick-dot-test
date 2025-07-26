import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:quick_dot_test/src/core/utils/test_id.dart';
import 'package:quick_dot_test/src/data/models/user_model.dart';

/// Custom exception for user-not-found errors from the API.
class UserNotFoundException implements Exception {}

/// Abstract interface for the user data source.
/// This defines the contract that any user data source implementation must follow.
abstract class IUserDataSource {
  Future<UserModel> createUser(UserModel user);
  Future<UserModel> getUser(String userId);
  Future<UserModel> updateUser(UserModel user);
  Future<void> deleteUser(String userId);
}

/// Data source implementation that fetches user data from a remote API.
class UserApiDataSource implements IUserDataSource {
  static const String _baseUrl = 'https://your-api-domain.com/api';
  static const String _usersEndpoint = '/users';

  final http.Client _client;

  // --- MOCK USER DATABASE ---
  // A map to store mock users, simulating a user table in a database.
  static final Map<String, UserModel> _mockUsers = {
    'iMEJYT1R4sMoria34AtgrJFr4ls2': UserModel(
      userId: 'iMEJYT1R4sMoria34AtgrJFr4ls2',
      userName: 'Alice Wonder',
      email: 'dipanshunamdev799@gmail.com',
      university: 'State University of Science',
      testsCreated: [
        // Corresponds to the 'Flutter Widgets Mastery' test
        TestID(
            testCreatorId: 'iMEJYT1R4sMoria34AtgrJFr4ls2',
            testTimeStamp: Timestamp.fromDate(DateTime(2025, 7, 20))),
      ],
      testsJoined: [
        // Corresponds to the 'Data Structures & Algorithms' test
        TestID(
            testCreatorId: 'prof_davis',
            testTimeStamp: Timestamp.fromDate(DateTime(2025, 6, 15))),
        // Corresponds to the 'Quantum Physics 101' test
        TestID(
            testCreatorId: 'dr_einstein',
            testTimeStamp: Timestamp.fromDate(DateTime(2025, 5, 10))),
      ],
    ),
    'user_456_def': UserModel(
      userId: 'user_456_def',
      userName: 'Bob Builder',
      email: 'bob.b@example.com',
      university: 'Institute of Technology',
      testsCreated: [],
      testsJoined: [
        // Corresponds to the 'Data Structures & Algorithms' test
        TestID(
            testCreatorId: 'prof_davis',
            testTimeStamp: Timestamp.fromDate(DateTime(2025, 6, 15))),
        // Corresponds to the 'Flutter Widgets Mastery' test
        TestID(
            testCreatorId: 'iMEJYT1R4sMoria34AtgrJFr4ls2',
            testTimeStamp: Timestamp.fromDate(DateTime(2025, 7, 20))),
      ],
    ),
    'prof_davis': UserModel(
      userId: 'prof_davis',
      userName: 'Prof. Evelyn Davis',
      email: 'e.davis@inst-tech.edu',
      university: 'Institute of Technology',
      testsCreated: [
        // Corresponds to the 'Data Structures & Algorithms' test
        TestID(
            testCreatorId: 'prof_davis',
            testTimeStamp: Timestamp.fromDate(DateTime(2025, 6, 15))),
      ],
      testsJoined: [],
    ),
  };
  // --- END MOCK USER DATABASE ---

  UserApiDataSource({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<UserModel> createUser(UserModel user) async {
    debugPrint("--- Mock API: Creating User ${user.userName} ---");
    await Future.delayed(const Duration(milliseconds: 500));
    final newUser = UserModel(
      userId: 'new_user_${DateTime.now().millisecondsSinceEpoch}',
      userName: user.userName,
      email: user.email,
      university: user.university,
      testsCreated: [],
      testsJoined: [
        // Welcome test for all new users
        TestID(
            testCreatorId: 'quickdot_admin',
            testTimeStamp: Timestamp.fromDate(DateTime(2025, 1, 1)))
      ],
    );
    // Add the new user to the mock store for this session
    _mockUsers[newUser.userId] = newUser;
    return newUser;
  }

  @override
  Future<UserModel> getUser(String userId) async {
    debugPrint("--- Mock API: Getting User $userId ---");
    await Future.delayed(const Duration(milliseconds: 600));

    if (_mockUsers.containsKey(userId)) {
      return _mockUsers[userId]!;
    } else {
      // Throwing an exception is more realistic for a failed API call.
      throw UserNotFoundException();
    }
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    debugPrint("--- Mock API: Updating User ${user.userId} ---");
    await Future.delayed(const Duration(seconds: 1));
    if (_mockUsers.containsKey(user.userId)) {
      _mockUsers[user.userId] = user; // Update in the mock store
    }
    return user;
  }

  @override
  Future<void> deleteUser(String userId) async {
    debugPrint("--- Mock API: Deleting User $userId ---");
    await Future.delayed(const Duration(seconds: 1));
    _mockUsers.remove(userId); // Remove from the mock store
    return;
  }
}