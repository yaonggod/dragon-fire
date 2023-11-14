import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../utils/token_control.dart';
import 'package:http/http.dart' as http;

class ConnectingService {
  static String baseUrl = dotenv.env['BASE_URL']!;

  static Future<void> connect(bool condition) async {
    Map<String, String> token = await TokenControl.readToken();

    final response = await http.patch(
      Uri.parse('$baseUrl/api/connecting'), // 실제 서버 엔드포인트로 대체
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${token["Authorization"]!}',
        'refreshToken': 'Bearer ${token['refreshToken']!}'
      },
      body: jsonEncode(<String, bool>{
        'condition': condition, // 업데이트할 데이터
      }),
    );
    if (response.statusCode == 200) {
      // 서버로부터 데이터 업데이트 성공
      print("내 접속 정보 변경 성공");
    } else {
      // 패치 요청이 실패한 경우
      throw Exception('Failed to patch data');
    }
  }
}
