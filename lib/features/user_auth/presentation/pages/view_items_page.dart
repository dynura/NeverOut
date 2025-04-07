// view_items_page.dart
import 'package:flutter/material.dart';
import 'package:neverout/features/user_auth/presentation/widgets/app_theme.dart';
import 'package:neverout/features/user_auth/presentation/widgets/app_navigation.dart';
import 'package:neverout/features/user_auth/presentation/pages/item_detail_page.dart';

class ViewItemsPage extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  
  const ViewItemsPage({Key? key, required this.items}) : super(key: key);

  @override
  State<ViewItemsPage> createState() => _ViewItemsPageState();
}

class _ViewItemsPageState extends State<ViewItemsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavigation.appBar('Scanned Items'),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final daysLeft = item['daysLeft'] as int;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 1,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                item['name'],
                style: AppTheme.bodyMedium(color: AppTheme.secondColor),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Expires on: ${item['expiryDate']}',
                    style: AppTheme.bodySmall(),
                  ),
                  const SizedBox(height: 4),
                  _buildExpiryTag(daysLeft),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit button
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppTheme.thirdColor),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDetailPage(
                            item: item,
                            isEditing: true,
                          ),
                        ),
                      );
                    },
                  ),
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppTheme.thirdColor),
                    onPressed: () {
                      _showDeleteConfirmation(item);
                    },
                  ),
                ],
              ),
              onTap: () {
                // Navigate to item details
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetailPage(item: item),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const SizedBox(height: 0),
    );
  }

  Widget _buildExpiryTag(int daysLeft) {
    Color tagColor;
    String text;
    
    if (daysLeft <= 3) {
      tagColor = Colors.red;
      text = 'Expires soon: $daysLeft days left';
    } else if (daysLeft <= 7) {
      tagColor = Colors.orange;
      text = '$daysLeft days left';
    } else {
      tagColor = Colors.green;
      text = '$daysLeft days left';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tagColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTheme.bodySmall(color: tagColor),
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete ${item['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement delete functionality
              // For now, just close dialog
              Navigator.pop(context);
              
              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item['name']} deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}