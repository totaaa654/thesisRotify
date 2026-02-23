import 'package:flutter/material.dart';
import 'home_nav.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _rememberMe = false; // ✅ Added this back for tracking

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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Center(
                        child:
                            Image.asset('assets/images/logo.png', width: 80)),
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
                    const Text('Email',
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: emailController,
                      hint: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),

                    // Password
                    const Text('Password',
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: passwordController,
                      hint: 'Password',
                      obscure: true,
                    ),
                    
                    // ✅ ADDED CHECKBOX SECTION BACK
                    Row(
                      children: [
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: Colors.white,
                            checkColor: const Color(0xFF0B6B3A),
                            side: const BorderSide(color: Colors.white70),
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                        ),
                        const Text(
                          "Keep me logged in",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            // TODO: implement forgot password
                          },
                          child: const Text('forgot password?',
                              style: TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // SIGN IN BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0B6B3A),
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Color(0xFF0B6B3A))
                            : const Text(
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
                        onTap: () => Navigator.pop(context),
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
          ),
        ],
      ),
    );
  }

  // ================= SIGN-IN HANDLER =================
  void _handleSignIn() async {
    final emailInput = emailController.text.trim();
    final password = passwordController.text.trim();

    if (emailInput.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter email and password', Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ FIXED: Now passing 3 arguments (Email, Password, RememberMe)
      final error = await _authService.signInStrict(emailInput, password, _rememberMe);

      if (!mounted) return;

      if (error != null) {
        _showSnackBar(error, Colors.redAccent);
        return;
      }

      // ✅ Login successful
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeNav()),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Something went wrong. Please try again.', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper to show SnackBar
  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: bgColor,
      ),
    );
  }

  // Input field helper
  static Widget _inputField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}