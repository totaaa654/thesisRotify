import 'package:flutter/material.dart';
import 'dashboard_content.dart';
import 'settings.dart';

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
    SettingsPage(),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14, // compact header
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF004C22), Color(0xFF00B250)],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // LOGO (moved left, NO SHADOW)
                Transform.translate(
                  offset: const Offset(-8, 0),
                  child: Transform.scale(
                    scale: 4.0,
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/images/full_logo.png',
                      height: 29,
                      fit: BoxFit.contain,
                    ),
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
// HISTORY PLACEHOLDER
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
