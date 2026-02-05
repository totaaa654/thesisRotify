import 'package:flutter/material.dart';
import 'login_signup.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient BG
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF004C22), Color(0xFF00B250)],
              ),
            ),
          ),

          // Bottom white arc
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 170,
              width: double.infinity,
              child: CustomPaint(painter: _BottomArcPainter()),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // HERO LOGO
                  Center(
                    child: Hero(
                      tag: 'rotifyLogo',
                      child: Image.asset('assets/images/logo.png', width: 140),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Welcome to Rotify!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Smart tracking to help you know what's\nfresh and what's not.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 26),

                  // GET STARTED BUTTON
                  SizedBox(
                    width: 220,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginSignupPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0B6B3A),
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'GET STARTED',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final center = Offset(size.width / 2, size.height + 120);
    const radius = 260.0;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
