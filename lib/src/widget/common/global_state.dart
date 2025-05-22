import 'package:flutter/foundation.dart';

ValueNotifier<int> globalEditModeNotifier = ValueNotifier<int>(0);
ValueNotifier<int> permissions = ValueNotifier<int>(0); //1:主管 2:測試人員 0:遊客?