import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getter to get current user data
  User? get currentUser => _auth.currentUser;

  /// ✅ CASE-SENSITIVE LOGIN WITH MANUAL PERSISTENCE
  Future<String?> signInStrict(String inputEmail, String password, bool rememberMe) async {
    try {
      // 1. Perform the sign in
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: inputEmail, password: password);

      String? officialEmail = credential.user?.email;

      // 2. Case-sensitive check
      if (officialEmail != inputEmail) {
        await _auth.signOut();
        return 'Email casing is incorrect. Please use the exact casing used during registration.';
      }

      // 3. Email verification check
      if (credential.user != null && !credential.user!.emailVerified) {
        await _auth.signOut();
        return 'Please verify your email before logging in.';
      }

      // 4. ✅ SAVE PERSISTENCE CHOICE
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', rememberMe);

      return null; // Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        default:
          return e.message ?? 'Login failed.';
      }
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  /// ✅ ADDED: UPDATE PASSWORD (Fixes Settings error)
  /// Requires current password for re-authentication (Firebase safety requirement)
  Future<String?> updatePassword(String newPassword, String currentPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'No user logged in';

      // Re-authentication is mandatory for sensitive security changes
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      await user.reload();

      return null; // Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          return 'The current password provided is incorrect.';
        case 'weak-password':
          return 'The new password is too weak.';
        default:
          return e.message ?? 'Failed to update password.';
      }
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  /// ✅ UPDATED SIGN OUT
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', false); // Reset the flag
      await _auth.signOut();
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }

  /// SIGN UP (Sends verification email)
  Future<String?> signUp(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await credential.user?.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'weak-password':
          return 'The password provided is too weak.';
        default:
          return e.message;
      }
    }
  }

  /// RESET PASSWORD
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// UPDATE DISPLAY NAME
  Future<String?> updateDisplayName(String newName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'No user logged in';
      await user.updateDisplayName(newName);
      await user.reload();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to update name.';
    }
  }

  /// UPDATE EMAIL (Requires re-authentication)
  Future<String?> updateEmail(String newEmail, String currentPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'No user logged in';

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.verifyBeforeUpdateEmail(newEmail);
      return 'Success: Check $newEmail for a link!';
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}