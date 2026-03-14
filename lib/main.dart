import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'login.dart';
import 'home_nav.dart';
import 'home_page.dart'; // Get Started page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // The "home" is the entry point
      home: const AuthWrapper(),
      // ✅ ADDED: Route table so pushNamed('/login') works in other files
      routes: {
        '/login': (context) => const LoginPage(),
        '/home_nav': (context) => const HomeNav(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  Widget _startPage = const SplashScreen();

  @override
  void initState() {
    super.initState();
    _determineStartPage();
  }

  Future<void> _determineStartPage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1️⃣ Check if user has seen Get Started
      final hasSeenGetStarted = prefs.getBool('has_seen_get_started') ?? false;

      // 2️⃣ Check if user wants to stay logged in
      final rememberMe = prefs.getBool('remember_me') ?? false;

      // 3️⃣ Check Firebase auth state
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        if (!rememberMe) {
          // If they didn't check "Remember Me", sign them out immediately
          await FirebaseAuth.instance.signOut();
          _startPage = const LoginPage();
        } else {
          // Logged in and "Remember Me" is true
          _startPage = const HomeNav();
        }
      } else {
        // Not logged in: Show Get Started or Login
        _startPage = hasSeenGetStarted ? const LoginPage() : const HomePage();
      }
    } catch (e) {
      debugPrint("AuthWrapper Error: $e");
      _startPage = const LoginPage();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show splash until we know which page to show
    if (_isLoading) {
      return const SplashScreen();
    }
    return _startPage;
  }
}