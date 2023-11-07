import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/screens/info_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:frontend/screens/myInfoUpdate_screen.dart';
import 'package:frontend/widgets/carousel_widget.dart';
import 'package:frontend/widgets/carousel_widget2.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  List<String> assetList = [
    "lib/assets/icons/tutorial0.png",
    "lib/assets/icons/tutorial1.png",
    "lib/assets/icons/tutorial2.png",
    "lib/assets/icons/tutorial3.png",
    "lib/assets/icons/tutorial4.png",
    "lib/assets/icons/tutorial5.png",
  ];

  @override
  void initState() {
    super.initState();
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
            CarouselWidget2(asset: assetList),
          ],
        ),
      ),
    );
  }
}
