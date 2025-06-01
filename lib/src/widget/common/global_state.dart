import 'package:flutter/foundation.dart';

//bill1
ValueNotifier<int> globalEditModeNotifier = ValueNotifier<int>(0);
ValueNotifier<int> permissions = ValueNotifier<int>(0); //1:主管 2:測試人員 0:訪客?