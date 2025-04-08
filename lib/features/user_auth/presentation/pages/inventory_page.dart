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
    {
      'name': 'Apples',
      'quantity': '6 pieces',
      'category': 'Food',
      'icon': Icons.apple,
    },
    {
      'name': 'Shampoo',
      'quantity': '400 ml',
      'category': 'Personal Care',
      'icon': Icons.shower,
    },
    {
      'name': 'Toothpaste',
      'quantity': '1 tube',
      'category': 'Personal Care',
      'icon': Icons.brush,
    },
    {
      'name': 'Orange Juice',
      'quantity': '1 litre',
      'category': 'Beverages',
      'icon': Icons.local_drink,
    },
    {
      'name': 'Bread',
      'quantity': '2 loaves',
      'category': 'Food',
      'icon': Icons.bakery_dining,
    },
    {
      'name': 'Laundry Detergent',
      'quantity': '1 bottle',
      'category': 'Cleaning',
      'icon': Icons.local_laundry_service,
    },
    {
      'name': 'Floor Cleaner',
      'quantity': '2 bottles',
      'category': 'Cleaning',
      'icon': Icons.cleaning_services,
    },
    {
      'name': 'Dog Treats',
      'quantity': '500 g',
      'category': 'Pet Supplies',
      'icon': Icons.pets,
    },
    {
      'name': 'Cat Litter',
      'quantity': '5 kg',
      'category': 'Pet Supplies',
      'icon': Icons.pets,
    },
    {
      'name': 'Soda',
      'quantity': '6 cans',
      'category': 'Beverages',
      'icon': Icons.local_drink,
    },
    {
      'name': 'Cereal',
      'quantity': '1 box',
      'category': 'Food',
      'icon': Icons.breakfast_dining,
    },
    {
      'name': 'Hand Soap',
      'quantity': '2 bottles',
      'category': 'Personal Care',
      'icon': Icons.soap,
    },
    {
      'name': 'Tissues',
      'quantity': '3 boxes',
      'category': 'Personal Care',
      'icon': Icons.airline_seat_legroom_reduced,
    },
    {
      'name': 'Batteries',
      'quantity': '8 AA',
      'category': 'Others',
      'icon': Icons.battery_full,
    },
    {
      'name': 'Light Bulbs',
      'quantity': '4 bulbs',
      'category': 'Others',
      'icon': Icons.lightbulb,
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

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(item['icon'], color: AppTheme.primaryColor),
          ),
          title: Text(
            item['name'],
            style: AppTheme.bodyMedium().copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(item['category'], style: AppTheme.bodySmall()),
          trailing: Text(item['quantity'], style: AppTheme.bodyMedium()),
          onTap: () => _showItemDetails(item),
        );
      },
    );
  }

  void _showItemDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(item['name'], style: AppTheme.headingMedium()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Icon(Icons.category, color: AppTheme.primaryColor),
                  title: Text('Category', style: AppTheme.bodyMedium()),
                  subtitle: Text(item['category']),
                ),
                ListTile(
                  leading: Icon(Icons.scale, color: AppTheme.primaryColor),
                  title: Text('Quantity', style: AppTheme.bodyMedium()),
                  subtitle: Text(item['quantity']),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close', style: AppTheme.bodyMedium()),
              ),
            ],
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
