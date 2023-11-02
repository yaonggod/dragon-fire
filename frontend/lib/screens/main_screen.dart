import 'package:flutter/material.dart';
import 'package:frontend/screens/friend_screen.dart';
import 'package:frontend/screens/myInfo_screen.dart';
import 'package:frontend/screens/ranking_screen.dart';
import 'package:frontend/screens/report_screen.dart';
import 'package:frontend/screens/start_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
  with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String buttonsrc = 'lib/assets/icons/startButton.png';
  String buttonsrc1 = 'lib/assets/icons/rankingButton.png';
  String buttonsrc2 = 'lib/assets/icons/reportButton.png';
  String buttonsrc3 = 'lib/assets/icons/friendButton.png';
  String buttonsrc4 = 'lib/assets/icons/myButton.png';

  void _navigateToMyInfoScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyInfoScreen(),
      ),
    );
  }

  void _navigateToStartScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StartScreen(),
      ),
    );
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

      _controller.forward().whenComplete(() {
    });

    super.initState();
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
      // appBar: AppBar(
      //   title: Center(
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         Text(
      //           '드래곤 불',
      //           style: TextStyle(
      //             fontWeight: FontWeight.w600,
      //           ),
      //         ),
      //         // Text(
      //         //   '천하제일 쎄쎄쎄',
      //         //   style: TextStyle(
      //         //     fontSize: 16,
      //         //   ),
      //         // ),
      //         ElevatedButton(
      //           onPressed: _navigateToMyInfoScreen,
      //           child: const Text("내 정보"),
      //         ),
      //       ],
      //     ),
      //   ),
      //   backgroundColor: Colors.red[100],
      // ),
      body: Stack(
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
                height: MediaQuery.of(context).size.height * 0.6,
              ),
              GestureDetector(
                onTap: () {
                  _navigateToStartScreen();
                },
                onTapDown: (_) {
                  setState(() {
                    buttonsrc = 'lib/assets/icons/startButton2.png';
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    buttonsrc = 'lib/assets/icons/startButton.png';
                  });
                },
                onTapCancel: () => setState(() {
                  buttonsrc = 'lib/assets/icons/startButton.png';
                }),
                child: Container(
                  width: 100,
                  height: 100,
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
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(buttonsrc1),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _navigateToReportScreen();
                    },
                    onTapDown: (_) {
                      setState(() {
                        buttonsrc2 = 'lib/assets/icons/reportButton2.png';
                      });
                    },
                    onTapUp: (_) {
                      setState(() {
                        buttonsrc2 = 'lib/assets/icons/reportButton.png';
                      });
                    },
                    onTapCancel: () => setState(() {
                      buttonsrc2 = 'lib/assets/icons/reportButton.png';
                    }),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(buttonsrc2),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
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
                      width: 100,
                      height: 100,
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
                      width: 100,
                      height: 100,
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
    );
  }
}
