import 'package:shared_preferences/shared_preferences.dart';

mixin LoginPersistence {
  Future<void> saveLoginInfo(String account, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('account', account);
    await prefs.setString('password', password);
  }

  Future<Map<String, String>?> loadLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final account = prefs.getString('account');
    final password = prefs.getString('password');
    if (account != null && password != null) {
      return {'account': account, 'password': password};
    }
    return null;
  }

  Future<void> clearLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('account');
    await prefs.remove('password');
  }
}
