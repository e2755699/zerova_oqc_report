import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class SendEmailService {
  static Future<void> sendMail() async {
    // 寄件者帳號與密碼 (⚠️實務上請勿硬編寫在前端，這裡僅供開發測試用途)
    String username = 'jackalope.studio0903@gmail.com';
    String password = 'kdzx opzw fjxz dfmf'; // 使用 Google App 密碼

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, '加卡洛普工作室')
      ..recipients.add('e2755699@gmail.com')
      ..subject = '審核通知'
      ..text = '請記得審核';

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
