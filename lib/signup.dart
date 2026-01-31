import 'package:flutter/material.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF004C22), Color(0xFF00B250)],
              ),
            ),
          ),

          // Bottom mist fade (won't block taps)
          IgnorePointer(
            ignoring: true,
            child: Align(
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
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // Logo
                  Image.asset('assets/images/logo.png', width: 80, height: 80),

                  const SizedBox(height: 16),

                  const Text(
                    'Sign up to Rotify',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 26),

                  // First + Middle name row
                  Row(
                    children: [
                      Expanded(
                        child: _labelAndField(
                          label: 'First name',
                          hint: 'Value',
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _labelAndField(
                          label: 'Middle Name',
                          hint: 'Value',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Last name
                  _labelAndField(label: 'Last Name', hint: 'Value'),

                  const SizedBox(height: 14),

                  // Email
                  _labelAndField(
                    label: 'Email',
                    hint: 'Value',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 14),

                  // Password
                  _labelAndField(
                    label: 'Password',
                    hint: 'Value',
                    obscure: true,
                  ),

                  const SizedBox(height: 24),

                  // SIGN UP button
                  SizedBox(
                    width: 220,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: create account
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0B6B3A),
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'SIGN UP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Already have an account? Sign in
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // back to previous
                    },
                    child: const Text(
                      'Already  have an account?\nSign in',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, height: 1.4),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _labelAndField({
    required String label,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 6),
        TextField(
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
