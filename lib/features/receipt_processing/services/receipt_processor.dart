// lib/features/receipt_processing/services/receipt_processor.dart
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

class ReceiptProcessor {
  final textRecognizer = TextRecognizer();
  
  Future<List<Map<String, dynamic>>> processReceiptImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await textRecognizer.processImage(inputImage);
      
      // Process the text to extract items and predict expiry dates
      return _extractItemsFromText(recognizedText.text);
    } catch (e) {
      rethrow;
    } finally {
      textRecognizer.close();
    }
  }
  
  List<Map<String, dynamic>> _extractItemsFromText(String text) {
    // This is where you would implement your item extraction logic
    // For now, we'll use a simplified approach
    
    final List<String> lines = text.split('\n');
    final List<Map<String, dynamic>> items = [];
    
    // Simple pattern matching for potential grocery items
    // A real implementation would use a machine learning model for categorization
    for (var line in lines) {
      // Skip empty lines and likely non-item lines
      if (line.trim().isEmpty || 
          line.contains('TOTAL') || 
          line.contains('RECEIPT') ||
          line.contains('TAX') ||
          line.contains('\$')) {
        continue;
      }
      
      // Basic filtering to find potential product names
      // Words longer than 3 characters, not numbers
      if (line.trim().length > 3 && !_isNumeric(line.trim())) {
        // Predict expiry date based on product category
        final expiryInfo = _predictExpiryDate(line.trim());
        
        items.add({
          'name': _formatItemName(line.trim()),
          'expiryDate': expiryInfo['date'],
          'daysLeft': expiryInfo['daysLeft'],
          'category': expiryInfo['category'],
        });
      }
    }
    
    return items;
  }
  
  bool _isNumeric(String str) {
    // Check if string is numeric
    if (str == null) {
      return false;
    }
    return double.tryParse(str.replaceAll(RegExp(r'[^\d.]'), '')) != null;
  }
  
  String _formatItemName(String raw) {
    // Capitalize first letter of each word
    return raw.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
  
  Map<String, dynamic> _predictExpiryDate(String itemName) {
    // In a real implementation, this would use a TensorFlow model
    // For now, we'll use some basic rules
    
    final now = DateTime.now();
    String category = 'other';
    int daysToAdd = 7; // Default one week
    
    // Simple rules based on common product names
    final itemNameLower = itemName.toLowerCase();
    
    if (itemNameLower.contains('milk') || 
        itemNameLower.contains('yogurt') ||
        itemNameLower.contains('cream')) {
      category = 'dairy';
      daysToAdd = 7; // 1 week
    } else if (itemNameLower.contains('bread') || 
               itemNameLower.contains('bun') ||
               itemNameLower.contains('bagel')) {
      category = 'bakery';
      daysToAdd = 5; // 5 days
    } else if (itemNameLower.contains('meat') || 
               itemNameLower.contains('chicken') ||
               itemNameLower.contains('beef') ||
               itemNameLower.contains('pork')) {
      category = 'meat';
      daysToAdd = 4; // 4 days if refrigerated
    } else if (itemNameLower.contains('veg') || 
               itemNameLower.contains('lettuce') ||
               itemNameLower.contains('spinach')) {
      category = 'produce';
      daysToAdd = 6; // 6 days
    } else if (itemNameLower.contains('fruit') || 
               itemNameLower.contains('apple') ||
               itemNameLower.contains('banana')) {
      category = 'produce';
      daysToAdd = 7; // 7 days
    } else {
      category = 'pantry';
      daysToAdd = 90; // 3 months for non-perishables
    }
    
    final expiryDate = now.add(Duration(days: daysToAdd));
    
    return {
      'date': "${expiryDate.year}-${expiryDate.month.toString().padLeft(2, '0')}-${expiryDate.day.toString().padLeft(2, '0')}",
      'daysLeft': daysToAdd,
      'category': category,
    };
  }
}
