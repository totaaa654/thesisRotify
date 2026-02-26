import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_nav.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  // Controllers
  late TextEditingController emailController;
  late TextEditingController passwordController;

  // State variables
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;

  // Registered emails from Firebase
  List<String> registeredEmails = [];

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    _loadRegisteredEmails(); // Fetch emails from Firestore
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Fetch emails from Firestore "users" collection
  void _loadRegisteredEmails() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        registeredEmails =
            snapshot.docs.map((doc) => doc['email'] as String).toList();
      });
    } catch (e) {
      debugPrint("Error fetching registered emails: $e");
    }
  }

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

                    // Email Field with Firebase autocomplete
                    const Text('Email', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    _emailFieldWithAutocomplete(),
                    const SizedBox(height: 18),

                    // Password Field
                    const Text('Password', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    _inputField(
                      key: const ValueKey('passwordField'),
                      controller: passwordController,
                      hint: 'Password',
                      obscure: _obscurePassword,
                      isPassword: true,
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Remember Me + Forgot Password
                    Row(
                      children: [
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: StatefulBuilder(
                            builder: (context, setInnerState) {
                              return Checkbox(
                                key: const ValueKey('rememberMeCheckbox'),
                                value: _rememberMe,
                                activeColor: Colors.white,
                                checkColor: const Color(0xFF0B6B3A),
                                side: const BorderSide(color: Colors.white70),
                                onChanged: (value) {
                                  bool newValue = value ?? false;
                                  setInnerState(() => _rememberMe = newValue);
                                  setState(() => _rememberMe = newValue);
                                },
                              );
                            },
                          ),
                        ),
                        const Text(
                          "Keep me logged in",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _forgotPassword,
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
                            ? const CircularProgressIndicator(color: Color(0xFF0B6B3A))
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

  // Email field with autocomplete from Firebase
  Widget _emailFieldWithAutocomplete() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return registeredEmails.where(
          (email) =>
              email.toLowerCase().contains(textEditingValue.text.toLowerCase()),
        );
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        emailController = controller;
        return TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Email',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        );
      },
      onSelected: (String selection) {
        emailController.text = selection;
      },
    );
  }

  // Regular input field for password
  Widget _inputField({
    Key? key,
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    VoidCallback? onToggleVisibility,
  }) {
    return TextField(
      key: key,
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
    );
  }

  void _handleSignIn() async {
    final emailInput = emailController.text.trim();
    final password = passwordController.text.trim();
    if (emailInput.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter email and password', Colors.redAccent);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final error = await _authService.signInStrict(emailInput, password, _rememberMe);
      if (!mounted) return;
      if (error != null) {
        _showSnackBar(error, Colors.redAccent);
        return;
      }
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

  // Forgot Password Flow
  void _forgotPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar('Please enter your email first', Colors.redAccent);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.sendPasswordResetEmail(email);
      _showSnackBar('Password reset email sent! Check your inbox.', Colors.green);
    } catch (e) {
      _showSnackBar('Failed to send reset email. Make sure the email is correct.', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: bgColor,
      ),
    );
  }
}