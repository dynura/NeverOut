// register_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neverout/features/user_auth/presentation/widgets/app_theme.dart';
import 'package:neverout/features/user_auth/presentation/pages/email_verification_page.dart';
import 'package:neverout/features/user_auth/presentation/widgets/password_strength_indicator.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  bool _isPasswordValid = false;
  Map<String, bool> _passwordCriteria = {
    'length': false,
    'uppercase': false,
    'lowercase': false,
    'digit': false,
    'special': false,
  };
  String? _passwordError;
  String _currentPassword = '';
  String? _confirmPasswordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
      // Check if password meets minimum strength requirements
      final hasMinLength = _passwordController.text.length >= 8;
      final hasUppercase = _passwordController.text.contains(RegExp(r'[A-Z]'));
      final hasLowercase = _passwordController.text.contains(RegExp(r'[a-z]'));
      final hasDigits = _passwordController.text.contains(RegExp(r'[0-9]'));
      final hasSpecialChars = _passwordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      
      // Calculate strength score (0-5)
      int strength = 0;
      if (hasMinLength) strength++;
      if (hasUppercase) strength++;
      if (hasLowercase) strength++;
      if (hasDigits) strength++;
      if (hasSpecialChars) strength++;
      
      // Require at least medium strength (score of 3+)
      if (strength < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please create a stronger password')),
        );
        return;
      }

    // Only proceed if password is fully valid
    if (!_isPasswordValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_passwordError ?? 'Please create a valid password')),
      );
      return;
    }

    if (_formKey.currentState!.validate() && _agreeToTerms) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create user account
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Add user details to Firestore
        if (userCredential.user != null) {
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'emailVerified': false,
            'createdAt': Timestamp.now(),
          });
          
          // Navigate to verification page instead of login page
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const EmailVerificationPage()),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An error occurred during registration.';
        
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'An account already exists for that email.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Please provide a valid email address.';
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the terms and conditions')),
      );
    }
  }
  void _validatePassword(String password) {
    setState(() {
      // Check each requirement
      _passwordCriteria['length'] = password.length >= 8;
      _passwordCriteria['uppercase'] = password.contains(RegExp(r'[A-Z]'));
      _passwordCriteria['lowercase'] = password.contains(RegExp(r'[a-z]'));
      _passwordCriteria['digit'] = password.contains(RegExp(r'[0-9]'));
      _passwordCriteria['special'] = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      
      // Determine if password is valid overall
      _isPasswordValid = _passwordCriteria.values.every((isValid) => isValid);
      
      // Set error message if any requirement is not met
      if (password.isEmpty) {
        _passwordError = 'Please enter a password';
      } else if (!_passwordCriteria['length']!) {
        _passwordError = 'Password must be at least 8 characters';
      } else if (!_passwordCriteria['uppercase']!) {
        _passwordError = 'Password must contain at least one uppercase letter';
      } else if (!_passwordCriteria['lowercase']!) {
        _passwordError = 'Password must contain at least one lowercase letter';
      } else if (!_passwordCriteria['digit']!) {
        _passwordError = 'Password must contain at least one digit';
      } else if (!_passwordCriteria['special']!) {
        _passwordError = 'Password must contain at least one special character';
      } else {
        _passwordError = null;
      }

      _currentPassword = password;
    });
  }

  void _validateConfirmPassword(String confirmPassword) {
    setState(() {
      if (confirmPassword.isEmpty) {
        _confirmPasswordError = 'Please confirm your password';
      } else if (confirmPassword != _passwordController.text) {
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Title
                  Text(
                    'NeverOut:\nAI Tracking Inventory App',
                    textAlign: TextAlign.center,
                    style: AppTheme.headingMedium(),
                  ),
                  const SizedBox(height: 50),
                  
                  // Register Title
                  Text(
                    'Register',
                    style: AppTheme.headingLarge(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: AppTheme.inputDecoration(hintText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: AppTheme.inputDecoration(hintText: 'Email Address'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: AppTheme.inputDecoration(hintText: 'Password').copyWith(
                      errorText: _passwordError,
                      suffixIcon: _isPasswordValid 
                          ? const Icon(Icons.check_circle, color: Colors.green) 
                          : null,
                    ),
                    obscureText: true,
                    onChanged: _validatePassword,
                  ),
                  const SizedBox(height: 8),

                  // Password Strength Indicator
                  PasswordStrengthIndicator(password: _currentPassword),
                  const SizedBox(height: 16),
                  
                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: AppTheme.inputDecoration(hintText: 'Confirm Password').copyWith(
                      errorText: _confirmPasswordError,
                    ),
                    obscureText: true,
                    onChanged: _validateConfirmPassword,
                  ),
                  const SizedBox(height: 20),
                  
                  // Terms Checkbox
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _agreeToTerms,
                          activeColor: AppTheme.primaryColor,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'I agree with the terms and conditions',
                          style: AppTheme.bodySmall(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Register Button
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          style: AppTheme.primaryButtonStyle,
                          onPressed: _register,
                          child: Text(
                            'Register',
                            style: AppTheme.buttonText(),
                          ),
                        ),
                  
                  // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: AppTheme.bodySmall(),
                        ),
                        TextButton(
                          style: AppTheme.textButtonStyle,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Login',
                            style: AppTheme.bodySmall(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}