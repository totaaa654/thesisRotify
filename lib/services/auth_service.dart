import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found': return 'No user found for that email.';
        case 'wrong-password': return 'Incorrect password.';
        case 'invalid-email': return 'Invalid email address.';
        case 'user-disabled': return 'This user account has been disabled.';
        default: return e.message ?? 'Login failed.';
      }
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      // BETTER ERROR HANDLING FOR SIGNUP
      switch (e.code) {
        case 'email-already-in-use': return 'This email is already registered.';
        case 'invalid-email': return 'The email address is not valid.';
        case 'weak-password': return 'The password provided is too weak.';
        default: return e.message;
      }
    }
  }

  Future<void> signOut() async => await _auth.signOut();

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

  Future<String?> updatePassword(String newPassword, String currentPassword) async {
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

      return 'Success: Password updated successfully.';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to update password.';
    }
  }

  Future<String?> updateDisplayName(String newName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'No user logged in';
      await user.updateDisplayName(newName);
      
      // CRITICAL: Always reload the user to sync local state with Firebase
      await user.reload(); 
      
      return 'Name updated successfully.';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to update name.';
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

  // OPTIONAL: Delete account if Firestore fails during signup
  Future<void> deleteCurrentUser() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      print("Error deleting user: $e");
    }
  }
}