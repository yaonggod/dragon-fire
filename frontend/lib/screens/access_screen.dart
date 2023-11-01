import 'package:flutter/material.dart';
import 'package:frontend/screens/main_screen.dart';

class AccessScreen extends StatefulWidget {
  const AccessScreen({super.key});

  @override
  _AccessScreenState createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen> with TickerProviderStateMixin {

  late AnimationController _controller;
  late AnimationController _controller2;

  @override
  void initState() {
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
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.black,
          ),
          Opacity(
            opacity: 0.5,
            child: Image.asset(
              'lib/assets/icons/fire.png',
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fitHeight,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 2 / 7,
            width: MediaQuery.of(context).size.width,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color.fromRGBO(255,255,255,0.6),Colors.white, Color.fromRGBO(255,255,255,0.6), Colors.white],
                      stops: [0.0, _controller.value - 0.1, _controller.value, 1.0], // Change the 0.1 value for different effects
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.modulate,
                  child: Image.asset(
                    'lib/assets/icons/mainMark2.png',
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 8 / 12,
            width: MediaQuery.of(context).size.width * 6.6 / 10,
            left: MediaQuery.of(context).size.width * 1.7/10,
            child: GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
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
    );
  }
}
