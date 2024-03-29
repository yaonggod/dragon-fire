import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:frontend/screens/tower_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TowerEnterScreen extends StatefulWidget {
  final int maxFloor; // 내가 갈 수 있는 maxFloor를 의미한다.
  final String nickname;

  const TowerEnterScreen({
    super.key,
    required this.maxFloor,
    required this.nickname,
  });

  @override
  State<TowerEnterScreen> createState() => _TowerScreenEnterState();
}

class _TowerScreenEnterState extends State<TowerEnterScreen> {
  ScrollController _scrollController = ScrollController();
  double _initialScrollOffset = 0;

  String buttonsrc = 'lib/assets/icons/startButton.png';
  String buttonsrc1 = 'lib/assets/icons/rankingButton.png';
  String buttonsrc2 = 'lib/assets/icons/reportButton.png';
  String buttonsrc3 = 'lib/assets/icons/friendButton.png';
  String buttonsrc4 = 'lib/assets/icons/myButton.png';

  String? nickname;
  String? accessToken;
  String? refreshToken;
  double cloudOpacity = 0.0;

  @override
  Future<void> _checkLoginStatus() async {
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

  void _navigateToTowerScreen(int floor) {
    print("이거 누름");
    print(widget.nickname);
    climbTower(floor);
  }

  Future<void> climbTower(int floor) async {
    String baseUrl = dotenv.env['BASE_URL']!;
    final response = await http.post(
      Uri.parse('$baseUrl/api/towerEnter'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
        'refreshToken': 'Bearer $refreshToken'
      },
      body: jsonEncode({"nickname": widget.nickname!}),
    );
    // final response = await http.post(
    //   Uri.parse('http://10.0.2.2:8080/towerEnter'),
    //   headers: {
    //     'Content-Type': 'application/json; charset=UTF-8',
    //     'Authorization': 'Bearer $accessToken',
    //     'refreshToken': 'Bearer $refreshToken'
    //   },
    //   body: jsonEncode({"nickname": widget.nickname!}),
    // );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      int nowFloor = data["nowFloor"];
      int roomNumber = data["roomNumber"];
      print("내가 받아온 층은");
      print(nowFloor);
      print("내가 방 번호는");
      print(roomNumber);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TowerScreen(
            nowFloor: floor,
            nickname: widget.nickname!,
            roomNumber: roomNumber,
          ),
        ),
      );
    } else {
      print('요청 실패: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    init();
    _initialScrollOffset = 0; // 100층 중 1층이 50.0, 2층이 100.0, ..., 100층이 4950.0
    _scrollController =
        ScrollController(initialScrollOffset: _initialScrollOffset);

    // 스크롤 이벤트를 감지하여 offset 조절
    _scrollController.addListener(() {
      if (_scrollController.offset <= 0) {
        _scrollController.jumpTo(0);
      }
    });
    _scrollController.addListener(changeOpacity);
    screenInit();
    super.initState();
  }

  Future<void> init() async {
    await _checkLoginStatus();
  }

  Future<void> screenInit() async {
    await Future.delayed(Duration(seconds: 5));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double calculateCloudOpacity(double scrollOffset) {
    const double maxScroll = 100.0;
    double opacity = (scrollOffset / maxScroll).clamp(0.0, 1.0);
    return opacity;
  }

  void changeOpacity() {
    if (_scrollController.offset <= 2000) {
      setState(() {
        cloudOpacity = 0.0;
      });
    } else if ((_scrollController.offset <= 4000) &&
        (_scrollController.offset > 2000)) {
      setState(() {
        cloudOpacity = 0.5;
      });
    } else if ((_scrollController.offset <= 6000) &&
        (_scrollController.offset > 4000)) {
      setState(() {
        cloudOpacity = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Container(color: Colors.black),
          Positioned(
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height,
              child: Container(
                child: Image.asset(
                  'lib/assets/icons/sky.png',
                  fit: BoxFit.fitHeight,
                ),
              )),
          SingleChildScrollView(
            controller: _scrollController,
            reverse: true,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.3,
                    left: MediaQuery.of(context).size.width * 0.2,
                    right: MediaQuery.of(context).size.width * 0.2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.width * 0.6 / 8,
                        width: MediaQuery.of(context).size.width * 0.6 / 8,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.width * 0.6 / 8,
                        width: MediaQuery.of(context).size.width * 0.6 / 8,
                        child: Image.asset('lib/assets/icons/bird.png',
                            fit: BoxFit.fill),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.width * 0.6 / 8,
                        width: MediaQuery.of(context).size.width * 0.6 / 8,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.width * 0.6 / 8,
                        width: MediaQuery.of(context).size.width * 0.6 / 8,
                        child: Image.asset('lib/assets/icons/bird2.png',
                            fit: BoxFit.fill),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.2,
                    right: MediaQuery.of(context).size.width * 0.2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.width * 0.6 / 8,
                        width: MediaQuery.of(context).size.width * 0.6 / 8,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.red),
                            left: BorderSide(color: Colors.red),
                            right: BorderSide(color: Colors.red),
                            bottom: BorderSide(color: Colors.grey),
                          ),
                          image: DecorationImage(
                              image: AssetImage('lib/assets/icons/tower3.png'),
                              repeat: ImageRepeat.repeat,
                              fit: BoxFit.fitWidth),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.width * 0.6 / 8,
                        width: MediaQuery.of(context).size.width * 0.6 / 8,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.red),
                            left: BorderSide(color: Colors.red),
                            right: BorderSide(color: Colors.red),
                            bottom: BorderSide(color: Colors.grey),
                          ),
                          image: DecorationImage(
                              image: AssetImage('lib/assets/icons/tower3.png'),
                              repeat: ImageRepeat.repeat,
                              fit: BoxFit.fitWidth),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.width * 0.6 / 8,
                        width: MediaQuery.of(context).size.width * 0.6 / 8,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.red),
                            left: BorderSide(color: Colors.red),
                            right: BorderSide(color: Colors.red),
                            bottom: BorderSide(color: Colors.grey),
                          ),
                          image: DecorationImage(
                              image: AssetImage('lib/assets/icons/tower3.png'),
                              repeat: ImageRepeat.repeat,
                              fit: BoxFit.fitWidth),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.width * 0.6 / 8,
                        width: MediaQuery.of(context).size.width * 0.6 / 8,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.red),
                            left: BorderSide(color: Colors.red),
                            right: BorderSide(color: Colors.red),
                            bottom: BorderSide(color: Colors.grey),
                          ),
                          image: DecorationImage(
                              image: AssetImage('lib/assets/icons/tower3.png'),
                              repeat: ImageRepeat.repeat,
                              fit: BoxFit.fitWidth),
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(),
                Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.2,
                    right: MediaQuery.of(context).size.width * 0.2,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.red),
                        left: BorderSide(color: Colors.red),
                        right: BorderSide(color: Colors.red),
                        bottom: BorderSide(color: Colors.grey),
                      ),
                      image: DecorationImage(
                          image: AssetImage('lib/assets/icons/tower3.png'),
                          repeat: ImageRepeat.repeat,
                          fit: BoxFit.fitWidth),
                    ),
                    child: Column(
                      children: List.generate(
                        100,
                        (index) => Column(
                          children: [
                            ListTile(
                              title: Text(
                                ' ${100 - index}층',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20),
                              ),
                              onTap: () {
                                if ((100 - index) >= 4) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(0),
                                        ),
                                        backgroundColor: Colors.grey,
                                        titlePadding:
                                            const EdgeInsets.only(right: 5),
                                        title: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.red,
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.black54,
                                                      offset:
                                                          const Offset(5, 5),
                                                      blurRadius: 0)
                                                ]),
                                            padding: const EdgeInsets.all(7),
                                            child: const Text(
                                              "드래곤 불",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.only(right: 5),
                                        content: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          child: Text(
                                            '오픈 예정입니다',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.white),
                                          ),
                                        ),
                                        actionsPadding:
                                            const EdgeInsets.only(bottom: 15),
                                        actions: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.grey,
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: Colors.black54,
                                                          offset: const Offset(
                                                              5, 5),
                                                          blurRadius: 0)
                                                    ]),
                                                padding:
                                                    const EdgeInsets.all(7),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text(
                                                    '확인',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  if (100 - index > widget.maxFloor) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(0),
                                          ),
                                          backgroundColor: Colors.grey,
                                          titlePadding:
                                              const EdgeInsets.only(right: 5),
                                          title: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.black54,
                                                        offset:
                                                            const Offset(5, 5),
                                                        blurRadius: 0)
                                                  ]),
                                              padding: const EdgeInsets.all(7),
                                              child: const Text(
                                                "드래곤 불",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.only(right: 5),
                                          content: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            child: Text(
                                              '전 단계를 클리어해주세요.',
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          actionsPadding:
                                              const EdgeInsets.only(bottom: 15),
                                          actions: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey,
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color:
                                                                Colors.black54,
                                                            offset:
                                                                const Offset(
                                                                    5, 5),
                                                            blurRadius: 0)
                                                      ]),
                                                  padding:
                                                      const EdgeInsets.all(7),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text(
                                                      '확인',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    _navigateToTowerScreen(100 - index);
                                  }
                                }
                                //여기에 다음 페이지로 이동하는 거 하면 됨
                                //100-index 가 층 수임
                              },
                            ),
                            if (index < 99)
                              Divider(
                                color: Colors.white70,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ).animate().fade(),
                Container(
                  height: MediaQuery.of(context).size.height * 0.15,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('lib/assets/icons/ground.png'),
                        repeat: ImageRepeat.repeat,
                        alignment: Alignment.topCenter,
                        fit: BoxFit.fitWidth),
                  ),
                )
              ],
            ),
          ).animate().fade(),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5,
            left: -MediaQuery.of(context).size.width * 0.1,
            child: IgnorePointer(
              child: Container(
                height: MediaQuery.of(context).size.width * 0.6,
                width: MediaQuery.of(context).size.width * 0.6,
                child: Opacity(
                  opacity: cloudOpacity,
                  child: Image.asset(
                    'lib/assets/icons/cloud.png',
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            right: MediaQuery.of(context).size.width * 0.05,
            child: IgnorePointer(
              child: Container(
                height: MediaQuery.of(context).size.width * 0.5,
                width: MediaQuery.of(context).size.width * 0.5,
                child: Opacity(
                  opacity: cloudOpacity,
                  child: Image.asset(
                    'lib/assets/icons/cloud.png',
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: -MediaQuery.of(context).size.width * 0.2,
            child: IgnorePointer(
              child: Container(
                height: MediaQuery.of(context).size.width * 1.0,
                width: MediaQuery.of(context).size.width * 1.0,
                child: Opacity(
                  opacity: cloudOpacity,
                  child: Image.asset(
                    'lib/assets/icons/cloud.png',
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -MediaQuery.of(context).size.width * 0.3,
            left: -MediaQuery.of(context).size.width * 0.3,
            child: IgnorePointer(
              child: Container(
                height: MediaQuery.of(context).size.width * 1.5,
                width: MediaQuery.of(context).size.width * 1.5,
                child: Opacity(
                  opacity: cloudOpacity,
                  child: Image.asset(
                    'lib/assets/icons/cloud.png',
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
