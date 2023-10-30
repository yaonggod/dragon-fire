import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:frontend/screens/regist_screen.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  Future<void> googleLogin() async {
    _googleSignIn.disconnect();
    GoogleSignInAccount? account = await _googleSignIn.signIn();

    final accessToken =
        (await _googleSignIn.currentUser!.authentication).accessToken!;

    // Uri uri = Uri.parse("https://k9a209.p.ssafy.io/api/oauth/login");
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
        saveToken(
            accessToken1.substring(7), refreshToken1.substring(7), "GOOGLE");
        setState(() {
          _googleLoggedIn = true;
        });
      }
    }
  }

  Future<void> naverLogin() async {
    // 네이버 로그인하기
    _naverLoginResult = await FlutterNaverLogin.logIn();

    // 그럼 네이버에서 토큰을 주는데, 성공했을 경우에는 토큰 문자열이 오지만 실패하면 빈 문자열이 옴
    NaverAccessToken token = await FlutterNaverLogin.currentAccessToken;

    if (token.accessToken != "") {
      // 네이버 AT를 보내서 백엔드에서 로그인하고, 서비스 AT와 RT를 받아오기

      Uri uri = Uri.parse("https://k9a209.p.ssafy.io/api/oauth/login");
      // Uri uri = Uri.parse("http://10.0.2.2:8080/oauth/logout");
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
          saveToken(
              accessToken1.substring(7), refreshToken1.substring(7), "NAVER");
          setState(() {
            _naverLoginStatus = true;
          });
        }
      }
    }
  }

  _logout() async {
    Map<String, String> list = await readToken();
    if (list.isNotEmpty) {
      if (_googleLoggedIn) {
        _googleSignIn.signOut();
      }
      if (_naverLoginStatus == true) {
        _naverLoginResult = await FlutterNaverLogin.logOutAndDeleteToken();
      }

      Uri uri = Uri.parse("https://k9a209.p.ssafy.io/api/oauth/logout");
      // Uri uri = Uri.parse("http://10.0.2.2:8080/oauth/logout");
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
      if (_googleLoggedIn) {
        _googleSignIn.signOut();
      }
      if (_naverLoginStatus == true) {
        _naverLoginResult = await FlutterNaverLogin.logOutAndDeleteToken();
      }
      Uri uri = Uri.parse("https://k9a209.p.ssafy.io/api/oauth/out");
      // Uri uri = Uri.parse("http://10.0.2.2:8080/oauth/out");
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

  void saveToken(
      String accessToken, String refreshToken, String socialType) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'accessToken', value: accessToken);
    await storage.write(key: 'refreshToken', value: refreshToken);
    await storage.write(key: 'socialType', value: socialType);
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
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / 3),
              (_naverLoginStatus != true && !_googleLoggedIn)
                  ? GestureDetector(
                      onTap: naverLogin,
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.15),
                              offset: Offset(0, 3),
                              blurRadius: 5,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'lib/assets/icons/naverButton.png',
                          width: MediaQuery.of(context).size.width * 0.8,
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(height: MediaQuery.of(context).size.height / 100),
              (_naverLoginStatus != true && !_googleLoggedIn)
                  ? GestureDetector(
                      onTap: googleLogin,
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.15),
                              offset: Offset(0, 5),
                              blurRadius: 5,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'lib/assets/icons/googleButton.png',
                          width: MediaQuery.of(context).size.width * 0.8,
                        ),
                      ),
                    )
                  : Container(),
              if (_naverLoginStatus == true || _googleLoggedIn == true)
                MaterialButton(
                  color: Colors.red,
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    _logout();
                    print('Logout button pressed.');
                  },
                ),
              if (_naverLoginStatus == true || _googleLoggedIn == true)
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
      ),
    );
  }
}
