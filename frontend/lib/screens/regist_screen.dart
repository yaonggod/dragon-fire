import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/screens/main_screen.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegistScreen extends StatefulWidget {
  final String accessToken;
  final String socialType;

  const RegistScreen(
      {super.key, required this.accessToken, required this.socialType});

  @override
  _RegistScreenState createState() => _RegistScreenState();
}

class _RegistScreenState extends State<RegistScreen> {
  TextEditingController nicknameController = TextEditingController();
  bool nicknameChecked = false;
  String? nicknameTemp;

  Future<List<String>> readToken() async {
    const storage = FlutterSecureStorage();
    List<String> list = [];
    String? accessToken = await storage.read(key: 'accessToken');
    String? refreshToken = await storage.read(key: 'refreshToken');

    if (accessToken != null && refreshToken != null) {
      list.add(accessToken);
      list.add(refreshToken);
    }
    return list;
  }

  bool containsWhitespace(String text) {
    return text.contains(' ');
  }

  Future<void> nicknameCheck() async {
    String nicknameCur = nicknameController.text;
    String baseUrl = dotenv.env['BASE_URL']!;
    final response = await http.get(
        Uri.parse('$baseUrl/api/member/nickname-duplicate/$nicknameCur')
        // Uri.parse('http://10.0.2.2:8080/member/nickname-duplicate/'+nickname)
        );
    if (response.statusCode == 200) {
      print("사용 가능");
      setState(() {
        nicknameChecked = true;
        nicknameTemp = nicknameCur;
      });
      // 사용 가능 팝업 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            backgroundColor: Colors.grey,
            titlePadding: const EdgeInsets.only(right: 5),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.red, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                padding: const EdgeInsets.all(7),
                child: const Text(
                  "드래곤 불",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            contentPadding: const EdgeInsets.only(right: 5),
            content: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                "사용 가능한 닉네임입니다.",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            actionsPadding: const EdgeInsets.only(bottom: 15),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.grey, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                    padding: const EdgeInsets.all(7),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('확인', style: TextStyle(color: Colors.white),),
                    ),
                  )
                ],
              ),
            ],

          );
        },
      );
    } else {
      print("중복");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            backgroundColor: Colors.grey,
            titlePadding: const EdgeInsets.only(right: 5),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.red, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                padding: const EdgeInsets.all(7),
                child: const Text(
                  "드래곤 불",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            contentPadding: const EdgeInsets.only(right: 5),
            content: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                "이미 사용중인 닉네임입니다.",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            actionsPadding: const EdgeInsets.only(bottom: 15),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.grey, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                    padding: const EdgeInsets.all(7),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('확인', style: TextStyle(color: Colors.white),),
                    ),
                  )
                ],
              ),
            ],

          );
        },
      );
    }
  }

  void sendDataToServer() async {
    final String nicknameCur = nicknameController.text;
    String baseUrl = dotenv.env['BASE_URL']!;
    if (nicknameCur == nicknameTemp) {
      final response = await http.post(
          Uri.parse('$baseUrl/api/oauth/${widget.socialType}'),
          // Uri.parse('http://10.0.2.2:8080/oauth/GOOGLE'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(
              {'accessToken': widget.accessToken, 'nickname': nicknameCur}));

      if (response.statusCode == 200) {
        print("Successfully sent data to server");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        print("Failed to send data to server");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              backgroundColor: Colors.grey,
              titlePadding: const EdgeInsets.only(right: 5),
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.red, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                  padding: const EdgeInsets.all(7),
                  child: const Text(
                    "드래곤 불",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              contentPadding: const EdgeInsets.only(right: 5),
              content: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Text(
                  "다시 시도해주세요",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),

              actionsPadding: const EdgeInsets.only(bottom: 15),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.grey, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                      padding: const EdgeInsets.all(7),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('확인', style: TextStyle(color: Colors.white),),
                      ),
                    )
                  ],
                ),
              ],

            );
          },
        );
      }
    } else {
      setState(() {
        nicknameChecked = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            backgroundColor: Colors.grey,
            titlePadding: const EdgeInsets.only(right: 5),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.red, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                padding: const EdgeInsets.all(7),
                child: const Text(
                  "드래곤 불",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            contentPadding: const EdgeInsets.only(right: 5),
            content: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                "닉네임 중복 확인을 해주세요.",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            actionsPadding: const EdgeInsets.only(bottom: 15),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.grey, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                    padding: const EdgeInsets.all(7),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('확인', style: TextStyle(color: Colors.white),),
                    ),
                  )
                ],
              ),
            ],

          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height,
              child: Container(
                child: Image.asset(
                  'lib/assets/icons/background.png',
                  fit: BoxFit.fitHeight,
                ),
              )),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height / 15),
                SizedBox(height: MediaQuery.of(context).size.height / 20),
                const Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
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
                    maxLength: 6,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(
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
                      contentPadding: const EdgeInsets.all(12),
                      labelText: '닉네임을 입력해주세요',
                      labelStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                    )),
                MaterialButton(
                  color: Colors.red,
                  child: const Text(
                    '중복체크',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (nicknameController.text.isEmpty) {
                      // 경고 메시지 표시 로직
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("닉네임 또는 소개는 필수사항입니다!")),
                      );
                    } else if (containsWhitespace(nicknameController.text)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("띄어쓰기가 포함되어 있습니다")),
                      );
                    } else {
                      nicknameCheck();
                    }
                  },
                ),
                MaterialButton(
                  color: Colors.red,
                  child: const Text(
                    '등록',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (nicknameChecked == false) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            backgroundColor: Colors.grey,
                            titlePadding: const EdgeInsets.only(right: 5),
                            title: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(color: Colors.red, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                                padding: const EdgeInsets.all(7),
                                child: const Text(
                                  "드래곤 불",
                                  style: TextStyle(fontSize: 20, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                            contentPadding: const EdgeInsets.only(right: 5),
                            content: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              child: Text(
                                "닉네임 중복 확인을 해주세요.",
                                style: const TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                            actionsPadding: const EdgeInsets.only(bottom: 15),
                            actions: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(color: Colors.grey, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                                    padding: const EdgeInsets.all(7),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('확인', style: TextStyle(color: Colors.white),),
                                    ),
                                  )
                                ],
                              ),
                            ],

                          );
                        },
                      );
                    } else {
                      if (containsWhitespace(nicknameController.text)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("띄어쓰기가 포함되어 있습니다")),
                        );
                      } else {
                        sendDataToServer();
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
