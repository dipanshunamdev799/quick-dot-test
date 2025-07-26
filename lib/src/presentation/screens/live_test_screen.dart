import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_dot_test/src/core/utils/test_id.dart';
import 'package:quick_dot_test/src/data/models/question_model.dart';
import 'package:quick_dot_test/src/logic/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_dot_test/src/presentation/screens/home_screen.dart';

// The controller remains unchanged, so we just import it.
import 'live_test_controller.dart';

class LiveTestScreen extends StatefulWidget {
  final List<Question> questions;
  final TestID testId;
  final Duration duration;
  final Timestamp testTimestamp;

  const LiveTestScreen({
    super.key,
    required this.questions,
    required this.testId,
    required this.duration,
    required this.testTimestamp,
  });

  @override
  State<LiveTestScreen> createState() => _LiveTestScreenState();
}

class _LiveTestScreenState extends State<LiveTestScreen> {
  late final LiveTestController _controller;
  final PageController _pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key for the drawer
  int _currentPage = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bool hasAlreadyJoined =
        userProvider.user?.testsJoined.contains(widget.testId) ?? false;

    _controller = LiveTestController(
      testId: widget.testId,
      duration: widget.duration,
      testTimestamp: widget.testTimestamp,
      hasUserAlreadyJoined: hasAlreadyJoined,
    );

    _controller.addListener(_handleControllerChanges);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  void _initialize() {
    final eligibility = _controller.initializeTest();
    switch (eligibility) {
      case TestEligibility.alreadyJoined:
        _showAppDialog(
          context: context,
          title: 'Test Already Attempted',
          content: 'You have already completed this test and cannot attempt it again.',
          onConfirm: () => Navigator.of(context).popUntil((route) => route.isFirst),
        );
        break;
      case TestEligibility.expired:
        _showAppDialog(
          context: context,
          title: 'Session Expired',
          content: 'This test session has already expired and can no longer be joined.',
          onConfirm: () => Navigator.of(context).popUntil((route) => route.isFirst),
        );
        break;
      case TestEligibility.eligible:
        setState(() => _isInitialized = true);
        break;
    }
  }

  void _handleControllerChanges() {
    if (_controller.remainingTime.inSeconds <= 0 && !_controller.isSubmitting) {
      _submitTest(autoSubmitted: true);
    }
    // We can also call setState here if a listener needs to rebuild the whole screen,
    // but Provider handles this well for specific widgets.
  }

  Future<void> _submitTest({bool autoSubmitted = false}) async {
    final success = await _controller.submitTest();

    if (!mounted) return;

    if (success) {
      Provider.of<UserProvider>(context, listen: false).addJoinedTest(widget.testId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(autoSubmitted
              ? 'Time is up! Test submitted automatically.'
              : 'Test submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Submission failed. Please check your connection and try again.')),
      );
    }
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await _showAppDialog<bool>(
      context: context,
      title: 'Exit Test?',
      content:
          'Are you sure you want to exit? Your progress will be lost and you cannot rejoin this test.',
      isConfirmation: true,
      onConfirm: () => Navigator.of(context).pop(true),
      confirmText: 'Exit Anyway',
    );
    // This logic seems a bit redundant. If shouldPop is true, we pop, then the willpopscope returns true and pops again.
    // Let's simplify. `_onWillPop` just needs to return true or false.
    return shouldPop ?? false;
  }

  void _showSubmitConfirmationDialog() {
    _showAppDialog(
      context: context,
      title: 'Submit Test?',
      content: 'You have answered ${_controller.selectedAnswers.length} out of ${widget.questions.length} questions. Are you sure you want to submit?',
      isConfirmation: true,
      onConfirm: () {
        Navigator.of(context).pop(); // Close the dialog
        _submitTest();
      },
      confirmText: 'Submit'
    );
  }
  
  void _jumpToQuestion(int page) {
    _pageController.jumpToPage(page);
    Navigator.of(context).pop(); // Close the drawer
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanges);
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ChangeNotifierProvider.value(
      value: _controller,
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          key: _scaffoldKey,
          // NEW: A drawer for quick navigation
          drawer: _QuestionPaletteDrawer(
            questionCount: widget.questions.length,
            currentPage: _currentPage,
            onQuestionTap: _jumpToQuestion,
          ),
          appBar: _LiveTestAppBar(
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          body: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.questions.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final question = widget.questions[index];
                    return _QuestionCard(
                      // Use a key to ensure widget state is preserved correctly
                      key: ValueKey('question_$index'), 
                      question: question,
                      questionIndex: index,
                    );
                  },
                ),
              ),
              _LiveTestBottomNav(
                pageController: _pageController,
                currentPage: _currentPage,
                questionCount: widget.questions.length,
                onSubmit: _showSubmitConfirmationDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- UI Sub-components (Updated & New) ---

class _LiveTestAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuPressed;
  
  const _LiveTestAppBar({required this.onMenuPressed});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 6); // Extra height for progress bar

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LiveTestController>();
    final remainingTime = controller.remainingTime;
    final formattedTime =
        '${remainingTime.inMinutes.toString().padLeft(2, '0')}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}';
    final isLowTime = remainingTime.inSeconds <= 60 && remainingTime.inSeconds > 0;
    final totalQuestions = Provider.of<LiveTestScreen>(context, listen: false).questions.length;
    final answeredCount = controller.selectedAnswers.length;
    final progress = totalQuestions > 0 ? answeredCount / totalQuestions : 0.0;


    return AppBar(
      title: const Text('Test In Progress'),
      leading: IconButton(
        icon: const Icon(Icons.grid_view_rounded),
        onPressed: onMenuPressed,
        tooltip: 'Show Questions',
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            children: [
              Icon(Icons.timer_outlined, color: isLowTime ? Colors.red.shade300 : Colors.white),
              const SizedBox(width: 8),
              Text(
                formattedTime,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isLowTime ? Colors.red.shade300 : Colors.white,
                      fontWeight: FontWeight.bold,
                      // fontVariant: [FontVariant.tabularNumbers()], // Prevents text jumping
                    ),
              ),
            ],
          ),
        )
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(6.0),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.blue.shade900.withOpacity(0.5),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.lightGreenAccent),
        ),
      ),
    );
  }
}

