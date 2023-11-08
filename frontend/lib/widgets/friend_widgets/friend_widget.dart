import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:frontend/models/friend_models/friend_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FriendWidget extends StatefulWidget {
  final FriendModel friend;

  const FriendWidget({super.key, required this.friend});

  @override
  State<FriendWidget> createState() => _FriendWidgetState();
}

class _FriendWidgetState extends State<FriendWidget> {
  bool visible = true;
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

  Future<bool> _deleteResultDialog(BuildContext context, bool result) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('친구 삭제'),
          content: Text(
            result ? '${widget.friend.toNickname}님을 삭제했습니다.' : '친구 삭제에 실패했습니다.',
            style: const TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('닫기'),
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

  @override
  Widget build(BuildContext context) {
    return !visible
        ? Container()
        : Slidable(
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.15,
              closeThreshold: 0.01,
              openThreshold: 0.001,
              children: [
                SlidableAction(
                  borderRadius: BorderRadius.circular(10.0),
                  padding: const EdgeInsets.only(right: 10),
                  icon: Icons.delete,
                  onPressed: (context) async {
                      bool result = await deleteFriend();
                      if (result) {
                        setState(() {
                          visible = false;
                        });
                      }
                      _deleteResultDialog(context, result);
                    },)
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
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '지존 ${widget.friend.score}점',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              '상대 전적 ${widget.friend.friendWin}승 ${widget.friend.friendLose}패',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('알림'),
                              content: Text('친구 대전은 아직 준비중입니다.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('확인'),
                                ),
                              ],
                            );
                          },
                        );

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
