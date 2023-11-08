import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/screens/friend_screen.dart';
import 'package:frontend/screens/game_screen.dart';
import 'package:frontend/screens/myInfo_screen.dart';
import 'package:frontend/screens/ranking_screen.dart';
import 'package:frontend/screens/report_screen.dart';
import 'package:frontend/screens/towerEnter_screen.dart';
import 'package:frontend/screens/tutorial_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  DateTime? backPressed;
  String? nickname;
  String? accessToken;
  String? refreshToken;
  String buttonsrc = 'lib/assets/icons/startButton.png';
  String buttonsrc1 = 'lib/assets/icons/rankingButton.png';
  String buttonsrc2 = 'lib/assets/icons/reportButton.png';
  String buttonsrc3 = 'lib/assets/icons/friendButton.png';
  String buttonsrc4 = 'lib/assets/icons/myButton.png';

  bool isButtonDisabled = false;

  bool _isFirstAccess = true; // 첫 접속 여부

  List<String> assetList =[
    "lib/assets/icons/tutorial0.png",
    "lib/assets/icons/tutorial1.png",
    "lib/assets/icons/tutorial2.png",
    "lib/assets/icons/tutorial3.png",
    "lib/assets/icons/tutorial4.png",
    "lib/assets/icons/tutorial5.png",
  ];


  Future<bool> endApp() async {
    DateTime curTime = DateTime.now();

    if (backPressed == null ||
        curTime.difference(backPressed!) > const Duration(seconds: 2)) {
      backPressed = curTime;
      Fluttertoast.showToast(msg: "'뒤로'버튼 한번 더 누르시면 종료됩니다.");
      return false;
    }
    return true;
  }

  Future<String?> getNickname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('nickname');
  }

  Future<void> _checkLoginStatus() async {
    await checkFirstAccess();
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

  Future<void> startGame() async {
    String baseUrl = dotenv.env['BASE_URL']!;
    // final response = await http.post(
    //   Uri.parse('$baseUrl/api/wait'),
    //   headers: {
    //     'Content-Type': 'application/json; charset=UTF-8',
    //     'Authorization': 'Bearer $accessToken',
    //     'refreshToken': 'Bearer $refreshToken'
    //   },
    //   body: jsonEncode({"nickname": nickname!}),
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
        int nowNumber = data["nowNumber"];
        print("나는 "+'$nowNumber'+"번 째 사람입니다");
        print('roomId: $roomId');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(
                roomId: roomId, nickname: nickname!, nowNumber: nowNumber), // 이건 game.dart에 있다.
          ),
        );
      } else {
        print('서버 응답에 roomId가 없음');
      }
    } else {
      print('요청 실패: ${response.statusCode}');
    }
  }

  void _navigateToMyInfoScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyInfoScreen(),
      ),
    );
  }

  void _navigateToStartScreen() {
    startGame();
  }

  void _navigateToRankingScreen() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(10),
          backgroundColor: const Color.fromRGBO(0, 0, 132, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: RankingScreen(),
        );
      },
    );
  }

  Future<void> checkFirstAccess() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isFirstAccess = prefs.getBool('isFirstAccess') ?? true;
    if (_isFirstAccess) {
      await prefs.setBool('isFirstAccess', false);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TutorialScreen()),
      );
    }
  }

  void _navigateToReportScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReportScreen(),
      ),
    );
  }

  void _navigateToFriendScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendScreen(),
      ),
    );
  }

  void _navigateToTowerEnterScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TowerEnterScreen(),
      ),
    );
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward().whenComplete(() {});
    init();
    updateFcmToken();
    super.initState();
  }

  Future<void> init() async {
    await _checkLoginStatus();
  }

  Future<void> updateFcmToken() async {
    String baseUrl = dotenv.env['BASE_URL']!;
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    Map<String, String> tokens = await readToken();
    accessToken = tokens['Authorization'];
    refreshToken = tokens['refreshToken'];
    final response = await http.post(
      Uri.parse('$baseUrl/api/member/fcm'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'refreshToken': 'Bearer $refreshToken'
      },
      body: jsonEncode({"fcmToken": fcmToken}),
    );
    print(response.statusCode);
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget slidingWidget(
    BuildContext context,
    Animation<double> animation,
    Widget child, {
    Offset begin = Offset.zero,
    Offset end = Offset.zero,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final currentPosition = Offset.lerp(begin, end, animation.value)!;
        return Positioned(
          top: MediaQuery.of(context).size.height * 1 / 7,
          width: MediaQuery.of(context).size.width,
          child: Opacity(
            opacity: 1 - animation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: endApp,
        child: Stack(
          children: [
            slidingWidget(
              context,
              _animation,
              Image.asset(
                'lib/assets/icons/mainMark2.png',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              begin: Offset(0, MediaQuery.of(context).size.height * 2 / 7),
              end: Offset(0, 0),
            ),
            Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                ),
                GestureDetector(
                  onTap: () {
                    if (!isButtonDisabled) {
                      _navigateToStartScreen();
                      setState(() {
                        isButtonDisabled = true;
                      });
                    }
                  },
                  onTapDown: (_) {
                    if (!isButtonDisabled) {
                      setState(() {
                        buttonsrc = 'lib/assets/icons/startButton2.png';
                      });
                    }
                  },
                  onTapUp: (_) {
                    if (!isButtonDisabled) {
                      setState(() {
                        buttonsrc = 'lib/assets/icons/startButton.png';
                      });
                    }
                  },
                  onTapCancel: () {
                    if (!isButtonDisabled) {
                      setState(() {
                        buttonsrc = 'lib/assets/icons/startButton.png';
                      });
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: MediaQuery.of(context).size.width * 0.35,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(buttonsrc),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _navigateToRankingScreen();
                      },
                      onTapDown: (_) {
                        setState(() {
                          buttonsrc1 = 'lib/assets/icons/rankingButton2.png';
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          buttonsrc1 = 'lib/assets/icons/rankingButton.png';
                        });
                      },
                      onTapCancel: () => setState(() {
                        buttonsrc1 = 'lib/assets/icons/rankingButton.png';
                      }),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.width * 0.25,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(buttonsrc1),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     _navigateToReportScreen();
                    //   },
                    //   onTapDown: (_) {
                    //     setState(() {
                    //       buttonsrc2 = 'lib/assets/icons/reportButton2.png';
                    //     });
                    //   },
                    //   onTapUp: (_) {
                    //     setState(() {
                    //       buttonsrc2 = 'lib/assets/icons/reportButton.png';
                    //     });
                    //   },
                    //   onTapCancel: () => setState(() {
                    //     buttonsrc2 = 'lib/assets/icons/reportButton.png';
                    //   }),
                    //   child: Container(
                    //     width: MediaQuery.of(context).size.width * 0.25,
                    //     height: MediaQuery.of(context).size.width * 0.25,
                    //     decoration: BoxDecoration(
                    //       image: DecorationImage(
                    //         image: AssetImage(buttonsrc2),
                    //         fit: BoxFit.fitWidth,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    GestureDetector(
                      onTap: () {
                        _navigateToFriendScreen();
                      },
                      onTapDown: (_) {
                        setState(() {
                          buttonsrc3 = 'lib/assets/icons/friendButton2.png';
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          buttonsrc3 = 'lib/assets/icons/friendButton.png';
                        });
                      },
                      onTapCancel: () => setState(() {
                        buttonsrc3 = 'lib/assets/icons/friendButton.png';
                      }),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.width * 0.25,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(buttonsrc3),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _navigateToMyInfoScreen();
                      },
                      onTapDown: (_) {
                        setState(() {
                          buttonsrc4 = 'lib/assets/icons/myButton2.png';
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          buttonsrc4 = 'lib/assets/icons/myButton.png';
                        });
                      },
                      onTapCancel: () => setState(() {
                        buttonsrc4 = 'lib/assets/icons/myButton.png';
                      }),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.width * 0.25,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(buttonsrc4),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
