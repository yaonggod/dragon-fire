

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
void backgroundHandler(NotificationResponse details) {

}

// 앱 시작할때 notification 열어놓기
void initializeNotification() async {
  final flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();
  
  // 알림 채널 만들기
  await flutterLocalNotificationPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!
      .createNotificationChannel(const AndroidNotificationChannel("dragon-fire", "dragon-fire",
      importance: Importance.defaultImportance
  ));

  // 앱에서 알림 수신 허락받자 
  flutterLocalNotificationPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()!.requestNotificationsPermission();

  await flutterLocalNotificationPlugin.initialize(
    // 안드로이드 기본 세팅
    const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),

    // 포그라운드에서 noti를 받을 때
    onDidReceiveNotificationResponse: (details) {
      print('foreground ${details.payload}');
    },

    // 백그라운드에서 noti를 받을 때
    onDidReceiveBackgroundNotificationResponse: backgroundHandler,

  );

  // firebase message를 듣기
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    if (message.notification != null) {
      // 메시지를 보여줘
      flutterLocalNotificationPlugin.show(
        message.notification.hashCode,
        // 메시지에서 지정한 title과 body
        message.notification!.title,
        message.notification!.body,
        const NotificationDetails(
          android: AndroidNotificationDetails("dragon-fire", "dragon-fire", importance: Importance.max, priority: Priority.high)
        ),
        payload: message.data.toString()
      );
    }

  });
}