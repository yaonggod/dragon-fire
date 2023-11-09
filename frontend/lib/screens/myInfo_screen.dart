import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/screens/info_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/myInfoUpdate_screen.dart';
import 'package:frontend/widgets/carousel_widget.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyInfoScreen extends StatefulWidget {
  const MyInfoScreen({super.key});

  @override
  _MyInfoScreenState createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
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

  String? nickname;

  List<String> assetList =[
    "lib/assets/icons/tutorial0.png",
    "lib/assets/icons/tutorial1.png",
    "lib/assets/icons/tutorial2.png",
    "lib/assets/icons/tutorial3.png",
    "lib/assets/icons/tutorial4.png",
    "lib/assets/icons/tutorial5.png",
  ];

  @override
  void initState() {
    _checkLoginStatus();
    super.initState();
    // storage에 토큰을 확인하고 로그인 여부 불러오기
  }

  // initState할때 토큰 존재 여부 확인해서 로그인 status 상태 저장하기
  Future<void> _checkLoginStatus() async {
    nickname = await getNickname();
    print("nickname ${nickname == null}");
    print(nickname);

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
    print(tokens['Authorization']);
    print(tokens['refreshToken']);
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

      // 로그아웃할때 fcm token도 없애버리기
      final response2 = await http.post(
        Uri.parse('$baseUrl/api/member/fcm'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${list["Authorization"]!}',
          'refreshToken': 'Bearer ${list['refreshToken']!}'
        },
        body: jsonEncode({"fcmToken": null}),
      );
      print(response2.statusCode);
      //

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
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('알림'),
              content: Text('회원탈퇴 되었습니다.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                    );
                  },
                  child: Text('확인'),
                ),
              ],
            );
          },
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

  Future<String?> getNickname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('nickname');
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
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "내 정보",
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
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    insetPadding: const EdgeInsets.all(10),
                    backgroundColor: const Color.fromRGBO(0, 50, 90, 0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 1.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Stack(
                                children: [
                                  Positioned(
                                    child: Center(
                                      child: Text(
                                        "환경설정",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 40,
                                        ),
                                      ),
                                    ),
                                    left: 0,
                                    height: MediaQuery.of(context).size.width * 0.2,
                                    right: 0,
                                  ),

                                  Positioned(
                                    child: Divider(
                                      color: Colors.white,
                                      thickness: 2,
                                    ),
                                    left: 0,
                                    top: MediaQuery.of(context).size.width * 0.2,
                                    right: 0,
                                  ),

                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width - 20,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: MediaQuery.of(context).size.width * 0.22),
                                        GestureDetector(
                                          onTap: () {
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(builder: (context) => MusicScreen()),
                                            // );
                                          },
                                          child: ListTile(
                                            title: Text(
                                              '음악',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          color: Colors.white,
                                          thickness: 2,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => InfoScreen()),
                                            );
                                          },
                                          child: ListTile(
                                            title: Text(
                                              '개인정보처리방침',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          color: Colors.white,
                                          thickness: 2,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return Scaffold(
                                                  backgroundColor: Colors.transparent,

                                                  body: Center(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        CarouselWidget(asset: assetList),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: ListTile(
                                            title: Text(
                                              '튜토리얼',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: Container(
              margin: EdgeInsets.only(right: 8),
              width: MediaQuery.of(context).size.width * 0.09,
              height: MediaQuery.of(context).size.width * 0.09,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/icons/settings.png'),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                    style: TextStyle(fontSize: 50),
                    nickname != null ? nickname! : "null"),
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 3),
              SizedBox(height: MediaQuery.of(context).size.height / 100),
              if (_naverLoginStatus == true || _googleLoggedIn == true)
                MaterialButton(
                  color: Colors.red,
                  child: const Text(
                    '닉네임 변경',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const MyInfoUpdateScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                    print('닉네임변경 버튼 클릭.');
                  },
                ),
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
              MaterialButton(
                color: Colors.red,
                child: const Text(
                  '회원탈퇴',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('알림'),
                        content: Text('회원탈퇴하시겠습니까?\n(재가입은 불가능합니다.)'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              _out();
                            },
                            child: Text('확인'),
                          ),
                        ],
                      );
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
