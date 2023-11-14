import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/my_resolve_model.dart';
import 'package:frontend/utils/token_control.dart';
import 'package:http/http.dart' as http;

class MyResolveServices {
  static String baseUrl = dotenv.env['BASE_URL']!;

  static Future<MyResolveModel?> getMyResolve() async {
    Map<String, String> token = await TokenControl.readToken();
    try {
      final url = Uri.parse('$baseUrl/api/resolve');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${token['Authorization']}',
        'refreshToken': 'Bearer ${token['refreshToken']}',
      });
      if (response.statusCode == 200) {
        var jsonString = utf8.decode(response.bodyBytes);
        final myResolve = jsonDecode(jsonString);
        return MyResolveModel.fromJson(myResolve);
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }

  static Future<MyResolveModel?> putMyResolve({
    required String nickname,
    required String content,
  }) async {
    Map<String, String> token = await TokenControl.readToken();
    try {
      Map<String, dynamic> data = {
        'nickname': nickname,
        'content': content,
      };
      var body = json.encode(data);
      final url = Uri.parse('$baseUrl/api/resolve');
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${token['Authorization']}',
          'refreshToken': 'Bearer ${token['refreshToken']}',
        },
        body: body,
      );
      if (response.statusCode == 200) {
        var jsonString = utf8.decode(response.bodyBytes);
        final myResolve = jsonDecode(jsonString);
        return MyResolveModel.fromJson(myResolve);
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }
}
