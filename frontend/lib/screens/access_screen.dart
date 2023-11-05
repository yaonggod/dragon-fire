
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/screens/access_screen2.dart';

class AccessScreen extends StatefulWidget {
  const AccessScreen({super.key});

  @override
  _AccessScreenState createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _controller2;
  final player = AudioPlayer();
  DateTime? backPressed;
  bool _isLoggedIn = false;

  Future<void> _checkLoginStatus() async {
    Map<String, String> tokens = await readToken();
    if (tokens.isNotEmpty) {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

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
  void initState() {
    player.setReleaseMode(ReleaseMode.loop);
    player.play(AssetSource('dragonSong.wav'), mode: PlayerMode.lowLatency);
    _checkLoginStatus();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reset();
          _controller.forward();
        }
      });

    _controller.forward();

    _controller2 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _controller2.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller2.dispose();
    player.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: endApp,
        child: Stack(
          children: [
            Container(
              color: Colors.black,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        AccessScreen2(isloggedin: _isLoggedIn),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  'lib/assets/icons/fire.png',
                  height: MediaQuery.of(context).size.height,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 2 / 7,
              width: MediaQuery.of(context).size.width,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return GestureDetector(
                    onTap: () {
                      print(1);
                      Navigator.pushAndRemoveUntil(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              AccessScreen2(isloggedin: _isLoggedIn),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromRGBO(255, 255, 255, 0.6),
                            Colors.white,
                            Color.fromRGBO(255, 255, 255, 0.6),
                            Colors.white
                          ],
                          stops: [
                            0.0,
                            _controller.value - 0.1,
                            _controller.value,
                            1.0
                          ], // Change the 0.1 value for different effects
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.modulate,
                      child: Image.asset(
                        'lib/assets/icons/mainMark2.png',
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 8 / 12,
              width: MediaQuery.of(context).size.width * 6.6 / 10,
              left: MediaQuery.of(context).size.width * 1.7 / 10,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          AccessScreen2(isloggedin: _isLoggedIn),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Opacity(
                  opacity: _controller2.value,
                  child: Image.asset('lib/assets/icons/pressStart.png'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
