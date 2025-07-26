import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:quick_dot_test/src/core/utils/auth_service.dart';
import 'package:quick_dot_test/src/logic/user_provider.dart';
import 'package:quick_dot_test/src/presentation/screens/home_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome'),
          centerTitle: true,
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Sign In'),
              Tab(text: 'Sign Up'),
            ],
            indicatorWeight: 3.0,
            indicatorColor: Theme.of(context).colorScheme.secondary,
          ),
        ),
        body: const TabBarView(
          children: [
            _SignInView(),
            _SignUpView(),
          ],
        ),
      ),
    );
  }
}

// --- SIGN IN VIEW (FIXED) ---
class _SignInView extends StatefulWidget {
  const _SignInView();

  @override
  State<_SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<_SignInView> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Step 1: Sign in with Firebase Auth
      final user = await _authService.signInWithEmailPassword(email, password);
      if (!mounted) return;


      // Step 2: Fetch user data via the provider using the correct ID
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.fetchUser(userId: user!.uid, email: email);

      // Step 3: Navigate to home screen on success
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String errorMessage = 'An error occurred. Please check your credentials.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = 'Invalid email or password. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load user profile: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
            obscureText: true,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _signIn,
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('SIGN IN'),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(child: Text('OR')),
          ),
          const _GoogleSignInButton(),
        ],
      ),
    );
  }
}

// --- SIGN UP VIEW (No changes needed) ---
class _SignUpView extends StatefulWidget {
  const _SignUpView();
  @override
  State<_SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<_SignUpView> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _showVerificationDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [Icon(Icons.email_outlined, color: Colors.orangeAccent), SizedBox(width: 10), Text('Verify Your Email')]),
          content: const Text('A verification link has been sent to your email. Please check your inbox and click the link to verify your account before signing in.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  void _signUp() async {
    if (!mounted) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match!")));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.signUpWithEmailPassword(_emailController.text.trim(), _passwordController.text.trim());
      if (!mounted) return;
      await _showVerificationDialog();
      DefaultTabController.of(context).animateTo(0);
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String errorMessage = 'An unexpected error occurred. Please try again.';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign up failed. Please try again.')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)), keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          TextFormField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)), obscureText: true),
          const SizedBox(height: 16),
          TextFormField(controller: _confirmPasswordController, decoration: const InputDecoration(labelText: 'Confirm Password', prefixIcon: Icon(Icons.lock_outline)), obscureText: true),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _signUp,
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('CREATE ACCOUNT'),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Center(child: Text('OR'))),
          const _GoogleSignInButton(),
        ],
      ),
    );
  }
}


// --- GOOGLE SIGN IN BUTTON (FIXED) ---
class _GoogleSignInButton extends StatefulWidget {
  const _GoogleSignInButton();

  @override
  State<_GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<_GoogleSignInButton> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;



  void _googleSignIn() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Step 1: Sign in with Google
      final user = await _authService.signInWithGoogle();
      if (!mounted) return;

      if (user != null && user.email != null) {
        
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.fetchUser(userId: user.uid, email: user.email!);
        
        if (!mounted) return;
        
        // Step 2: Navigate to home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google Sign-in was cancelled or email is unavailable.')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google Sign-in failed. Please try again.')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : OutlinedButton.icon(
            icon: Image.asset('assets/images/google_logo.png', height: 24.0, width: 24.0, errorBuilder: (context, error, stackTrace) => const Icon(Icons.error_outline)),
            label: const Text('Sign in with Google', style: TextStyle(fontSize: 16)),
            onPressed: _googleSignIn,
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          );
  }
}