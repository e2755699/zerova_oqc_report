import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/widget/common/global_state.dart';
import 'package:zerova_oqc_report/src/report/spec/account_data.dart';
import 'package:easy_localization/easy_localization.dart';

class InputAccountAndPassword extends StatefulWidget {
  const InputAccountAndPassword({super.key});

  @override
  State<InputAccountAndPassword> createState() =>
      _InputAccountAndPasswordState();
}

class _InputAccountAndPasswordState extends State<InputAccountAndPassword> {
  final _formKey = GlobalKey<FormState>();
  final _snController = TextEditingController();
  final _modelController = TextEditingController();
  final _modelFocusNode = FocusNode();
  final _snFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _modelFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _snController.dispose();
    _modelController.dispose();
    _modelFocusNode.dispose();
    _snFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr('input_account_password')),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              focusNode: _modelFocusNode,
              controller: _modelController,
              decoration: InputDecoration(
                labelText: context.tr('account'),
                hintText: context.tr('please_input_account'),
                prefixIcon: const Icon(Icons.text_fields),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.tr('please_input_account');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              focusNode: _snFocusNode,
              controller: _snController,
              decoration: InputDecoration(
                labelText: context.tr('pwd'),
                hintText: context.tr('please_input_pwd'),
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              obscureText: true, // 密碼欄位
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.tr('please_input_pwd');
                }
                return null;
              },
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop({'success': false});
          },
          child: Text(context.tr('cancel')),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final account = _modelController.text.trim();
              final pwd = _snController.text.trim();

              bool loginSuccess = false;

              if (accountList.containsKey(account) &&
                  accountList[account]!['pwd'] == pwd) {
                permissions.value = accountList[account]!['permission'];
                currentAccount = account;
                final userName = accountList[account]!['name'];
                print("登入成功：$userName，權限：${permissions.value}");
                loginSuccess = true;
              } else {
                permissions.value = 2; // Default to employee on failed login
                print("登入失敗");
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      loginSuccess
                          ? (permissions.value == 0
                          ? context.tr('login_success_owner')
                          : permissions.value == 1
                          ? context.tr('login_success_admin')
                          : permissions.value == 2
                          ? context.tr('login_success_employee')
                          : context.tr('login_success_guest'))
                          : context.tr('login_failed'),
                    ),
                  ),
                );

                Navigator.of(context).pop({
                  'success': loginSuccess,
                  if (loginSuccess) 'account': account,
                  if (loginSuccess) 'password': pwd,
                });
              }
            }
          },
          child: Text(context.tr('submit')),
        ),
      ],
    );
  }
}
