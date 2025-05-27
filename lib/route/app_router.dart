import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zerova_oqc_report/src/report/model/package_list_result.dart';
import 'package:zerova_oqc_report/src/widget/admin/model_spec_template_page.dart';
import 'package:zerova_oqc_report/src/widget/camera/camera_page.dart';
import 'package:zerova_oqc_report/src/widget/home/home_page.dart';
import 'package:zerova_oqc_report/src/widget/oqc/oqc_report_page.dart';

/// 應用程序路由配置
final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
    ),
    GoRoute(
      path: '/camera',
      builder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>;
        return CameraPage(
          sn: extra['sn'],
          model: extra['model'],
          packagingOrAttachment: extra['packagingOrAttachment'],
        );
      },
    ),
    GoRoute(
      path: '/oqc-report',
      builder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>;
        return OqcReportPage(
          sn: extra['sn'],
          model: extra['model'],
          softwareVersion: extra['softwareVersion'],
          testFunction: extra['testFunction'],
          inputOutputCharacteristics: extra['inputOutputCharacteristics'],
          protectionTestResults: extra['protectionTestResults'],
          psuSerialNumbers: extra['psuSerialNumbers'],
          packageListResult: extra['packageListResult'] ?? PackageListResult(),
        );
      },
    ),
    GoRoute(
      path: '/model-spec-template',
      builder: (BuildContext context, GoRouterState state) {
        return const ModelSpecTemplatePage();
      },
    ),
  ],
);
