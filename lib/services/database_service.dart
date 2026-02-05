import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ================= CREATE USER =================
  /// Save user info after signup
  Future<void> createUser({
    required String firstName,
    String? middleName,
    required String lastName,
    required String email,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await _db.collection('users').doc(uid).set({
        'firstName': firstName,
        'middleName': middleName ?? '',
        'lastName': lastName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Throw the error so the signup handler can catch it
      throw 'Failed to create user: $e';
    }
  }

  /// ================= GET FIRST NAME =================
  /// Fetch first name for greeting
  Future<String> getFirstName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 'User';

    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return 'User';

      final data = doc.data()!;
      return data['firstName'] ?? 'User';
    } catch (e) {
      return 'User';
    }
  }

  /// ================= UPDATE USER =================
  /// Update first name, middle name, or last name later
  Future<void> updateUser({
    String? firstName,
    String? middleName,
    String? lastName,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final Map<String, dynamic> updateData = {};

    if (firstName != null) updateData['firstName'] = firstName;
    if (middleName != null) updateData['middleName'] = middleName;
    if (lastName != null) updateData['lastName'] = lastName;

    if (updateData.isNotEmpty) {
      try {
        await _db.collection('users').doc(uid).update(updateData);
      } catch (e) {
        throw 'Failed to update user: $e';
      }
    }
  }
}
