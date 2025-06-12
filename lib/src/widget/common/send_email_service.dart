import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class SendEmailService {
  static Future<void> sendMail() async {
    // 寄件者帳號與密碼 (⚠️實務上請勿硬編寫在前端，這裡僅供開發測試用途)
    String username = ''; // 使用 Gmail
    String password = ''; // 使用 Google App 密碼

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, '') // 發送單位名稱
      ..recipients.add('')  // 收件者信箱
      ..subject = '審核通知'  // 主旨
      ..text = '請記得審核'; // 內容

    try {
      final sendReport = await send(message, smtpServer);
      print('寄信成功: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('寄信失敗: $e');
      for (var p in e.problems) {
        print('問題: ${p.code}: ${p.msg}');
      }
    }
  }
}
