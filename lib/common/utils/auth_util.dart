import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:spark_chat/common/index.dart';

class AuthUtil {
  static const String host = 'spark-api.xf-yun.com';
  static String generateAuthUrl(String path) {
    String apiKey = ConfigService.ins.apiKey;
    DateTime now = DateTime.now().toUtc();
    String date = formatDate(now);
    String tmp = "host: $host\ndate: $date\nGET $path HTTP/1.1";
    String signature = generateSignature(tmp, date);
    String authorizationOrigin =
        """api_key="$apiKey", algorithm="hmac-sha256", headers="host date request-line", signature="$signature\"""";
    String authorization = base64Encode(utf8.encode(authorizationOrigin));
    Map<String, String> queryParams = {
      'authorization': authorization,
      'date': date,
      'host': host,
    };
    String queryParamStr = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    String url = 'wss://$host$path?${(queryParamStr)}';
    return url;
  }

  static final DateFormat formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss');
  static String formatDate(DateTime date) {
    return '${formatter.format(date)} GMT';
  }

  static String generateSignature(String tmp, String date) {
    String apiSecret = ConfigService.ins.apiSecret;
    List<int> key = utf8.encode(apiSecret);
    List<int> bytes = utf8.encode(tmp);
    Hmac hmacSha256 = Hmac(sha256, key);
    Digest digest = hmacSha256.convert(bytes);
    return base64Encode(digest.bytes);
  }
}
