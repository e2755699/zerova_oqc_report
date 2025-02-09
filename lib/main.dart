import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/route/app_router.dart';
import 'src/config/config_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await ConfigManager.initialize();
  // SharePointUploader(uploadOrDownload: 1, sn: '').startAuthorization();

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
