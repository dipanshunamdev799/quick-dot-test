import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quick_dot_test/src/core/utils/test_id.dart';

// Adjust these import paths to where your files are located
import 'package:quick_dot_test/src/data/repositories/test_repository.dart';
import 'package:quick_dot_test/src/logic/user_provider.dart';
import 'package:quick_dot_test/src/presentation/screens/created_test_detail_screen.dart';

// --- NEW ---: Import the JoinedTestDetailScreen
import 'package:quick_dot_test/src/presentation/screens/joined_test_detail_screen.dart';


/// A screen to display lists of tests the user has joined and created.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Results'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.history), text: 'Tests Joined'),
              Tab(icon: Icon(Icons.my_library_books), text: 'Tests Created'),
            ],
          ),
        ),
        // Use a Consumer to react to changes in UserProvider
        body: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final user = userProvider.user;

            // Handle case where user is not loaded
            if (user == null) {
              return const Center(
                child: Text('Please log in to see your results.'),
              );
            }

            return TabBarView(
              children: [
                _buildTestList(
                  context: context,
                  testIds: user.testsJoined,
                  userId: user.userId,
                  emptyListMessage: 'You have not joined any tests yet.',
                  isJoinedList: true,
                ),
                _buildTestList(
                  context: context,
                  testIds: user.testsCreated,
                  userId: user.userId,
                  emptyListMessage: 'You have not created any tests yet.',
                  isJoinedList: false,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Helper widget to build a list of tests, showing a message if empty.
  Widget _buildTestList({
    required BuildContext context,
    required List<TestID> testIds,
    required String userId,
    required String emptyListMessage,
    required bool isJoinedList,
  }) {
    if (testIds.isEmpty) {
      return Center(
        child: Text(
          emptyListMessage,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    // Display the list of tests using a ListView
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: testIds.length,
      itemBuilder: (context, index) {
        // Return the appropriate card for each test ID
        final testId = testIds[index];
        return isJoinedList
            ? _JoinedTestCard(testId: testId, userId: userId)
            : _CreatedTestCard(testId: testId);
      },
    );
  }
}


/// A card widget to display the details of a test the user has joined.
class _JoinedTestCard extends StatelessWidget {
  final TestID testId;
  final String userId;

  const _JoinedTestCard({required this.testId, required this.userId});

  @override
  Widget build(BuildContext context) {
    final testRepository = TestRepository.instance;

    return FutureBuilder<ParticipationDetails>(
      future: testRepository.getParticipationDetails(testId: testId, userId: userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(child: Center(child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          )));
        }

        if (snapshot.hasError) {
          return Card(
            color: Colors.red.shade100,
            child: ListTile(
              leading: const Icon(Icons.error, color: Colors.red),
              title: const Text('Failed to load test details'),
              subtitle: Text('ID: ${testId.testCreatorId}${testId.testTimeStamp}'),
            ),
          );
        }

        if (snapshot.hasData) {
          final details = snapshot.data!;
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${details.marksObtained}/${details.totalMarks}'),
              ),
              title: Text(details.testName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Taken on: ${DateFormat.yMMMd().format(details.timestamp)}'),
              trailing: const Icon(Icons.chevron_right),
              // --- MODIFIED ---: Implemented navigation on tap.
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JoinedTestDetailScreen(
                      testId: testId,
                      userId: userId,
                    ),
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink(); // Should not happen
      },
    );
  }
}

/// A card widget to display the details of a test the user has created.
class _CreatedTestCard extends StatelessWidget {
  final TestID testId;

  const _CreatedTestCard({required this.testId});

  @override
  Widget build(BuildContext context) {
    final testRepository = TestRepository.instance;

    return FutureBuilder<CreationDetails>(
      future: testRepository.getCreationDetails(testId: testId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(child: Center(child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          )));
        }

        if (snapshot.hasError) {
          return Card(
            color: Colors.red.shade100,
            child: ListTile(
              leading: const Icon(Icons.error, color: Colors.red),
              title: const Text('Failed to load test summary'),
              subtitle: Text('ID: ${testId.testCreatorId}${testId.testTimeStamp}'),
            ),
          );
        }

        if (snapshot.hasData) {
          final details = snapshot.data!;
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.bar_chart)),
              title: Text(details.testName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  '${details.numberOfParticipants} participants • Avg Score: ${details.averageScore.toStringAsFixed(1)}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatedTestDetailScreen(testId: testId),
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}