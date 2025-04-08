import 'dart:math';
import 'package:flutter/material.dart';
import 'package:neverout/features/user_auth/presentation/widgets/app_theme.dart';
import 'package:neverout/features/user_auth/presentation/widgets/app_navigation.dart';
import 'package:neverout/features/user_auth/presentation/pages/add_page.dart';
import 'package:neverout/features/user_auth/presentation/pages/profile_page.dart';
import 'package:neverout/features/user_auth/presentation/pages/inventory_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final lowStockItems = allItems.where((item) => item['count'] < 3).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: AppTheme.headingLarge().copyWith(color: AppTheme.primaryColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Summary', style: AppTheme.headingMedium()),

              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  double boxWidth = (constraints.maxWidth - 24) / 2;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildResponsiveSummaryCard('Total Items', '9', Icons.inventory_2_outlined, boxWidth),
                      _buildResponsiveSummaryCard('Shopping List', '4', Icons.shopping_cart_outlined, boxWidth),
                      _buildResponsiveSummaryCard('Expiring Soon', '2', Icons.access_time_outlined, boxWidth),
                      _buildResponsiveAddItemCard(context, boxWidth),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),
              Text(
                'Low Stock Items',
                style: AppTheme.headingMedium().copyWith(
                  color: AppTheme.secondColor,
                ),
              ),
              const SizedBox(height: 16),
              _buildLowStockList(lowStockItems),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppNavigation.bottomNavigationBar(
        currentIndex: 0,
        onTap: (index) => _handleNavigation(index, context),
      ),
    );
  }

  Widget _buildResponsiveSummaryCard(String title, String count, IconData icon, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF2),
        border: Border.all(color: AppTheme.primaryColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(count, style: AppTheme.headingLarge().copyWith(color: AppTheme.primaryColor)),
          const SizedBox(height: 8),
          Icon(icon, color: AppTheme.primaryColor, size: 28),
          const SizedBox(height: 4),
          Text(title, style: AppTheme.bodySmall().copyWith(color: AppTheme.primaryColor)),
        ],
      ),
    );
  }

  Widget _buildResponsiveAddItemCard(BuildContext context, double width) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPage()));
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Add Items',
            style: AppTheme.bodyMedium().copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLowStockList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'All items are sufficiently stocked.',
          style: AppTheme.bodyMedium(),
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = items[index];
        final daysLeft = Random().nextInt(10) + 1;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.95),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['name'],
                    style: AppTheme.bodyMedium().copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['category'],
                      style: AppTheme.bodySmall().copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item['quantity'],
                style: AppTheme.bodySmall().copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildStatusTag('Low in stock', Colors.pink.shade300),
                  const SizedBox(width: 8),
                  _buildStatusTag('$daysLeft days left', Colors.white),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusTag(String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTheme.bodySmall().copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _handleNavigation(int index, BuildContext context) {
    if (index == 1) {
      Navigator.pushNamed(context, '/inventory');
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPage()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
    }
  }
}
