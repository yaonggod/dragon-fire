import 'package:flutter/material.dart';
import 'package:frontend/screens/main_screen.dart';

class AccessScreen extends StatefulWidget {
  const AccessScreen({super.key});

  @override
  _AccessScreenState createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen> with SingleTickerProviderStateMixin{

  late AnimationController _controller;


  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _controller.addListener(() {
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
              child: Image.asset(
                'lib/assets/icons/mainMark2.png',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
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
                opacity: _controller.value,
                child: Image.asset(
                  'lib/assets/icons/pressStart.png',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
