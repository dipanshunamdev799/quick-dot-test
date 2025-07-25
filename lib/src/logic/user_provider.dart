import 'package:flutter/material.dart';
import 'package:quick_dot_test/src/core/utils/test_id.dart';
import 'package:quick_dot_test/src/data/models/user_model.dart';
// Adjust these import paths to where your files are saved
import 'package:quick_dot_test/src/data/datasources/user_api.dart'; // For UserNotFoundException
import 'package:quick_dot_test/src/data/repositories/user_repository.dart';

/// Manages the state of the current user by interacting with a [IUserRepository].
///
/// This provider serves as the bridge between the UI and the data layer. It handles
/// fetching, creating,updating, and deleting user data, while also managing
/// loading and error states for the UI to react to.
class UserProvider extends ChangeNotifier {
  final IUserRepository _userRepository;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  /// The currently logged-in user. Returns null if no user is logged in or fetched.
  UserModel? get user => _user;

  /// True if the provider is currently performing an asynchronous operation.
  bool get isLoading => _isLoading;

  /// Contains an error message if the last operation failed.
  String? get error => _error;

  /// **NEW**: Returns a list of the 5 most recently joined tests.
  List<TestID> get recentActivity {
    // Return an empty list if there's no user or no joined tests.
    if (_user == null || _user!.testsJoined.isEmpty) {
      return [];
    }

    // Reverse the list to get the newest tests first, then take up to 5.
    return _user!.testsJoined.reversed.take(5).toList();
  }

  /// Constructor requires an implementation of the user repository.
  UserProvider({required IUserRepository userRepository})
      : _userRepository = userRepository;

  /// Fetches user data. If the user doesn't exist, it creates a new profile.
  ///
  /// This should be called after a user signs in.
  Future<void> fetchUser({required String userId, required String email}) async {
    _startLoading();
    try {
      _user = await _userRepository.getUser(userId);
    } on UserNotFoundException {
      // **NEW LOGIC**: If the user is not found, create a new one.
      try {
        final String defaultUserName =
            email.split('@').first; // Use email prefix as default username
        final newUser = UserModel(
          userId: userId,
          userName: defaultUserName,
          email: email,
          university: '', // Can be set by the user later in their profile.
        );
        _user = await _userRepository.createUser(newUser);
      } on CreateUserException catch (e) {
        _setError(e.message);
      } catch (e) {
        _setError('An unexpected error occurred while creating your profile.');
      }
    } on UserRepositoryException catch (e) {
      // Catch other repository-related errors during fetch.
      _setError(e.message);
    } catch (e) {
      _setError('An unexpected error occurred while fetching user data.');
    } finally {
      _stopLoading();
    }
  }

  /// Updates the user's profile information in the repository.
  Future<bool> updateUserProfile({String? userName, String? university}) async {
    if (_user == null) {
      _setError('Cannot update profile: no user is loaded.');
      return false;
    }
    _startLoading();
    try {
      final updatedUser = await _userRepository.updateUser(
        _user!.copyWith(userName: userName, university: university),
      );
      _user = updatedUser; // Update state with the returned model
      return true;
    } on UserRepositoryException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _stopLoading();
    }
  }

  /// Adds a newly created test to the user's record and persists it.
  Future<void> addCreatedTest(TestID newTestId) async {
    if (_user == null) return;

    final updatedTests = List<TestID>.from(_user!.testsCreated)..add(newTestId);
    final userToUpdate = _user!.copyWith(testsCreated: updatedTests);

    // We can call updateUserProfile for simplicity or have a dedicated method
    await updateUser(userToUpdate);
  }

  /// Adds a newly joined test to the user's record and persists it.
  Future<void> addJoinedTest(TestID newTestId) async {
    if (_user == null) return;

    final updatedTests = List<TestID>.from(_user!.testsJoined)..add(newTestId);
    final userToUpdate = _user!.copyWith(testsJoined: updatedTests);

    await updateUser(userToUpdate);
  }

  /// Deletes the current user's account and data.
  Future<bool> deleteCurrentUser() async {
    if (_user == null) {
      _setError('Cannot delete account: no user is logged in.');
      return false;
    }
    _startLoading();
    try {
      await _userRepository.deleteUser(_user!.userId);
      clearUser(); // Clear local state on successful deletion
      return true;
    } on UserRepositoryException catch (e) {
      _setError(e.message);
      // Re-authentication errors are common, so the UI can specifically check for them.
      // if (e is ReauthenticationRequiredException) { /* handle specifically */ }
      return false;
    } finally {
      _stopLoading();
    }
  }

  /// Clears local user data, loading, and error states. Called on sign-out.
  void clearUser() {
    _user = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  // --- Private Helper Methods ---

  /// A generic helper to update the user model in the repository.
  @visibleForTesting
  Future<void> updateUser(UserModel userToUpdate) async {
    _startLoading();
    try {
      _user = await _userRepository.updateUser(userToUpdate);
    } on UpdateUserException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('An unexpected error occurred while updating the user.');
    } finally {
      _stopLoading();
    }
  }

  void _startLoading() {
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
  }
}