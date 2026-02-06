import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  final AuthService _authService = AuthService();

  String get userName {
    final user = _authService.currentUser;
    if (user == null) return "User";
    return user.displayName ?? "User";
  }

  // ================= CHANGE NAME DIALOG =================
  void _showChangeNameDialog() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Name"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: "Enter new name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              final result =
                  await _authService.updateDisplayName(nameController.text.trim());

              Navigator.pop(context);
              setState(() {}); // refresh greeting
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result ?? "Name updated successfully"),
                ),
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ================= CHANGE EMAIL DIALOG (FIXED) =================
  void _showChangeEmailDialog() {
    final TextEditingController emailController = TextEditingController(
      text: _authService.currentUser?.email ?? '',
    );
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Email"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "New Email"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Current Password"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
  onPressed: () async {
    final newEmail = emailController.text.trim();
    final currentPassword = passwordController.text.trim();

    if (newEmail.isEmpty || currentPassword.isEmpty) return;

    // 1. Try to update Auth
    final authResult = await _authService.updateEmail(newEmail, currentPassword);

    if (mounted) {
      // 2. CHECK: If the result is a success OR the "already changed" message
      bool isSuccess = authResult != null && authResult.contains('Success');
      bool isMismatchError = authResult != null && authResult.contains('already changed');

      if (isSuccess || isMismatchError) {
        
        // Only try to update Firestore if it was a real success
        if (isSuccess) {
          try {
            await DatabaseService().updateUser(email: newEmail);
          } catch (e) {
            print("Firestore sync failed: $e");
          }
        }

        // 3. CLOSE THE BOX for both success and the mismatch error
        Navigator.pop(context);
        setState(() {}); 
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authResult!)),
        );

        // Optional: If it was the mismatch error, you might want to force sign out
        if (isMismatchError) {
          await _authService.signOut();
          // Navigator.pushReplacement to your Login Page here if desired
        }

      } else {
        // 4. FAILURE: Generic error (like actually wrong password)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authResult ?? "Incorrect password")),
        );
      }
    }
  },
  child: const Text("Save"),
),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      children: [
        // ================= GREETING =================
        Text(
          "Hi $userName!!",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        // ================= ACCOUNT SETTINGS =================
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          leading: const Icon(Icons.person_outline),
          title: const Text(
            'Account Settings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          childrenPadding: const EdgeInsets.only(left: 20, bottom: 10),
          children: [
            _ArrowItem(text: 'Change name', onTap: _showChangeNameDialog),
            _ArrowItem(text: 'Change email', onTap: _showChangeEmailDialog),
            _ArrowItem(text: 'Change password', onTap: () {}),
          ],
        ),
        const SizedBox(height: 20),

        // ================= NOTIFICATIONS =================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.notifications_none, size: 22),
                SizedBox(width: 10),
                Text(
                  'Notifications',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Switch(
              value: notificationsEnabled,
              activeColor: const Color(0xFF00B250),
              onChanged: (value) {
                setState(() => notificationsEnabled = value);
              },
            ),
          ],
        ),
        const SizedBox(height: 28),

        // ================= ABOUT =================
        const Row(
          children: [
            Icon(Icons.info_outline, size: 22),
            SizedBox(width: 10),
            Text(
              'About',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(left: 32, top: 8),
          child: Text(
            'Rotify\nVersion 1.0.0\nDish Spoilage Detection System',
            style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
          ),
        ),
      ],
    );
  }
}

// =================================================
// DROPDOWN ITEM
// =================================================
class _ArrowItem extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _ArrowItem({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.arrow_right, size: 18),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
