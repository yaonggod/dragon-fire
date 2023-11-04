import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameResultScreen extends StatefulWidget {
  final int roomId;
  final String nickname;

  const GameResultScreen({
    super.key,
    required this.roomId,
    required this.nickname,
  });

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen> {
  DateTime? currentBackPressTime;
  Future<String?>? nicknameFuture;


  Future<String?> getNickname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('nickname');
  }

  @override
  void initState() {
    super.initState();
    nicknameFuture = getNickname();
  }

  @override
  void dispose() {
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
        child: FutureBuilder<String?>(
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
                          height: MediaQuery.of(context).size.width * 0.5,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.nickname == nickname ?
                                  '승리': '패배',
                                  style: TextStyle(fontSize: 34, color: Colors.white),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.width * 0.15,
                                ),
                                Text(
                                  widget.nickname == nickname ?
                                  '+10': '-10',
                                  style: TextStyle(fontSize: 20, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}