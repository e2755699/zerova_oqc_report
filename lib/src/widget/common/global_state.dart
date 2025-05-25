import 'package:flutter/foundation.dart';

ValueNotifier<int> globalEditModeNotifier = ValueNotifier<int>(1);
ValueNotifier<int> permissions = ValueNotifier<int>(1); //1:主管 2:測試人員 0:訪客?