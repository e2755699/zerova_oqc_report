import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/widget/home/home_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/widget/common/global_state.dart';

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
            Navigator.of(context).pop();
          },
          child: Text(context.tr('cancel')),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final pwd = _snController.text;
              final account = _modelController.text;
              if (pwd == 'admin' && account == 'admin') {
                permissions.value = 1;
              } else if (pwd == 'user' && account == 'user') {
                permissions.value = 2;
              } else {
                permissions.value = 0;
              }
              print("permissions is now: ${permissions.value}");
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(permissions.value == 1
                        ? context.tr('login_success_admin')
                        : permissions.value == 2
                            ? context.tr('login_success_operator')
                            : context.tr('login_success_guest')),
                  ),
                );
                Navigator.of(context).pop();
              } /*await loadFileModule(pwd, account, context).then((_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                      Text(context.tr('submit_success', args: [pwd, account])),
                    ),
                  );
                  Navigator.of(context).pop();
                }
              }).onError((e, st) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                      Text(context.tr('submit_fail', args: [pwd, account])),
                    ),
                  );
                }
              });*/
            }
          },
          child: Text(context.tr('submit')),
        ),
      ],
    );
  }
}
