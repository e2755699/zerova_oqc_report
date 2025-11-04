import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/service/account_service.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/global_state.dart';
import 'package:zerova_oqc_report/src/widget/common/main_layout.dart';
import 'package:zerova_oqc_report/src/report/spec/account_data.dart';
import 'package:zerova_oqc_report/src/utils/permission_helper.dart';

class AccountManagementPage extends StatefulWidget {
  const AccountManagementPage({super.key});

  @override
  State<AccountManagementPage> createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  final AccountService _accountService = AccountService();
  List<Map<String, dynamic>> _accounts = [];
  bool _isLoading = true;
  bool _isMigrating = false;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _migrateAccounts() async {
    setState(() {
      _isMigrating = true;
    });

    try {
      await _accountService.migrateAccounts(accountList);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('帳號遷移完成'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await _loadAccounts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('遷移失敗: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isMigrating = false;
      });
    }
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final accounts = await _accountService.getAllAccounts();
      setState(() {
        _accounts = accounts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('載入帳號失敗: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAddAccountDialog() async {
    final formKey = GlobalKey<FormState>();
    final accountController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    final vnNameController = TextEditingController();
    final employeeIdController = TextEditingController();
    int selectedPermission = 2; // Default to employee

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('新增帳號'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: accountController,
                      decoration: const InputDecoration(
                        labelText: '帳號 *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '請輸入帳號';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: '密碼 *',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '請輸入密碼';
                        }
                        if (value.length < 4) {
                          return '密碼長度至少 4 個字元';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '姓名 *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '請輸入姓名';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: vnNameController,
                      decoration: const InputDecoration(
                        labelText: '越南文姓名（選填）',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: employeeIdController,
                      decoration: const InputDecoration(
                        labelText: '員工編號 *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '請輸入員工編號';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedPermission,
                      decoration: const InputDecoration(
                        labelText: '權限 *',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 0,
                          child: Text(context.tr('permission_owner')),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text(context.tr('permission_admin')),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text(context.tr('permission_employee')),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedPermission = value ?? 2;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  await _createAccount(
                    account: accountController.text.trim(),
                    password: passwordController.text,
                    permission: selectedPermission,
                    name: nameController.text.trim(),
                    vnName: vnNameController.text.trim().isEmpty
                        ? null
                        : vnNameController.text.trim(),
                    employeeId: employeeIdController.text.trim(),
                  );
                }
              },
              child: Text(context.tr('submit')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createAccount({
    required String account,
    required String password,
    required int permission,
    required String name,
    String? vnName,
    String? employeeId,
  }) async {
    try {
      await _accountService.createAccount(
        account: account,
        password: password,
        permission: permission,
        name: name,
        vnName: vnName,
        employeeId: employeeId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('帳號 $account 建立成功'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await _loadAccounts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('建立帳號失敗: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteAccount(String account, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要刪除帳號「$account」（$name）嗎？\n此操作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _accountService.deleteAccount(account);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('帳號 $account 已刪除'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await _loadAccounts();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('刪除帳號失敗: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: permissions,
      builder: (context, permissionValue, child) {
        if (!PermissionHelper.canAccessAdmin(permissionValue)) {
          return MainLayout(
            title: '帳號管理',
            body: const Center(
              child: Text(
                '您沒有權限存取此頁面',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
          );
        }

        return MainLayout(
          title: '帳號管理',
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StyledCard(
                        title: '帳號管理',
                        titleAction: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_accounts.isEmpty)
                              ElevatedButton.icon(
                                onPressed:
                                    _isMigrating ? null : _migrateAccounts,
                                icon: _isMigrating
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.cloud_upload),
                                label: Text(_isMigrating ? '遷移中...' : '遷移現有帳號'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            if (_accounts.isEmpty) const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _showAddAccountDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('新增帳號'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _loadAccounts,
                              icon: const Icon(Icons.refresh),
                              tooltip: '重新載入',
                            ),
                          ],
                        ),
                        content: _accounts.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Text(
                                    '尚無帳號資料\n點擊「遷移現有帳號」將 account_data.dart 中的帳號遷移到 Firestore\n或點擊「新增帳號」手動建立新帳號',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                            : DataTable(
                                columns: const [
                                  DataColumn(label: Text('帳號')),
                                  DataColumn(label: Text('姓名')),
                                  DataColumn(label: Text('權限')),
                                  DataColumn(label: Text('越南文姓名')),
                                  DataColumn(label: Text('員工編號')),
                                  DataColumn(label: Text('操作')),
                                ],
                                rows: _accounts.map((account) {
                                  final permission =
                                      account['permission'] as int? ?? 2;
                                  final permissionText = permission == 0
                                      ? context.tr('permission_owner')
                                      : permission == 1
                                          ? context.tr('permission_admin')
                                          : context.tr('permission_employee');
                                  final permissionColor = permission == 0
                                      ? Colors.red
                                      : permission == 1
                                          ? Colors.orange
                                          : Colors.blue;

                                  final canDelete =
                                      PermissionHelper.canDeleteAccount(
                                          permissions.value);

                                  return DataRow(
                                    cells: [
                                      DataCell(Text(account['account'] ?? '')),
                                      DataCell(Text(account['name'] ?? '')),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: permissionColor
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            border: Border.all(
                                              color: permissionColor,
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            permissionText,
                                            style: TextStyle(
                                              color: permissionColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(account['vn_name'] ??
                                          account['vnName'] ??
                                          '-')),
                                      DataCell(Text(account['employee_id'] ??
                                          account['employeeId'] ??
                                          '-')),
                                      DataCell(
                                        canDelete
                                            ? IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () => _deleteAccount(
                                                  account['account'],
                                                  account['name'],
                                                ),
                                                tooltip: '刪除帳號',
                                              )
                                            : const Icon(
                                                Icons.delete_outline,
                                                color: Colors.grey,
                                              ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
