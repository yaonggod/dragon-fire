import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/friend_models/message_model.dart';
import 'package:http/http.dart' as http;

class MessageWidget extends StatefulWidget {
  final MessageModel message;

  const MessageWidget({super.key, required this.message});

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  bool visible = true;

  // String baseUrl = "http://10.0.2.2:8080";
  String baseUrl = "https://k9a209.p.ssafy.io/api";

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
      return true;
    }
    return false;
  }

  Future<void> _acceptDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '${widget.message.toNickname}님과 친구가 되었습니다.',
            style: const TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('닫기'),
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
          title: Text(
            '${widget.message.toNickname}님의 친구 신청을 거절했습니다.',
            style: const TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('닫기'),
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
      return true;
    }
    return false;
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
