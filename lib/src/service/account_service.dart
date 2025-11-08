import 'package:cloud_firestore/cloud_firestore.dart';

/// Account service for managing accounts in Firestore
class AccountService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'accounts';

  /// Create a new account
  Future<bool> createAccount({
    required String account,
    required String password,
    required int permission,
    required String name,
    String? vnName,
    String? employeeId,
  }) async {
    try {
      // Check if account already exists
      final docRef = _firestore.collection(_collection).doc(account);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        throw Exception('Account already exists');
      }

      // Create account document
      await docRef.set({
        'account': account,
        'password': password,
        'permission': permission,
        'name': name,
        if (vnName != null && vnName.isNotEmpty) 'vn_name': vnName,
        if (employeeId != null && employeeId.isNotEmpty)
          'employee_id': employeeId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error creating account: $e');
      rethrow;
    }
  }

  /// Get all accounts
  Future<List<Map<String, dynamic>>> getAllAccounts() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('account')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error getting accounts: $e');
      rethrow;
    }
  }

  /// Get account by account name
  Future<Map<String, dynamic>?> getAccount(String account) async {
    try {
      final docRef = _firestore.collection(_collection).doc(account);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        return {
          'id': docSnapshot.id,
          ...docSnapshot.data()!,
        };
      }
      return null;
    } catch (e) {
      print('Error getting account: $e');
      rethrow;
    }
  }

  /// Delete account
  Future<bool> deleteAccount(String account) async {
    try {
      await _firestore.collection(_collection).doc(account).delete();
      return true;
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }

  /// Update account
  Future<bool> updateAccount({
    required String account,
    String? password,
    int? permission,
    String? name,
    String? vnName,
    String? employeeId,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc(account);
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (password != null) updateData['password'] = password;
      if (permission != null) updateData['permission'] = permission;
      if (name != null) updateData['name'] = name;
      if (vnName != null) updateData['vn_name'] = vnName;
      if (employeeId != null) updateData['employee_id'] = employeeId;

      await docRef.update(updateData);
      return true;
    } catch (e) {
      print('Error updating account: $e');
      rethrow;
    }
  }

  /// Migrate existing accountList to Firestore
  Future<void> migrateAccounts(Map<String, Map<String, dynamic>> accountList) async {
    try {
      // Get all existing accounts first
      final existingAccounts = await getAllAccounts();
      final existingAccountSet = existingAccounts
          .map((acc) => acc['account'] as String)
          .toSet();

      WriteBatch? batch;
      int count = 0;
      int totalMigrated = 0;

      for (final entry in accountList.entries) {
        final account = entry.key;
        final data = entry.value;

        // Skip if account already exists
        if (existingAccountSet.contains(account)) {
          print('Account $account already exists in Firestore, skipping...');
          continue;
        }

        // Create new batch if needed
        if (batch == null || count % 500 == 0) {
          if (batch != null) {
            await batch.commit();
            print('Migrated $totalMigrated accounts...');
          }
          batch = _firestore.batch();
        }

        final docRef = _firestore.collection(_collection).doc(account);

        // Prepare account data
        // Use employee_id if exists, otherwise use account name as employee_id
        final employeeId = data.containsKey('employee_id') && data['employee_id'] != null
            ? data['employee_id']
            : account;
        
        // Permission is already in new system (0=owner, 1=admin, 2=employee)
        // No migration needed as account_data.dart has been updated
        final permission = data['permission'] ?? 2;
        
        final accountData = {
          'account': account,
          'password': data['pwd'] ?? '',
          'permission': permission,
          'name': data['name'] ?? '',
          'employee_id': employeeId,
          if (data.containsKey('vn_name')) 'vn_name': data['vn_name'],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        batch.set(docRef, accountData);
        count++;
        totalMigrated++;
      }

      // Commit remaining accounts
      if (batch != null && count % 500 != 0) {
        await batch.commit();
      }

      print('✅ Successfully migrated $totalMigrated accounts to Firestore');
    } catch (e) {
      print('Error migrating accounts: $e');
      rethrow;
    }
  }
}