class _QuestionPaletteDrawer extends StatelessWidget {
  final int questionCount;
  final int currentPage;
  final ValueChanged<int> onQuestionTap;

  const _QuestionPaletteDrawer({
    required this.questionCount,
    required this.currentPage,
    required this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedAnswers = context.watch<LiveTestController>().selectedAnswers;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Questions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: questionCount,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final bool isAnswered = selectedAnswers.containsKey(index);
                  final bool isCurrent = index == currentPage;

                  return InkWell(
                    onTap: () => onQuestionTap(index),
                    customBorder: const CircleBorder(),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isAnswered ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                        border: Border.all(
                          color: isCurrent ? Theme.of(context).colorScheme.primary : (isAnswered ? Colors.green : Colors.transparent),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCurrent ? Theme.of(context).colorScheme.primary : (isAnswered ? Colors.green.shade900 : Theme.of(context).textTheme.bodyLarge?.color),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}


class _LiveTestBottomNav extends StatelessWidget {
  final PageController pageController;
  final int currentPage;
  final int questionCount;
  final VoidCallback onSubmit;

  const _LiveTestBottomNav({
    required this.pageController,
    required this.currentPage,
    required this.questionCount,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<LiveTestController>().isSubmitting;
    final isLastPage = currentPage == questionCount - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 0, blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          TextButton.icon(
            onPressed: currentPage == 0
                ? null
                : () => pageController.previousPage(
                    duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
            icon: const Icon(Icons.arrow_back_ios_new),
            label: const Text('Prev'),
          ),

          // Next / Submit Button
          if (isLastPage)
            FilledButton.icon(
              onPressed: isSubmitting ? null : onSubmit,
              style: FilledButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              icon: isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_circle_outline),
              label: Text(isSubmitting ? 'Submitting...' : 'SUBMIT TEST'),
            )
          else
            ElevatedButton.icon(
              onPressed: () => pageController.nextPage(
                  duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
              label: const Icon(Icons.arrow_forward_ios),
              icon: const Text('Next'),
            ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final Question question;
  final int questionIndex; // Use index directly for map keys

  const _QuestionCard({super.key, required this.question, required this.questionIndex});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LiveTestController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${questionIndex + 1} of ${Provider.of<LiveTestScreen>(context, listen: false).questions.length}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(question.questionText, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          ...List.generate(question.options.length, (index) {
            return _OptionTile(
              text: question.options[index],
              isSelected: controller.selectedAnswers[questionIndex] == index,
              onTap: () => controller.selectAnswer(questionIndex, index),
            );
          }),
        ],
      ),
    );
  }
}

// NEW beautiful option tile
class _OptionTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
              width: isSelected ? 2.0 : 1.0,
            ),
            color: isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.3) : null,
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? theme.colorScheme.primary : Colors.grey,
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
            ],
          ),
        ),
      ),
    );
  }
}


// --- Utility Helper (No changes needed) ---

Future<T?> _showAppDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  bool isConfirmation = false,
  VoidCallback? onConfirm,
  String confirmText = 'OK',
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        if (isConfirmation)
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Return false on cancel
            child: const Text('Cancel'),
          ),
        TextButton(
          onPressed: onConfirm,
          child: Text(confirmText, style: TextStyle(color: isConfirmation ? Colors.red : null)),
        ),
      ],
    ),
  );
}