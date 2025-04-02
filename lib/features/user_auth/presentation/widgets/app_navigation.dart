// app_navigation.dart

import 'package:flutter/material.dart';
import 'package:neverout/features/user_auth/presentation/widgets/app_theme.dart';

class AppNavigation {
  // Define page titles
  static const Map<int, String> pageTitles = {
    0: 'Dashboard',
    1: 'Add',
    2: 'Inventory',
    3: 'Profile',
  };

  // Get title for specific page index
  static String getPageTitle(int index) {
    return pageTitles[index] ?? 'NeverOut';
  }

  // Standard app bar
  static AppBar appBar(String title, {List<Widget>? actions, bool automaticallyImplyLeading = true}) {
    return AppBar(
      title: Text(
        title,
        style: AppTheme.headingMedium(color: AppTheme.primaryColor),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
    );
  }

  // Bottom navigation bar
  static BottomNavigationBar bottomNavigationBar({
    required int currentIndex,
    required Function(int) onTap,
  }) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: AppTheme.thirdColor,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Add',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}