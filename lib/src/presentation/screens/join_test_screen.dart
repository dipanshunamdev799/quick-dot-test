import 'package:flutter/material.dart';
import 'package:quick_dot_test/src/logic/test_session_manager.dart';
import 'package:quick_dot_test/src/presentation/screens/live_test_screen.dart';

class JoinTestScreen extends StatefulWidget {
  const JoinTestScreen({super.key});

  @override
  State<JoinTestScreen> createState() => _JoinTestScreenState();
}

class _JoinTestScreenState extends State<JoinTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _testIdController = TextEditingController();
  bool _isLoading = false;

  /// Handles the logic when the "Join Test" button is pressed.
  Future<void> _submitJoinTest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      final uniqueTestIdentifier = _testIdController.text.trim();
      final liveTestData =
          await TestSessionManager.instance.joinTestSession(uniqueTestIdentifier);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LiveTestScreen(
              questions: liveTestData.questions.values.toList(),
              testId: liveTestData.testId,
              duration: liveTestData.duration,
              testTimestamp: liveTestData.timestamp,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  // --- NEW: Method to show the rules dialog ---
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Rules'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRuleTile(
              context,
              icon: Icons.timer_off_outlined,
              text: "An expired test session cannot be joined again.",
            ),
            const SizedBox(height: 16),
            _buildRuleTile(
              context,
              icon: Icons.check_circle_outline,
              text: "Make sure to submit your answers before leaving the screen.",
            ),
            const SizedBox(height: 16),
            _buildRuleTile(
              context,
              icon: Icons.warning_amber_rounded,
              text: "Switching applications during the test may result in a penalty.",
              iconColor: Colors.orange.shade700,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  // --- NEW: Helper widget for a single rule in the dialog ---
  Widget _buildRuleTile(BuildContext context, {required IconData icon, required String text, Color? iconColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(child: Text(text)),
      ],
    );
  }

  @override
  void dispose() {
    _testIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a Test'),
        centerTitle: true,
        // --- MODIFICATION: Added actions for the info button ---
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Test Rules',
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enter Test ID',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please enter the unique ID provided by the test creator to begin.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _testIdController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                        labelText: 'Unique Test ID',
                        hintText: 'e.g., QKDT-2025-JULY',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a test ID';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _isLoading ? null : _submitJoinTest,
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 3),
                            )
                          : const Text('JOIN TEST'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}