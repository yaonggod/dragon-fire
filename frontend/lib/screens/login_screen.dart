import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:frontend/screens/regist_screen.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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

  bool _appleLoggedIn = false;

  bool _isIos = false;
  String? nickname;

  @override
  void initState() {
    _checkLoginStatus();
    super.initState();
    // storage에 토큰을 확인하고 로그인 여부 불러오기
  }

  // initState할때 토큰 존재 여부 확인해서 로그인 status 상태 저장하기
  Future<void> _checkLoginStatus() async {
    await isIOSPlatform();
    nickname = await getNickname();
    print(nickname);
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
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    }

    print(_googleLoggedIn);
    print(_naverLoginStatus);
  }

  Future<void> googleLogin() async {
    _googleSignIn.disconnect();
    GoogleSignInAccount? account = await _googleSignIn.signIn();

    final accessToken =
        (await _googleSignIn.currentUser!.authentication).accessToken!;
    String baseUrl = dotenv.env['BASE_URL']!;
    Uri uri = Uri.parse("$baseUrl/api/oauth/login");
    // Uri uri = Uri.parse("http://10.0.2.2:8080/oauth/login");
    final response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"accessToken": accessToken, "socialType": "GOOGLE"}));

    if (response.statusCode != 200) {
      if (response.body == "탈퇴된 회원") {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('알림'),
              content: Text('탈퇴한 회원입니다.\n(재가입을 원할시 문의를 남겨주세요.)'),
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
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RegistScreen(
                    accessToken: accessToken,
                    socialType: "GOOGLE",
                  )),
        );
      }
    }
    if (response.statusCode == 200) {
      String? accessToken1 = response.headers['authorization'];
      String? refreshToken1 = response.headers['refreshtoken'];
      String? nickname =
          jsonDecode(utf8.decode(response.bodyBytes))['nickname'];
      String? email = jsonDecode(utf8.decode(response.bodyBytes))['email'];
      String? introduction = jsonDecode(utf8.decode(response.bodyBytes))['introduction'];
      if (accessToken1 != null &&
          refreshToken1 != null &&
          nickname != null &&
          email != null) {
        saveToken(
            accessToken1.substring(7), refreshToken1.substring(7), "GOOGLE");
        saveNickname(nickname);
        saveEmail(email);
        saveIntroduction(introduction!);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    }
  }

  // Future<void> appleLogin() async {
  //   final credential = await SignInWithApple.getAppleIDCredential(
  //     scopes: [
  //       AppleIDAuthorizationScopes.email,
  //     ],
  //   );
  //   GoogleSignInAccount? account = await _googleSignIn.signIn();
  //
  //   final accessToken =
  //       (await _googleSignIn.currentUser!.authentication).accessToken!;
  //   String baseUrl = dotenv.env['BASE_URL']!;
  //   Uri uri = Uri.parse("$baseUrl/api/oauth/login");
  //   // Uri uri = Uri.parse("http://10.0.2.2:8080/oauth/login");
  //   final response = await http.post(uri,
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({"accessToken": accessToken, "socialType": "APPLE"}));
  //
  //   if (response.statusCode != 200) {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => RegistScreen(
  //                 accessToken: accessToken,
  //                 socialType: "APPLE",
  //               )),
  //     );
  //   }
  //   if (response.statusCode == 200) {
  //     String? accessToken1 = response.headers['authorization'];
  //     String? refreshToken1 = response.headers['refreshtoken'];
  //     String? nickname =
  //         jsonDecode(utf8.decode(response.bodyBytes))['nickname'];
  //
  //     if (accessToken1 != null && refreshToken1 != null && nickname != null) {
  //       saveToken(
  //           accessToken1.substring(7), refreshToken1.substring(7), "APPLE");
  //       saveNickname(nickname);
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (context) => const MainScreen()),
  //         (route) => false,
  //       );
  //     }
  //   }
  // }

  Future<void> naverLogin() async {
    // 네이버 로그인하기
    _naverLoginResult = await FlutterNaverLogin.logIn();

    // 그럼 네이버에서 토큰을 주는데, 성공했을 경우에는 토큰 문자열이 오지만 실패하면 빈 문자열이 옴
    NaverAccessToken token = await FlutterNaverLogin.currentAccessToken;

    if (token.accessToken != "") {
      // 네이버 AT를 보내서 백엔드에서 로그인하고, 서비스 AT와 RT를 받아오기
      String baseUrl = dotenv.env['BASE_URL']!;
      Uri uri = Uri.parse("$baseUrl/api/oauth/login");
      // Uri uri = Uri.parse("http://10.0.2.2:8080/oauth/logout");
      final response = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(
              {"accessToken": token.accessToken, "socialType": "NAVER"}));

      // 유저가 존재하지 않을 경우
      if (response.statusCode != 200) {
        if (response.body == "탈퇴된 회원") {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('알림'),
                content: Text('탈퇴한 회원입니다.\n(재가입을 원할시 문의를 남겨주세요.)'),
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
      }

      // 유저가 존재할 경우 서버에서 AT와 RT를 보내줌
      if (response.statusCode == 200) {
        String? accessToken1 = response.headers['authorization'];
        String? refreshToken1 = response.headers['refreshtoken'];
        String? nickname =
            jsonDecode(utf8.decode(response.bodyBytes))['nickname'];
        String? email = jsonDecode(utf8.decode(response.bodyBytes))['email'];
        String? introduction = jsonDecode(utf8.decode(response.bodyBytes))['introduction'];

        if (accessToken1 != null &&
            refreshToken1 != null &&
            nickname != null &&
            email != null) {
          saveToken(
              accessToken1.substring(7), refreshToken1.substring(7), "NAVER");
          saveNickname(nickname);
          saveEmail(email);
          saveIntroduction(introduction!);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        }
      }
    }
  }

  Future<void> isIOSPlatform() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    try {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    } catch (e) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      setState(() {
        _isIos = true;
      });
    }
    ;
  }

  _logout() async {
    Map<String, String> list = await readToken();
    String baseUrl = dotenv.env['BASE_URL']!;
    if (list.isNotEmpty) {
      if (_googleLoggedIn) {
        _googleSignIn.signOut();
      }
      if (_naverLoginStatus == true) {
        _naverLoginResult = await FlutterNaverLogin.logOutAndDeleteToken();
      }

      Uri uri = Uri.parse("$baseUrl/api/oauth/logout");
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
        removeNickname();
        print("로그아웃 완료");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
      setState(() {});
    }
  }

  _out() async {
    Map<String, String> list = await readToken();
    String baseUrl = dotenv.env['BASE_URL']!;
    if (list.isNotEmpty) {
      if (_googleLoggedIn) {
        _googleSignIn.signOut();
      }
      if (_naverLoginStatus == true) {
        _naverLoginResult = await FlutterNaverLogin.logOutAndDeleteToken();
      }
      Uri uri = Uri.parse("$baseUrl/api/oauth/out");
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
        removeNickname();
        print("탈퇴 완료");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
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

  saveNickname(String nickname) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('nickname', nickname);
  }

  saveIntroduction(String introduction) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('introduction', introduction);
  }

  saveEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
  }

  Future<String?> getNickname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('nickname');
  }

  Future<String?> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  removeNickname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('nickname');
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
              )).animate().fade(),
          Positioned(
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                  child: Text(
                "비무대회\n입장",
                style: TextStyle(
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(10.0, 10.0),
                        blurRadius: 3.0,
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                      ),
                      Shadow(
                        offset: Offset(10.0, 10.0),
                        blurRadius: 8.0,
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                      ),
                    ],
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 60),
                    textAlign: TextAlign.center,
              ))),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.55,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SizedBox(height: MediaQuery.of(context).size.height / 3),
                  GestureDetector(
                    onTap: naverLogin,
                    child: Container(
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.25),
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
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 60),
                  GestureDetector(
                    onTap: googleLogin,
                    child: Container(
                      decoration: const BoxDecoration(
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
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 60),
                  (_isIos)
                      ? SignInWithAppleButton(
                          text: "Continue with Apple",
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                          style: SignInWithAppleButtonStyle.black,
                          iconAlignment: IconAlignment.center,
                          onPressed: () async {},
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
