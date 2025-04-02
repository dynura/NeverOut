// main.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:neverout/firebase_options.dart';
import 'package:neverout/features/user_auth/presentation/widgets/app_theme.dart';
import 'package:neverout/features/user_auth/presentation/pages/login_page.dart';
import 'package:neverout/features/user_auth/presentation/pages/home_page.dart';
import 'package:neverout/features/user_auth/presentation/pages/email_verification_page.dart';
import 'package:neverout/features/app/splash_screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase with options from .env
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
      title: 'NeverOut:\nAI Tracking Inventory App',
      theme: ThemeData(
        primaryColor: AppTheme.primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryColor,
          primary: AppTheme.primaryColor,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show splash screen while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // User is logged in
          if (snapshot.hasData) {
            User user = snapshot.data!;
            
            // Check if email is verified
            if (user.emailVerified) {
              return SplashScreen(child: const HomePage());
            } else {
              return SplashScreen(child: const EmailVerificationPage());
            }
          }
          
          // User is not logged in
          return SplashScreen(child: const LoginPage());
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}