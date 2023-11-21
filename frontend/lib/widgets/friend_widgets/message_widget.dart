import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/friend_models/message_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/friend_game_screen.dart';

class MessageWidget extends StatefulWidget {
  final MessageModel message;

  const MessageWidget({super.key, required this.message});

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  bool visible = true;

  String baseUrl = "${dotenv.env["BASE_URL"]!}/api";

  String messageText = "";

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

  Widget acceptButton() {
    return GestureDetector(
      onTap: () async {
        bool result = await acceptFriend();
        if (result) {
          await _acceptDialog(context);
          setState(() {
            visible = false;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(5)),
        child: const Icon(Icons.check),
      ),
    );
  }

  Widget rejectButton() {
    return GestureDetector(
      onTap: () async {
        bool result = await rejectFriend();
        if (result) {
          await _rejectDialog(context);
          setState(() {
            visible = false;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(5)),
        child: const Icon(Icons.close_outlined),
      ),
    );
  }

  Widget checkButton() {
    return GestureDetector(
      onTap: () async {
        bool result = await checkFriend();
        if (result) {
          setState(() {
            visible = false;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(5)),
        child: const Icon(Icons.check),
      ),
    );
  }

  Widget acceptFriendGameButton() {
    return GestureDetector(
      onTap: ()  async {
        bool result = await acceptFriendGame();
        if (result) {
          setState(() {
            visible = false;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(5)),
        child: const Icon(Icons.check),
      ),
    );
  }

  Widget rejectFriendGameButton() {
    return GestureDetector(
      onTap: () async{
        bool result = await rejectFriendGame();
        if(result){
          setState(() {
            visible = false;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(5)),
        child: const Icon(Icons.close_outlined),
      ),
    );
  }

  @override
  void initState() {
    setState(() {
      messageText = widget.message.friendStatus == "REQUESTCHECK" ?
      "${widget.message.toNickname}님이 친구를 신청했습니다. 수락하시겠습니까?" :
      "${widget.message.toNickname}님이 친구 신청을 수락했습니다.";
    });
    super.initState();
  }

  Future<bool> acceptFriend() async {
    Map<String, String> list = await readToken();
    Uri uri = Uri.parse("$baseUrl/friend/accept");
    final response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${list["Authorization"]!}',
          'refreshToken': 'Bearer ${list['refreshToken']!}'
        },
        body: jsonEncode(
            {"toMember": widget.message.toMember}));
    if (response.statusCode == 200) {
      // firebase AT 받아서 알람 보내기
      final firebaseAccessToken = response.headers["firebase"]!.substring(7);

      print("firebase AT $firebaseAccessToken");

      // 내 닉네임
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final myNickname = prefs.getString('nickname');

      // 상대가 fcm token이 있을 경우에만 보내기
      if (widget.message.fcmToken != null) {

        final response2 = await http.post(Uri.parse("https://fcm.googleapis.com/v1/projects/${dotenv.env["PROJECT_ID"]}/messages:send"),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': "Bearer $firebaseAccessToken"
            },
            body: jsonEncode(
                {
                  "message": {
                    "data": {
                      "do": "friend-accept",
                      "nickname": "$myNickname"
                    },
                    "token": widget.message.fcmToken
                  }

                }
            )
        );
        print(response2.statusCode);
      }
      return true;
    }
    return false;
  }

  Future<void> _acceptDialog(BuildContext context) async {
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
              '${widget.message.toNickname}님과 친구가 되었습니다.',
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
                      Navigator.of(context).pop(true);
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

  Future<bool> rejectFriend() async {
    Map<String, String> list = await readToken();
    Uri uri = Uri.parse("$baseUrl/friend/reject");
    final response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${list["Authorization"]!}',
          'refreshToken': 'Bearer ${list['refreshToken']!}'
        },
        body: jsonEncode(
            {"toMember": widget.message.toMember}));
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<void> _rejectDialog(BuildContext context) async {
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
              '${widget.message.toNickname}님의 친구 신청을 거절했습니다.',
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
                      Navigator.of(context).pop(true);
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

  Future<bool> checkFriend() async {
    Map<String, String> list = await readToken();
    Uri uri = Uri.parse("$baseUrl/friend/check");
    final response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${list["Authorization"]!}',
          'refreshToken': 'Bearer ${list['refreshToken']!}'
        },
        body: jsonEncode(
            {"toMember": widget.message.toMember}));
    if (response.statusCode == 200) {
      // firebase AT 받아서 알람 보내기
      return true;
    }
    return false;
  }

  Future<bool> acceptFriendGame() async {
    Map<String, String> list = await readToken();
    Uri uri = Uri.parse("$baseUrl/friend-game/accept");
    String? nickname = await getNickname();
    final response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${list["Authorization"]!}',
          'refreshToken': 'Bearer ${list['refreshToken']!}'
        },
    );

    if(response.statusCode == 200){
      final Map<String, dynamic> data = json.decode(response.body);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FriendGameScreen(
              roomId: data["roomId"],
              nickname: nickname!,
              nowNumber: -1
          ), // 이건 game.dart에 있다.
        ),
      );
      return true;
    }
    return false;
  }

  Future<bool> rejectFriendGame() async {
    Map<String, String> list = await readToken();
    Uri uri = Uri.parse("$baseUrl/friend-game/reject");
    final response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${list["Authorization"]!}',
          'refreshToken': 'Bearer ${list['refreshToken']!}'
        },
        // body: jsonEncode(
        //     {"roomId": widget.message.roomId}
        // )
    );
    if(response.statusCode == 200) return true;
    return false;

  }

  Future<String?> getNickname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('nickname');
  }

  @override
  Widget build(BuildContext context) {
    return visible
        ? Card(
            color: const Color.fromRGBO(0, 0, 0, 0.5),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      messageText,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      overflow: TextOverflow.clip,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  widget.message.friendStatus == "REQUESTCHECK" ? acceptButton() : Container(),
                  widget.message.friendStatus == "REQUESTCHECK" ? const SizedBox(
                    width: 5,
                  ) : Container(),
                  widget.message.friendStatus == "REQUESTCHECK" ? rejectButton() : Container(),
                  widget.message.friendStatus != "REQUESTCHECK" ? checkButton() : Container(),
                ],
              ),
            ),
          )
        : Container();
  }
}
