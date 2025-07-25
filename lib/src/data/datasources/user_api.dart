import 'dart:convert';
import 'package:quick_dot_test/src/core/utils/test_id.dart';
import 'package:quick_dot_test/src/data/models/user_model.dart'; // Adjust import path
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Custom exception for user-not-found errors from the API.
class UserNotFoundException implements Exception {}

/// Abstract interface for the user data source.
/// This defines the contract that any user data source implementation must follow.
abstract class IUserDataSource {
  Future<UserModel> createUser(UserModel user);
  Future<UserModel> getUser(String userId);
  Future<UserModel> updateUser(UserModel user);
  /// Deletes a user by their ID.
  Future<void> deleteUser(String userId);
}

/// Data source implementation that fetches user data from a remote API.
class UserApiDataSource implements IUserDataSource {
  /// The base URL for the backend API.
  static const String _baseUrl = 'https://your-api-domain.com/api';
  
  // Define endpoints as constants to avoid magic strings
  static const String _usersEndpoint = '/users';

  final http.Client _client;

  UserApiDataSource({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<UserModel> createUser(UserModel user) async {
    // ... mock implementation is the same
    return UserModel(
      userId: user.userId,
      userName: user.userName,
      email: user.email,
      university: user.university,
      testsCreated: [],
      testsJoined: [],
    );

    /* --- REAL API IMPLEMENTATION ---
    final uri = Uri.parse('$_baseUrl$_usersEndpoint');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 201) { // 201 Created
      return UserModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create user: ${response.statusCode}');
    }
    */
  }

  @override
  Future<UserModel> getUser(String userId) async {
    // ... mock implementation is the same
    return UserModel(
      userId: userId,
      userName: 'Mock User',
      email: 'mock.user@example.com',
      university: 'Flutter University',
      testsCreated: [TestID(testCreatorId: 'creator_abc', testTimeStamp: Timestamp.now())],
      testsJoined: [TestID(testCreatorId: 'creator_xyz', testTimeStamp: Timestamp.now())],
    );

    /* --- REAL API IMPLEMENTATION ---
    final uri = Uri.parse('$_baseUrl$_usersEndpoint/$userId');
    final response = await _client.get(uri, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw UserNotFoundException();
    } else {
      throw Exception('Failed to load user: ${response.statusCode}');
    }
    */
  }
  
  // ... other methods (updateUser, deleteUser) would be updated similarly.
  @override
  Future<UserModel> updateUser(UserModel user) async {
    /* --- REAL API IMPLEMENTATION ---
    final uri = Uri.parse('$_baseUrl$_usersEndpoint/${user.userId}');
    ...
    */
    debugPrint("--- Calling User API: Updating User ---");
    await Future.delayed(const Duration(seconds: 1));
    return user;
  }

  @override
  Future<void> deleteUser(String userId) async {
    /* --- REAL API IMPLEMENTATION ---
    final uri = Uri.parse('$_baseUrl$_usersEndpoint/$userId');
    ...
    */
    debugPrint("--- Calling User API: Deleting User $userId ---");
    await Future.delayed(const Duration(seconds: 1));
    return;
  }
}