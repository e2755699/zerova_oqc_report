import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/widget/home/home_page.dart';
import 'package:easy_localization/easy_localization.dart';

class InputModelNameAndSnDialog extends StatefulWidget {
  const InputModelNameAndSnDialog({super.key});

  @override
  State<InputModelNameAndSnDialog> createState() =>
      _InputModelNameAndSnDialogState();
}

class _InputModelNameAndSnDialogState extends State<InputModelNameAndSnDialog>
    with LoadFileHelper {
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
      title: Text(context.tr('input_sn_model')),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              focusNode: _modelFocusNode,
              controller: _modelController,
              decoration: InputDecoration(
                labelText: context.tr('model_name'),
                hintText: context.tr('please_input_model_name'),
                prefixIcon: const Icon(Icons.text_fields),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.tr('please_input_model_name');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              focusNode: _snFocusNode,
              controller: _snController,
              decoration: InputDecoration(
                labelText: context.tr('sn'),
                hintText: context.tr('please_input_sn'),
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.tr('please_input_sn');
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
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final sn = _snController.text;
              final model = _modelController.text;

              await loadFileModule(sn, model, context).then((_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(context.tr('submit_success', args: [sn, model])),
                    ),
                  );
                  Navigator.of(context).pop();
                }
              }).onError((e, st) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(context.tr('submit_fail', args: [sn, model])),
                    ),
                  );
                }
              });
            }
          },
          child: Text(context.tr('submit')),
        ),
      ],
    );
  }
}
