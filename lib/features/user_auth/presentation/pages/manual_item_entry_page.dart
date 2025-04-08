// manual_item_entry_page.dart
import 'package:flutter/material.dart';
import 'package:neverout/features/user_auth/presentation/widgets/app_theme.dart';
import 'package:neverout/features/user_auth/presentation/widgets/app_navigation.dart';
import 'package:neverout/features/user_auth/presentation/pages/view_items_page.dart';

class ManualItemEntryPage extends StatefulWidget {
  const ManualItemEntryPage({super.key});

  @override
  State<ManualItemEntryPage> createState() => _ManualItemEntryPageState();
}

class _ManualItemEntryPageState extends State<ManualItemEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();
  String _selectedReminder = '3 days before';
  final List<String> _reminderOptions = [
    '1 day before',
    '3 days before',
    '1 week before'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavigation.appBar('Add Item Manually'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Item name
            Text('Item Name', style: AppTheme.bodyMedium()),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: AppTheme.inputDecoration(hintText: 'Enter item name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an item name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            // Expiry date
            Text('Expiry Date', style: AppTheme.bodyMedium()),
            const SizedBox(height: 8),
            TextFormField(
              controller: _expiryController,
              decoration: AppTheme.inputDecoration(hintText: 'YYYY-MM-DD'),
              readOnly: true,
              onTap: () => _selectDate(context),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select an expiry date';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            // Reminder setting
            Text('Set Reminder', style: AppTheme.bodyMedium()),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedReminder,
              decoration: AppTheme.inputDecoration(),
              items: _reminderOptions.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReminder = value!;
                });
              },
            ),
            
            const SizedBox(height: 32),
            
            // Add button
            ElevatedButton(
              onPressed: _saveItem,
              style: AppTheme.primaryButtonStyle,
              child: Text(
                'Add Item',
                style: AppTheme.buttonText(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    
    if (picked != null) {
      setState(() {
        _expiryController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      // Create the new item
      final newItem = {
        'name': _nameController.text,
        'expiryDate': _expiryController.text,
        'daysLeft': _calculateDaysLeft(_expiryController.text),
        'reminderSetting': _selectedReminder,
      };
      
      // Here you would save to your database
      // For now, navigate to view items page with just this item
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ViewItemsPage(
            items: [newItem],
          ),
        ),
      );
    }
  }

  int _calculateDaysLeft(String expiryDateStr) {
    try {
      final expiryDate = DateTime.parse(expiryDateStr);
      final today = DateTime.now();
      return expiryDate.difference(today).inDays;
    } catch (e) {
      return 0;
    }
  }
}
