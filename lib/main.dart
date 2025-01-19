import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:zerova_oqc_report/src/widget/home/home_page.dart';
import 'package:zerova_oqc_report/src/widget/oqc/oqc_report_page.dart';
import 'package:zerova_oqc_report/src/widget/camera/camera_page.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/camera',
      builder: (context, state) => const CameraPage(),
    ),
    GoRoute(
      path: '/oqc-report',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return OqcReportPage(
          softwareVersion: extra['softwareVersion'],
          testFunction: extra['testFunction'],
          inputOutputCharacteristics: extra['inputOutputCharacteristics'],
          protectionTestResults: extra['protectionTestResults'],
        );
      },
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(EasyLocalization(
    supportedLocales: const [
      Locale('en', 'US'), // 英文
      Locale('zh', 'CN'), // 中文
      Locale('vi', 'VN'), // 越南文
      Locale('ja', 'JP'), // 日文
    ],
    path: 'assets/translations', // 翻譯檔案的路徑
    fallbackLocale: const Locale('en', 'US'), // 預設語言
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(  // 使用 MaterialApp.router
      title: 'Zerova OQC Report',
      routerConfig: _router,  // 使用 router 配置
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
