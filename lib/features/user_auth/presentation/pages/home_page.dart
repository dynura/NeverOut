// home_page.dart

import 'package:flutter/material.dart';
import 'package:neverout/features/user_auth/presentation/widgets/app_theme.dart';
import 'package:neverout/features/user_auth/presentation/pages/add_page.dart';
import 'package:neverout/features/user_auth/presentation/pages/inventory_page.dart';
import 'package:neverout/features/user_auth/presentation/pages/profile_page.dart';
import 'package:neverout/features/user_auth/presentation/widgets/app_navigation.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard title
              Text('Dashboard', style: AppTheme.headingLarge()),
              const SizedBox(height: 16),
              
              // Empty state message
              Text(
                "There's nothing here yet.",
                style: AppTheme.bodyMedium(color: AppTheme.thirdColor),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppNavigation.bottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 3) { // Profile tab
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          } else if (index == 1) { // Add tab
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPage()),
              );
            } else if (index == 2) { // Inventory tab
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InventoryPage()),
              );
            }
        },
      ),
    );
  }
}