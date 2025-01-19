import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zerova_oqc_report/src/widget/camera/camera_page.dart';
import 'package:zerova_oqc_report/src/widget/home/home_page.dart';
import 'package:zerova_oqc_report/src/widget/oqc/oqc_report_page.dart';

/// 應用程序路由配置
final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return HomePage();
      },
    ),
    GoRoute(
      path: '/camera',
      builder: (BuildContext context, GoRouterState state) {
        return const CameraPage();
      },
    ),
    GoRoute(
      path: '/oqc-report',
      builder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>;
        return OqcReportPage(
          softwareVersion: extra['softwareVersion'],
          testFunction: extra['testFunction'],
          inputOutputCharacteristics: extra['inputOutputCharacteristics'],
          protectionTestResults: extra['protectionTestResults'],
          psuSerialNumbers: extra['psuSerialNumbers'],
          packageListResult: extra['packageListResult'],
        );
      },
    ),
  ],
); 