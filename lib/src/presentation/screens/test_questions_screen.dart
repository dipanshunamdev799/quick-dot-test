import 'package:flutter/material.dart';
import 'package:quick_dot_test/src/data/models/question_model.dart';

// Assuming your Question model is defined somewhere like this
// import 'package:quick_dot_test/src/data/models/question_model.dart'; 

class TestQuestionsScreen extends StatelessWidget {
  final String testName;
  final List<Question> questions;

  const TestQuestionsScreen({
    super.key,
    required this.testName,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions & Answers'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              title: Text(
                question.questionText,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              childrenPadding: const EdgeInsets.only(bottom: 8.0, left: 16.0, right: 16.0),
              expandedAlignment: Alignment.centerLeft,
              children: question.options.asMap().entries.map((entry) {
                final isCorrect = entry.key == question.correctOptionIndex;
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isCorrect ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                    color: isCorrect ? Colors.green.shade600 : Colors.grey,
                  ),
                  title: Text(
                    entry.value,
                    style: TextStyle(
                      fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                      color: isCorrect ? Colors.green.shade700 : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}