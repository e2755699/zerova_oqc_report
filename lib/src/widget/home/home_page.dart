import 'package:flutter/foundation.dart';
import 'package:zerova_oqc_report/src/mixin/load_file_helper.dart';

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
import 'package:zerova_oqc_report/src/utils/permission_helper.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerova_oqc_report/src/report/spec/account_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with LoadFileHelper<HomePage> {
  bool isLoggedIn = false; // 控制頁面切換
  bool isLoading = false;
  String result = '';
  String? savedAccount;
  String? savedPassword;
  String appVersion = ''; // 應用版本號

  @override
  void initState() {
    super.initState();
    loadSavedLogin();
    loadAppVersion();
  }

  Future<void> loadAppVersion() async {
    // 從pubspec.yaml讀取版本號，這裡暫時硬編碼為當前版本
    setState(() {
      appVersion = 'v2.2.0+1';
    });
  }

  Future<void> loadSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final account = prefs.getString('account');
    final password = prefs.getString('password');

    if (account != null && password != null) {
      // 確認帳密正確才登入
      if (accountList.containsKey(account) &&
          accountList[account]!['pwd'] == password) {
        setState(() {
          currentAccount = account; // 設定目前登入帳號
          permissions.value = accountList[account]!['permission']; // 設定權限
          isLoggedIn = true;
        });
        print('自動登入成功: $account');
      } else {
        print('自動登入失敗：帳號或密碼錯誤');
        // 若自動登入失敗，也可清除舊資料或做其他處理
      }
    } else {
      print('沒有儲存帳密，跳過自動登入');
    }
  }

  Future<void> saveLogin(String account, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('account', account);
    await prefs.setString('password', password);
  }

  Future<void> clearLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('account');
    await prefs.remove('password');
    setState(() {
      isLoggedIn = false;
      savedAccount = null;
      savedPassword = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          Center(
            child:
                isLoggedIn ? buildAfterLoginUI(context) : buildLoginUI(context),
          ),
          // Version display in bottom right corner
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                appVersion,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 登入頁面
  Widget buildLoginUI(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/logo.png', height: 300),
        const SizedBox(height: 40),
        SizedBox(
          width: 300,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20)),
            onPressed: () async {
              final loginResult = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) => const InputAccountAndPassword(),
              );

              print("loginResult = $loginResult");

              if (loginResult != null &&
                  loginResult['success'] == true &&
                  loginResult.containsKey('account') &&
                  loginResult.containsKey('password')) {
                await saveLogin(
                    loginResult['account'], loginResult['password']);
                setState(() {
                  isLoggedIn = true;
                  savedAccount = loginResult['account'];
                  savedPassword = loginResult['password'];
                });
              }
            },
            child: Text(context.tr('input_account_password')),
          ),
        ),
        const SizedBox(height: 20),
        // 離開按鈕
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
                builder: (context) => AlertDialog(
                  title: Text(context.tr('exit_confirm_title')),
                  content: Text(context.tr('exit_confirm_message')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(context.tr('cancel')),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(context.tr('exit')),
                    ),
                  ],
                ),
              );

              if (shouldClose == true) {
                await windowManager.close();
              }
            },
            child: Text(
              context.tr('exit'),
              style: const TextStyle(color: AppColors.darkBlueColor),
            ),
          ),
        ),
      ],
    );
  }

  // 登入後主畫面
  Widget buildAfterLoginUI(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/logo.png', height: 300),
          const SizedBox(height: 40),

          // 管理員按鈕
          ValueListenableBuilder<int>(
            valueListenable: permissions,
            builder: (context, value, child) {
              if (PermissionHelper.canAccessAdmin(value) || kDebugMode) {
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
                        child: Text(
                          context.tr('model_spec_template'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 300,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 20),
                          backgroundColor: Colors.purple,
                        ),
                        onPressed: () {
                          context.go('/account-management');
                        },
                        child: const Text(
                          '帳號管理',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),

          // SN 輸入按鈕
          SizedBox(
            width: 300,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20)),
              onPressed: isLoading
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (context) => const InputModelNameAndSnDialog(),
                      );
                    },
              child: Text(context.tr('input_sn_model')),
            ),
          ),
          const SizedBox(height: 20),
/*
          // QR 掃描按鈕
          SizedBox(
            width: 300,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20)),
              onPressed: isLoading
                  ? null
                  : () async {
                globalPackageListSpecInitialized = false;
                setState(() {
                  isLoading = true;
                });

                try {
                  final res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BarcodeScannerScreen(),
                    ),
                  );

                  if (res != null) {
                    setState(() {
                      result = res;
                    });

                    String model = "";
                    String serialNumber = "";

                    final cleanedRes = res.replaceAll(RegExp(r'\s+'), '');

                    if (cleanedRes.length >= 11) {
                      serialNumber =
                          cleanedRes.substring(cleanedRes.length - 11);
                      model = cleanedRes.substring(0, cleanedRes.length - 11);
                    } else {
                      print("錯誤：字串長度不足 11 碼");
                    }

                    print("Model: $model");
                    print("Serial Number: $serialNumber");

                    await loadFileHelper(serialNumber, model).then((_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.tr(
                                'submit_success', args: [serialNumber, model])),
                          ),
                        );
                      }
                    }).onError((e, st) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.tr(
                                'submit_fail', args: [serialNumber, model])),
                          ),
                        );
                      }
                    });
                  }
                } finally {
                  setState(() {
                    isLoading = false;
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
                  const SizedBox(width: 10),
                  Text(context.tr('processing')),
                ],
              )
                  : Text(context.tr('qr_code_scan')),
            ),
          ),
          const SizedBox(height: 20),*/

          // 登出按鈕
          SizedBox(
            width: 300,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
                backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              ),
              onPressed: () async {
                await clearLogin();
              },
              child: Text(
                context.tr('logout'),
                style: const TextStyle(color: AppColors.darkBlueColor),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 離開按鈕
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
                  builder: (context) => AlertDialog(
                    title: Text(context.tr('exit_confirm_title')),
                    content: Text(context.tr('exit_confirm_message')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(context.tr('cancel')),
                      ),
                      TextButton(
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(context.tr('exit')),
                      ),
                    ],
                  ),
                );

                if (shouldClose == true) {
                  await windowManager.close();
                }
              },
              child: Text(
                context.tr('exit'),
                style: const TextStyle(color: AppColors.darkBlueColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// BarcodeScannerScreen 保留不變
class BarcodeScannerScreen extends StatelessWidget {
  const BarcodeScannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const SimpleBarcodeScannerPage(),
          Positioned(
            top: 40,
            right: 20,
            child: SizedBox(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  textStyle: const TextStyle(fontSize: 20, color: Colors.white),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(context.tr('qrcode_back'),
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
