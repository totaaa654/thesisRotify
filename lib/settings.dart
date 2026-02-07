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

  // Helper to get the display name
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
          decoration: const InputDecoration(hintText: "Enter new name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              final result = await _authService.updateDisplayName(nameController.text.trim());
              if (mounted) {
                Navigator.pop(context);
                setState(() {}); // Refresh the "Hi User" text
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result ?? "Name updated successfully")),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ================= CHANGE EMAIL DIALOG =================
  void _showChangeEmailDialog() {
    final TextEditingController emailController = 
        TextEditingController(text: _authService.currentUser?.email ?? '');
    final TextEditingController passwordController = TextEditingController();
    bool isObscure = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                obscureText: isObscure,
                decoration: InputDecoration(
                  labelText: "Current Password",
                  suffixIcon: IconButton(
                    icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setDialogState(() => isObscure = !isObscure),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final newEmail = emailController.text.trim();
                final currentPassword = passwordController.text.trim();
                if (newEmail.isEmpty || currentPassword.isEmpty) return;

                final authResult = await _authService.updateEmail(newEmail, currentPassword);
                if (mounted) {
                  bool isSuccess = authResult != null && authResult.contains('Success');
                  bool isMismatch = authResult != null && authResult.contains('already changed');

                  if (isSuccess || isMismatch) {
                    if (isSuccess) await DatabaseService().updateUser(email: newEmail);
                    Navigator.pop(context);
                    setState(() {}); 
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authResult!)));
                    if (isMismatch) await _authService.signOut();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(authResult ?? "Error updating email")),
                    );
                  }
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CHANGE PASSWORD DIALOG =================
  void _showChangePasswordDialog() {
    final TextEditingController currentPassController = TextEditingController();
    final TextEditingController newPassController = TextEditingController();
    bool isObscure = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Change Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPassController,
                obscureText: isObscure,
                decoration: const InputDecoration(labelText: "Current Password"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPassController,
                obscureText: isObscure,
                decoration: InputDecoration(
                  labelText: "New Password",
                  suffixIcon: IconButton(
                    icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setDialogState(() => isObscure = !isObscure),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final curPass = currentPassController.text.trim();
                final newPass = newPassController.text.trim();
                if (curPass.isEmpty || newPass.isEmpty) return;

                final result = await _authService.updatePassword(newPass, curPass);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result ?? "Error updating password")),
                  );
                  if (result != null && result.contains('Success')) Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SIGN OUT DIALOG =================
  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to sign out of Rotify?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                // Adjust '/login' to your actual login route name or use MaterialPageRoute
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            child: const Text("Sign Out", style: TextStyle(color: Colors.red)),
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
        // Greeting
        Text("Hi $userName!!", 
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),

        // Account Settings Group
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          leading: const Icon(Icons.person_outline),
          title: const Text('Account Settings', 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          childrenPadding: const EdgeInsets.only(left: 20, bottom: 10),
          children: [
            _ArrowItem(text: 'Change name', onTap: _showChangeNameDialog),
            _ArrowItem(text: 'Change email', onTap: _showChangeEmailDialog),
            _ArrowItem(text: 'Change password', onTap: _showChangePasswordDialog),
          ],
        ),
        const SizedBox(height: 20),

        // Notifications Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: const [
              Icon(Icons.notifications_none, size: 22),
              SizedBox(width: 10),
              Text('Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ]),
            Switch(
              value: notificationsEnabled,
              activeColor: const Color(0xFF00B250),
              onChanged: (value) => setState(() => notificationsEnabled = value),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // About Section
        const Row(children: [
          Icon(Icons.info_outline, size: 22),
          SizedBox(width: 10),
          Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ]),
        const Padding(
          padding: EdgeInsets.only(left: 32, top: 8),
          child: Text('Rotify\nVersion 1.0.0\nDish Spoilage Detection System', 
            style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.5)),
        ),

        const SizedBox(height: 40),

        // Sign Out Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ElevatedButton.icon(
            onPressed: _showSignOutDialog,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text("SIGN OUT", style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

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
        child: Row(children: [
          const Icon(Icons.arrow_right, size: 18),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}