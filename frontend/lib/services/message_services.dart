
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

  final flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();

  String notiBody = "멍멍";
  if (message.data["do"] == "friend-add") {
    notiBody = "${message.data["nickname"]}님이 친구 추가 요청을 보냈습니다.";
  } else if (message.data["do"] == "friend-accept") {
    notiBody = "${message.data["nickname"]}님이 친구 요청을 수락했습니다.";
  } else if (message.data["do"] == "friend-fight"){
    notiBody = "${message.data["nickname"]}님이 친구 대전을 요청을 보냈습니다.";
  }

  flutterLocalNotificationPlugin.show(
      0,
      "드래곤 불",
      notiBody,
      const NotificationDetails(
          android: AndroidNotificationDetails("high_importance_channel", "dragon-fire", importance: Importance.max)
      ),
      payload: message.data["do"]
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

      // 받은 데이터로 리다이렉트하기
      if (details.payload == "friend-add" || details.payload == "friend-accept") {
        DragonG.navigatorKey.currentState!.pushNamed('/friend');
      }
    },

    // 백그라운드에서 noti를 받을 때
    onDidReceiveBackgroundNotificationResponse: backgroundHandler,

  );

  // 포그라운드에서 firebase message를 듣기
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    String notiBody = "멍멍";
    if (message.data["do"] == "friend-add") {
      notiBody = "${message.data["nickname"]}님이 친구 추가 요청을 보냈습니다.";
    } else if (message.data["do"] == "friend-accept") {
      notiBody = "${message.data["nickname"]}님이 친구 요청을 수락했습니다.";
    }

    flutterLocalNotificationPlugin.show(
        0,
        "드래곤 불",
        notiBody,
        const NotificationDetails(
            android: AndroidNotificationDetails("high_importance_channel", "dragon-fire", importance: Importance.max)
        ),
        payload: message.data["do"]
    );
  });

  RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
  if (message != null) {
    print(message.data);
  }

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    print("background opened ${message.data}");

    final route = message.data["do"];
    // 받은 데이터로 리다이렉트하기
    if (route == "friend-add" || route == "friend-accept")  {
      DragonG.navigatorKey.currentState!.pushNamed('/friend');
    }
  });

}