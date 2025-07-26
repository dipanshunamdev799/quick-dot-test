import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add 'intl' to your pubspec.yaml for date formatting
import 'dart:math'; // For min function in progress indicator

// Assuming these files exist from your provided context
import 'package:quick_dot_test/src/core/utils/test_id.dart';
import 'package:quick_dot_test/src/data/models/question_model.dart';
import 'package:quick_dot_test/src/data/repositories/test_repository.dart'; // Corrected import path

/// A screen that displays a detailed review of a test a user has completed.
///
/// It shows the overall score, the date of completion, and a question-by-question
/// breakdown with the user's answers marked against the correct answers.
class JoinedTestDetailScreen extends StatelessWidget {
  final TestID testId;
  final String userId;

  const JoinedTestDetailScreen({
    super.key,
    required this.testId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<JoinedTestDetail>(
        // Fetch data from the repository
        future: TestRepository.instance.getJoinedTestDetail(
          testId: testId,
          userId: userId,
        ),
        builder: (context, snapshot) {
          // -- Loading State --
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // -- Error State --
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load test details.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString()),
                ],
              ),
            );
          }

          // -- Success State --
          final testDetail = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(testDetail.testName),
                centerTitle: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 2,
                pinned: true,
                floating: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // 1. Score Summary Card
                      _ScoreSummaryCard(testDetail: testDetail),
                      const SizedBox(height: 24),

                      // 2. Review Section Header
                      Text(
                        'Review Your Answers',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // 3. List of Question Review Cards
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final question = testDetail.questions[index];
                      final selectedOption =
                          testDetail.optionsSelectedByUser[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _QuestionReviewCard(
                          question: question,
                          questionIndex: index,
                          selectedOptionIndex: selectedOption,
                        ),
                      );
                    },
                    childCount: testDetail.questions.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                  child: SizedBox(height: 20)), // Bottom padding
            ],
          );
        },
      ),
    );
  }
}

/// A card widget that displays the overall score summary.
class _ScoreSummaryCard extends StatelessWidget {
  final JoinedTestDetail testDetail;

  const _ScoreSummaryCard({required this.testDetail});

  @override
  Widget build(BuildContext context) {
    final double scorePercentage = testDetail.totalMarks > 0
        ? testDetail.marksObtained / testDetail.totalMarks
        : 0.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Your Score',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: scorePercentage,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${testDetail.marksObtained}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '/ ${testDetail.totalMarks}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Completed on ${DateFormat.yMMMd().format(testDetail.timestamp)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// A card widget for reviewing a single question, its options, and the answer.
class _QuestionReviewCard extends StatelessWidget {
  final Question question;
  final int questionIndex;
  final int? selectedOptionIndex;

  const _QuestionReviewCard({
    required this.question,
    required this.questionIndex,
    this.selectedOptionIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Text
            Text(
              'Q${questionIndex + 1}: ${question.questionText}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600, height: 1.4),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),

            // Options List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: question.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, optionIndex) {
                return _OptionTile(
                  optionText: question.options[optionIndex],
                  optionIndex: optionIndex,
                  correctOptionIndex: question.correctOptionIndex,
                  selectedOptionIndex: selectedOptionIndex,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A tile representing a single answer option, styled based on its state.
class _OptionTile extends StatelessWidget {
  final String optionText;
  final int optionIndex;
  final int correctOptionIndex;
  final int? selectedOptionIndex;

  const _OptionTile({
    required this.optionText,
    required this.optionIndex,
    required this.correctOptionIndex,
    this.selectedOptionIndex,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCorrect = optionIndex == correctOptionIndex;
    final bool isSelected = optionIndex == selectedOptionIndex;

    Color getBorderColor() {
      if (isCorrect) return Colors.green.shade700;
      if (isSelected && !isCorrect) return Colors.red.shade700;
      return Colors.grey.shade300;
    }

    Color getBackgroundColor() {
      if (isCorrect) return Colors.green.shade50;
      if (isSelected && !isCorrect) return Colors.red.shade50;
      return Colors.transparent;
    }

    Widget? getTrailingIcon() {
      if (isCorrect) {
        return const Icon(Icons.check_circle, color: Colors.green);
      }
      if (isSelected && !isCorrect) {
        return const Icon(Icons.cancel, color: Colors.red);
      }
      return null;
    }

    return Container(
      decoration: BoxDecoration(
        color: getBackgroundColor(),
        border: Border.all(color: getBorderColor(), width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(optionText),
        trailing: getTrailingIcon(),
        dense: true,
      ),
    );
  }
}