// lib/features/user_auth/presentation/pages/email_verification_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neverout/features/user_auth/presentation/widgets/app_theme.dart';
import 'package:neverout/features/user_auth/presentation/pages/home_page.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({Key? key}) : super(key: key);

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Timer _timer;
  bool _isEmailVerified = false;
  bool _canResendEmail = true;
  int _remainingTime = 0;
  late Timer _resendTimer;

  @override
  void initState() {
    super.initState();
    _isEmailVerified = _auth.currentUser?.emailVerified ?? false;

    // If not verified, send verification email and start verification check timer
    if (!_isEmailVerified) {
      sendVerificationEmail();

      // Check verification status every 3 seconds
      _timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    if (_remainingTime > 0) {
      _resendTimer.cancel();
    }
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    // Call reload() to get the latest user info
    await _auth.currentUser?.reload();
    
    setState(() {
      _isEmailVerified = _auth.currentUser?.emailVerified ?? false;
    });

    // If email is verified, cancel the timer and navigate to home
    if (_isEmailVerified) {
      _timer.cancel();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      await user?.sendEmailVerification();
      
      // Disable resend button and start countdown
      setState(() {
        _canResendEmail = false;
        _remainingTime = 60; // 60 seconds cooldown
      });
      
      // Countdown timer for resend button
      _resendTimer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          setState(() {
            if (_remainingTime > 0) {
              _remainingTime--;
            } else {
              _canResendEmail = true;
              timer.cancel();
            }
          });
        },
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent! Check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending verification email: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 100,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 30),
                Text(
                  'Verify your email',
                  style: AppTheme.headingLarge(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'We\'ve sent a verification email to:\n${_auth.currentUser?.email}',
                  style: AppTheme.bodyMedium(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Click the link in the email to verify your account.',
                  style: AppTheme.bodyMedium(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: AppTheme.primaryButtonStyle,
                  onPressed: _canResendEmail ? sendVerificationEmail : null,
                  child: Text(
                    _canResendEmail
                        ? 'Resend Email'
                        : 'Resend in $_remainingTime seconds',
                    style: AppTheme.buttonText(),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  style: AppTheme.textButtonStyle,
                  onPressed: () async {
                    await _auth.signOut();
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    'Cancel',
                    style: AppTheme.bodyMedium(color: AppTheme.primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}