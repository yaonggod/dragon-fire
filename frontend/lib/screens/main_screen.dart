import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

import '../services/connecting_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Animation<double> _animation;
  DateTime? backPressed;
  String? nickname;
  String? accessToken;
  String? refreshToken;
  String buttonsrc = 'lib/assets/icons/pvpButton.png';
  String buttonsrc1 = 'lib/assets/icons/rankingButton.png';
  String buttonsrc2 = 'lib/assets/icons/reportButton.png';
  String buttonsrc3 = 'lib/assets/icons/friendButton.png';
  String buttonsrc4 = 'lib/assets/icons/myButton.png';
  String buttonsrc5 = 'lib/assets/icons/towerButton.png';

  bool isButtonDisabled = false;

  bool _isFirstAccess = true; // 첫 접속 여부

  bool _isHaptic = true;

  List<String> assetList = [
    "lib/assets/icons/tutorial0.png",
    "lib/assets/icons/tutorial1.png",
    "lib/assets/icons/tutorial2.png",
    "lib/assets/icons/tutorial3.png",
    "lib/assets/icons/tutorial4.png",
    "lib/assets/icons/tutorial5.png",
  ];

  Random random = Random();
  List<String> myImageList = [
    'lib/assets/skills/newFireBallPlayer.gif',
    'lib/assets/skills/blink.gif',
    'lib/assets/skills/charging.gif',
    'lib/assets/skills/fireShield.gif',
  ];
  List<String> contenderImageList = [
    'lib/assets/skills/newFireBallRival.gif',
    'lib/assets/skills/blink.gif',
    'lib/assets/skills/charging.gif',
    'lib/assets/skills/fireShield.gif',
  ];
  int currentMyImageIndex = 0;
  int currentContenderImageIndex = 0;


  void startImageChangeTimer() {
    Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        currentMyImageIndex = random.nextInt(myImageList.length);
        currentContenderImageIndex = random.nextInt(contenderImageList.length);
      });
    });
  }

  Future<bool> endApp() async {
    DateTime curTime = DateTime.now();

    if (backPressed == null ||
        curTime.difference(backPressed!) > const Duration(seconds: 2)) {
      backPressed = curTime;
      Fluttertoast.showToast(msg: "'뒤로'버튼 한번 더 누르시면 종료됩니다.");
      return false;
    }
    ConnectingService.connect(false);
    return true;
  }

  Future<String?> getNickname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('nickname');
  }

  Future<bool?> getHaptic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('haptic');
  }

  Future<void> _checkLoginStatus() async {
    await checkFirstAccess();
    nickname = await getNickname();
    _isHaptic = await getHaptic() ?? true;
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
    final response = await http.post(
      Uri.parse('$baseUrl/api/wait'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
        'refreshToken': 'Bearer $refreshToken'
      },
      body: jsonEncode({"nickname": nickname!}),
    );

    // final response = await http.post(
    //   Uri.parse('http://10.0.2.2:8080/wait'),
    //   headers: {
    //     'Content-Type': 'application/json; charset=UTF-8',
    //     'Authorization': 'Bearer $accessToken',
    //     'refreshToken': 'Bearer $refreshToken'
    //   },
    //   body: jsonEncode({"nickname": nickname!}),
    // );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data.containsKey("roomId")) {
        int roomId = data["roomId"];
        int nowNumber = data["nowNumber"];
        print("나는 " '$nowNumber' "번 째 사람입니다");
        print('roomId: $roomId');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(
                roomId: roomId,
                nickname: nickname!,
                nowNumber: nowNumber), // 이건 game.dart에 있다.
          ),
        );
      } else {
        print('서버 응답에 roomId가 없음');
      }
    } else {
      print('요청 실패: ${response.statusCode}');
    }
  }

  Future<void> TowerSelect() async {
    String baseUrl = dotenv.env['BASE_URL']!;
    final response = await http.post(
      Uri.parse('$baseUrl/api/tower'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
        'refreshToken': 'Bearer $refreshToken'
      },
      body: jsonEncode({"nickname": nickname!}),
    );

    // final response = await http.post(
    //   Uri.parse('http://10.0.2.2:8080/tower'),
    //   headers: {
    //     'Content-Type': 'application/json; charset=UTF-8',
    //     'Authorization': 'Bearer $accessToken',
    //     'refreshToken': 'Bearer $refreshToken'
    //   },
    //   body: jsonEncode({"nickname": nickname!}),
    // );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data.containsKey("maxFloor")) {
        int maxFloor = data["maxFloor"];
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TowerEnterScreen(
                maxFloor: maxFloor,
                nickname: nickname!,
              ),
            ));
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
        builder: (context) => const MyInfoScreen(),
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
          backgroundColor: const Color.fromRGBO(3, 8, 61, 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: 0,
                left: 0,
                top: -85,
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.asset('lib/assets/icons/trophyIcon.PNG'),
                ),
              ),
              RankingScreen()
            ],
          ),
        );
      },
    );
  }

  saveVibrate(bool vibrate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('vibrate', vibrate);
  }

  saveBGM(bool bgm) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('bgm', bgm);
  }

  Future<void> checkFirstAccess() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('vibrate') == null || prefs.getBool('bgm') == null) {
      prefs.setBool('vibrate', true);
      prefs.setBool('bgm', true);
    }
    _isFirstAccess = prefs.getBool('isFirstAccess') ?? true;
    if (_isFirstAccess) {
      await prefs.setBool('isFirstAccess', false);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TutorialScreen()),
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
        builder: (context) => const FriendScreen(
          friendSelected: true,
        ),
      ),
    );
  }

  void _navigateToTowerEnterScreen() {
    TowerSelect();
  }

  @override
  void initState() {
    super.initState();
    startImageChangeTimer();

    WidgetsBinding.instance?.addObserver(this);

    ConnectingService.connect(true);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
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
                  "공 지 사 항",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            contentPadding: const EdgeInsets.only(left: 5, right: 5),
            content: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                '업데이트를 하신 후에는 앱 데이터(쿠키, 캐시) 삭제 후 재시작 부탁드립니다.\n\n죄송합니다. 정식 배포시에는 수정하도록 하겠습니다.',
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
    });
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
    WidgetsBinding.instance?.removeObserver(this);
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
            Container(color: Colors.black),
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
            if(currentContenderImageIndex!=1)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.25,
                height: MediaQuery.of(context).size.height * 0.1,
                child: Center(
                  child:
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: Image.asset(
                      'lib/assets/icons/contender.gif',
                      fit: BoxFit.fitHeight,
                      width: MediaQuery.of(context).size.width,
                    ).animate().fade(),
                  ),
                ),
              ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              height: MediaQuery.of(context).size.height * 0.2,
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Image.asset(
                      contenderImageList[currentContenderImageIndex],
                      fit: BoxFit.fitHeight,
                      width: MediaQuery.of(context).size.width,
                    ).animate().fade(),
                  ),
                ],
              ),
            ),
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.3,
                height: MediaQuery.of(context).size.height * 0.2,
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: Image.asset(
                        myImageList[currentMyImageIndex],
                        fit: BoxFit.fitHeight,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                  ],
                ),
              ),
            if(currentMyImageIndex!=1)
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.3,
                height: MediaQuery.of(context).size.height * 0.1,
                child: Center(
                  child:
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: Image.asset(
                      'lib/assets/icons/myCharacter.gif',
                      fit: BoxFit.fitHeight,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),
                ),
              ),
            slidingWidget(
              context,
              _animation,
              Image.asset(
                'lib/assets/icons/mainMark2.png',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              begin: Offset(0, MediaQuery.of(context).size.height * 5 / 7),
              end: const Offset(0, 0),
            ),
            Positioned(
              bottom: 0,
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.55,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (!isButtonDisabled) {
                            if (_isHaptic) {
                              HapticFeedback.lightImpact();
                            }
                            _navigateToStartScreen();
                            setState(() {
                              isButtonDisabled = true;
                            });
                            Timer(Duration(milliseconds: 1500), () {
                              setState(() {
                                isButtonDisabled = false;
                              });
                            });
                          }
                        },
                        onTapDown: (_) {
                          if (!isButtonDisabled) {
                            setState(() {
                              buttonsrc = 'lib/assets/icons/pvpButton2.png';
                            });
                            if (_isHaptic) {
                              HapticFeedback.lightImpact();
                            }
                          }
                        },
                        onTapUp: (_) {
                          if (!isButtonDisabled) {
                            setState(() {
                              buttonsrc = 'lib/assets/icons/pvpButton.png';
                            });
                          }
                        },
                        onTapCancel: () {
                          if (!isButtonDisabled) {
                            setState(() {
                              buttonsrc = 'lib/assets/icons/pvpButton.png';
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
                      GestureDetector(
                        onTap: () {
                          if (!isButtonDisabled) {
                            if (_isHaptic) {
                              HapticFeedback.lightImpact();
                            }
                            _navigateToTowerEnterScreen();
                            setState(() {
                              isButtonDisabled = true;
                            });
                            Timer(Duration(milliseconds: 1500), () {
                              setState(() {
                                isButtonDisabled = false;
                              });
                            });
                          }
                        },
                        onTapDown: (_) {
                          if (!isButtonDisabled) {
                            setState(() {
                              buttonsrc5 = 'lib/assets/icons/towerButton2.png';
                            });
                            if (_isHaptic) {
                              HapticFeedback.lightImpact();
                            }
                          }
                        },
                        onTapUp: (_) {
                          if (!isButtonDisabled) {
                            setState(() {
                              buttonsrc5 = 'lib/assets/icons/towerButton.png';
                            });
                          }
                        },
                        onTapCancel: () {
                          if (!isButtonDisabled) {
                            setState(() {
                              buttonsrc5 = 'lib/assets/icons/towerButton.png';
                            });
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          height: MediaQuery.of(context).size.width * 0.35,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(buttonsrc5),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_isHaptic) {
                            HapticFeedback.lightImpact();
                          }
                          _navigateToRankingScreen();
                        },
                        onTapDown: (_) {
                          setState(() {
                            buttonsrc1 = 'lib/assets/icons/rankingButton2.png';
                          });
                          if (_isHaptic) {
                            HapticFeedback.lightImpact();
                          }
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
                          width: MediaQuery.of(context).size.width * 0.33,
                          height: MediaQuery.of(context).size.width * 0.33,
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
                      //     if (_isHaptic) {
                      //       HapticFeedback.lightImpact();
                      //     }
                      //     _navigateToReportScreen();
                      //   },
                      //   onTapDown: (_) {
                      //     setState(() {
                      //       buttonsrc2 = 'lib/assets/icons/reportButton2.png';
                      //     });
                      //     if (_isHaptic) {
                      //       HapticFeedback.lightImpact();
                      //     }
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
                          if (_isHaptic) {
                            HapticFeedback.lightImpact();
                          }
                          _navigateToFriendScreen();
                        },
                        onTapDown: (_) {
                          setState(() {
                            buttonsrc3 = 'lib/assets/icons/friendButton2.png';
                          });
                          if (_isHaptic) {
                            HapticFeedback.lightImpact();
                          }
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
                          width: MediaQuery.of(context).size.width * 0.33,
                          height: MediaQuery.of(context).size.width * 0.33,
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
                          if (_isHaptic) {
                            HapticFeedback.lightImpact();
                          }
                          _navigateToMyInfoScreen();
                        },
                        onTapDown: (_) {
                          setState(() {
                            buttonsrc4 = 'lib/assets/icons/myButton2.png';
                          });
                          if (_isHaptic) {
                            HapticFeedback.lightImpact();
                          }
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
                          width: MediaQuery.of(context).size.width * 0.33,
                          height: MediaQuery.of(context).size.width * 0.33,
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
            ),
          ],
        ),
      ),
    );
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때의 동작
      print("main 앱이 다시 활성화될 때의 동작");
      ConnectingService.connect(true);
    } else if (state == AppLifecycleState.inactive) {
      // 앱이 동작 안할 때
      print("main 앱이 동작 안할 때");
      ConnectingService.connect(false);
    } else if (state == AppLifecycleState.paused) {
      // 앱이 일시 중지될 때의 동작
      print("main 앱이 일시 중지될 때의 동작");
      ConnectingService.connect(false);
    } else if (state == AppLifecycleState.detached) {
      // 앱이 종료될 때의 동작
      // update
      print("main 앱이 종료될 때의 동작");
      ConnectingService.connect(false);
    }
  }
}
