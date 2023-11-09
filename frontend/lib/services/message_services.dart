
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:frontend/main.dart';

@pragma('vm:entry-point')
void backgroundHandler(NotificationResponse details) {
  // print('background111 ${details.payload}');
  print("1111111");

}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 앱이 백그라운드에 있을 시 여기로 옴, firebase를 시작하고
  await Firebase.initializeApp();
  // 알림을 보여주자 
  final flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();
  flutterLocalNotificationPlugin.show(
      message.notification.hashCode,
      // 메시지에서 지정한 title과 body
      message.notification!.title,
      message.notification!.body,
      const NotificationDetails(
          android: AndroidNotificationDetails("high_importance_channel", "dragon-fire", importance: Importance.max)
      ),
      payload: message.data.toString()
  );
}

// 앱 시작할때 notification 열어놓기
void initializeNotification() async {
  final flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();
  
  // 알림 채널 만들기
  await flutterLocalNotificationPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!
      .createNotificationChannel(const AndroidNotificationChannel("high_importance_channel", "dragon-fire",
      importance: Importance.max
  ));

  // 앱에서 알림 수신 허락받자 
  flutterLocalNotificationPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()!.requestNotificationsPermission();

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );


  await flutterLocalNotificationPlugin.initialize(
    // 안드로이드 기본 세팅
    const InitializationSettings(android: AndroidInitializationSettings('appicontrans')),

    // 포그라운드에서 noti를 받을 때
    onDidReceiveNotificationResponse: (details) async {
      print('foreground ${details.payload}');

      final route = details.payload!.split(":")[1].trim().replaceAll("}", "");
      // 받은 데이터로 리다이렉트하기
      if (route == "friend") {
        DragonG.navigatorKey.currentState!.pushNamed('/friend');
      }
    },

    // 백그라운드에서 noti를 받을 때
    onDidReceiveBackgroundNotificationResponse: backgroundHandler,

  );

  // 포그라운드에서 firebase message를 듣기
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    if (message.notification != null) {
      // 메시지를 보여줘
      flutterLocalNotificationPlugin.show(
        message.notification.hashCode,
        // 메시지에서 지정한 title과 body
        message.notification!.title,
        message.notification!.body,
        const NotificationDetails(
          android: AndroidNotificationDetails("high_importance_channel", "dragon-fire", importance: Importance.max)
        ),
        payload: message.data.toString()
      );
    }

  });

  RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
  if (message != null) {
    print(message.data);
  }

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    print("background opened ${message.data}");

    final route = message.data["do"];
    // 받은 데이터로 리다이렉트하기
    if (route == "friend") {
      DragonG.navigatorKey.currentState!.pushNamed('/friend');
    }
  });

}