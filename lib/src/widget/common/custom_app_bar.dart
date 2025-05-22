import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/widget/common/global_state.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final TextStyle? titleStyle;
  final List<Widget>? additionalActions;
  final Widget? leading;
  final bool isEditing;
  final VoidCallback? onEditModeToggle;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleStyle,
    this.additionalActions,
    this.leading,
    this.isEditing = false,
    this.onEditModeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 84,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA8C8CC), Color(0x00808080)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.4),
      leading: leading,
      title: title != null
          ? Text(
        title!,
        style: titleStyle ??
            const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 32,
              fontWeight: FontWeight.w700,
              height: 1.2,
              textBaseline: TextBaseline.alphabetic,
            ),
      )
          : null,
      actions: [
        if (additionalActions != null) ...additionalActions!,
        IconButton(
          icon: Icon(isEditing ? Icons.edit_off : Icons.edit),
          //onPressed: onEditModeToggle ?? () {},
          onPressed: () {
            // 切換全域變數
            globalEditModeNotifier.value = globalEditModeNotifier.value == 0 ? 1 : 0;  // 更新 globalEditModeNotifier
            print("globalEditMode is now: $globalEditModeNotifier.value");

            // 呼叫原本的切換函式（如果有的話）
            if (onEditModeToggle != null) {
              onEditModeToggle!();
            }
          },
          tooltip: isEditing ? '關閉編輯模式' : '開啟編輯模式',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildLanguageDropdownButton(context),
        ),
      ],
    );
  }

  Container _buildLanguageDropdownButton(BuildContext context) {
    final currentLocale = context.locale;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<Locale>(
        value: currentLocale,
        icon: const Icon(Icons.language),
        underline: Container(),
        elevation: 4,
        items: context.supportedLocales.map((locale) {
          String label = '';
          switch (locale.languageCode) {
            case 'en':
              label = 'English';
              break;
            case 'zh':
              label = '繁體中文';
              break;
            case 'vi':
              label = 'Tiếng Việt';
              break;
            case 'ja':
              label = '日本語';
              break;
            default:
              label = locale.languageCode;
          }
          return DropdownMenuItem(
            value: locale,
            child: Text(label),
          );
        }).toList(),
        onChanged: (Locale? locale) {
          if (locale != null) {
            context.setLocale(locale);
          }
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(84);
}

