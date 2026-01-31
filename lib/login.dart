import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF004C22), Color(0xFF00B250)],
              ),
            ),
          ),

          // Bottom mist
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 0,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00FFFFFF),
                    Color(0xCCFFFFFF),
                    Color(0xFFFFFFFF),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  Center(
                    child: Image.asset('assets/images/logo.png', width: 80),
                  ),

                  const SizedBox(height: 24),

                  const Center(
                    child: Text(
                      'Log in to Rotify',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Email
                  const Text('Email', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 6),
                  _inputField(hint: 'Value'),

                  const SizedBox(height: 18),

                  // Password
                  const Text(
                    'Password',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  _inputField(hint: 'Value', obscure: true),

                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: forgot password
                      },
                      child: const Text(
                        'forgot password?',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // SIGN IN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: authenticate
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0B6B3A),
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'SIGN IN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // back to signup choice
                      },
                      child: const Text(
                        "Don't have an account?\nSign up",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, height: 1.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _inputField({required String hint, bool obscure = false}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
