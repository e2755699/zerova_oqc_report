import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:zerova_oqc_report/src/mixin/load_file_helper.dart';
import 'package:zerova_oqc_report/src/repo/firebase_service.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/home/input_model_name_and_sn_dialog.dart';
import 'package:zerova_oqc_report/src/widget/home/input_account_and_password.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/widget/common/custom_app_bar.dart';
import 'package:window_manager/window_manager.dart';
import 'package:zerova_oqc_report/src/widget/common/global_state.dart';
import 'package:zerova_oqc_report/src/report/spec/package_list_spec.dart';
import 'package:intl/intl.dart';
import 'package:zerova_oqc_report/src/repo/sharepoint_uploader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with LoadFileHelper<HomePage> {
  String result = '';
  bool isLoading = false; // 添加 loading 狀態變數
  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 公司LOGO
            Image.asset(
              'assets/logo.png', // 請確保此路徑下有對應的圖片
              height: 300, // 調整LOGO大小
            ),
            const SizedBox(height: 40),
            // 按鈕Mail
            /*SizedBox(
              width: 300,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () async {
                  await SendEmailService.sendMail();
                },
                child: const Text('Send Mail'),
              ),
            ),
            const SizedBox(height: 20),*/
            // 按鈕1: 輸入帳號密碼
            SizedBox(
              width: 300, // 增加按鈕寬度
              height: 60, // 增加按鈕高度
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20), // 增加文字大小
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const InputAccountAndPassword(); // 彈出視窗
                    },
                  );
                },
                child: Text(context.tr('input_account_password')),
              ),
            ),
            const SizedBox(height: 20),
            // Model Spec Template 按鈕 (只有管理員可見)
            ValueListenableBuilder<int>(
              valueListenable: permissions,
              builder: (context, value, child) {
                if (value == 1) {
                  // 只有管理員 (permissions == 1) 可見
                  return Column(
                    children: [
                      SizedBox(
                        width: 300,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 20),
                            backgroundColor: Colors.amber,
                          ),
                          onPressed: () {
                            context.go('/model-spec-template');
                          },
                          child: Text(context.tr('model_spec_template')),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                } else {
                  return const SizedBox.shrink(); // 非管理員不顯示
                }
              },
            ),
            // 按鈕2: 輸入SN機種
            SizedBox(
              width: 300, // 增加按鈕寬度
              height: 60, // 增加按鈕高度
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20), // 增加文字大小
                ),
                onPressed: isLoading
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const InputModelNameAndSnDialog(); // 彈出視窗
                          },
                        );
                      },
                child: Text(context.tr('input_sn_model')),
              ),
            ),
            const SizedBox(height: 20),

            // 按鈕3: QR Scan
            SizedBox(
              width: 300, // 增加按鈕寬度
              height: 60, // 增加按鈕高度
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20), // 增加文字大小
                ),
                onPressed: isLoading
                    ? null // 如果正在加載，禁用按鈕
                    : () async {
                        globalPackageListSpecInitialized = false;
                        setState(() {
                          isLoading = true; // 開始加載
                        });
                        try {
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const BarcodeScannerScreen(),
                            ),
                          );
                          if (res != null) {
                            setState(() {
                              result = res;
                              print(result);
                            });
                            /*String model = '';
                            String serialNumber = '';

                            List<String> parts = res.split(RegExp(r'\s+'));
                            if (parts.length >= 2) {
                              model = parts[0];
                              serialNumber = parts[1];
                            } else {
                              model = res;
                              serialNumber = '';
                            }
                            */

                            //String? tres = "EV100T2449A003A1";  // 或是 "EV100\nT2449A003A1"
                            String model = "";
                            String serialNumber = "";

                            if (res != null) {
                              final cleanedRes = res.replaceAll(RegExp(r'\s+'), '');

                              if (cleanedRes.length >= 11) {
                                serialNumber = cleanedRes.substring(cleanedRes.length - 11); // T2449A003A1
                                model = cleanedRes.substring(0, cleanedRes.length - 11);     // EV100
                              } else {
                                print("錯誤：字串長度不足 11 碼");
                              }
                            }

                            print("Model: $model");
                            print("Serial Number: $serialNumber");

                            await loadFileHelper(serialNumber, model).then((_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.tr('submit_success',
                                          args: [serialNumber, model]),
                                    ),
                                  ),
                                );
                              }
                            }).onError((e, st) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.tr('submit_fail',
                                          args: [serialNumber, model]),
                                    ),
                                  ),
                                );
                              }
                            });
                          }
                        } finally {
                          setState(() {
                            isLoading = false; // 結束加載
                          });
                        }
                      },
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(context.tr('processing')),
                        ],
                      )
                    : Text(context.tr('qr_code_scan')),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 300,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                ),
                onPressed: () async {
                  bool? shouldClose = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(context.tr('exit_confirm_title')),
                        content: Text(context.tr('exit_confirm_message')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(context.tr('cancel')),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(context.tr('exit')),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldClose == true) {
                    await windowManager.close();
                  }
                },
                child: Text(
                  context.tr('exit'),
                  style: const TextStyle(
                    color: AppColors.darkBlueColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildLanguageDropdownButton(
      BuildContext context, Locale currentLocale) {
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
}

class BarcodeScannerScreen extends StatelessWidget {
  const BarcodeScannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 內嵌掃描畫面
          const SimpleBarcodeScannerPage(),

          /// 返回按鈕 (右上角)
          Positioned(
            top: 40, // 按鈕距離畫面上方的距離
            right: 20, // 按鈕對齊右邊
            child: SizedBox(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 返回上一頁
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  // 黑底
                  textStyle: const TextStyle(fontSize: 20, color: Colors.white),
                  // 白字
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back, color: Colors.white), // 白色箭頭
                    const SizedBox(width: 8),
                    Text(
                      context.tr('qrcode_back'),
                      style: const TextStyle(color: Colors.white), // 確保文字為白色
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
