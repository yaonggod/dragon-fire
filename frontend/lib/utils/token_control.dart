import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenControl {
  static Future<Map<String, String>> readToken() async {
    const storage = FlutterSecureStorage();
    Map<String, String> tokenInfo = {};
    String? accessToken = await storage.read(key: 'accessToken');
    String? refreshToken = await storage.read(key: 'refreshToken');
    String? socialType = await storage.read(key: 'socialType');

    if (accessToken != null && refreshToken != null && socialType != null) {
      tokenInfo['Authorization'] = accessToken;
      tokenInfo['refreshToken'] = refreshToken;
      tokenInfo['socialType'] = socialType;
    }
    return tokenInfo;
  }
}
