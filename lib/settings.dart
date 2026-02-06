import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      children: [
        // ================= ACCOUNT SETTINGS (DROPDOWN) =================
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          leading: const Icon(Icons.person_outline),
          title: const Text(
            'Account Settings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          childrenPadding: const EdgeInsets.only(left: 20, bottom: 10),
          children: [
            _ArrowItem(text: 'Change name', onTap: () {}),
            _ArrowItem(text: 'Change email', onTap: () {}),
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
              activeThumbColor: const Color(0xFF00B250),
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
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
