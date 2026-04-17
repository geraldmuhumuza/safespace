// lib/services/image_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;

  /// Pick an image, upload to Firebase Storage, save URL + metadata to Firestore.
  /// Returns the Firestore document ID on success.
  Future<String?> pickUploadAndSave({
    bool fromCamera = false,
    String userId = 'default_user', // replace with your auth user ID
  }) async {
    // 1. Pick image
    final XFile? xfile = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
    );
    if (xfile == null) return null;

    final file = File(xfile.path);
    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // 2. Upload to Firebase Storage
    final storageRef = _storage.ref().child('user_images/$userId/$fileName');
    final uploadTask = storageRef.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    // Optionally track upload progress:
    // uploadTask.snapshotEvents.listen((snap) { ... });

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    // 3. Save metadata + URL to Firestore
    final docRef = await _firestore
        .collection('users')
        .doc(userId)
        .collection('images')
        .add({
          'url': downloadUrl,
          'storagePath': 'user_images/$userId/$fileName',
          'uploadedAt': FieldValue.serverTimestamp(),
          'fileName': fileName,
        });

    return docRef.id;
  }

  /// Fetch all image documents for a user from Firestore
  Future<List<Map<String, dynamic>>> getUserImages(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('images')
        .orderBy('uploadedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  /// Delete image from both Storage and Firestore
  Future<void> deleteImage({
    required String userId,
    required String docId,
    required String storagePath,
  }) async {
    await _storage.ref(storagePath).delete();
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('images')
        .doc(docId)
        .delete();
  }
}
