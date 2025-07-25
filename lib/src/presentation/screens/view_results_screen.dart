import 'package:flutter/material.dart';

class ViewResultsScreen extends StatelessWidget {
  const ViewResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // DefaultTabController is a convenient way to coordinate a TabBar and a TabBarView.
    return DefaultTabController(
      length: 2, // The number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('View Results'),
          // The TabBar is placed in the bottom of the AppBar.
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Joined Tests'),
              Tab(text: 'Created Tests'),
            ],
          ),
        ),
        // TabBarView contains a widget for each tab.
        body: const TabBarView(
          children: [
            // The content for the "Joined Tests" tab.
            _JoinedTestsList(),
            // The content for the "Created Tests" tab.
            _CreatedTestsList(),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET FOR "JOINED TESTS" LIST ---
class _JoinedTestsList extends StatelessWidget {
  const _JoinedTestsList();

  @override
  Widget build(BuildContext context) {
    // Using a ListView.builder for performance, even with static data for now.
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 3, // Placeholder count
      itemBuilder: (context, index) {
        // Placeholder data
        final List<Map<String, String>> joinedTests = [
          {
            'title': 'Quantum Physics Mid-Term',
            'date': 'Completed on 22 Jul 2025',
            'score': '78%',
            'icon': 'science'
          },
          {
            'title': 'World History Final',
            'date': 'Completed on 15 Jul 2025',
            'score': '91%',
            'icon': 'history'
          },
          {
            'title': 'Advanced Calculus Quiz',
            'date': 'Completed on 05 Jul 2025',
            'score': '85%',
            'icon': 'calculus'
          },
        ];
        return _TestResultTile(
          title: joinedTests[index]['title']!,
          subtitle: joinedTests[index]['date']!,
          score: joinedTests[index]['score']!,
        );
      },
    );
  }
}

// --- WIDGET FOR "CREATED TESTS" LIST ---
class _CreatedTestsList extends StatelessWidget {
  const _CreatedTestsList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 2, // Placeholder count
      itemBuilder: (context, index) {
        // Placeholder data
        final List<Map<String, String>> createdTests = [
          {
            'title': 'Introduction to Dart',
            'date': 'Created on 18 Jul 2025',
            'participants': '32 Participants',
            'avgScore': 'Avg. Score: 88%'
          },
          {
            'title': 'Flutter Widgets 101',
            'date': 'Created on 10 Jul 2025',
            'participants': '45 Participants',
            'avgScore': 'Avg. Score: 82%'
          },
        ];
        return _CreatedTestTile(
          title: createdTests[index]['title']!,
          date: createdTests[index]['date']!,
          participants: createdTests[index]['participants']!,
          avgScore: createdTests[index]['avgScore']!,
        );
      },
    );
  }
}

// --- CUSTOM TILE FOR JOINED TEST RESULTS ---
class _TestResultTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String score;

  const _TestResultTile({
    required this.title,
    required this.subtitle,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: const Icon(Icons.check_circle_outline, color: Colors.green),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
        trailing: Text(
          score,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}

// --- CUSTOM TILE FOR CREATED TESTS ---
class _CreatedTestTile extends StatelessWidget {
  final String title;
  final String date;
  final String participants;
  final String avgScore;

  const _CreatedTestTile({
    required this.title,
    required this.date,
    required this.participants,
    required this.avgScore,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(date, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.group, color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(participants),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.star_border, color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(avgScore),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
