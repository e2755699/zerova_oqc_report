import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:window_manager/window_manager.dart';
import 'package:zerova_oqc_report/route/app_router.dart';
import 'package:zerova_oqc_report/src/utils/window_size_manager.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'src/config/config_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  // windowManager.setFullScreen(true);
  await EasyLocalization.ensureInitialized();
  await ConfigManager.initialize();
  //SharePointUploader(uploadOrDownload: 1, sn: '').startAuthorization();

  // 初始化 SharePointUploader
  // final uploader = SharePointUploader();
  // uploader.startAuthorization();

  runApp(EasyLocalization(
    supportedLocales: const [
      Locale('en', 'US'), // 英文
      Locale('zh', 'TW'), // 繁體中文
      Locale('vi', 'VN'), // 越南文
      Locale('ja', 'JP'), // 日文
    ],
    path: 'assets/translations', // 翻譯檔案的路徑
    fallbackLocale: const Locale('en', 'US'), // 預設語言
    child: const ZerovaOqcReport(),
  ));
}

class ZerovaOqcReport extends StatelessWidget {
  const ZerovaOqcReport({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Zerova OQC Report',
      theme: ThemeData(
        dataTableTheme: DataTableTheme.of(context).copyWith(
          headingRowAlignment: MainAxisAlignment.center,
          horizontalMargin: 20,
          columnSpacing: 10,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        return child ?? const SizedBox();
      },
    );
  }
}
