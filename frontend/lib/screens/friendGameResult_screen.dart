import 'dart:async';

import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FriendGameResultScreen extends StatefulWidget {
  final int roomId;
  final String nickname;
  final String win;
  final String lose;

  const FriendGameResultScreen({
    super.key,
    required this.roomId,
    required this.nickname,
    required this.win,
    required this.lose,
  });

  @override
  State<FriendGameResultScreen> createState() => _FriendGameResultScreenState();
}

class _FriendGameResultScreenState extends State<FriendGameResultScreen>
    with SingleTickerProviderStateMixin {
  // late AnimationController _controller;
  int? point;
  int? win;
  int? lose;
  AnimatedDigitController? _controllerWin;
  AnimatedDigitController? _controllerLose;

  DateTime? currentBackPressTime;
  Future<String?>? nicknameFuture;

  Future<String?> getNickname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('nickname');
  }

  @override
  void initState() {
    nicknameFuture = getNickname();
    win = int.parse(widget.win);
    lose = int.parse(widget.lose);

    print("나는 $win승 $lose패가 되었다!!!");
    super.initState();

    // 내가 이겼다
    if (nicknameFuture == widget.nickname) {
      _controllerWin = AnimatedDigitController(win! - 1);
      _controllerLose = AnimatedDigitController(lose!);
      _controllerWin!.addValue(1);
    // 내가 졌다
    } else {
      _controllerLose = AnimatedDigitController(lose! - 1);
      _controllerWin = AnimatedDigitController(win!);
      _controllerLose!.addValue(1);
    }

    // + 1 효과



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
    _controllerWin!.dispose();
    _controllerLose!.dispose();
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
                                              0.10,
                                        ),
                                        Text("상대 전적", style: TextStyle(
                                            fontSize: 22,
                                            color: Colors.white)),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.05,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'lib/assets/icons/trophyIcon.PNG',
                                              height: 30,
                                              fit: BoxFit.fitHeight,
                                            ),
                                            const SizedBox(width: 5,),
                                            widget.nickname == nickname ? AnimatedDigitWidget(
                                              autoSize: true,
                                              controller: _controllerWin,
                                              duration:
                                              Duration(milliseconds: 1000),
                                              textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 25),
                                              enableSeparator: true,
                                            ) : Text("$win", style: TextStyle(color: Colors.white, fontSize: 25)),
                                            Text(" 승 ", style: TextStyle(color: Colors.white, fontSize: 25)),
                                            widget.nickname != nickname ? AnimatedDigitWidget(
                                              autoSize: true,
                                              controller: _controllerLose,
                                              duration:
                                              Duration(milliseconds: 1000),
                                              textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 25),
                                              enableSeparator: true,
                                            ) : Text("$lose", style: TextStyle(color: Colors.white, fontSize: 25)),
                                            Text(" 패", style: TextStyle(color: Colors.white, fontSize: 25)),
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
