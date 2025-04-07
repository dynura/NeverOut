// lib/features/receipt_processing/repositories/item_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItemRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collection reference
  CollectionReference get _itemsCollection => 
      _firestore.collection('users')
      .doc(_auth.currentUser?.uid)
      .collection('items');
  
  // Add a new item
  Future<void> addItem(Map<String, dynamic> item) async {
    try {
      await _itemsCollection.add({
        ...item,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
   // Add multiple items
  Future<void> addItems(List<Map<String, dynamic>> items) async {
    try {
      final batch = _firestore.batch();
      
      for (var item in items) {
        final docRef = _itemsCollection.doc();
        batch.set(docRef, {
          ...item,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }
  
  // Get all items
  Stream<QuerySnapshot> getItems() {
    return _itemsCollection
        .orderBy('expiryDate', descending: false)
        .snapshots();
  }
  
  // Get items expiring soon (within 7 days)
  Stream<QuerySnapshot> getItemsExpiringSoon() {
    final now = DateTime.now();
    final sevenDaysLater = now.add(const Duration(days: 7));
    final sevenDaysLaterStr = "${sevenDaysLater.year}-${sevenDaysLater.month.toString().padLeft(2, '0')}-${sevenDaysLater.day.toString().padLeft(2, '0')}";
    
    return _itemsCollection
        .where('expiryDate', isLessThanOrEqualTo: sevenDaysLaterStr)
        .where('expiryDate', isGreaterThanOrEqualTo: "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}")
        .orderBy('expiryDate', descending: false)
        .snapshots();
  }
  
  // Update an item
  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    try {
      await _itemsCollection.doc(id).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete an item
  Future<void> deleteItem(String id) async {
    try {
      await _itemsCollection.doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }
}