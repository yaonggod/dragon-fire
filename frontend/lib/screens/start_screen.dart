import 'package:flutter/material.dart';
import 'package:frontend/screens/game_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart'; // 이 임포트를 추가

class StartScreen extends StatefulWidget {

  const StartScreen({super.key});

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {

  String? nickname;
  String? accessToken;
  String? refreshToken;
  @override
  void initState() {
    _checkLoginStatus();
    super.initState();
  }


  Future<void> _checkLoginStatus() async {
    nickname = await getNickname();
    Map<String, String> tokens = await readToken();
    accessToken = tokens['Authorization'];
    refreshToken = tokens['refreshToken'];
    print(refreshToken);
  }

  Future<Map<String, String>> readToken() async {
    const storage = FlutterSecureStorage();
    Map<String, String> list = {};
    String? accessToken = await storage.read(key: 'accessToken');
    String? refreshToken = await storage.read(key: 'refreshToken');
    String? socialType = await storage.read(key: 'socialType');

    if (accessToken != null && refreshToken != null && socialType != null) {
      list['Authorization'] = accessToken;
      list['refreshToken'] = refreshToken;
      list['socialType'] = socialType;
    }

    return list;
  }

  void startGame() async {

    // final response = await http.post(
    //   Uri.parse('https://k9a209.p.ssafy.io/api/wait'),
    //   headers: {
    //     'Content-Type': 'application/json; charset=UTF-8',
    //     'Authorization': 'Bearer $accessToken',
    //     'refreshToken': 'Bearer $refreshToken'
    //   },
    //     body: jsonEncode({"nickname": nickname!}),
    //
    // );

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/wait'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
        'refreshToken': 'Bearer $refreshToken'

      },
      body: jsonEncode({"nickname": nickname!}),

    );

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
        title: Text('게임 매칭'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            ElevatedButton(
              onPressed: () {
                startGame();
              },
              child: Text('게임 매칭'),
            ),
          ],
        ),
      ),
    );
  }
}