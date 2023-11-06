import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/screens/tower_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class TowerEnterScreen extends StatefulWidget {
  const TowerEnterScreen({
    super.key,
  });

  @override
  State<TowerEnterScreen> createState() => _TowerScreenEnterState();
}

class _TowerScreenEnterState extends State<TowerEnterScreen>
  with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  String buttonsrc = 'lib/assets/icons/startButton.png';
  String buttonsrc1 = 'lib/assets/icons/rankingButton.png';
  String buttonsrc2 = 'lib/assets/icons/reportButton.png';
  String buttonsrc3 = 'lib/assets/icons/friendButton.png';
  String buttonsrc4 = 'lib/assets/icons/myButton.png';

  String? nickname;
  String? accessToken;
  String? refreshToken;
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

  void _navigateToTowerScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TowerScreen(),
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
    init();
    super.initState();

  }

  Future<void> init() async {
    await _checkLoginStatus();
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
                height: MediaQuery.of(context).size.height * 0.55,
              ),
              GestureDetector(
                onTap: () {
                  _navigateToTowerScreen();
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
                  width: MediaQuery.of(context).size.width *0.35,
                  height:  MediaQuery.of(context).size.width *0.35,
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
                      _navigateToTowerScreen();
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
                      width: MediaQuery.of(context).size.width *0.25,
                      height:  MediaQuery.of(context).size.width *0.25,
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
                      _navigateToTowerScreen();
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
                      width: MediaQuery.of(context).size.width *0.25,
                      height:  MediaQuery.of(context).size.width *0.25,
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
                      _navigateToTowerScreen();
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
                      width: MediaQuery.of(context).size.width *0.25,
                      height:  MediaQuery.of(context).size.width *0.25,
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
                      _navigateToTowerScreen();
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
                      width: MediaQuery.of(context).size.width *0.25,
                      height:  MediaQuery.of(context).size.width *0.25,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(buttonsrc4),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    // tower를 위해서 추가한 부분
                    onTap: () {
                      _navigateToTowerScreen();
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
                      width: MediaQuery.of(context).size.width *0.25,
                      height:  MediaQuery.of(context).size.width *0.25,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(buttonsrc3),
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
