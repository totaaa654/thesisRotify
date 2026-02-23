import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Import this
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'login.dart'; 
import 'home_nav.dart'; 
import 'home_page.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ THE FIX: Check if the user wanted to be remembered
  final prefs = await SharedPreferences.getInstance();
  final bool rememberMe = prefs.getBool('remember_me') ?? false;

  // If Firebase thinks someone is logged in, but 'rememberMe' is false, force sign out.
  if (!rememberMe) {
    await FirebaseAuth.instance.signOut();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        // This stream will now reflect the signOut() we did in main()
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasData && snapshot.data != null) {
            return const HomeNav(); 
          }

          return const HomePage(); 
        },
      ),
      routes: {
        '/login': (context) => const LoginPage(), 
      },
    );
  }
}