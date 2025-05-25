import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zerova_oqc_report/src/widget/common/custom_app_bar.dart';

class MainLayout extends StatelessWidget {
  final String? title;
  final TextStyle? titleStyle;
  final Widget? leading;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? additionalActions;
  final bool showBackButton;

  const MainLayout({
    super.key,
    this.title,
    this.titleStyle,
    this.leading,
    required this.body,
    this.floatingActionButton,
    this.additionalActions,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        titleStyle: titleStyle,
        leading: leading ?? (showBackButton ? FittedBox(
          fit: BoxFit.cover,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.arrow_back_outlined),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
        ) : null),
        additionalActions: additionalActions,
      ),
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }
} 