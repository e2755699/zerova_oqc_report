import 'package:flutter/foundation.dart';

// Permission levels:
// 0: Owner (擁有者) - Can do everything
// 1: Admin (管理員) - Can manage accounts and templates
// 2: Employee (一般員工) - Can only edit reports
ValueNotifier<int> globalEditModeNotifier = ValueNotifier<int>(0);
ValueNotifier<int> permissions = ValueNotifier<int>(2); // Default to employee