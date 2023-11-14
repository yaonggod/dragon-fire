import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:frontend/models/friend_models/friend_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/friend_game_screen.dart';

class FriendWidget extends StatefulWidget {
  final FriendModel friend;

  const FriendWidget({super.key, required this.friend});

  @override
  State<FriendWidget> createState() => _FriendWidgetState();
}

class _FriendWidgetState extends State<FriendWidget> {
  bool visible = true;
  BuildContext? myContext;
  String buttonsrc = 'lib/assets/icons/friendFightButton.png';

  String baseUrl = "${dotenv.env["BASE_URL"]!}/api";

  Future<Map<String, String>> readToken() async {
    const storage = FlutterSecureStorage();
    Map<String, String> list = {};
    String? accessToken = await storage.read(key: 'accessToken');
    String? refreshToken = await storage.read(key: 'refreshToken');
    String? socialType = await storage.read(key: 'socialType');

    if (accessToken != null && refreshToken != null && socialType != null) {
      list['Authorization'] = accessToken;
      list['refreshToken'] = refreshToken;
      list['socialType'] = socialType;
    }

    return list;
  }

  Future<void> _deleteResultDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          backgroundColor: Colors.grey,
          titlePadding: const EdgeInsets.only(right: 5),
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(color: Colors.red, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
              padding: const EdgeInsets.all(7),
              child: const Text(
                "드래곤 불",
                style: TextStyle(fontSize: 20, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          contentPadding: const EdgeInsets.only(right: 5),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(
              '${widget.friend.toNickname}님을 삭제했습니다.',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),

          actionsPadding: const EdgeInsets.only(bottom: 15),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(color: Colors.grey, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                  padding: const EdgeInsets.all(7),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('확인', style: TextStyle(color: Colors.white),),
                  ),
                )
              ],
            ),
          ],

        );
      },
    );
  }

  Future<bool> deleteFriend() async {
    // 친삭 api 쏘고
    Map<String, String> list = await readToken();
    Uri uri = Uri.parse("$baseUrl/friend/disconnect");
    final response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${list["Authorization"]!}',
          'refreshToken': 'Bearer ${list['refreshToken']!}'
        },
        body: jsonEncode(
            {"toMember": widget.friend.toMember}));
    if (response.statusCode == 200) {
      return true;
    }
    return false;

  }

  Future<bool> friendFight() async {
    Map<String, String> list = await readToken();
    // 친구랑 싸우자!
    Uri uri = Uri.parse("$baseUrl/friend-game/wait");
    final response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${list["Authorization"]!}',
          'refreshToken': 'Bearer ${list['refreshToken']!}'
        });
    // 성공하면 룸넘버랑 firebase AT 가져옴
    if (response.statusCode == 200) {
      var jsonString = utf8.decode(response.bodyBytes);
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      // 친구랑 싸울 방 번호
      final roomId = jsonMap["roomId"];
      // 친구한테 알림보낼 firebase AT
      final firebaseAccessToken = response.headers["firebase"]!.substring(7);
      // 내 닉네임
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final myNickname = prefs.getString('nickname');

      // 일단 친구한테 알림을 보내고
      if (widget.friend.fcmToken != null) {

        final response2 = await http.post(Uri.parse("https://fcm.googleapis.com/v1/projects/${dotenv.env["PROJECT_ID"]}/messages:send"),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': "Bearer $firebaseAccessToken"
            },
            body: jsonEncode(
                {
                  "message": {
                    "data": {
                      "do": "friend-fight",
                      "nickname": "$myNickname",
                      "roomId": "$roomId"
                    },
                    "token": widget.friend.fcmToken
                  }
                }
            )
        );
        // 알람을 보내고 성공할 경우 친구대전 가넝~
        if (response2.statusCode == 200) {
          print('성공 했다.');
          print(roomId);
          Navigator.push(
              context,
            MaterialPageRoute(
              builder: (context) => FriendGameScreen(
                  roomId: roomId,
                  nickname: myNickname!,
                  nowNumber: -1), // 이건 game.dart에 있다.
            ),
          );
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    myContext = context;

    if (!visible) {
      return Container();
    } else {
      return Slidable(
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.15,
              closeThreshold: 0.01,
              openThreshold: 0.001,
              children: [
                SlidableAction(
                  backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
                  borderRadius: BorderRadius.circular(10.0),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  icon: Icons.clear_outlined,
                  label: "삭제",
                  onPressed: (context) async {
                    bool result = await deleteFriend();
                    if (result) {
                      await _deleteResultDialog(myContext!);
                      setState(() {
                        visible = false;
                      });
                    }
                  },

                  )


                  ],
                ),
            child: Card(
              color: const Color.fromRGBO(0, 0, 0, 0.5),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage:
                              AssetImage("lib/assets/icons/appIcon.png"),
                          radius: 30,
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.03),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.friend.toNickname,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              '${widget.friend.score}점 ${widget.friend.win}승 ${widget.friend.lose}패',
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                            Text(
                              '상대 전적 ${widget.friend.friendWin}승 ${widget.friend.friendLose}패',
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        friendFight();
                        // showDialog(
                        //   context: context,
                        //   builder: (BuildContext context) {
                        //     return AlertDialog(
                        //       title: Text('알림'),
                        //       content: Text('친구 대전은 아직 준비중입니다.'),
                        //       actions: <Widget>[
                        //         TextButton(
                        //           onPressed: () {
                        //             Navigator.of(context).pop();
                        //           },
                        //           child: Text('확인'),
                        //         ),
                        //       ],
                        //     );
                        //   },
                        // );

                      },
                      onTapDown: (_) {
                        setState(() {
                          buttonsrc =
                              'lib/assets/icons/friendFightButton2.png';
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          buttonsrc = 'lib/assets/icons/friendFightButton.png';
                        });
                      },
                      onTapCancel: () => setState(() {
                        buttonsrc = 'lib/assets/icons/friendFightButton.png';
                      }),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(buttonsrc),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
    }
  }
}
