import 'package:flutter/material.dart';
import 'package:frontend/screens/game_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // 이 임포트를 추가

class StartScreen extends StatelessWidget {
  final TextEditingController _nicknameController = TextEditingController();

  void startGame(BuildContext context) async {
    //final response = await http.get(Uri.parse('https://k9a209.p.ssafy.io/api/wait'));
    final response = await http.get(Uri.parse('http://10.0.2.2:8080/wait'));
    String nickname = _nicknameController.text;
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data.containsKey("roomId")) {
        int roomId = data["roomId"];
        print('roomId: $roomId');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(roomId: roomId,nickname:nickname), // 이건 game.dart에 있다.
          ),
        );
      } else {
        print('서버 응답에 roomId가 없음');
      }
    } else {
      print('요청 실패: ${response.statusCode}');
    }
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
          children: <Widget>[
            TextFormField(
              controller: _nicknameController,
              decoration: InputDecoration(labelText: '닉네임'), // 입력 필드 레이블
            ),
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