import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/screens/access_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:frontend/screens/friend_screen.dart';
import 'package:frontend/services/message_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  Timer(const Duration(seconds: 2), () => FlutterNativeSplash.remove());
  await dotenv.load(fileName: ".env");

  // firebase를 시작하고 notification도 열어놓는다
  await Firebase.initializeApp();
  initializeNotification();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  //

  runApp(const DragonG());
}

class DragonG extends StatelessWidget {
  const DragonG({super.key});

  // 친구 신청 팝업 -> FriendScreen
  // 친구 대전 -> ??
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    _initBGM();
    return MaterialApp(
      title: '드래곤 불',
      theme: ThemeData(
        fontFamily: 'DungGeunMo',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const AccessScreen(),

      // 팝업 오면 원하는데로 라우팅, 기본은 AccessScreen
      initialRoute: '/',
      routes: {
        '/': (context) => const AccessScreen(),
        '/friend': (context) => FriendScreen(friendSelected: false),
      },
      navigatorKey: navigatorKey,

    );
  }

  void _initBGM() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isBGM = prefs.getBool('bgm');

    //첫 접속시
    if(isBGM == null){
      AudioManager.init();

    //첫 접속이 아닌 경우
    } else if (isBGM != null && !isBGM) {
      await AudioManager.initAndPause();
    } else {
      AudioManager.init();
    }
  }
}

class AudioManager {
  static AudioPlayer audioPlayer = AudioPlayer();

  static Future<void> initAndPause() async {
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    await audioPlayer.play(AssetSource('Showdown_full.wav'), mode: PlayerMode.mediaPlayer);
    pause();
  }

  static void init() async {
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    await audioPlayer.play(AssetSource('Showdown_full.wav'), mode: PlayerMode.mediaPlayer);
  }

  static void pause() {
    audioPlayer.pause();
  }

  static void resume() {
    audioPlayer.resume();
  }
}
