import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'login.dart';
import 'home_nav.dart';
import 'home_page.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
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

      final hasSeenGetStarted = prefs.getBool('has_seen_get_started') ?? false;
      final rememberMe = prefs.getBool('remember_me') ?? false;
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        if (!rememberMe) {
          await FirebaseAuth.instance.signOut();
          _startPage = const LoginPage();
        } else {
          _startPage = const HomeNav();
        }
      } else {
        _startPage = hasSeenGetStarted ? const LoginPage() : const HomePage();
      }

      await Future.delayed(const Duration(milliseconds: 6200));
    } catch (e) {
      debugPrint("AuthWrapper Error: $e");
      _startPage = const LoginPage();

      await Future.delayed(const Duration(milliseconds: 6200));
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
    if (_isLoading) {
      return const SplashScreen();
    }
    return _startPage;
  }
}
