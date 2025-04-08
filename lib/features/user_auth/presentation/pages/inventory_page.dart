import 'dart:math';
import 'package:flutter/material.dart';
import 'package:neverout/features/user_auth/presentation/widgets/app_theme.dart';
import 'package:neverout/features/user_auth/presentation/widgets/app_navigation.dart';
import 'package:neverout/features/user_auth/presentation/pages/home_page.dart';
import 'package:neverout/features/user_auth/presentation/pages/add_page.dart';
import 'package:neverout/features/user_auth/presentation/pages/profile_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final List<String> categories = [
    'All',
    'Food',
    'Beverages',
    'Cleaning',
    'Personal Care',
    'Pet Supplies',
    'Others',
  ];

  String selectedCategory = 'All';
  String searchQuery = '';

  final List<Map<String, dynamic>> allItems = [
    {'name': 'Apples', 'quantity': '6 pieces', 'count': 6, 'category': 'Food'},
    {
      'name': 'Shampoo',
      'quantity': '400 ml',
      'count': 1,
      'category': 'Personal Care',
    },
    {
      'name': 'Toothpaste',
      'quantity': '1 tube',
      'count': 1,
      'category': 'Personal Care',
    },
    {
      'name': 'Orange Juice',
      'quantity': '1 litre',
      'count': 1,
      'category': 'Beverages',
    },
    {'name': 'Bread', 'quantity': '2 loaves', 'count': 2, 'category': 'Food'},
    {
      'name': 'Laundry Detergent',
      'quantity': '1 bottle',
      'count': 1,
      'category': 'Cleaning',
    },
    {
      'name': 'Floor Cleaner',
      'quantity': '2 bottles',
      'count': 2,
      'category': 'Cleaning',
    },
    {
      'name': 'Dog Treats',
      'quantity': '500 g',
      'count': 1,
      'category': 'Pet Supplies',
    },
    {
      'name': 'Cat Litter',
      'quantity': '5 kg',
      'count': 5,
      'category': 'Pet Supplies',
    },
    {'name': 'Soda', 'quantity': '6 cans', 'count': 6, 'category': 'Beverages'},
    {'name': 'Cereal', 'quantity': '1 box', 'count': 1, 'category': 'Food'},
    {
      'name': 'Hand Soap',
      'quantity': '2 bottles',
      'count': 2,
      'category': 'Personal Care',
    },
    {
      'name': 'Tissues',
      'quantity': '3 boxes',
      'count': 3,
      'category': 'Personal Care',
    },
    {'name': 'Batteries', 'quantity': '8 AA', 'count': 8, 'category': 'Others'},
    {
      'name': 'Light Bulbs',
      'quantity': '4 bulbs',
      'count': 4,
      'category': 'Others',
    },
  ];

  List<Map<String, dynamic>> get filteredItems {
    return allItems.where((item) {
      final matchesCategory =
          selectedCategory == 'All' || item['category'] == selectedCategory;
      final matchesSearch = item['name'].toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory', style: AppTheme.headingLarge()),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 20),
              _buildSectionHeader('Categories'),
              const SizedBox(height: 12),
              _buildCategoryChips(),
              const SizedBox(height: 24),
              _buildSectionHeader('Items'),
              const SizedBox(height: 8),
              Expanded(child: _buildItemList(filteredItems)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppNavigation.bottomNavigationBar(
        currentIndex: 1,
        onTap: (index) => _handleNavigation(index, context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddPage()),
            ),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search items...',
          hintStyle: AppTheme.bodyMedium(color: AppTheme.thirdColor),
          prefixIcon: Icon(Icons.search, color: AppTheme.primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: AppTheme.bodyMedium(),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      children:
          categories.map((category) {
            final isSelected = selectedCategory == category;
            return ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  selectedCategory = category;
                });
              },
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              backgroundColor: AppTheme.secondColor.withOpacity(0.1),
              labelStyle: AppTheme.bodyMedium(),
            );
          }).toList(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTheme.headingMedium().copyWith(color: AppTheme.secondColor),
    );
  }

  Widget _buildItemList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Center(
        child: Text('No items found.', style: AppTheme.bodyMedium()),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final daysLeft = Random().nextInt(10) + 1;
        final isLowStock = item['count'] < 3;

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Categories',
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
                  if (isLowStock)
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
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddPage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }
}
