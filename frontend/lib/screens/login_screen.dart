import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:frontend/screens/regist_screen.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 구글
  bool _isLoggedIn = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 네이버
  // 네이버 로그인 객체
  NaverLoginResult? naverLoginResult;
  // 네이버 로그인 결과 객체: loggedIn, cancelledByUser, error
  NaverLoginStatus naverLoginStatus = NaverLoginStatus.cancelledByUser;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    Map<String, String> tokens = await readToken();
    setState(() {
      _isLoggedIn = tokens.isNotEmpty;
    });
  }

  Future<void> googleLogin() async {
    GoogleSignInAccount? account = await _googleSignIn.signIn();

    final accessToken =
        (await _googleSignIn.currentUser!.authentication).accessToken!;

    Uri uri = Uri.parse("http://10.0.2.2:8080/oauth/login");
    final response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"accessToken": accessToken, "socialType": "GOOGLE"}));

    if (response.statusCode != 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RegistScreen(
                  accessToken: accessToken,
                  socialType: "GOOGLE",
                )),
      );
    }
    if (response.statusCode == 200) {
      String? accessToken1 = response.headers['authorization'];
      String? refreshToken1 = response.headers['refreshtoken'];

      if (accessToken1 != null && refreshToken1 != null) {
        print(accessToken1.substring(7));
        print(refreshToken1.substring(7));
        saveToken(accessToken1.substring(7), refreshToken1.substring(7));
        setState(() {
          _isLoggedIn = true;
        });
      }
    }
  }

  Future<void> naverLogin() async {
    // 네이버 로그인하기
    naverLoginResult = await FlutterNaverLogin.logIn();

    // 그럼 네이버에서 토큰을 주는데, 성공했을 경우에는 토큰 문자열이 오지만 실패하면 빈 문자열이 옴
    NaverAccessToken token = await FlutterNaverLogin.currentAccessToken;

    if (token.accessToken != "") {
      // 네이버 AT를 보내서 백엔드에서 로그인하고, 서비스 AT와 RT를 받아오기
      Uri uri = Uri.parse("http://10.0.2.2:8080/oauth/login");
      final response = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(
              {"accessToken": token.accessToken, "socialType": "NAVER"}));

      // 유저가 존재하지 않을 경우
      if (response.statusCode != 200) {
        // AT와 NAVER를 가지고 회원가입 페이지로 보내기
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RegistScreen(
                    accessToken: token.accessToken,
                    socialType: "NAVER",
                  )),
        );
      }

      // 유저가 존재할 경우 서버에서 AT와 RT를 보내줌
      if (response.statusCode == 200) {
        String? accessToken1 = response.headers['authorization'];
        String? refreshToken1 = response.headers['refreshtoken'];

        if (accessToken1 != null && refreshToken1 != null) {
          saveToken(accessToken1.substring(7), refreshToken1.substring(7));
          setState(() {
            naverLoginStatus = naverLoginResult!.status;
          });
        }
      }
    }
  }

  _logout() async {
    Map<String, String> list = await readToken();
    if (list.isNotEmpty) {
      _googleSignIn.signOut();
      Uri uri = Uri.parse("http://10.0.2.2:8080/oauth/logout");
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${list["Authorization"]!}',
          'refreshToken': 'Bearer ${list['refreshToken']!}'
        },
      );

      if (response.statusCode == 200) {
        FlutterSecureStorage storage = const FlutterSecureStorage();
        storage.deleteAll();
        print("로그아웃 완료");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
      setState(() {});
    }
  }

  _out() async {
    Map<String, String> list = await readToken();
    if (list.isNotEmpty) {
      _googleSignIn.signOut();
      Uri uri = Uri.parse("http://10.0.2.2:8080/oauth/out");
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${list["Authorization"]!}',
          'refreshToken': 'Bearer ${list['refreshToken']!}'
        },
      );

      if (response.statusCode == 200) {
        FlutterSecureStorage storage = const FlutterSecureStorage();
        storage.deleteAll();
        print("탈퇴 완료");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
      setState(() {});
    }
  }

  void saveToken(String accessToken, String refreshToken) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'accessToken', value: accessToken);
    await storage.write(key: 'refreshToken', value: refreshToken);
  }

  Future<Map<String, String>> readToken() async {
    const storage = FlutterSecureStorage();
    Map<String, String> list = {};
    String? accessToken = await storage.read(key: 'accessToken');
    String? refreshToken = await storage.read(key: 'refreshToken');

    if (accessToken != null && refreshToken != null) {
      list['Authorization'] = accessToken;
      list['refreshToken'] = refreshToken;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "로그인",
          style: TextStyle(
            fontSize: 22,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 3),
            SizedBox(height: MediaQuery.of(context).size.height / 8),
            naverLoginStatus != NaverLoginStatus.loggedIn
                ? GestureDetector(
                    onTap: naverLogin,
                    child: const Text("Naver 로그인"),
                  )
                : Container(),
            SizedBox(height: MediaQuery.of(context).size.height / 8),
            _isLoggedIn == false
                ? GestureDetector(
                    onTap: googleLogin,
                    child: const Text("Gmail 로그인"),
                  )
                : Container(),
            _isLoggedIn == true
                ? MaterialButton(
                    color: Colors.red,
                    child: const Text(
                      '로그아웃',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      _logout();
                      print('Logout button pressed.');
                    },
                  )
                : Container(),
            if (_isLoggedIn)
              MaterialButton(
                color: Colors.red,
                child: const Text(
                  '회원탈퇴',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  _out();
                  print('회원탈퇴.');
                },
              )
          ],
        ),
      ),
    );
  }
}
