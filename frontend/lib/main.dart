import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/screens/access_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:frontend/services/message_services.dart';

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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '드래곤 불',
      theme: ThemeData(
        fontFamily: 'DungGeunMo',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AccessScreen(),
    );
  }
}
