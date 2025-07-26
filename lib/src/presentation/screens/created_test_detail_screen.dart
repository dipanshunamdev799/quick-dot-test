import 'package:flutter/material.dart';
import 'dart:math';

// Adjust these import paths to where your files are located
import 'package:quick_dot_test/src/core/utils/test_id.dart';
import 'package:quick_dot_test/src/data/repositories/test_repository.dart';
import 'test_questions_screen.dart'; // Import the new screen

/// A screen that displays detailed results and statistics of a created test for the creator.
class CreatedTestDetailScreen extends StatefulWidget {
  final TestID testId;

  const CreatedTestDetailScreen({super.key, required this.testId});

  @override
  State<CreatedTestDetailScreen> createState() => _CreatedTestDetailScreenState();
}

class _CreatedTestDetailScreenState extends State<CreatedTestDetailScreen> {
  late final Future<CreatedTestDetail> _detailsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch the data using the singleton repository instance
    _detailsFuture = TestRepository.instance.getCreatedTestDetail(testId: widget.testId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a FutureBuilder to handle the asynchronous data fetching
      body: FutureBuilder<CreatedTestDetail>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load test details.\nError: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.hasData) {
            final details = snapshot.data!;
            // Pre-calculate statistics for display
            final participants = details.participants;
            participants.sort((a, b) => b.marksObtained.compareTo(a.marksObtained)); // Sort for leaderboard

            double averageScore = 0;
            if (participants.isNotEmpty) {
              averageScore = participants.map((p) => p.marksObtained).reduce((a, b) => a + b) / participants.length;
            }

            return _buildDetailView(context, details, participants, averageScore);
          }

          return const Center(child: Text('No details available.'));
        },
      ),
    );
  }

  /// The main view built when data is successfully loaded.
  Widget _buildDetailView(
    BuildContext context,
    CreatedTestDetail details,
    List<ParticipantScore> sortedParticipants,
    double averageScore,
  ) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220.0,
          pinned: true,
          stretch: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              details.testName,
              style: const TextStyle(fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 10)]),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.primaryColor, theme.colorScheme.primary.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: -20,
                  child: Icon(Icons.analytics_outlined, size: 120, color: Colors.white.withOpacity(0.1)),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Icon(Icons.bar_chart_rounded, size: 80, color: Colors.white.withOpacity(0.15)),
                ),
              ],
            ),
          ),
        ),

        // --- Summary Statistics Section ---
        SliverToBoxAdapter(
          child: _AnimatedFadeIn(
            delay: const Duration(milliseconds: 100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.people_alt,
                      value: details.participants.length.toString(),
                      label: 'Participants',
                      color: Colors.blue.shade400,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.score_rounded,
                      value: averageScore.toStringAsFixed(1),
                      label: 'Avg. Score',
                      color: Colors.orange.shade400,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.star_rounded,
                      value: details.totalMarks.toString(),
                      label: 'Total Marks',
                      color: Colors.green.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // --- Participant Leaderboard Section ---
        const _SectionHeader(title: 'Leaderboard'),
        SliverList.builder(
          itemCount: min(10, sortedParticipants.length), // Show top 10 or less
          itemBuilder: (context, index) {
            final participant = sortedParticipants[index];
            return _AnimatedFadeIn(
              delay: Duration(milliseconds: 200 + (index * 50)),
              child: _ParticipantTile(
                participant: participant,
                rank: index + 1,
                totalMarks: details.totalMarks,
              ),
            );
          },
        ),

        // --- View All Questions Button ---
        SliverToBoxAdapter(
          child: _AnimatedFadeIn(
            delay: const Duration(milliseconds: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: FilledButton.icon(
                icon: const Icon(Icons.list_alt_rounded),
                label: const Text('View Questions & Answers'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: theme.textTheme.titleMedium,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TestQuestionsScreen(
                        testName: details.testName,
                        questions: details.questions,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A reusable, animated widget for displaying a single statistic.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.9),
              foregroundColor: Colors.white,
              child: Icon(icon, size: 28),
            ),
            const SizedBox(height: 12),
            Text(value, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: textTheme.bodyMedium?.copyWith(color: textTheme.bodySmall?.color)),
          ],
        ),
      ),
    );
  }
}

/// A reusable tile to display a participant's rank and score.
class _ParticipantTile extends StatelessWidget {
  final ParticipantScore participant;
  final int rank;
  final int totalMarks;

  const _ParticipantTile({
    required this.participant,
    required this.rank,
    required this.totalMarks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTopThree = rank <= 3;
    final Color rankColor = switch (rank) {
      1 => Colors.amber.shade600, // Gold
      2 => Colors.grey.shade500,  // Silver
      3 => Colors.brown.shade400,   // Bronze
      _ => theme.colorScheme.primary,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: rankColor.withOpacity(isTopThree ? 1.0 : 0.2),
              foregroundColor: isTopThree ? Colors.white : rankColor,
              child: Text('$rank', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User: ${participant.userId.substring(0, 8)}...', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: totalMarks > 0 ? participant.marksObtained / totalMarks : 0,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    backgroundColor: theme.colorScheme.surfaceVariant,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${participant.marksObtained}/${totalMarks}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A reusable widget for section headers.
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// A simple helper widget to fade and slide in its child.
class _AnimatedFadeIn extends StatelessWidget {
  final Duration delay;
  final Widget child;

  const _AnimatedFadeIn({required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}