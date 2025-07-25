import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quick_dot_test/src/core/utils/auth_service.dart';
import 'package:quick_dot_test/src/core/utils/test_id.dart';
import 'package:quick_dot_test/src/logic/user_provider.dart';
import 'package:quick_dot_test/src/presentation/screens/auth_screen.dart';
import 'package:quick_dot_test/src/presentation/screens/edit_profile_screen.dart';
import 'package:quick_dot_test/src/presentation/screens/view_results_screen.dart';

/// The main screen after a user logs in.
/// It's composed of modular widgets for each section.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // FIX: Data fetching is now delegated to the specific widgets that need it
    // using `context.select`. This prevents the entire HomeScreen from rebuilding
    // when user data changes, improving performance.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        // AppBar actions are encapsulated in their own widget.
        actions: const [_AppBarActions()],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: const [
          // FIX: Widgets now fetch their own data, making them more self-contained.
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

// BEST PRACTICE: Using an enum for menu actions is safer than raw strings.
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
          // FIX: Switched from String to the `_MenuAction` enum.
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

  // FIX: Using a switch statement with the enum is cleaner and safer.
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

  // BEST PRACTICE: Extracted sign-out logic into its own method.
  Future<void> _signOut(BuildContext context) async {
    // It's good practice to get the provider with listen: false inside a method.
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
                  text: 'If you enjoy this software, please consider rating it on the Play Store.'),
              const SizedBox(height: 16),
              _buildInfoTile(context,
                  icon: Icons.upload_file_outlined,
                  text: 'Create Test: Upload a PDF, get test questions, and generate a test session.'),
              const SizedBox(height: 16),
              _buildInfoTile(context,
                  icon: Icons.group_work_outlined,
                  text: 'Anyone with a test ID can join the session when the test is live.'),
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

  Widget _buildInfoTile(BuildContext context, {required IconData icon, required String text}) {
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
          content: const Text('This will permanently delete your account and all associated data. This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            if (isDeleting)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
              )
            else
              FilledButton.tonal(
                style: FilledButton.styleFrom(backgroundColor: Colors.red.shade100, foregroundColor: Colors.red.shade900),
                onPressed: () async {
                  setState(() => isDeleting = true);
                  final success = await userProvider.deleteCurrentUser();

                  // FIX: Added a `mounted` check for the original context before showing a SnackBar.
                  // This prevents errors if the user navigates away while the deletion is processing.
                  if (!context.mounted) return;

                  Navigator.of(dialogContext).pop();

                  if (success) {
                    // The sign-out logic is already encapsulated in the `_signOut` method.
                    await _signOut(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(userProvider.error ?? 'Failed to delete account. Please try again.'),
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
    // PERFORMANCE: `context.select` ensures this widget only rebuilds if `userName` changes.
    final String userName = context.select((UserProvider p) => p.user?.userName ?? 'User');

    return Card(
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, $userName!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Ready to challenge yourself or create a new quiz?', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9))),
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
        Text('What would you like to do?', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _FeatureCard(icon: Icons.create_outlined, title: 'Create Test', onTap: () {/* TODO: Nav to create */}),
            _FeatureCard(icon: Icons.group_add_outlined, title: 'Join Test', onTap: () {/* TODO: Nav to join */}),
            _FeatureCard(
              icon: Icons.history_outlined,
              title: 'View Results',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ViewResultsScreen())),
            ),
            _FeatureCard(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const EditProfileScreen())),
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
  const _FeatureCard({required this.icon, required this.title, required this.onTap});

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
            Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
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
    // PERFORMANCE: `context.select` ensures this widget only rebuilds if the list of tests changes.
    final List<TestID> recentTests = context.select((UserProvider p) => p.recentActivity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        if (recentTests.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Text('Join a test to see your activity here!', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          // CLEANUP: Using the spread operator `...` is a cleaner way to insert a list of
          // widgets than creating an unnecessary intermediate Column.
          ...recentTests.take(5).map((test) {
            return _RecentActivityTile(
              title: 'Test Joined',
              subtitle: 'On: ${DateFormat.yMMMd().add_jm().format(test.testTimeStamp.toDate())}',
            );
          }),
      ],
    );
  }
}

/// The list tile used within the [_RecentActivitySection].
class _RecentActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  const _RecentActivityTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: Icon(Icons.history_edu_outlined, color: Theme.of(context).colorScheme.secondary),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle),
      ),
    );
  }
}