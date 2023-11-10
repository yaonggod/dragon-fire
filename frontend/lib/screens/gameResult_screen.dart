import 'dart:async';

import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameResultScreen extends StatefulWidget {
  final int roomId;
  final String nickname;
  final String win;
  final String lose;
  final int point;

  const GameResultScreen({
    super.key,
    required this.roomId,
    required this.nickname,
    required this.win,
    required this.lose,
    required this.point,
  });

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen>
    with SingleTickerProviderStateMixin {
  // late AnimationController _controller;
  int? point;
  AnimatedDigitController? _controller2;
  int _currentValue = 0;

  DateTime? currentBackPressTime;
  Future<String?>? nicknameFuture;

  Future<String?> getNickname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('nickname');
  }

  @override
  void initState() {
    nicknameFuture = getNickname();
    point = widget.point;
    super.initState();

    _controller2 = AnimatedDigitController(point!);

    // _controller = AnimationController(
    //   vsync: this,
    //   duration: Duration(seconds: 2),
    // );

    // final Animation<int> _animation = IntTween(begin: 0, end: widget.point).animate(
    //   CurvedAnimation(
    //     parent: _controller,
    //     curve: Curves.fastEaseInToSlowEaseOut,
    //   ),
    // );
    //
    // _controller.forward();
    //
    // _animation.addListener(() {
    //   setState(() {
    //     _currentValue = _animation.value;
    //   });
    // });
  }

  @override
  void dispose() {
    // _controller.dispose();
    _controller2!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
            (route) => false,
          );
          return true;
        },
        child: Stack(
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
            FutureBuilder<String?>(
              future: nicknameFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  String? nickname = snapshot.data;

                  return Stack(
                    children: [
                      Container(
                        color: Colors.black.withOpacity(0.6),
                        height: MediaQuery.of(context).size.height,
                        child: Center(
                          child: Dialog(
                            insetPadding: const EdgeInsets.all(10),
                            backgroundColor: const Color.fromRGBO(0, 0, 132, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: MediaQuery.of(context).size.width * 0.6,
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const MainScreen()),
                                            (Route<dynamic> route) => false,
                                          );
                                        },
                                        child: Image.asset(
                                          'lib/assets/icons/close.png',
                                          width: 25,
                                          height: 25,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          widget.nickname == nickname
                                              ? '승리'
                                              : '패배',
                                          style: TextStyle(
                                              fontSize: 34,
                                              color: Colors.white),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.15,
                                        ),
                                        Text(
                                          widget.nickname == nickname
                                              ? '+20'
                                              : '-20',
                                          style: TextStyle(
                                              fontSize: 25,
                                              color: Colors.white),
                                        ),
                                        // Text(
                                        //   '랭킹 점수: $_currentValue',
                                        //   style: TextStyle(
                                        //       fontSize: 25, color: Colors.white),
                                        // ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'lib/assets/icons/trophyIcon.PNG',
                                              height: 30,
                                              fit: BoxFit.fitHeight,
                                            ),
                                            Text(
                                              " : ",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 25),
                                            ),
                                            AnimatedDigitWidget(
                                              autoSize: true,
                                              controller: _controller2,
                                              duration:
                                                  Duration(milliseconds: 1000),
                                              textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 35),
                                              enableSeparator: true,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fade()
                              .scaleXY(begin: 0, curve: Curves.bounceInOut),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
