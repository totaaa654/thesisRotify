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
          return 'Incorrect password. Please try again.';
        case 'invalid-email':
          return 'Invalid email address.';
        default:
          return e.message ?? 'Login failed.';
      }
    }
  }

  // ================= SIGN UP =================
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // ================= SIGN OUT =================
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ================= UPDATE DISPLAY NAME =================
  Future<String?> updateDisplayName(String newName) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(newName);
        await user.reload(); // Refresh user info
      }
      return null;
    } catch (e) {
      return 'Failed to update display name.';
    }
  }

  // Optional alias for convenience
  Future<String?> updateName(String newName) async {
    return await updateDisplayName(newName);
  }

  // ================= REAUTHENTICATE =================
  Future<String?> reauthenticate(String email, String password) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await _auth.currentUser!.reauthenticateWithCredential(credential);
      return null;
    } catch (e) {
      return 'Reauthentication failed.';
    }
  }

  // ================= UPDATE EMAIL =================
  Future<String?> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser!.verifyBeforeUpdateEmail(newEmail);
      return "Verification email sent.";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // ================= UPDATE PASSWORD =================
  Future<String?> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser!.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
