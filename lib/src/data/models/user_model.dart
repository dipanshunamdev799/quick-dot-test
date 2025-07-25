import 'package:flutter/foundation.dart';
import 'package:quick_dot_test/src/core/utils/test_id.dart';


@immutable
class UserModel {
  final String userId; // From Firebase Auth UID
  final String userName;
  final String email;    // From Firebase Auth
  final String university;
  final List<TestID> testsCreated;
  final List<TestID> testsJoined;

  const UserModel({
    required this.userId,
    required this.userName,
    required this.email,
    required this.university,
    this.testsCreated = const [],
    this.testsJoined = const [],
  });

  /// Creates a copy of this user model but with the given fields replaced with the new values.
  UserModel copyWith({
    String? userId,
    String? userName,
    String? email,
    String? university,
    List<TestID>? testsCreated,
    List<TestID>? testsJoined,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      university: university ?? this.university,
      testsCreated: testsCreated ?? this.testsCreated,
      testsJoined: testsJoined ?? this.testsJoined,
    );
  }

  /// Converts this [UserModel] instance to a Map, suitable for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'email': email,
      'university': university,
      // Convert each TestID object in the list to a Map
      'testsCreated': testsCreated.map((record) => record.toJson()).toList(),
      'testsJoined': testsJoined.map((record) => record.toJson()).toList(),
    };
  }

  /// Creates a [UserModel] instance from a Firestore document.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      email: json['email'] as String,
      university: json['university'] as String,
      // Convert the list of maps from Firestore into a list of TestID objects
      testsCreated: (json['testsCreated'] as List<dynamic>?)
              ?.map((item) => TestID.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      testsJoined: (json['testsJoined'] as List<dynamic>?)
              ?.map((item) => TestID.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}