// add_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neverout/features/user_auth/presentation/widgets/app_theme.dart';
import 'package:neverout/features/user_auth/presentation/widgets/app_navigation.dart';
import 'package:neverout/features/user_auth/presentation/pages/home_page.dart';
import 'package:neverout/features/user_auth/presentation/pages/inventory_page.dart';
import 'package:neverout/features/user_auth/presentation/pages/profile_page.dart';
import 'package:neverout/features/user_auth/presentation/pages/view_items_page.dart';
import 'package:neverout/features/user_auth/presentation/pages/manual_item_entry_page.dart';
import 'package:neverout/features/receipt_processing/services/receipt_processor.dart';
import 'package:neverout/features/receipt_processing/repositories/item_repository.dart';
import 'package:neverout/features/receipt_processing/services/reminder_service.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  // Add to class variables
  final ReceiptProcessor _receiptProcessor = ReceiptProcessor();
  final ItemRepository _itemRepository = ItemRepository();
  final ReminderService _reminderService = ReminderService();
  bool _isProcessing = false;

  // Initialize reminder service in initState
  @override
  void initState() {
    super.initState();
    _reminderService.initialize();
  }

  // Update _processImage method
  Future<void> _processImage() async {
    // Set processing state
    setState(() {
      _isProcessing = true;
    });

    try {
      // Process receipt with OCR and TensorFlow
      final items = await _receiptProcessor.processReceiptImage(_image!);
      
      // Save items to database
      await _itemRepository.addItems(items);
      
      // Schedule reminders for each item (default to 3 days before)
      for (var item in items) {
        await _reminderService.setReminderForItem(
          item['name'],
          item['expiryDate'],
          '3 days before',
        );
      }
        
      // Navigate to view items page after processing
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewItemsPage(items: items),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing image: ${e.toString()}')),
        );
      }
    } finally {
      // Reset processing state
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      
      // Process the image with TensorFlow Lite
      _processImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page title
              Text('Add/Scan Items', style: AppTheme.headingLarge()),
              const SizedBox(height: 24),
              
              // Upload area
              InkWell(
                onTap: () => _getImage(ImageSource.gallery),
                child: Container(
                  width: double.infinity,
                  height: 320,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isProcessing 
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.upload_outlined,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Click to upload',
                            style: AppTheme.bodyMedium(color: Colors.white),
                          ),
                          Text(
                            'or drag and drop',
                            style: AppTheme.bodyMedium(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'PNG, JPG or PDF (max. 10MB)',
                            style: AppTheme.bodySmall(color: Colors.white.withOpacity(0.8)),
                          ),
                        ],
                      ),
                ),
              ),
              
              const SizedBox(height: 24),
              const Center(child: Text('OR')),
              const SizedBox(height: 16),
              
              // Take a photo button
              OutlinedButton.icon(
                onPressed: () => _getImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt, color: AppTheme.secondColor),
                label: const Text('Take a Photo'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: AppTheme.thirdColor),
                  foregroundColor: AppTheme.secondColor,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Add manually button
              ElevatedButton(
                onPressed: () {
                  // Navigate to manual item entry form
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManualItemEntryPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.secondColor,
                  elevation: 0,
                  side: const BorderSide(color: AppTheme.thirdColor),
                ),
                child: const Text('Add manually'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppNavigation.bottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InventoryPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        },
      ),
    );
  }
}