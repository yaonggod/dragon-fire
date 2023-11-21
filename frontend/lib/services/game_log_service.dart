import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/game_log_model.dart';
import 'package:frontend/utils/token_control.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GameLogService {
  static String baseUrl = dotenv.env['BASE_URL']!;

  static Future<List<GameLogModel>?> getGameLogList() async {
    Map<String, String> token = await TokenControl.readToken();
    List<GameLogModel> gameLogListInstances = [];
    try {
      final url = Uri.parse('$baseUrl/api/play-log');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${token['Authorization']}',
        'refreshToken': 'Bearer ${token['refreshToken']}',
      });
      if (response.statusCode == 200 && response.contentLength != 0) {
        var jsonString = utf8.decode(response.bodyBytes);
        final gameLogs = jsonDecode(jsonString);
        for (var gameLog in gameLogs) {
          final instance = GameLogModel.fromJson(gameLog);
          gameLogListInstances.add(instance);
        }
        return gameLogListInstances;
      }
    } catch (error) {
      Dialog(
        insetPadding: const EdgeInsets.all(10),
        backgroundColor: const Color.fromRGBO(3, 8, 61, 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text('로그 불러오기에 실패했습니다.\n다시 시도해 주십시오.'),
      );
    }
    return null;
  }
}
