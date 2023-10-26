import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/screens/main_screen.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegistScreen extends StatefulWidget {
  final String accessToken;

  RegistScreen({required this.accessToken});

  @override
  _RegistScreenState createState() => _RegistScreenState();
}

class _RegistScreenState extends State<RegistScreen> {
  TextEditingController nicknameController = TextEditingController();

  Future<List<String>> readToken() async {
    final storage = new FlutterSecureStorage();
    List<String> list = [];
    String? accessToken = await storage.read(key: 'accessToken');
    String? refreshToken = await storage.read(key: 'refreshToken');

    if (accessToken != null && refreshToken != null) {
      list.add(accessToken);
      list.add(refreshToken);
    }
    return list;
  }

  void sendDataToServer() async {
    final String nickname = nicknameController.text;

    final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/oauth/GOOGLE'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'accessToken': widget.accessToken, 'nickname': nickname}));

    if (response.statusCode == 200) {
      print("Successfully sent data to server");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      print("Failed to send data to server");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / 15),
              SizedBox(height: MediaQuery.of(context).size.height / 20),
              Padding(
                padding: EdgeInsets.only(left: 5.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    '닉네임',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 100),
              TextField(
                  controller: nicknameController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Color(0xFFF6766E),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ),
                    isDense: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    contentPadding: EdgeInsets.all(12),
                    labelText: '닉네임을 입력해주세요',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  )),
              ElevatedButton(
                onPressed: () {
                  // print(widget.code);
                  if (nicknameController.text.isEmpty) {
                    // 경고 메시지 표시 로직
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("닉네임 또는 소개는 필수사항입니다!")),
                    );
                  } else {
                    sendDataToServer();
                  }

                  // '등록하기' 버튼이 눌렸을 때 수행할 로직
                },
                child: Text('등록'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
