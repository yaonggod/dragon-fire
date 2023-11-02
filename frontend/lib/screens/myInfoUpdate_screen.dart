import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyInfoUpdateScreen extends StatefulWidget {
  const MyInfoUpdateScreen({super.key});

  @override
  _MyInfoUpdateScreenState createState() => _MyInfoUpdateScreenState();
}

class _MyInfoUpdateScreenState extends State<MyInfoUpdateScreen> {
  // 구글
  // 구글 로그인 여부
  bool _googleLoggedIn = false;

  // 구글 로그인 객체
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 네이버
  // 네이버 로그인 결과 객체: loggedIn, cancelledByUser, error
  bool _naverLoginStatus = false;

  String? nicknameTemp;
  // 네이버 로그인 객체
  NaverLoginResult? _naverLoginResult;

  String? nickname;

  bool containsWhitespace(String text) {
    return text.contains(' ');
  }

  @override
  void initState() {
    _checkLoginStatus();

    super.initState();

  }

  @override
  void dispose() {
    nicknameController.dispose();
    super.dispose();
  }

  TextEditingController nicknameController = TextEditingController();
  bool nicknameChecked = false;

  Future<void> _checkLoginStatus() async {
    Map<String, String> tokens = await readToken();
    if (tokens.isNotEmpty && tokens['socialType'] == "GOOGLE") {
      setState(() {
        // 토큰이 있을 경우에 로그인한 서비스에 따라서 상태 설정하기
        _googleLoggedIn = true;
      });
    } else if (tokens.isNotEmpty && tokens['socialType'] == "NAVER") {
      setState(() {
        // 토큰이 있을 경우에 로그인한 서비스에 따라서 상태 설정하기
        _naverLoginStatus = true;
      });
    }

    print(_googleLoggedIn);
    print(_naverLoginStatus);
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

  Future<void> nicknameCheck() async {
    String nicknameCur = nicknameController.text;

    final response = await http.get(Uri.parse(
            'https://k9a209.p.ssafy.io/api/member/nickname-duplicate/$nicknameCur')
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
            title: Text('알림'),
            content: Text('사용 가능'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
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
            title: Text('알림'),
            content: Text('이미 사용중인 닉네임입니다'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }
  saveNickname(String nickname) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('nickname', nickname);
  }

  Future<String?> getNickname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('nickname');
  }

  removeNickname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('nickname');
  }

  void sendDataToServer() async {
    Map<String, String> list = await readToken();

    final String nicknameCur = nicknameController.text;
    if(nicknameCur == nicknameTemp){

      final response = await http.put(
          Uri.parse('https://k9a209.p.ssafy.io/api/member/nickname-modify'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${list["Authorization"]!}',
            'refreshToken': 'Bearer ${list['refreshToken']!}'
          },
          body: jsonEncode({'nickname': nicknameCur}));

      if (response.statusCode == 200) {
        print("Successfully sent data to server");
        nickname = jsonDecode(utf8.decode(response.bodyBytes))['nickname'];
        removeNickname();
        saveNickname(nickname!);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('알림'),
              content: Text('닉네임 변경 성공'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('확인'),
                ),
              ],
            );
          },
        );
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
              title: Text('알림'),
              content: Text('다시 시도해주세요'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('확인'),
                ),
              ],
            );
          },
        );
      }
    }else{
      setState((){
        nicknameChecked = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('알림'),
            content: Text('닉네임 중복체크를 해주세요.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
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
      appBar: AppBar(
        title: const Text('닉네임 수정',
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
              ElevatedButton(
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
                child: const Text('중복체크'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nicknameChecked == false) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('알림'),
                          content: Text('닉네임 중복체크를 해주세요.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('확인'),
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
                child: const Text('등록'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
