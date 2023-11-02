import 'package:flutter/material.dart';
import 'package:frontend/screens/game_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart'; // 이 임포트를 추가

class StartScreen extends StatelessWidget {
  String? nickname;
  void startGame(BuildContext context) async {
    nickname = await getNickname();
    const storage = FlutterSecureStorage();
    String? accessToken = await storage.read(key: 'accessToken');
    // String nickname = _nicknameController.text;
    // //final response = await http.get(Uri.parse('https://k9a209.p.ssafy.io/api/wait'));
    final response = await http.get(
      Uri.parse('https://k9a209.p.ssafy.io/api/wait'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'X-Nickname': nickname!,
      },
    );
     // final response = await http.get(
     //     Uri.parse('http://10.0.2.2:8080/wait'),
     //     headers: {
     //       'Content-Type': 'application/json',
     //       'Accept': 'application/json',
     //       'Authorization': 'Bearer $accessToken',
     //       'X-Nickname': nickname!,
     //     },
     //
     //
     // );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data.containsKey("roomId")) {
        int roomId = data["roomId"];
        print('roomId: $roomId');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(roomId: roomId,nickname:nickname!), // 이건 game.dart에 있다.
          ),
        );
      } else {
        print('서버 응답에 roomId가 없음');
      }
    } else {
      print('요청 실패: ${response.statusCode}');
    }
  }

  Future<String?> getNickname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('nickname');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Game Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            ElevatedButton(
              onPressed: () {
                startGame(context);
              },
              child: Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}