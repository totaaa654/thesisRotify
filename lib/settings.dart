import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    });
  }

  Future<void> _saveNotificationPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);

    if (!mounted) return;
    setState(() {
      notificationsEnabled = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? 'Notifications enabled' : 'Notifications disabled',
        ),
        backgroundColor: const Color(0xFF00B250),
      ),
    );
  }

  String get userName {
    final user = _authService.currentUser;
    if (user == null) return "User";
    return user.displayName ?? "User";
  }

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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) return;

              try {
                final user = _authService.currentUser;
                if (user != null) {
                  await user.updateDisplayName(newName);
                  await user.reload();
                }

                if (!mounted) return;
                Navigator.pop(context);
                setState(() {});

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Name updated successfully"),
                    backgroundColor: Color(0xFF00B250),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

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
                    icon: Icon(
                      isObscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setDialogState(() => isObscure = !isObscure),
                  ),
                ),
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

                final authResult =
                    await _authService.updateEmail(newEmail, currentPassword);

                if (!mounted) return;

                final bool isSuccess =
                    authResult != null && authResult.contains('Success');
                final bool isMismatch = authResult != null &&
                    authResult.contains('already changed');

                if (isSuccess || isMismatch) {
                  if (isSuccess) {
                    await DatabaseService().updateUser(email: newEmail);
                  }

                  if (!mounted) return;
                  Navigator.pop(context);
                  setState(() {});

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(authResult!),
                      backgroundColor: const Color(0xFF00B250),
                    ),
                  );

                  if (isMismatch) {
                    await _authService.signOut();
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(authResult ?? "Error updating email"),
                    ),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final TextEditingController currentPassController = TextEditingController();
    final TextEditingController newPassController = TextEditingController();

    bool isObscureCurrent = true;
    bool isObscureNew = true;

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
                obscureText: isObscureCurrent,
                decoration: InputDecoration(
                  labelText: "Current Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      isObscureCurrent
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () => setDialogState(
                      () => isObscureCurrent = !isObscureCurrent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPassController,
                obscureText: isObscureNew,
                decoration: InputDecoration(
                  labelText: "New Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      isObscureNew ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setDialogState(
                      () => isObscureNew = !isObscureNew,
                    ),
                  ),
                ),
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
                final curPass = currentPassController.text.trim();
                final newPass = newPassController.text.trim();

                if (curPass.isEmpty || newPass.isEmpty) {
                  _showSnackBar("Please fill in both fields", Colors.redAccent);
                  return;
                }

                if (curPass == newPass) {
                  _showSnackBar(
                    "New password cannot be the same as your current password.",
                    Colors.redAccent,
                  );
                  return;
                }

                if (newPass.length < 6) {
                  _showSnackBar(
                    "New password must be at least 6 characters.",
                    Colors.redAccent,
                  );
                  return;
                }

                final result =
                    await _authService.updatePassword(newPass, curPass);

                if (!mounted) return;

                if (result == null) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Password changed successfully. Please log in again.",
                      ),
                      backgroundColor: Color(0xFF00B250),
                    ),
                  );

                  await Future.delayed(const Duration(milliseconds: 500));

                  await _authService.signOut();

                  if (!mounted) return;
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (route) => false);
                } else {
                  _showSnackBar(result, Colors.redAccent);
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to sign out of Rotify?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await _authService.signOut();
              if (!mounted) return;
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text(
              "Sign Out",
              style: TextStyle(color: Colors.red),
            ),
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
        Text(
          "Hi $userName!!",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
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
            _ArrowItem(
                text: 'Change password', onTap: _showChangePasswordDialog),
          ],
        ),
        const SizedBox(height: 20),
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
              onChanged: (value) async {
                await _saveNotificationPreference(value);
              },
            ),
          ],
        ),
        const SizedBox(height: 28),
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
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ElevatedButton.icon(
            onPressed: _showSignOutDialog,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              "SIGN OUT",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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

  const _ArrowItem({
    required this.text,
    required this.onTap,
  });

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
