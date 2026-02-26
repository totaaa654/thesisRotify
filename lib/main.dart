import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'login.dart'; 
import 'home_nav.dart'; 

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
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginPage(), 
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  // This function checks the flag and handles the sign-out if needed
  Future<bool> _shouldStayLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final bool rememberMe = prefs.getBool('remember_me') ?? false;
    
    if (!rememberMe) {
      await FirebaseAuth.instance.signOut();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Wait for Firebase connection
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // If a user is found in Firebase, we MUST check SharedPreferences
        if (authSnapshot.hasData && authSnapshot.data != null) {
          return FutureBuilder<bool>(
            future: _shouldStayLoggedIn(),
            builder: (context, prefsSnapshot) {
              if (prefsSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }

              // If our persistence check says false, the check inside 
              // _shouldStayLoggedIn already called signOut(), so we show login
              if (prefsSnapshot.data == false) {
                return const LoginPage();
              }

              // Only if both are true do we go to Home
              return const HomeNav();
            },
          );
        }

        // No user found in Firebase
        return const LoginPage();
      },
    );
  }
}