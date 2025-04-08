// item_detail_page.dart
import 'package:flutter/material.dart';
import 'package:neverout/features/user_auth/presentation/widgets/app_theme.dart';
import 'package:neverout/features/user_auth/presentation/widgets/app_navigation.dart';

class ItemDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isEditing;
  
  const ItemDetailPage({
    super.key, 
    required this.item, 
    this.isEditing = false,
  });

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late TextEditingController _nameController;
  late TextEditingController _expiryController;
  late String _selectedReminder;
  final List<String> _reminderOptions = ['1 day before', '3 days before', '1 week before'];
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item['name']);
    _expiryController = TextEditingController(text: widget.item['expiryDate']);
    _selectedReminder = _reminderOptions[1]; // Default to 3 days
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavigation.appBar(
        widget.isEditing ? 'Edit Item' : 'Item Details',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item name
            Text('Item Name', style: AppTheme.bodyMedium()),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: AppTheme.inputDecoration(hintText: 'Enter item name'),
              readOnly: !widget.isEditing,
            ),
            
            const SizedBox(height: 24),
            
            // Expiry date
            Text('Expiry Date', style: AppTheme.bodyMedium()),
            const SizedBox(height: 8),
            TextField(
              controller: _expiryController,
              decoration: AppTheme.inputDecoration(hintText: 'YYYY-MM-DD'),
              readOnly: !widget.isEditing,
              onTap: widget.isEditing ? () => _selectDate(context) : null,
            ),
            
            const SizedBox(height: 24),
            
            // Reminder setting
            Text('Set Reminder', style: AppTheme.bodyMedium()),
            const SizedBox(height: 8),
            widget.isEditing
              ? DropdownButtonFormField<String>(
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
                )
              : TextField(
                  controller: TextEditingController(text: _selectedReminder),
                  decoration: AppTheme.inputDecoration(),
                  readOnly: true,
                ),
            
            const SizedBox(height: 32),
            
            // Save button (only in edit mode)
            if (widget.isEditing)
              ElevatedButton(
                onPressed: _saveChanges,
                style: AppTheme.primaryButtonStyle,
                child: Text(
                  'Save Changes',
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

  void _saveChanges() {
    // Update the item data
    final updatedItem = {
      'name': _nameController.text,
      'expiryDate': _expiryController.text,
      // Calculate days left
      'daysLeft': _calculateDaysLeft(_expiryController.text),
      'reminderSetting': _selectedReminder,
    };
    
    // Here you would update in your database
    // For now, just navigate back with confirmation
    Navigator.pop(context, updatedItem);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item updated successfully')),
    );
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
