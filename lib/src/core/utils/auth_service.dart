import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // SIGN UP with email & password
  Future<User?> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // --- ADDED: Send email verification ---
      // Send verification email if the user object is not null.
      if (credential.user != null) {
        await credential.user!.sendEmailVerification();
      }
      
      return credential.user;
    } on FirebaseAuthException catch (e) {
      // Re-throw the exception to be handled by the UI.
      // This allows for specific error messages on the UI side.
      rethrow;
    }
  }

  // SIGN IN with email & password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // --- ADDED: Check if email is verified ---
      if (credential.user != null && !credential.user!.emailVerified) {
         // If email is not verified, sign the user out and throw a specific error.
         // The UI layer will catch this and show an appropriate message.
         await _auth.signOut();
         throw FirebaseAuthException(
           code: 'email-not-verified',
           message: 'Please verify your email before signing in.',
         );
      }
      return credential.user;
    } on FirebaseAuthException {
        // Re-throw the exception to be handled by the UI.
        rethrow;
    }
  }

  // SIGN IN with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Error during Google sign in: $e");
      return null;
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    // It's good practice to also sign out from Google if the user signed in with it.
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }
}
