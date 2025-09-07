import 'package:cloud_firestore/cloud_firestore.dart';

class CompareImageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection name for storing image mappings
  static const String _collection = 'compare_image_mappings';

  // Get document reference for specific model and serial number
  DocumentReference _getDocRef(String model, String sn) {
    return _firestore.collection(_collection).doc('${model}_$sn');
  }

  /// Load image mappings for specific model and serial number
  Future<Map<String, String>> loadImageMappings(String model, String sn) async {
    try {
      final docRef = _getDocRef(model, sn);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return Map<String, String>.from(data['mappings'] ?? {});
      }

      return {};
    } catch (e) {
      print('Error loading image mappings: $e');
      return {};
    }
  }

  /// Save image mappings for specific model and serial number
  Future<void> saveImageMappings(
      String model, String sn, Map<String, String> mappings) async {
    try {
      final docRef = _getDocRef(model, sn);
      await docRef.set({
        'model': model,
        'sn': sn,
        'mappings': mappings,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving image mappings: $e');
      throw Exception('Failed to save image mappings');
    }
  }

  /// Update single image mapping
  Future<void> updateImageMapping(String model, String sn,
      String compareImagePath, String? actualImagePath) async {
    try {
      final docRef = _getDocRef(model, sn);

      if (actualImagePath == null) {
        // Remove mapping if actualImagePath is null
        await docRef.update({
          'mappings.$compareImagePath': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Add or update mapping
        await docRef.set({
          'mappings': {compareImagePath: actualImagePath},
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error updating image mapping: $e');
      throw Exception('Failed to update image mapping');
    }
  }

  /// Check if all compare images have mappings
  Future<bool> areAllImagesMapped(
      String model, String sn, List<String> compareImagePaths) async {
    try {
      final mappings = await loadImageMappings(model, sn);
      return compareImagePaths.every((path) => mappings.containsKey(path));
    } catch (e) {
      print('Error checking image mappings: $e');
      return false;
    }
  }
}
