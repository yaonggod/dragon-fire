import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:frontend/screens/regist_screen.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String nickname = "하이";
  TextEditingController detailController = TextEditingController();

  // 구글
  // 구글 로그인 여부
  bool _googleLoggedIn = false;

  // 구글 로그인 객체
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 네이버
  // 네이버 로그인 결과 객체: loggedIn, cancelledByUser, error
  bool _naverLoginStatus = false;

  // 네이버 로그인 객체
  NaverLoginResult? _naverLoginResult;

  /*
  * 대전전적의 각 전적의 신고버튼으로 이 화면으로 올 수 있음
  *
  * 해당 전적에 대한 신고
  *
  * 신고 상세 정보 적고 제출
   */
  @override
  void initState() {
    super.initState();
    // storage에 토큰을 확인하고 로그인 여부 불러오기
    _checkLoginStatus();
  }

  // initState할때 토큰 존재 여부 확인해서 로그인 status 상태 저장하기
  Future<void> _checkLoginStatus() async {
    Map<String, String> tokens = await readToken();
    print(tokens.toString());
    print(tokens.isNotEmpty);
    print(tokens);
    if (tokens.isNotEmpty && tokens['socialType'] == "GOOGLE") {
      print(1);
      setState(() {
        // 토큰이 있을 경우에 로그인한 서비스에 따라서 상태 설정하기
        _googleLoggedIn = true;
      });
    } else if (tokens.isNotEmpty && tokens['socialType'] == "NAVER") {
      print(2);
      setState(() {
        // 토큰이 있을 경우에 로그인한 서비스에 따라서 상태 설정하기
        _naverLoginStatus = true;
      });
    }

    print(_googleLoggedIn);
    print(_naverLoginStatus);
  }

  Future<void> sendReport() async {
    Map<String, String> tokens = await readToken();
    final String nickname = detailController.text;
    String otherId = "";
    String baseUrl = dotenv.env['BASE_URL']!;
    if (tokens.isNotEmpty) {
      Uri uri = Uri.parse("$baseUrl/api/report/new");
      final response = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${tokens["Authorization"]!}',
            'refreshToken': 'Bearer ${tokens["refreshToken"]!}',
          },
          body: jsonEncode({"suspect": otherId, "reportDetail": nickname}));

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('알림'),
              content: Text('신고가 접수되었습니다'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MainScreen()),
                            (route) => false);
                  },
                  child: Text('확인'),
                ),
              ],
            );
          },
        );
      }
      if (response.statusCode != 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('알'),
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
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('피드백',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const Padding(
              //   padding: EdgeInsets.only(left: 5.0),
              //   child: Align(
              //     alignment: Alignment.centerLeft,
              //     child: Text(
              //       '신고 회원',
              //       style: TextStyle(
              //         fontSize: 15.0,
              //       ),
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: EdgeInsets.only(left: 5.0),
              //   child: Align(
              //     alignment: Alignment.centerLeft,
              //     child: Text(
              //       nickname,
              //       style: TextStyle(
              //         fontSize: 15.0,
              //       ),
              //     ),
              //   ),
              // ),
              SizedBox(height: MediaQuery.of(context).size.height / 15),
              SizedBox(height: MediaQuery.of(context).size.height / 20),
              const Padding(
                padding: EdgeInsets.only(left: 5.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '피드백',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 100),
              Container(
                child: TextField(
                  controller: detailController,
                  minLines: 10, // 최소 라인 수 설정
                  maxLines: 10, // 최대 라인 수 설정
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
                    labelText: '피드백을 자유롭게 남겨주세요',
                    labelStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 100),
              ElevatedButton(
                onPressed: () {
                  // print(widget.code);
                  if (detailController.text.isEmpty) {
                    // 경고 메시지 표시 로직
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("신고 사유는 필수사항입니다!")),
                    );
                  } else {
                    sendReport();
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
