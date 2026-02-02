import 'package:flutter/material.dart';
import 'dashboard_content.dart';

class HomeNav extends StatefulWidget {
  const HomeNav({super.key});

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardContent(),
    HistoryContent(),
    SettingsContent(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ================= BODY =================
      body: Column(
        children: [
          // ---------- HEADER ----------
          Container(
            padding: const EdgeInsets.fromLTRB(20, 46, 20, 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF004C22), Color(0xFF00B250)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
            child: Row(
              children: [
                Image.asset('assets/images/logo.png', width: 42),
                const SizedBox(width: 12),
                const Text(
                  'ROTIFY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // ---------- CONTENT ----------
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: Padding(
                key: ValueKey(_currentIndex),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: _pages[_currentIndex],
              ),
            ),
          ),
        ],
      ),

      // ================= FOOTER =================
      bottomNavigationBar: Container(
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(0.08)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              selected: _currentIndex == 0,
              onTap: () => _onTab(0),
            ),
            _NavItem(
              icon: Icons.history_rounded,
              label: 'History',
              selected: _currentIndex == 1,
              onTap: () => _onTab(1),
            ),
            _NavItem(
              icon: Icons.settings_rounded,
              label: 'Settings',
              selected: _currentIndex == 2,
              onTap: () => _onTab(2),
            ),
          ],
        ),
      ),
    );
  }

  void _onTab(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }
}

// =================================================
// BOTTOM NAV ITEM
// =================================================
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF00B250) : Colors.grey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        width: 90,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================
// PLACEHOLDER PAGES
// =================================================
class HistoryContent extends StatelessWidget {
  const HistoryContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'History\n(sensor logs later)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Settings\n(profile, logout, thresholds)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
