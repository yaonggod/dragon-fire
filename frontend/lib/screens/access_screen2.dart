import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/main_screen.dart';

class AccessScreen2 extends StatefulWidget {

  final bool isloggedin;

  const AccessScreen2({Key? key, required this.isloggedin}) : super(key: key);

  @override
  _AccessScreen2State createState() => _AccessScreen2State();
}

class _AccessScreen2State extends State<AccessScreen2>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;


  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if(widget.isloggedin) {
      _controller.forward().whenComplete(() {
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                MainScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
              (Route<dynamic> route) => false,
        );
      });
    }else{
      _controller.forward().whenComplete(() {
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                LoginScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
              (Route<dynamic> route) => false,
        );
      });
    }

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
          top: currentPosition.dy,
          left: currentPosition.dx,
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
            Container(
              color: Colors.black,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
          slidingWidget(
            context,
            _animation,
            Opacity(
              opacity: 0.5,
              child: Image.asset(
                'lib/assets/icons/fire.png',
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fitHeight,
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
            begin: Offset(0, MediaQuery.of(context).size.height * 2 / 7),
            end: Offset(0, 0),
          ),
          slidingWidget(
            context,
            _animation,
            Image.asset('lib/assets/icons/pressStart.png',
            width: MediaQuery.of(context).size.width * 6.6 / 10),
            begin: Offset(MediaQuery.of(context).size.width * 1.7 / 10,
                MediaQuery.of(context).size.height * 8 / 12),
            end: Offset(MediaQuery.of(context).size.width * 1.7 / 10,MediaQuery.of(context).size.height),
          ),
        ],
      ),
    );
  }
}
