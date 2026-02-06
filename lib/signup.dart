import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_nav.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  // Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 30),
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
                  Row(
                    children: [
                      Expanded(
                        child: _labelAndField(
                            controller: firstNameController,
                            label: 'First Name',
                            hint: 'First Name'),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _labelAndField(
                            controller: middleNameController,
                            label: 'Middle Name (Optional)',
                            hint: 'Middle Name'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _labelAndField(
                      controller: lastNameController,
                      label: 'Last Name',
                      hint: 'Last Name'),
                  const SizedBox(height: 14),
                  _labelAndField(
                      controller: emailController,
                      label: 'Email',
                      hint: 'Email',
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 14),
                  _labelAndField(
                      controller: passwordController,
                      label: 'Password',
                      hint: 'Password',
                      obscure: true),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 220,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignup,
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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Already have an account?\nSign in',
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

  // ================= SIGN UP HANDLER =================
  void _handleSignup() async {
  final firstName = firstNameController.text.trim();
  final middleName = middleNameController.text.trim();
  final lastName = lastNameController.text.trim();
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill in all required fields.')),
    );
    return;
  }

  if (!email.contains('@')) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a valid email address.')),
    );
    return;
  }

  if (password.length < 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password must be at least 6 characters long.')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    // 1️⃣ Sign up in Firebase Auth
    final authError = await _authService.signUp(email, password);
    if (authError != null) throw authError;

    // 2️⃣ Update display name (does not require Firestore)
    await _authService.updateDisplayName('$firstName $lastName');

    // ✅ For testing, skip Firestore write
    // await _dbService.createUser(...);

    // 3️⃣ Navigate to Home
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signup successful!')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeNav()),
    );
  } catch (e) {
    // Delete Auth user if something fails
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        await currentUser.delete();
      } catch (_) {}
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signup failed: $e')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}


  // ================= HELPER WIDGET =================
  static Widget _labelAndField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
