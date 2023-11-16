import 'dart:convert';

import 'package:flutter/material.dart';
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
    introductionController.dispose();
    super.dispose();
  }

  TextEditingController nicknameController = TextEditingController();
  TextEditingController introductionController = TextEditingController();

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
    String baseUrl = dotenv.env['BASE_URL']!;
    final String nicknameCur = nicknameController.text;
    if (nicknameCur == nicknameTemp) {
      final response =
          await http.put(Uri.parse('$baseUrl/api/member/nickname-modify'),
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
          barrierDismissible: false,
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
                  "닉네임 변경 성공",
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
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainScreen(),
                            ),
                                (Route<dynamic> route) => false,
                          );
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
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(builder: (context) => const MainScreen()),
        //   (Route<dynamic> route) => false,
        // );
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

  void sendIntroDataToServer() async {
    Map<String, String> list = await readToken();
    String baseUrl = dotenv.env['BASE_URL']!;
    String introduction = introductionController.text;
    introduction = introduction.replaceAll('\n', ' ');

    final response =
        await http.put(Uri.parse('$baseUrl/api/member/introduction-modify'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${list["Authorization"]!}',
              'refreshToken': 'Bearer ${list['refreshToken']!}'
            },
            body: jsonEncode({'introduction': introduction}));

    if (response.statusCode == 200) {
      saveIntroduction(
          jsonDecode(utf8.decode(response.bodyBytes))['introduction']);
      Future.microtask(
        () {
          showDialog(
            context: context,
            barrierDismissible: false,
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
                    "자기소개 변경 성공",
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
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainScreen(),
                              ),
                                  (Route<dynamic> route) => false,
                            );
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
        },
      );
    } else {
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
  }

  saveIntroduction(String introduction) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('introduction', introduction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              'lib/assets/icons/background.png',
              fit: BoxFit.fitHeight,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                      color: Colors.red,
                      child: const Text(
                        '중복체크',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        String text = nicknameController.text;
                        if (nicknameController.text.isEmpty) {



                          // 경고 메시지 표시 로직
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("닉네임 또는 소개는 필수사항입니다!")),
                          );
                        } else if (containsWhitespace(
                            text.replaceAll('\n', ' '))) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("띄어쓰기가 포함되어 있습니다")),
                          );
                        } else {
                          nicknameCheck();
                        }
                      },
                    ),
                    const SizedBox(width: 25),
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
                const SizedBox(
                  height: 20,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '자기소개',
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 100),
                TextField(
                  controller: introductionController,
                  maxLength: 20,
                  minLines: 2,
                  maxLines: 2,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
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
                    labelText: '자기소개를 입력해주세요',
                    labelStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                MaterialButton(
                  color: Colors.red,
                  child: const Text(
                    '등록',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    sendIntroDataToServer();
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
