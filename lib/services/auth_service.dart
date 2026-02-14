import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getter to get current user data
  User? get currentUser => _auth.currentUser;

  /// ✅ CASE-SENSITIVE LOGIN
  /// This checks if the casing matches exactly what was registered.
  Future<String?> signInStrict(String inputEmail, String password) async {
    try {
      // 1. Firebase standard login (case-insensitive)
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: inputEmail, password: password);

      // 2. Get the exact email stored in Firebase
      String? officialEmail = credential.user?.email;

      // 3. Compare the typed email with the official email
      if (officialEmail != inputEmail) {
        await signOut(); // Kick them out if casing is wrong
        return 'Email casing is incorrect. Please use the exact casing used during registration.';
      }

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
    }
  }

  // Standard sign in (backwards compatibility)
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed.';
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'weak-password':
          return 'The password provided is too weak.';
        default:
          return e.message;
      }
    }
  }

  Future<void> signOut() async => await _auth.signOut();

  /// ✅ RESTORED: Update Display Name
  Future<String?> updateDisplayName(String newName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'No user logged in';
      await user.updateDisplayName(newName);
      await user.reload();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to update name.';
    }
  }

  /// ✅ RESTORED: Update Email
  Future<String?> updateEmail(String newEmail, String currentPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'No user logged in';

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      final actionCodeSettings = ActionCodeSettings(
        url: 'https://thesis-rotify.firebaseapp.com',
        handleCodeInApp: true,
        androidPackageName: 'com.example.rotify_app',
        androidInstallApp: true,
        androidMinimumVersion: '1',
      );

      await user.verifyBeforeUpdateEmail(newEmail, actionCodeSettings);
      return 'Success: Check $newEmail for a link and try again!';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-mismatch') {
        return 'Your email is already changed. Please sign in again.';
      }
      return e.message;
    }
  }

  /// ✅ RESTORED: Update Password
  Future<String?> updatePassword(
      String newPassword, String currentPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'No user logged in';

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      await user.reload();

      return null; // Success (change logic in settings.dart if it expects a string)
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to update password.';
    }
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
