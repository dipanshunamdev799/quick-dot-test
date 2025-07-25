import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:quick_dot_test/src/data/datasources/user_api.dart';
import 'package:quick_dot_test/src/data/models/user_model.dart';

// --- Custom Exceptions for the Repository Layer ---

/// Base exception for all user repository-related errors.
class UserRepositoryException implements Exception {
  final String message;
  const UserRepositoryException(this.message);

  @override
  String toString() => 'UserRepositoryException: $message';
}

/// Thrown when creating a user fails.
class CreateUserException extends UserRepositoryException {
  const CreateUserException([String message = 'Failed to create user.']) : super(message);
}

/// Thrown when fetching a user fails.
class GetUserException extends UserRepositoryException {
  const GetUserException([String message = 'Failed to retrieve user.']) : super(message);
}

/// Thrown when updating a user fails.
class UpdateUserException extends UserRepositoryException {
  const UpdateUserException([String message = 'Failed to update user.']) : super(message);
}

/// Thrown when deleting a user fails.
class DeleteUserException extends UserRepositoryException {
  const DeleteUserException(String message) : super(message);
}

/// Thrown for sensitive operations that require the user to have recently signed in.
class ReauthenticationRequiredException extends DeleteUserException {
  const ReauthenticationRequiredException()
      : super('This operation is sensitive and requires recent authentication. Please sign in again before retrying.');
}


/// Abstract interface for the user repository.
/// This defines the contract that the application's business logic will use.
abstract class IUserRepository {
  Future<UserModel> createUser(UserModel user);
  Future<UserModel> getUser(String userId);
  Future<UserModel> updateUser(UserModel user);
  /// Deletes a user by their ID.
  Future<void> deleteUser(String userId);
}


/// Repository implementation that uses a remote data source and Firebase Auth.
class UserRepository implements IUserRepository {
  final IUserDataSource _dataSource;
  final FirebaseAuth _firebaseAuth;

  UserRepository({
    required IUserDataSource dataSource,
    FirebaseAuth? firebaseAuth,
  })  : _dataSource = dataSource,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<UserModel> createUser(UserModel user) async {
    try {
      return await _dataSource.createUser(user);
    } catch (e) {
      // Log the original error for debugging purposes.
      debugPrint('DataSource error during createUser: $e');
      throw const CreateUserException();
    }
  }

  @override
  Future<UserModel> getUser(String userId) async {
    try {
      return await _dataSource.getUser(userId);
    } on UserNotFoundException {
      // This specific exception is expected, so we let it pass through.
      rethrow;
    } catch (e) {
      debugPrint('DataSource error during getUser: $e');
      throw const GetUserException();
    }
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    try {
      return await _dataSource.updateUser(user);
    } catch (e) {
      debugPrint('DataSource error during updateUser: $e');
      throw const UpdateUserException();
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null || currentUser.uid != userId) {
      throw const DeleteUserException(
        'Operation failed: You can only delete your own account and must be signed in to do so.',
      );
    }

    try {
      await currentUser.delete();
      await _dataSource.deleteUser(userId);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const ReauthenticationRequiredException();
      }
      throw DeleteUserException('Firebase could not delete the user. Reason: ${e.message}');
    } catch (e) {
      // Log the critical error from the data source.
      debugPrint('CRITICAL: Failed to delete user from data source after auth deletion: $e');
      throw DeleteUserException(
        'CRITICAL: User was deleted from authentication, but failed to delete user data from the database. Please contact support.',
      );
    }
  }
}