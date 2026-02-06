import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ================= CURRENT USER =================
  User? get currentUser => _auth.currentUser;

  // ================= SIGN IN =================
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'invalid-email':
          return 'Invalid email.';
        default:
          return e.message ?? 'Login failed.';
      }
    }
  }

  // ================= SIGN UP =================
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // ================= SIGN OUT =================
  Future<void> signOut() async => await _auth.signOut();

  // ================= REAUTHENTICATE =================
  Future<String?> reauthenticate(String currentPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'No user logged in';

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Reauthentication failed.';
    }
  }

 // ================= UPDATE EMAIL =================
  Future<String?> updateEmail(String newEmail, String currentPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'No user logged in';

      // PRINT THIS to your console to debug the mismatch
      print("Current User in Firebase: ${user.email}");
      print("Password being sent: $currentPassword");

      // 1. Re-authenticate using the CURRENT email on file
      final credential = EmailAuthProvider.credential(
        email: user.email!, // This is the old email
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // 2. Configure the link settings
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://thesis-rotify.firebaseapp.com', // Must be in Authorized Domains
        handleCodeInApp: true,
        androidPackageName: 'com.example.rotify_app', // Check your build.gradle
        androidInstallApp: true,
        androidMinimumVersion: '1',
      );

      // 3. Send the link to the NEW address
      await user.verifyBeforeUpdateEmail(newEmail, actionCodeSettings); 
      
      return 'Success: Check $newEmail for a link!';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-mismatch') {
        return 'Your email is already changed. Please sign in again.';
      }
      return e.message;
    }
  }
  // ================= UPDATE PASSWORD =================
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

      return 'Password updated successfully.';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to update password.';
    }
  }

  // ================= UPDATE DISPLAY NAME =================
  // This fixes the 'updateDisplayName' error in settings.dart
  Future<String?> updateDisplayName(String newName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'No user logged in';

      await user.updateDisplayName(newName);
      await user.reload(); // Refresh the user object locally

      return 'Name updated successfully.';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to update name.';
    }
  }

  // ================= SEND PASSWORD RESET EMAIL =================
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}