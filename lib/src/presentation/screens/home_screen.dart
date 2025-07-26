import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quick_dot_test/src/core/utils/auth_service.dart';
import 'package:quick_dot_test/src/core/utils/test_id.dart';
import 'package:quick_dot_test/src/data/repositories/test_repository.dart';
import 'package:quick_dot_test/src/logic/user_provider.dart';
import 'package:quick_dot_test/src/presentation/screens/auth_screen.dart';
import 'package:quick_dot_test/src/presentation/screens/edit_profile_screen.dart';
import 'package:quick_dot_test/src/presentation/screens/joined_test_detail_screen.dart';
// ADDED: Import for the Join Test screen
import 'package:quick_dot_test/src/presentation/screens/join_test_screen.dart';
import 'package:quick_dot_test/src/presentation/screens/result_screen.dart';


/// The main screen after a user logs in.
/// It's composed of modular widgets for each section.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: const [_AppBarActions()],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: const [
          _GreetingCard(),
          SizedBox(height: 24),
          _FeatureGrid(),
          SizedBox(height: 24),
          _RecentActivitySection(),
        ],
      ),
    );
  }
}

// --- MODULAR WIDGETS ---

enum _MenuAction { signOut, deleteAccount }

/// Widget for displaying AppBar actions and handling their logic.
class _AppBarActions extends StatelessWidget {
  const _AppBarActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          tooltip: 'Information',
          onPressed: () => _showInfoDialog(context),  
        ),
        PopupMenuButton<_MenuAction>(
          onSelected: (value) => _handleMenuSelection(context, value),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<_MenuAction>>[
            const PopupMenuItem<_MenuAction>(
              value: _MenuAction.signOut,
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text('Sign Out'),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<_MenuAction>(
              value: _MenuAction.deleteAccount,
              child: ListTile(
                leading: Icon(Icons.delete_forever, color: Colors.red.shade700),
                title: Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleMenuSelection(BuildContext context, _MenuAction value) {
    switch (value) {
      case _MenuAction.signOut:
        _signOut(context);
        break;
      case _MenuAction.deleteAccount:
        _showDeleteConfirmationDialog(context);
        break;
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authService = AuthService();

    userProvider.clearUser();
    await authService.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('How It Works'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              _buildInfoTile(context,
                  icon: Icons.star_outline,
                  text:
                      'If you enjoy this software, please consider rating it on the Play Store.'),
              const SizedBox(height: 16),
              _buildInfoTile(context,
                  icon: Icons.upload_file_outlined,
                  text:
                      'Create Test: Upload a PDF, get test questions, and generate a test session.'),
              const SizedBox(height: 16),
              _buildInfoTile(context,
                  icon: Icons.group_work_outlined,
                  text:
                      'Anyone with a test ID can join the session when the test is live.'),
              const SizedBox(height: 16),
              _buildInfoTile(context,
                  icon: Icons.history_toggle_off_outlined,
                  text: 'Test data will be permanently deleted after 7 days.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Got It!'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context,
      {required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
        const SizedBox(width: 16),
        Expanded(child: Text(text)),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    bool isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Delete Account?'),
          content: const Text(
              'This will permanently delete your account and all associated data. This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            if (isDeleting)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: SizedBox(
                    width: 24, height: 24, child: CircularProgressIndicator()),
              )
            else
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.red.shade900),
                onPressed: () async {
                  setState(() => isDeleting = true);
                  final success = await userProvider.deleteCurrentUser();

                  if (!context.mounted) return;

                  Navigator.of(dialogContext).pop();

                  if (success) {
                    await _signOut(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(userProvider.error ??
                            'Failed to delete account. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Delete'),
              ),
          ],
        ),
      ),
    );
  }
}

/// A card that displays a welcome message to the user.
class _GreetingCard extends StatelessWidget {
  const _GreetingCard();

  @override
  Widget build(BuildContext context) {
    final String userName =
        context.select((UserProvider p) => p.user?.userName ?? 'User');

    return Card(
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, $userName!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Ready to challenge yourself or create a new quiz?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onPrimary.withOpacity(0.9))),
          ],
        ),
      ),
    );
  }
}

/// A grid of cards for navigating to the app's main features.
class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What would you like to do?',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _FeatureCard(
                icon: Icons.create_outlined,
                title: 'Create Test',
                onTap: () {/* TODO: Nav to create */}),
            // --- MODIFICATION START ---
            _FeatureCard(
              icon: Icons.group_add_outlined,
              title: 'Join Test',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const JoinTestScreen(),
              )),
            ),
            // --- MODIFICATION END ---
            _FeatureCard(
              icon: Icons.history_outlined,
              title: 'View Results',
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ResultScreen())),
            ),
            _FeatureCard(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const EditProfileScreen())),
            ),
          ],
        ),
      ],
    );
  }
}

/// The card used within the [_FeatureGrid].
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _FeatureCard(
      {required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// A section that displays a list of the user's recent activities.
class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context) {
    final List<TestID> recentTests =
        context.select((UserProvider p) => p.user?.testsJoined ?? []);

    recentTests.sort((a, b) => b.testTimeStamp.compareTo(a.testTimeStamp));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        if (recentTests.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Text('Join a test to see your activity here! 🚀',
                  style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ...recentTests.take(5).map((testId) {
            return _RecentActivityTile(
              key: ValueKey(testId), // Using testId as a stable key
              testId: testId,
            );
          }),
      ],
    );
  }
}

/// Fetches and displays the details for a single test participation.
class _RecentActivityTile extends StatefulWidget {
  final TestID testId;
  const _RecentActivityTile({super.key, required this.testId});

  @override
  State<_RecentActivityTile> createState() => _RecentActivityTileState();
}

class _RecentActivityTileState extends State<_RecentActivityTile> {
  late final Future<ParticipationDetails> _detailsFuture;
  final TestRepository _testRepository = TestRepository.instance;

  @override
  void initState() {
    super.initState();
    final userId =
        Provider.of<UserProvider>(context, listen: false).user?.userId;

    if (userId != null) {
      _detailsFuture = _testRepository.getParticipationDetails(
        testId: widget.testId,
        userId: userId,
      );
    } else {
      _detailsFuture = Future.error('User not logged in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: FutureBuilder(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ListTile(
              leading: Icon(Icons.history_edu_outlined),
              title: Text('Loading activity...'),
              trailing: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            );
          }
          if (snapshot.hasError) {
            return ListTile(
              leading: Icon(Icons.error_outline, color: Colors.red.shade400),
              title: const Text('Failed to load details'),
              subtitle: Text(
                snapshot.error.toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }
          if (snapshot.hasData) {
            final details = snapshot.data!;
            return ListTile(
              leading: Icon(Icons.history_edu_outlined,
                  color: Theme.of(context).colorScheme.secondary),
              title: Text(details.testName,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Score: ${details.marksObtained} / ${details.totalMarks}  •  On: ${DateFormat.yMMMd().format(details.timestamp)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Get the user ID again (safely)
                final userId = Provider.of<UserProvider>(context, listen: false)
                    .user
                    ?.userId;

                // Navigate only if we have a valid user ID
                if (userId != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => JoinedTestDetailScreen(
                        testId: widget.testId,
                        userId: userId,
                      ),
                    ),
                  );
                } else {
                  // Optionally, show an error if the user is somehow logged out
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not open details. Please sign in again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}