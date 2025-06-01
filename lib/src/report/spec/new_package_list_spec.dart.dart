// package_list_spec.dart

import 'package:zerova_oqc_report/src/report/model/package_list_result.dart';

class PackageListSpecGlobal {
  static PackageListResult globalPackageListResult = PackageListResult();

  static PackageListResult get() => globalPackageListResult;

  static void set(PackageListResult value) {
    globalPackageListResult = value;
  }
}

