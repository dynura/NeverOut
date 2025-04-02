// profile_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neverout/features/user_auth/presentation/widgets/app_theme.dart';
import 'package:neverout/features/user_auth/presentation/widgets/app_navigation.dart';
import 'package:neverout/features/user_auth/presentation/pages/home_page.dart';
import 'package:neverout/features/user_auth/presentation/pages/login_page.dart';
import 'package:neverout/features/user_auth/presentation/pages/add_page.dart';
import 'package:neverout/features/user_auth/presentation/pages/inventory_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  bool _isLoading = false;
  String _profileImageUrl = '';
  File? _imageFile;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();
        if (userData.exists && userData.data() != null) {
          Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
          _nameController.text = data['name'] ?? '';
          _emailController.text = user.email ?? '';
          
          // Get profile image URL if exists
          if (data.containsKey('profileImageUrl')) {
            setState(() {
              _profileImageUrl = data['profileImageUrl'] ?? '';
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = _auth.currentUser;
        if (user != null) {
          // Upload image if selected
          String imageUrl = _profileImageUrl;
          if (_imageFile != null) {
            // Create storage reference
            Reference storageRef = _storage.ref().child('profile_images/${user.uid}');
            
            // Upload file
            await storageRef.putFile(_imageFile!);
            
            // Get download URL
            imageUrl = await storageRef.getDownloadURL();
          }
          
          // Update data in Firestore
          await _firestore.collection('users').doc(user.uid).update({
            'name': _nameController.text.trim(),
            'profileImageUrl': imageUrl,
          });

          // Update email if it has changed
          if (user.email != _emailController.text.trim()) {
            await user.updateEmail(_emailController.text.trim());
          }

          // Update password if provided
          if (_passwordController.text.isNotEmpty) {
            await user.updatePassword(_passwordController.text.trim());
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating profile: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Fixed sign out dialog with action buttons
  Future<void> _showSignOutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Sign Out',
            style: AppTheme.bodyMedium(color: AppTheme.secondColor),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: AppTheme.bodyMedium(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: AppTheme.bodyMedium(color: AppTheme.thirdColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Sign Out',
                style: AppTheme.bodyMedium(color: AppTheme.primaryColor),
              ),
              onPressed: () async {
                await _auth.signOut();
                if (mounted) {
                  Navigator.of(context).pop();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove app bar completely - no back icon or sign out icon
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Add Profile title at the top
                      Text('Profile', style: AppTheme.headingLarge()),
                      const SizedBox(height: 24),
                      
                      // Profile picture
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.primaryColor, width: 2),
                                image: _imageFile != null
                                    ? DecorationImage(
                                        image: FileImage(_imageFile!),
                                        fit: BoxFit.cover,
                                      )
                                    : _profileImageUrl.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(_profileImageUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                              ),
                              child: _imageFile == null && _profileImageUrl.isEmpty
                                  ? const Center(
                                      child: Icon(Icons.person, size: 60, color: AppTheme.primaryColor),
                                    )
                                  : null,
                            ),
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Name field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name', style: AppTheme.bodyMedium()),
                          TextFormField(
                            controller: _nameController,
                            decoration: AppTheme.inputDecoration(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Email field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email Address', style: AppTheme.bodyMedium()),
                          TextFormField(
                            controller: _emailController,
                            decoration: AppTheme.inputDecoration(),
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
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Password field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Password', style: AppTheme.bodyMedium()),
                          TextFormField(
                            controller: _passwordController,
                            decoration: AppTheme.inputDecoration(hintText: 'Leave blank to keep current password'),
                            obscureText: true,
                            validator: (value) {
                              if (value != null && value.isNotEmpty && value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      
                      // Update button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: AppTheme.primaryButtonStyle,
                          onPressed: _updateProfile,
                          child: Text(
                            'Save Changes',
                            style: AppTheme.buttonText(),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Sign out button - with working dialog
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: ButtonStyle(
                            side: MaterialStateProperty.all(
                              const BorderSide(color: AppTheme.primaryColor),
                            ),
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                          onPressed: _showSignOutDialog,
                          child: Text(
                            'Sign Out',
                            style: AppTheme.bodyMedium(color: AppTheme.primaryColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: AppNavigation.bottomNavigationBar(
        currentIndex: 3, // Profile is selected
        onTap: (index) {
          if (index != 3) {
            // If not the current tab (Profile)
            if (index == 0) {
              // Home tab
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPage()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InventoryPage()),
              );
            }
          }
        },
      ),
    );
  }
}
