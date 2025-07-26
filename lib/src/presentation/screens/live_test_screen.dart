import 'dart:async';
import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_dot_test/src/data/models/question_model.dart'; // Required for Timestamp



class LiveTestScreen extends StatefulWidget {
  final List<Question> questions;
  final Duration duration;
  final dynamic testId;
  final Timestamp testTimestamp;

  const LiveTestScreen({
    super.key,
    required this.questions,
    required this.duration,
    required this.testId,
    required this.testTimestamp,
  });

  @override
  State<LiveTestScreen> createState() => _LiveTestScreenState();
}

class _LiveTestScreenState extends State<LiveTestScreen> {
  // State management variables
  late final PageController _pageController;
  late final Timer _timer;
  late Duration _remainingTime;
  late List<int?> _selectedAnswers;
  int _currentPage = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Convert the Firestore Timestamp to a DateTime object to perform calculations.
    final DateTime startTime = widget.testTimestamp.toDate();
    
    // Calculate the exact end time of the test.
    final DateTime endTime = startTime.add(widget.duration);
    
    // Calculate the initial remaining time by finding the difference
    // between the end time and the current time.
    _remainingTime = endTime.difference(DateTime.now());

    // If the user loads the screen after the test should have ended, set time to zero.
    if (_remainingTime.isNegative) {
      _remainingTime = Duration.zero;
    }
    
    _selectedAnswers = List.filled(widget.questions.length, null);

    // Start the countdown timer
    _startTimer();
  }


  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds <= 0) {
        timer.cancel();
        if (!_isSubmitting) {
           _submitTest(); 
        }
      } else {
        if (mounted) {
          setState(() => _remainingTime -= const Duration(seconds: 1));
        }
      }
    });
  }

  // --- State Modification Methods ---

  void _selectAnswer(int questionIndex, int optionIndex) {
    setState(() {
      // If the user taps the same option again, deselect it.
      if (_selectedAnswers[questionIndex] == optionIndex) {
        _selectedAnswers[questionIndex] = null;
      } else {
        // Otherwise, select the new option.
        _selectedAnswers[questionIndex] = optionIndex;
      }
    });
  }

  Future<void> _submitTest() async {
    setState(() => _isSubmitting = true);
    _timer.cancel();
    
    // Simulate a network call for submission
    await Future.delayed(const Duration(seconds: 2)); 
    
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Test Submitted Successfully!"), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop();
    }
  }
  
  void _showSubmitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Submit Test?'),
        content: const Text('Are you sure you want to end the test and submit your answers?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _submitTest();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _jumpToQuestion(int index) {
    Navigator.of(context).pop(); // Close the palette
    _pageController.jumpToPage(index);
  }

  void _showQuestionPalette() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuestionPaletteDrawer(
        onQuestionTap: _jumpToQuestion,
        currentPage: _currentPage,
        selectedAnswers: _selectedAnswers,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, 
      child: Scaffold(
        extendBody: true,
        appBar: _LiveTestAppBar(
          questionCount: widget.questions.length,
          currentPage: _currentPage,
          remainingTime: _remainingTime,
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: widget.questions.length,
          onPageChanged: (index) => setState(() => _currentPage = index),
          itemBuilder: (context, index) {
            return _QuestionCard(
              question: widget.questions[index],
              selectedOptionIndex: _selectedAnswers[index],
              onOptionSelected: (selectedOption) {
                _selectAnswer(index, selectedOption);
              },
            );
          },
        ),
        bottomNavigationBar: _GlassmorphicBottomNav(
          pageController: _pageController,
          currentPage: _currentPage,
          questionCount: widget.questions.length,
          onPaletteTap: _showQuestionPalette,
          onSubmit: _showSubmitConfirmationDialog,
          isSubmitting: _isSubmitting,
        ),
      ),
    );
  }
}

// --- UI Sub-components (Stateless and receive data via constructor) ---

class _LiveTestAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int questionCount;
  final int currentPage;
  final Duration remainingTime;

  const _LiveTestAppBar({
    required this.questionCount,
    required this.currentPage,
    required this.remainingTime,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedTime =
        '${remainingTime.inMinutes.toString().padLeft(2, '0')}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}';
    final isLowTime = remainingTime.inSeconds <= 59 && remainingTime.inMinutes < 1;

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${currentPage + 1} of $questionCount',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(top: 4),
            height: 4,
            width: (MediaQuery.of(context).size.width * 0.4) * ((currentPage + 1) / questionCount),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16.0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isLowTime ? Colors.red.withOpacity(0.1) : theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isLowTime ? Colors.red.withOpacity(0.2) : theme.primaryColor.withOpacity(0.2),
            )
          ),
          child: Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 20,
                color: isLowTime ? Colors.red.shade700 : theme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                formattedTime,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isLowTime ? Colors.red.shade700 : theme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlassmorphicBottomNav extends StatelessWidget {
  final PageController pageController;
  final int currentPage;
  final int questionCount;
  final VoidCallback onPaletteTap;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  const _GlassmorphicBottomNav({
    required this.pageController,
    required this.currentPage,
    required this.questionCount,
    required this.onPaletteTap,
    required this.onSubmit,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastQuestion = currentPage == questionCount - 1;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0).copyWith(
            bottom: MediaQuery.of(context).padding.bottom + 12.0,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.apps_outlined),
                tooltip: 'Question Palette',
                onPressed: onPaletteTap,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: currentPage == 0
                    ? null
                    : () => pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.primaryColor,
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Prev'),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: isSubmitting
                    ? null
                    : () {
                        if (isLastQuestion) {
                          onSubmit();
                        } else {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: isLastQuestion ? theme.colorScheme.secondary : theme.primaryColor,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                      )
                    : Text(isLastQuestion ? 'SUBMIT TEST' : 'Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final Question question;
  final int? selectedOptionIndex;
  final ValueChanged<int> onOptionSelected;

  const _QuestionCard({
    required this.question,
    required this.selectedOptionIndex,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 150), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.questionText,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
          ),
          const SizedBox(height: 32),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: question.options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              return _OptionTile(
                title: question.options[index],
                isSelected: selectedOptionIndex == index,
                onTap: () => onOptionSelected(index),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({required this.title, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withOpacity(0.1) : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.5,
          ),
          borderRadius: BorderRadius.circular(14),
           boxShadow: isSelected ? [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4)
            )
          ] : [],
        ),
        child: Row(
          children: [
            Expanded(child: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500))),
            const SizedBox(width: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? theme.primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? theme.primaryColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
            )
          ],
        ),
      ),
    );
  }
}

class _QuestionPaletteDrawer extends StatelessWidget {
  final ValueChanged<int> onQuestionTap;
  final int currentPage;
  final List<int?> selectedAnswers;

  const _QuestionPaletteDrawer({
    required this.onQuestionTap,
    required this.currentPage,
    required this.selectedAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question Palette', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              itemCount: selectedAnswers.length,
              itemBuilder: (context, index) {
                final isAnswered = selectedAnswers[index] != null;
                final isCurrent = index == currentPage;

                Color bgColor = Colors.white;
                Color textColor = Colors.grey.shade800;
                Border? border;

                if (isAnswered) { // Only Answered
                  bgColor = const Color(0xFFE3F8F2);
                  textColor = const Color(0xFF047857);
                }
                
                if (isCurrent) {
                  border = Border.all(color: theme.primaryColor, width: 2.5);
                } else {
                   border = Border.all(color: Colors.grey.shade200);
                }

                return GestureDetector(
                  onTap: () => onQuestionTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                      border: border,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}