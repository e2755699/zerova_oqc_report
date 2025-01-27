import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final TextStyle? titleStyle;
  final List<Widget>? additionalActions;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleStyle,
    this.additionalActions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 84,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF008999), Color(0x808080)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.4),
      leading: leading,
      title: title != null ? Text(
        title!,
        style: titleStyle ?? const TextStyle(),
      ) : null,
      actions: [
        if (additionalActions != null) ...additionalActions!,
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